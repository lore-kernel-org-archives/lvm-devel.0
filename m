From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:38 +0000 (UTC)
Subject: master - test: Properly detect warnings from testcases.
Message-ID: <20150205134338.3EE4060EAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8983d4bd4c76381c8bd9149c942b83cd8d013b4
Commit:        d8983d4bd4c76381c8bd9149c942b83cd8d013b4
Parent:        c96e42006d3bbbcc21cf952c96bf1fc7b15f1bd0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 11:28:15 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Properly detect warnings from testcases.

---
 test/lib/brick-shelltest.h |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 71194cf..7a2b8f0 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -543,8 +543,22 @@ struct KMsg : Source {
 };
 
 struct Observer : Sink {
-    Observer() {}
-    void push( std::string ) {}
+    TimedBuffer stream;
+
+    bool warnings;
+    Observer() : warnings( false ) {}
+
+    void push( std::string s ) {
+        stream.push( s );
+    }
+
+    void sync( bool force ) {
+        while ( !stream.empty( force ) ) {
+            TimedBuffer::Line line = stream.shift( force );
+            if ( line.second.find( "TEST WARNING" ) != std::string::npos )
+                warnings = true;
+        }
+    }
 };
 
 struct IO : Sink {
@@ -850,6 +864,9 @@ struct TestCase {
         else
             r = Journal::FAILED;
 
+        if ( r == Journal::PASSED && io.observer().warnings )
+            r = Journal::WARNED;
+
         io.close();
 
         if ( iobuf && ( r == Journal::FAILED || r == Journal::TIMEOUT ) )


