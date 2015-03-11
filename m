From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:01:58 +0000 (UTC)
Subject: master - tests: cleanup some cxx warnings
Message-ID: <20150311100158.1ABDD60DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cecf61cc3aa9983f82ed571021149ee4ed83e5b
Commit:        6cecf61cc3aa9983f82ed571021149ee4ed83e5b
Parent:        3f7e62b340045888b974fd0082d034db6c5af902
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 11:00:55 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: cleanup some cxx warnings

---
 test/lib/brick-shelltest.h |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 3c88a85..820aa81 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -353,7 +353,7 @@ struct Substitute {
         else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
             _map[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
         else {
-            int off;
+            size_t off;
             for ( Map::iterator s = _map.begin(); s != _map.end(); ++s )
                 while ( (off = line.find( s->first )) != std::string::npos )
                     line.replace( off, s->first.length(), s->second );
@@ -370,7 +370,7 @@ struct Format {
     std::string format( TimedBuffer::Line l ) {
         std::stringstream result;
         if ( stamp ) {
-            int rel = l.first - start;
+            time_t rel = l.first - start;
             result << "[" << std::setw( 2 ) << std::setfill( ' ' ) << rel / 60
                    << ":" << std::setw( 2 ) << std::setfill( '0' ) << rel % 60 << "] ";
         }
@@ -477,7 +477,7 @@ struct Source {
             return -1;
     }
 
-    Source( int fd = -1 ) : fd( fd ) {}
+    Source( int _fd = -1 ) : fd( _fd ) {}
     virtual ~Source() {
         if ( fd >= 0 )
             ::close( fd );
@@ -531,7 +531,7 @@ struct KMsg : Source {
 
     void sync( Sink *s ) {
 #ifdef __unix
-        int sz;
+        ssize_t sz;
         char buf[ 128 * 1024 ];
 
         if ( dev_kmsg() ) {
@@ -813,7 +813,8 @@ struct TestCase {
     std::string tag( std::string n ) {
         if ( options.batch )
             return "## ";
-        int pad = (12 - n.length());
+        size_t pad = n.length();
+        pad = (pad < 12) ? 12 - pad : 0;
         return "### " + std::string( pad, ' ' ) + n + ": ";
     }
 
@@ -932,8 +933,8 @@ struct TestCase {
             io.sources.push_back( new KMsg );
     }
 
-    TestCase( Journal &j, Options opt, std::string path, std::string name, std::string flavour )
-        : child( path ), name( name ), flavour( flavour ), timeout( false ),
+    TestCase( Journal &j, Options opt, std::string path, std::string _name, std::string _flavour )
+        : child( path ), name( _name ), flavour( _flavour ), timeout( false ),
           last_update( 0 ), last_heartbeat( 0 ), options( opt ), journal( &j )
     {
     }
@@ -1087,7 +1088,7 @@ void split( std::string s, C &c ) {
 
 }
 
-int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
+static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
 {
     Args args( argc, argv );
     Options opt;


