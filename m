From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 17 Jul 2015 18:38:15 +0000 (UTC)
Subject: master - test: Help, default and relative paths in runner
Message-ID: <20150717183815.8290A613AC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b785a50da415cd8ee48e971f720640457514032d
Commit:        b785a50da415cd8ee48e971f720640457514032d
Parent:        2bc0525e939ea38c74a814bd51683955599824a3
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jul 15 14:20:37 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jul 17 20:36:50 2015 +0200

test: Help, default and relative paths in runner

Add help message.
Handle relative paths first.
Use `.` for OUTDIR instead of `/` if empty.
---
 test/lib/brick-shelltest.h |  138 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 114 insertions(+), 24 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 21e1eec..b29e626 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -79,6 +79,8 @@
 #include <unistd.h>
 #endif
 
+#include "configure.h"
+
 #ifndef BRICK_SHELLTEST_H
 #define BRICK_SHELLTEST_H
 
@@ -1088,6 +1090,7 @@ struct Args {
         return std::find( args.begin(), args.end(), fl ) != args.end();
     }
 
+    // TODO: This does not handle `--option=VALUE`:
     std::string opt( std::string fl ) {
         V::iterator i = std::find( args.begin(), args.end(), fl );
         if ( i == args.end() || i + 1 == args.end() )
@@ -1117,11 +1120,88 @@ void split( std::string s, C &c ) {
 
 }
 
+const char *DEF_FLAVOURS="ndev-vanilla";
+
+std::string resolve_path(std::string a_path, const char *default_path=".")
+{
+    char temp[PATH_MAX];
+    const char *p;
+    p = a_path.empty() ? default_path : a_path.c_str();
+    if ( !realpath( p, temp ) )
+        throw syserr( "Failed to resolve path", p );
+    return temp;
+}
+
 static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
 {
     Args args( argc, argv );
     Options opt;
 
+    if ( args.has( "--help" ) ) {
+        std::cout <<
+            "  lvm2-testsuite - Run a lvm2 testsuite.\n\n"
+            "lvm2-testsuite"
+            "\n\t"
+            " [--flavours FLAVOURS]"
+            " [--only TESTS]"
+            "\n\t"
+            " [--outdir OUTDIR]"
+            " [--testdir TESTDIR]"
+            " [--workdir WORKDIR]"
+            "\n\t"
+            " [--batch|--verbose|--interactive]"
+            "\n\t"
+            " [--fatal-timeouts]"
+            " [--continue]"
+            " [--heartbeat]"
+            " [--watch WATCH]"
+            " [--timeout TIMEOUT]"
+            " [--nokmsg]\n\n"
+            /* TODO: list of flavours:
+            "lvm2-testsuite"
+            "\n\t"
+            " --list-flavours [--testdir TESTDIR]"
+            */
+            "\n\n"
+            "OPTIONS:\n\n"
+            // TODO: looks like this could be worth a man page...
+            "Filters:\n"
+            "  --flavours FLAVOURS\n\t\t- comma separated list of flavours to run.\n\t\t  For the list of flavours see `$TESTDIR/lib/flavour-*`.\n\t\t  Default: \"" << DEF_FLAVOURS << "\".\n"
+            "  --only TESTS\t- comma separated list of tests to run. Default: All tests.\n"
+            "\n"
+            "Directories:\n"
+            "  --testdir TESTDIR\n\t\t- directory where tests reside. Default: \"" TESTSUITE_DATA "\".\n"
+            "  --workdir WORKDIR\n\t\t- directory to change to when running tests.\n\t\t  This is directory containing testing libs. Default: TESTDIR.\n"
+            "  --outdir OUTDIR\n\t\t- directory where all the output files should go. Default: \".\".\n"
+            "\n"
+            "Formatting:\n"
+            "  --batch\t- Brief format for automated runs.\n"
+            "  --verbose\t- More verbose format for automated runs displaying progress on stdout.\n"
+            "  --interactive\t- Verbose format for interactive runs.\n"
+            "\n"
+            "Other:\n"
+            "  --fatal-timeouts\n\t\t- exit after encountering 2 timeouts in a row.\n"
+            "  --continue\t- If set append to journal. Otherwise it will be overwritten.\n"
+            "  --heartbeat HEARTBEAT\n\t\t- Name of file to update periodicaly while running.\n"
+            "  --watch WATCH\t- Comma separated list of files to watch and print.\n"
+            "  --timeout TIMEOUT\n\t\t- Period of silence in seconds considered a timeout. Default: 180.\n"
+            "  --nokmsg\t- Do not try to read kernel messages.\n"
+            "\n\n"
+            "ENV.VARIABLES:\n\n"
+            "  T\t\t- see --only\n"
+            "  INTERACTIVE\t- see --interactive\n"
+            "  VERBOSE\t- see --verbose\n"
+            "  BATCH\t\t- see --batch\n"
+            "  LVM_TEST_CAN_CLOBBER_DMESG\n\t\t- when set and non-empty tests are allowed to flush\n\t\t  kmsg in an attempt to read it."
+            "\n\n"
+            "FORMATS:\n\n"
+            "When multiple formats are specified interactive overrides verbose\n"
+            "which overrides batch. Command line options override environment\n"
+            "variables.\n\n"
+            ;
+        return 0;
+    }
+
     opt.flavour_envvar = fl_envvar;
 
     if ( args.has( "--continue" ) )
@@ -1138,26 +1218,44 @@ static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVO
     if ( args.has( "--heartbeat" ) )
         opt.heartbeat = args.opt( "--heartbeat" );
 
-    if ( args.has( "--batch" ) || hasenv( "BATCH" ) ) {
-        opt.verbose = false;
-        opt.batch = true;
-    }
+    if ( args.has( "--batch" ) || args.has( "--verbose" ) || args.has( "--interactive" ) ) {
+        if ( args.has( "--batch" ) ) {
+            opt.verbose = false;
+            opt.batch = true;
+        }
 
-    if ( args.has( "--verbose" ) || hasenv( "VERBOSE" ) ) {
-        opt.batch = false;
-        opt.verbose = true;
-    }
+        if ( args.has( "--verbose" ) ) {
+            opt.batch = false;
+            opt.verbose = true;
+        }
+
+        if ( args.has( "--interactive" ) ) {
+            opt.verbose = false;
+            opt.batch = false;
+            opt.interactive = true;
+        }
+    } else {
+        if ( hasenv( "BATCH" ) ) {
+            opt.verbose = false;
+            opt.batch = true;
+        }
+
+        if ( hasenv( "VERBOSE" ) ) {
+            opt.batch = false;
+            opt.verbose = true;
+        }
 
-    if ( args.has( "--interactive" ) || hasenv( "INTERACTIVE" ) ) {
-        opt.verbose = false;
-        opt.batch = false;
-        opt.interactive = true;
+        if ( hasenv( "INTERACTIVE" ) ) {
+            opt.verbose = false;
+            opt.batch = false;
+            opt.interactive = true;
+        }
     }
 
     if ( args.has( "--flavours" ) )
         split( args.opt( "--flavours" ), opt.flavours );
     else
-        opt.flavours.push_back( "vanilla" );
+        split( DEF_FLAVOURS, opt.flavours );
 
     if ( args.has( "--watch" ) )
         split( args.opt( "--watch" ), opt.watch );
@@ -1168,17 +1266,9 @@ static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVO
     if ( args.has( "--nokmsg" ) )
         opt.kmsg = false;
 
-    opt.outdir = args.opt( "--outdir" );
-    opt.testdir = args.opt( "--testdir" );
-    opt.workdir = args.opt( "--workdir" );
-
-    if ( opt.testdir.empty() )
-        opt.testdir = TESTSUITE_DATA;
-
-    if ( opt.workdir.empty() )
-        opt.workdir = opt.testdir;
-
-    opt.testdir += "/";
+    opt.testdir = resolve_path( args.opt( "--testdir" ), TESTSUITE_DATA ) + "/";
+    opt.workdir = resolve_path( args.opt( "--workdir" ), opt.testdir.c_str() );
+    opt.outdir = resolve_path( args.opt( "--outdir" ), "." );
 
     setup_handlers();
 


