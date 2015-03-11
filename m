From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:01:56 +0000 (UTC)
Subject: master - tests: enable kmsg by default
Message-ID: <20150311100156.039F760DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f7e62b340045888b974fd0082d034db6c5af902
Commit:        3f7e62b340045888b974fd0082d034db6c5af902
Parent:        db5166fbfab2c7455fd97fd73afc6c1139b0ddc4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 10:43:28 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: enable kmsg by default

By default we want to capture kernel log into test trace
(since when test crashes it could be problem to reproduce).
---
 test/lib/brick-shelltest.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 4f0e1bf..3c88a85 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -649,7 +649,7 @@ struct Options {
     std::string flavour_envvar;
     int timeout;
     Options() : verbose( false ), batch( false ), interactive( false ),
-                cont( false ), fatal_timeouts( false ), kmsg( false ),
+                cont( false ), fatal_timeouts( false ), kmsg( true ),
                 timeout( 180 ) {}
 };
 
@@ -1135,8 +1135,8 @@ int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
     if ( args.has( "--timeout" ) )
         opt.timeout = atoi( args.opt( "--timeout" ).c_str() );
 
-    if ( args.has( "--kmsg" ) )
-        opt.kmsg = true;
+    if ( args.has( "--nokmsg" ) )
+        opt.kmsg = false;
 
     opt.outdir = args.opt( "--outdir" );
     opt.testdir = args.opt( "--testdir" );


