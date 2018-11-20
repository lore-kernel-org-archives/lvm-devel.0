From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Nov 2018 10:05:44 -0500
Subject: 2018-06-01-stable - io: use sync io if aio fails
Message-ID: <201811201505.wAKF5iQI032758@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8ce9bf3bc38df8f89021517d7967d94ace129df
Commit:        f8ce9bf3bc38df8f89021517d7967d94ace129df
Parent:        9fda169077d09e4136d9af14990fb5bee045f196
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 16 12:21:20 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 20 09:00:26 2018 -0600

io: use sync io if aio fails

io_setup() for aio may fail if a system has reached the
aio request limit.  In this case, fall back to using
sync io.  Also, lvm use of aio can be disabled entirely
with config setting global/use_aio=0.

The system limit for aio requests can be seen from
  /proc/sys/fs/aio-max-nr

The current usage of aio requests can be seen from
  /proc/sys/fs/aio-nr

The system limit for aio requests can be increased by
setting fs.aio-max-nr using sysctl.

Also add last-byte limit to the sync io code.
---
 lib/commands/toolcontext.c   |    2 ++
 lib/config/config_settings.h |    3 +++
 lib/config/defaults.h        |    1 +
 lib/device/bcache.c          |   42 ++++++++++++++++++++++++++++++++++++++++++
 lib/label/label.c            |   17 +++++++++++++----
 lib/misc/lvm-globals.c       |   11 +++++++++++
 lib/misc/lvm-globals.h       |    2 ++
 7 files changed, 74 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c9596e2..ecd8fd7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -333,6 +333,8 @@ static void _init_logging(struct cmd_context *cmd)
 	    find_config_tree_bool(cmd, global_test_CFG, NULL);
 	init_test(cmd->default_settings.test);
 
+	init_use_aio(find_config_tree_bool(cmd, global_use_aio_CFG, NULL));
+
 	/* Settings for logging to file */
 	if (find_config_tree_bool(cmd, log_overwrite_CFG, NULL))
 		append = 0;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f49709c..3433d0c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -935,6 +935,9 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
 	"was never a valid path in the /dev filesystem.\n")
 
+cfg(global_use_aio_CFG, "use_aio", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 183), NULL, 0, NULL,
+	"Use async I/O when reading and writing devices.\n")
+
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), "@DEFAULT_USE_LVMETAD@", 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
 	"When enabled (and running), lvmetad provides LVM commands with VG\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 7cebd84..fc2f603 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -59,6 +59,7 @@
 #define DEFAULT_METADATA_READ_ONLY 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 #define DEFAULT_UNKNOWN_DEVICE_NAME "[unknown]"
+#define DEFAULT_USE_AIO 1
 
 #define DEFAULT_SANLOCK_LV_EXTEND_MB 256
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 6235256..571ee7a 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -388,6 +388,48 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
         	return false;
 	}
 
+	/*
+	 * If bcache block goes past where lvm wants to write, then clamp it.
+	 */
+	if ((d == DIR_WRITE) && _last_byte_offset && (fd == _last_byte_fd)) {
+		uint64_t offset = where;
+		uint64_t nbytes = len;
+		sector_t limit_nbytes = 0;
+		sector_t extra_nbytes = 0;
+
+		if (offset > _last_byte_offset) {
+			log_error("Limit write at %llu len %llu beyond last byte %llu",
+				  (unsigned long long)offset,
+				  (unsigned long long)nbytes,
+				  (unsigned long long)_last_byte_offset);
+			return false;
+		}
+
+		if (offset + nbytes > _last_byte_offset) {
+			limit_nbytes = _last_byte_offset - offset;
+			if (limit_nbytes % _last_byte_sector_size)
+				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
+
+			if (extra_nbytes) {
+				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes,
+					  (unsigned long long)(limit_nbytes + extra_nbytes));
+				nbytes = limit_nbytes + extra_nbytes;
+			} else {
+				log_debug("Limit write at %llu len %llu to len %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes);
+				nbytes = limit_nbytes;
+			}
+		}
+
+		where = offset;
+		len = nbytes;
+	}
+
 	while (len) {
         	do {
                 	if (d == DIR_READ)
diff --git a/lib/label/label.c b/lib/label/label.c
index 5377847..b26ff33 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -798,7 +798,7 @@ out:
 
 static int _setup_bcache(int cache_blocks)
 {
-	struct io_engine *ioe;
+	struct io_engine *ioe = NULL;
 
 	if (cache_blocks < MIN_BCACHE_BLOCKS)
 		cache_blocks = MIN_BCACHE_BLOCKS;
@@ -806,9 +806,18 @@ static int _setup_bcache(int cache_blocks)
 	if (cache_blocks > MAX_BCACHE_BLOCKS)
 		cache_blocks = MAX_BCACHE_BLOCKS;
 
-	if (!(ioe = create_async_io_engine())) {
-		log_error("Failed to create bcache io engine.");
-		return 0;
+	if (use_aio()) {
+		if (!(ioe = create_async_io_engine())) {
+			log_warn("Failed to set up async io, using sync io.");
+			init_use_aio(0);
+		}
+	}
+
+	if (!ioe) {
+		if (!(ioe = create_sync_io_engine())) {
+			log_error("Failed to set up sync io.");
+			return 0;
+		}
 	}
 
 	if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe))) {
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9941489..82c5706 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -24,6 +24,7 @@
 static int _verbose_level = VERBOSE_BASE_LEVEL;
 static int _silent = 0;
 static int _test = 0;
+static int _use_aio = 0;
 static int _md_filtering = 0;
 static int _internal_filtering = 0;
 static int _fwraid_filtering = 0;
@@ -71,6 +72,11 @@ void init_test(int level)
 	_test = level;
 }
 
+void init_use_aio(int use_aio)
+{
+	_use_aio = use_aio;
+}
+
 void init_md_filtering(int level)
 {
 	_md_filtering = level;
@@ -227,6 +233,11 @@ int test_mode(void)
 	return _test;
 }
 
+int use_aio(void)
+{
+	return _use_aio;
+}
+
 int md_filtering(void)
 {
 	return _md_filtering;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index b383891..f985cfa 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -25,6 +25,7 @@ enum dev_ext_e;
 void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
+void init_use_aio(int use_aio);
 void init_md_filtering(int level);
 void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);
@@ -58,6 +59,7 @@ const char *get_cmd_name(void);
 void set_sysfs_dir_path(const char *path);
 
 int test_mode(void);
+int use_aio(void);
 int md_filtering(void);
 int internal_filtering(void);
 int fwraid_filtering(void);


