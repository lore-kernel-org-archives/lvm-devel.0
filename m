From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:16 +0000 (GMT)
Subject: main - cov: ignore syscall
Message-ID: <20210920133016.9F42C3858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efaab93491751ccf39108d076745c6774b263232
Commit:        efaab93491751ccf39108d076745c6774b263232
Parent:        055406bb398ddf60f18c545baffcec4ee4d5646e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 01:45:55 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: ignore syscall

---
 daemons/lvmlockd/lvmlockd-core.c   |  6 +++---
 lib/device/bcache.c                |  2 +-
 test/lib/brick-shelltest.h         | 36 ++++++++++++++++++------------------
 test/lib/not.c                     |  2 +-
 test/unit/activation-generator_t.c |  4 ++--
 test/unit/percent_t.c              | 26 +++++++++++++-------------
 6 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 701372220..c1785a764 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -919,7 +919,7 @@ static void write_adopt_file(void)
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	fflush(fp);
-	fclose(fp);
+	(void) fclose(fp);
 }
 
 static int read_adopt_file(struct list_head *vg_lockd)
@@ -1010,11 +1010,11 @@ static int read_adopt_file(struct list_head *vg_lockd)
 		}
 	}
 
-	fclose(fp);
+	(void) fclose(fp);
 	return 0;
 
 fail:
-	fclose(fp);
+	(void) fclose(fp);
 	return -1;
 }
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index be25cc7e2..790ff71d3 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -734,7 +734,7 @@ static void _block_remove(struct block *b)
         k.parts.di = b->di;
         k.parts.b = b->index;
 
-	radix_tree_remove(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes));
+	(void) radix_tree_remove(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes));
 }
 
 //----------------------------------------------------------------
diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 6bc02e0d2..517c0f7d9 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -102,7 +102,7 @@ struct dir {
         if ( !d )
             throw syserr( "error opening directory", p );
     }
-    ~dir() { closedir( d ); }
+    ~dir() { (void) closedir( d ); }
 };
 
 typedef std::vector< std::string > Listing;
@@ -111,8 +111,8 @@ inline void fsync_name( std::string n )
 {
     int fd = open( n.c_str(), O_WRONLY );
     if ( fd >= 0 ) {
-        fsync( fd );
-        close( fd );
+        (void) fsync( fd );
+        (void) close( fd );
     }
 }
 
@@ -464,8 +464,8 @@ struct FileSink : FdSink {
 
     ~FileSink() {
         if ( fd >= 0 ) {
-            fsync( fd );
-            close( fd );
+            (void) fsync( fd );
+            (void) close( fd );
         }
     }
 };
@@ -515,7 +515,7 @@ struct Source {
     Source( int _fd = -1 ) : fd( _fd ) {}
     virtual ~Source() {
         if ( fd >= 0 )
-            ::close( fd );
+            (void) ::close( fd );
     }
 };
 
@@ -570,7 +570,7 @@ struct KMsg : Source {
                 can_clear = false;
         } else if ( lseek( fd, 0L, SEEK_END ) == (off_t) -1 ) {
             fprintf( stderr, "lseek log %s %s\n", read_msg, strerror( errno ) );
-            close(fd);
+            (void) close(fd);
             fd = -1;
         }
 #endif
@@ -712,13 +712,13 @@ struct TestProcess
         if ( !interactive ) {
             int devnull = ::open( "/dev/null", O_RDONLY );
             if ( devnull >= 0 ) { /* gcc really doesn't like to not have stdin */
-                dup2( devnull, STDIN_FILENO );
-                close( devnull );
+                (void) dup2( devnull, STDIN_FILENO );
+                (void) close( devnull );
             } else
-                close( STDIN_FILENO );
-            dup2( fd, STDOUT_FILENO );
-            dup2( fd, STDERR_FILENO );
-            close( fd );
+                (void) close( STDIN_FILENO );
+            (void) dup2( fd, STDOUT_FILENO );
+            (void) dup2( fd, STDERR_FILENO );
+            (void) close( fd );
         }
 
         setpgid( 0, 0 );
@@ -804,7 +804,7 @@ struct TestCase {
                 if ( waitpid( pid, &status, WNOHANG ) == 0 ) {
                     system( "echo t > /proc/sysrq-trigger 2> /dev/null" );
                     kill( -pid, SIGKILL );
-                    waitpid( pid, &status, 0 );
+                    (void) waitpid( pid, &status, 0 );
                 }
                 timeout = true;
                 io.sync( true );
@@ -897,7 +897,7 @@ struct TestCase {
 
     void parent()
     {
-        ::close( child.fd );
+        (void) ::close( child.fd );
         setupIO();
 
         journal->started( id() );
@@ -957,9 +957,9 @@ struct TestCase {
             exit(201);
         } else if (pid == 0) {
             io.close();
-            chdir( options.workdir.c_str() );
+            (void) chdir( options.workdir.c_str() );
             if ( !options.flavour_envvar.empty() )
-                setenv( options.flavour_envvar.c_str(), flavour.c_str(), 1 );
+                (void) setenv( options.flavour_envvar.c_str(), flavour.c_str(), 1 );
             child.exec();
         } else {
             parent();
@@ -1053,7 +1053,7 @@ struct Main {
         if ( options.cont )
             journal.read();
         else
-            ::unlink( journal.location.c_str() );
+            (void) ::unlink( journal.location.c_str() );
     }
 
     int run() {
diff --git a/test/lib/not.c b/test/lib/not.c
index 0cff13062..0245c3475 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -80,7 +80,7 @@ int main(int args, char **argv) {
 			val = "5";
 
 		if (val)
-			setenv("LVM_EXPECTED_EXIT_STATUS", val, 1);
+			(void) setenv("LVM_EXPECTED_EXIT_STATUS", val, 1);
 
 		execvp(argv[1], &argv[1]);
 		/* should not be accessible */
diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index 7a2aa337b..f1e2aeda4 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -185,7 +185,7 @@ static const char *_fake_lvmconfig(const char *output)
 	fprintf(fp, "%s", output);
 	fprintf(fp, "EOF\n");
 
-	fclose(fp);
+	(void) fclose(fp);
 	if (chmod(path, 0770))
 		test_fail("chmod 0777 failed on path %s", path);
 
@@ -234,7 +234,7 @@ static void _test_get_config(void *fixture)
 				test_fail("_get_config() <- '%s' unexpectedly succeeded", t->output);
 		}
 
-		unlink(path);
+		(void) unlink(path);
 	}
 }
 
diff --git a/test/unit/percent_t.c b/test/unit/percent_t.c
index 9b349a97c..3575e12b3 100644
--- a/test/unit/percent_t.c
+++ b/test/unit/percent_t.c
@@ -31,25 +31,25 @@ static void test_percent_100(void *fixture)
 	T_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
 	T_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
 
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
 	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
 	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
 	T_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
 	T_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
+	(void) dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
 	T_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
+	(void) dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
 	T_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
+	(void) dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
 	T_ASSERT_EQUAL(strcmp(buf, "99"), 0);
 }
 
@@ -66,22 +66,22 @@ static void test_percent_0(void *fixture)
 	T_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
 	T_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
 
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
 	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
 	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
 	T_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
+	(void) dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
 	T_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
+	(void) dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
 	T_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
 
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
+	(void) dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
 	T_ASSERT_EQUAL(strcmp(buf, "1"), 0);
 }
 


