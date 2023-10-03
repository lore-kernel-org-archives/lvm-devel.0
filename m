From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 03 Oct 2023 19:37:13 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: filters: sysfs use device_id_sysfs_dir
Message-ID: <651c6d695f1dc_2aa55c891b0@gitlab-sidekiq-low-urgency-cpu-bound-v2-544d54bc88-qfqc5.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
cf46f4ba by Zdenek Kabelac at 2023-10-03T21:30:22+02:00
filters: sysfs use device_id_sysfs_dir

This is mainly useful in internal testing - but keep sysfs dir also
passed to filter.
Also drop use of static variable within sysfs filter and base whole
config at creation time.

- - - - -
8f61a127 by Zdenek Kabelac at 2023-10-03T21:32:12+02:00
tests: fix reader for runner

Since we now push more data into journal, parser reading this file
for --continue mode need to be adapted.
Also properly align batch mode with &#39;.&#39; for max test length name.

- - - - -


4 changed files:

- lib/commands/toolcontext.c
- lib/filters/filter-sysfs.c
- lib/filters/filter.h
- test/lib/brick-shelltest.h


Changes:

=====================================
lib/commands/toolcontext.c
=====================================
@@ -1229,7 +1229,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	 * (currently not used for devs match to device id using syfs)
 	 */
 	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG, NULL)) {
-		if ((filters[nr_filt] = sysfs_filter_create()))
+		if ((filters[nr_filt] = sysfs_filter_create(cmd->device_id_sysfs_dir ?: dm_sysfs_dir())))
 			nr_filt++;
 	}
 


=====================================
lib/filters/filter-sysfs.c
=====================================
@@ -15,19 +15,14 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
-static int _sys_dev_block_found;
-
 #ifdef __linux__
 
 static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	char path[PATH_MAX];
-	const char *sysfs_dir;
+	const char *sysfs_dir = f->private;
 	struct stat info;
 
-	if (!_sys_dev_block_found)
-		return 1;
-
 	dev->filtered_flags &= ~DEV_FILTERED_SYSFS;
 
 	/*
@@ -37,19 +32,16 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	if (dev->id && dev->id->idtype && (dev->id->idtype != DEV_ID_TYPE_DEVNAME))
 		return 1;
 
-	sysfs_dir = dm_sysfs_dir();
-	if (sysfs_dir && *sysfs_dir) {
-		if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
-				sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
-			log_debug("failed to create sysfs path");
-			return 1;
-		}
-
-		if (lstat(path, &info)) {
-			log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
-			dev->filtered_flags |= DEV_FILTERED_SYSFS;
-			return 0;
-		}
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
+			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
+		log_debug("failed to create sysfs path");
+		return 1;
+	}
+
+	if (lstat(path, &info)) {
+		log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
+		dev->filtered_flags |= DEV_FILTERED_SYSFS;
+		return 0;
 	}
 
 	return 1;
@@ -62,53 +54,51 @@ static void _destroy(struct dev_filter *f)
 	free(f);
 }
 
-static void _check_sys_dev_block(void)
+static int _check_sys_dev_block(const char *sysfs_dir)
 {
 	char path[PATH_MAX];
-	const char *sysfs_dir;
 	struct stat info;
 
-	sysfs_dir = dm_sysfs_dir();
-	if (sysfs_dir && *sysfs_dir) {
-		if (dm_snprintf(path, sizeof(path), "%sdev/block", sysfs_dir) < 0)
-			return;
-
-		if (lstat(path, &info)) {
-			log_debug("filter-sysfs disabled: /sys/dev/block not found");
-			_sys_dev_block_found = 0;
-		} else {
-			_sys_dev_block_found = 1;
-		}
+	if (dm_snprintf(path, sizeof(path), "%sdev/block", sysfs_dir) < 0)
+		return_0;
+
+	if (lstat(path, &info)) {
+		log_debug("filter-sysfs disabled: /sys/dev/block not found");
+		return 0;
 	}
+
+	return 1;
 }
 
-struct dev_filter *sysfs_filter_create(void)
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
 {
-	const char *sysfs_dir = dm_sysfs_dir();
 	struct dev_filter *f;
+	size_t len;
 
-	if (!*sysfs_dir) {
+	if (!sysfs_dir || *sysfs_dir) {
 		log_verbose("No proc filesystem found: skipping sysfs filter");
 		return NULL;
 	}
 
 	/* support old kernels that don't have this */
