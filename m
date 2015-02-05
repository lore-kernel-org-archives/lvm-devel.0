From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:51 +0000 (UTC)
Subject: master - test: Update brick-shelltest (configurable timeout, better banner, exit code).
Message-ID: <20150205134251.D3218601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c82c69bb5618721ac82286623f9deb019e216ca5
Commit:        c82c69bb5618721ac82286623f9deb019e216ca5
Parent:        b6884f8a87ee442b88d7c4b5dfb7af4a10c26670
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 11:15:51 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Update brick-shelltest (configurable timeout, better banner, exit code).

---
 test/lib/brick-shelltest.h |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 9b0afe0..7c6a021 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -64,8 +64,9 @@
 #include <algorithm>
 #include <stdexcept>
 
-#ifdef __unix
 #include <dirent.h>
+
+#ifdef __unix
 #include <sys/stat.h>
 #include <sys/resource.h> /* rusage */
 #include <sys/select.h>
@@ -262,7 +263,10 @@ struct Journal {
 
     void banner() {
         std::cout << std::endl << "### " << status.size() << " tests: "
-                  << count( PASSED ) << " passed" << std::endl;
+                  << count( PASSED ) << " passed, "
+                  << count( SKIPPED ) << " skipped, "
+                  << count( TIMEOUT ) + count( WARNED ) << " broken, "
+                  << count( FAILED ) << " failed" << std::endl;
     }
 
     void details() {
@@ -442,7 +446,6 @@ struct FileSink : FdSink {
     }
 };
 
-#define BRICK_SYSLOG_ACTION_READ           2
 #define BRICK_SYSLOG_ACTION_READ_CLEAR     4
 #define BRICK_SYSLOG_ACTION_CLEAR          5
 
@@ -619,8 +622,10 @@ struct Options {
     std::string testdir, outdir, workdir, heartbeat;
     std::vector< std::string > flavours, filter, watch;
     std::string flavour_envvar;
+    int timeout;
     Options() : verbose( false ), batch( false ), interactive( false ),
-                cont( false ), fatal_timeouts( false ), kmsg( false ) {}
+                cont( false ), fatal_timeouts( false ), kmsg( false ),
+                timeout( 60 ) {}
 };
 
 struct TestProcess
@@ -718,7 +723,7 @@ struct TestCase {
 
         /* kill off tests after a minute of silence */
         if ( !options.interactive )
-            if ( end - silent_start > 60 ) {
+            if ( end - silent_start > options.timeout ) {
                 kill( pid, SIGINT );
                 sleep( 5 ); /* wait a bit for a reaction */
                 if ( waitpid( pid, &status, WNOHANG ) == 0 ) {
@@ -982,7 +987,7 @@ struct Main {
         if ( die || fatal_signal )
             return 1;
 
-        return 0;
+        return journal.count( Journal::FAILED ) ? 1 : 0;
     }
 
     Main( Options o ) : die( false ), journal( o.outdir ), options( o ) {}
@@ -1099,6 +1104,9 @@ int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
     if ( args.has( "--watch" ) )
         split( args.opt( "--watch" ), opt.watch );
 
+    if ( args.has( "--timeout" ) )
+        opt.timeout = atoi( args.opt( "--timeout" ).c_str() );
+
     if ( args.has( "--kmsg" ) )
         opt.kmsg = true;
 
@@ -1128,7 +1136,7 @@ int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
 #ifdef BRICK_DEMO
 
 int main( int argc, const char **argv ) {
-    brick::shelltest::run( argc, argv );
+    return brick::shelltest::run( argc, argv );
 }
 
 #endif


