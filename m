From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:23 +0000 (UTC)
Subject: master - tests: move stamp handling
Message-ID: <20150415113823.F23FE60F79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e478471dd54835b88d68d6d5b372e00b311807a9
Commit:        e478471dd54835b88d68d6d5b372e00b311807a9
Parent:        5d4695569d58f42dfc95feda55e463ebcbf03ffb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 13:11:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: move stamp handling

Shift stamp handling into TimedBuffer,
so it's same everywhere.
---
 test/lib/brick-shelltest.h |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 4540a71..362ee8a 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -296,6 +296,7 @@ struct TimedBuffer {
 
     std::deque< Line > data;
     Line incomplete;
+    bool stamp;
 
     Line shift( bool force = false ) {
         Line result = std::make_pair( 0, "" );
@@ -309,7 +310,7 @@ struct TimedBuffer {
     }
 
     void push( std::string buf ) {
-        time_t now = time( 0 );
+        time_t now = stamp ? time( 0 ) : 0;
         std::string::iterator b = buf.begin(), e = buf.begin();
 
         while ( e != buf.end() )
@@ -323,6 +324,16 @@ struct TimedBuffer {
             if ( e != buf.end() ) {
                 incomplete.second += "\n";
                 data.push_back( incomplete );
+                if (incomplete.second[0] == '#') {
+                    /* Disable timing between '## 0 STACKTRACE' & '## teardown' keywords */
+                    if (incomplete.second.find("# 0 STACKTRACE", 1) != std::string::npos) {
+                        stamp = false;
+                        now = 0;
+                    } else if (incomplete.second.find("# teardown", 1) != std::string::npos) {
+                        stamp = true;
+                        now = time( 0 );
+                    }
+                }
                 incomplete = std::make_pair( now, "" );
             }
             b = (e == buf.end() ? e : e + 1);
@@ -334,6 +345,8 @@ struct TimedBuffer {
             return false;
         return data.empty();
     }
+
+    TimedBuffer() : stamp(true) {}
 };
 
 struct Sink {
@@ -369,12 +382,11 @@ struct Substitute {
 
 struct Format {
     time_t start;
-    bool stamp;
     Substitute subst;
 
     std::string format( TimedBuffer::Line l ) {
         std::stringstream result;
-        if ( stamp ) {
+        if ( l.first >= start ) {
             time_t rel = l.first - start;
             result << "[" << std::setw( 2 ) << std::setfill( ' ' ) << rel / 60
                    << ":" << std::setw( 2 ) << std::setfill( '0' ) << rel % 60 << "] ";
@@ -383,7 +395,7 @@ struct Format {
         return result.str();
     }
 
-    Format() : start( time( 0 ) ), stamp( true ) {}
+    Format() : start( time( 0 ) ) {}
 };
 
 struct BufSink : Sink {
@@ -411,13 +423,6 @@ struct FdSink : Sink {
     virtual void outline( bool force )
     {
         TimedBuffer::Line line = stream.shift( force );
-        if (line.second.c_str()[0] == '#') {
-            /* Disable timing between  STACKTRACE & teardown keywords */
-            if (strstr(line.second.c_str() + 1, "# 0 STACKTRACE"))
-                fmt.stamp = false;
-            else if (strstr(line.second.c_str() + 1, "# teardown"))
-                fmt.stamp = true;
-        }
         std::string out = fmt.format( line );
         write( fd, out.c_str(), out.length() );
     }


