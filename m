From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 11:21:21 +0000 (UTC)
Subject: master - tests: add missing --skip option and S env.variable
Message-ID: <20151119112121.65D3C60CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a23550cf3f3ecf6f3daec211e2304444170daf3
Commit:        2a23550cf3f3ecf6f3daec211e2304444170daf3
Parent:        0614c63579b9ab6ebf68b957b4de3806f231a14c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 19 10:48:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 12:00:59 2015 +0100

tests: add missing --skip option and S env.variable

---
 test/lib/brick-shelltest.h |   40 ++++++++++++++++++++++++++++++++--------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index cc7135f..be7c3fe 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -675,7 +675,7 @@ bool interrupt = false;
 struct Options {
     bool verbose, batch, interactive, cont, fatal_timeouts, kmsg;
     std::string testdir, outdir, workdir, heartbeat;
-    std::vector< std::string > flavours, filter, watch;
+    std::vector< std::string > flavours, filter, skip, watch;
     std::string flavour_envvar;
     int timeout;
     Options() : verbose( false ), batch( false ), interactive( false ),
@@ -986,6 +986,7 @@ struct Main {
     Cases cases;
 
     void setup() {
+        bool filter;
         Listing l = listdir( options.testdir, true );
         std::sort( l.begin(), l.end() );
 
@@ -997,15 +998,33 @@ struct Main {
                     continue;
                 if ( i->substr( 0, 4 ) == "lib/" )
                     continue;
-                bool filter = !options.filter.empty();
 
-                for ( std::vector< std::string >::iterator filt = options.filter.begin();
-                      filt != options.filter.end(); ++filt ) {
-                    if ( i->find( *filt ) != std::string::npos )
-                        filter = false;
+                if (!options.filter.empty()) {
+                    filter = true;
+                    for ( std::vector< std::string >::iterator filt = options.filter.begin();
+                          filt != options.filter.end(); ++filt ) {
+                        if ( i->find( *filt ) != std::string::npos ) {
+                            filter = false;
+                            break;
+                        }
+                    }
+                    if ( filter )
+                        continue;
                 }
-                if ( filter )
-                    continue;
+
+                if (!options.skip.empty()) {
+                    filter = false;
+                    for ( std::vector< std::string >::iterator filt = options.skip.begin();
+                          filt != options.skip.end(); ++filt ) {
+                        if ( i->find( *filt ) != std::string::npos ) {
+                            filter = true;
+                            break;
+                        }
+                    }
+                    if ( filter )
+                        continue;
+                }
+
                 cases.push_back( TestCase( journal, options, options.testdir + *i, *i, *flav ) );
                 cases.back().options = options;
             }
@@ -1215,6 +1234,11 @@ static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVO
     else if ( hasenv( "T" ) )
         split( getenv( "T" ), opt.filter );
 
+    if ( args.has( "--skip" ) )
+        split( args.opt( "--skip" ), opt.skip );
+    else if ( hasenv( "S" ) )
+        split( getenv( "S" ), opt.skip );
+
     if ( args.has( "--fatal-timeouts" ) )
         opt.fatal_timeouts = true;
 