-	_check_sys_dev_block();
+	if (!_check_sys_dev_block(sysfs_dir))
+		return NULL;
 
-	if (!(f = zalloc(sizeof(*f))))
-		goto_bad;
+	len = strlen(sysfs_dir) + 1;
+	if (!(f = zalloc(sizeof(*f) + len)))
+		return NULL;
 
 	f->passes_filter = _accept_p;
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->name = "sysfs";
 
+	memcpy(f + 1, sysfs_dir, len);
+	f->private = (f + 1);
+
 	log_debug_devs("Sysfs filter initialised.");
 
 	return f;
-
- bad:
-	return NULL;
 }
 
 #else


=====================================
lib/filters/filter.h
=====================================
@@ -28,7 +28,7 @@ struct dev_filter *fwraid_filter_create(struct dev_types *dt);
 struct dev_filter *mpath_filter_create(struct dev_types *dt);
 struct dev_filter *partitioned_filter_create(struct dev_types *dt);
 struct dev_filter *persistent_filter_create(struct dev_types *dt, struct dev_filter *f);
-struct dev_filter *sysfs_filter_create(void);
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir);
 struct dev_filter *signature_filter_create(struct dev_types *dt);
 struct dev_filter *deviceid_filter_create(struct cmd_context *cmd);
 


=====================================
test/lib/brick-shelltest.h
=====================================
@@ -289,7 +289,7 @@ struct Journal {
             writ = written.find( i->first );
             if ( writ == written.end() || writ->second != i->second ) {
                 RUsage::const_iterator ru = rusage.find( i->first );
-                of << size_max << std::left << std::setw( (int)size_max ) << std::setfill( ' ' )
+                of << std::left << std::setw( (int)size_max ) << std::setfill( ' ' )
                    << i->first << " " << std::setw( 12 ) << i->second;
                 if (ru != rusage.end())
                     of << ru->second;
@@ -314,8 +314,8 @@ struct Journal {
         std::ofstream of( path.c_str() );
         for ( Status::const_iterator i = status.begin(); i != status.end(); ++i )
             of << i->first << " "  << i->second << std::endl;
-         of.flush();
-         of.close();
+        of.flush();
+        of.close();
     }
 
     void sync() {
@@ -375,13 +375,17 @@ struct Journal {
     void read( const std::string &n ) {
         std::ifstream ifs( n.c_str() );
         typedef std::istream_iterator< std::pair< std::string, R > > It;
-        for ( It i( ifs ); i != It(); ++i )
+        for ( std::string line; std::getline( ifs, line ); ) {
+            std::istringstream iss( line );
+            It i( iss );
             status[ i->first ] = i->second;
+        }
     }
 
     void read() { read( location ); }
 
     void check_name_size( const std::string &n ) { if ( n.size() > size_max ) size_max = n.size(); }
+    size_t name_size_max() const { return size_max; }
 
     Journal( const std::string &dir );
     ~Journal();
@@ -851,7 +855,7 @@ struct TestProcess
         _exit( 202 );
     }
 
-    TestProcess( std::string file ) :
+    TestProcess( const std::string &file ) :
         filename( file ), interactive( false ), fd( -1 )
     {
     }
@@ -948,7 +952,7 @@ struct TestCase {
         int nfds = io.fd_set_( &set );
 
         if ( !options.verbose && !options.interactive && !options.batch ) {
-            if ( last_update.elapsed().sec() >= 1 ) {
+            if ( last_update.elapsed().sec() ) {
                 progress( Update ) << tag( "running" )
                     << pretty() << " " << start.elapsed() << std::flush;
                 last_update.gettime();
@@ -1058,7 +1062,8 @@ struct TestCase {
         journal->done( id(), r, ru );
 
         if ( options.batch ) {
-            int spaces = std::max( 64 - int(pretty().length()), 0 );
+            int spaces = std::max( int(journal->name_size_max()) - int(pretty().length()), 0 );
+
             progress( Last ) << " " << std::string( spaces, '.' ) << " "
                 << std::left << std::setw( 9 ) << std::setfill( ' ' ) << r;
             if ( r != Journal::SKIPPED )



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0e8c631f5e58473d7f802ccaaf3fe61cf4dc403e...8f61a127b5350ddb639b9950c07f2862b567b791

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0e8c631f5e58473d7f802ccaaf3fe61cf4dc403e...8f61a127b5350ddb639b9950c07f2862b567b791
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231003/88a1a5f1/attachment-0001.htm>
