From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:36 +0000 (UTC)
Subject: master - tests: update runner
Message-ID: <20150413143936.905F160F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4261ba03784f122759670cc2022a2dcb5f5a3ef
Commit:        e4261ba03784f122759670cc2022a2dcb5f5a3ef
Parent:        0aef2b719f17bddfe8afeaa4d38447975c192f50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 16:31:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:32 2015 +0200

tests: update runner

Reenable TESTDIR  & PREFIX replacement.
Since we need to replace string in proper order (1st. @TESTDIR@,
2nd. @PREFIX@), drop map and use plain string.

Drop timestamp logging when 'stacktracing'
---
 test/lib/brick-shelltest.h |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 60aab20..00f1616 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -345,18 +345,23 @@ struct Sink {
 
 struct Substitute {
     typedef std::map< std::string, std::string > Map;
-    Map _map;
+    std::string testdir; // replace testdir first
+    std::string prefix;
 
     std::string map( std::string line ) {
         if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
-            _map[ "@TESTDIR@" ] = std::string( line, 9, std::string::npos );
+            testdir = std::string( line, 9, line.length() - 10 ); // skip \n
         else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
-            _map[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
+            prefix = std::string( line, 8, line.length() - 9 );  // skip \n
         else {
             size_t off;
-            for ( Map::iterator s = _map.begin(); s != _map.end(); ++s )
-                while ( (off = line.find( s->first )) != std::string::npos )
-                    line.replace( off, s->first.length(), s->second );
+            if (!testdir.empty())
+                while ( (off = line.find( testdir )) != std::string::npos )
+                    line.replace( off, testdir.length(), "@TESTDIR@" );
+
+            if (!prefix.empty())
+                while ( (off = line.find( prefix )) != std::string::npos )
+                    line.replace( off, prefix.length(), "@PREFIX@" );
         }
         return line;
     }
@@ -406,6 +411,13 @@ struct FdSink : Sink {
     virtual void outline( bool force )
     {
         TimedBuffer::Line line = stream.shift( force );
+        if (line.second.c_str()[0] == '#') {
+            /* Disable timing between  STACKTRACE & teardown keywords */
+            if (strstr(line.second.c_str() + 1, "# 0 STACKTRACE"))
+                fmt.stamp = false;
+            else if (strstr(line.second.c_str() + 1, "# teardown"))
+                fmt.stamp = true;
+        }
         std::string out = fmt.format( line );
         write( fd, out.c_str(), out.length() );
     }


