From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:36 +0000 (UTC)
Subject: master - test: Only force an IO sync when the testcase has finished.
Message-ID: <20150205134336.29B8760EAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c96e42006d3bbbcc21cf952c96bf1fc7b15f1bd0
Commit:        c96e42006d3bbbcc21cf952c96bf1fc7b15f1bd0
Parent:        72ee3f920b235c516328e92757571d311308f439
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 11:27:44 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Only force an IO sync when the testcase has finished.

---
 test/lib/brick-shelltest.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 7c6a021..71194cf 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -339,7 +339,7 @@ struct TimedBuffer {
 struct Sink {
     virtual void outline( bool ) {}
     virtual void push( std::string x ) = 0;
-    virtual void sync() {}
+    virtual void sync( bool ) {}
     virtual ~Sink() {}
 };
 
@@ -410,11 +410,11 @@ struct FdSink : Sink {
         write( fd, out.c_str(), out.length() );
     }
 
-    virtual void sync() {
+    virtual void sync( bool force ) {
         if ( killed )
             return;
-        while ( !stream.empty( true ) )
-            outline( true );
+        while ( !stream.empty( force ) )
+            outline( force );
     }
 
     virtual void push( std::string x ) {
@@ -429,13 +429,13 @@ struct FileSink : FdSink {
     std::string file;
     FileSink( std::string n ) : FdSink( -1 ), file( n ) {}
 
-    void sync() {
+    void sync( bool force ) {
         if ( fd < 0 && !killed ) {
             fd = open( file.c_str(), O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644 );
             if ( fd < 0 )
                 killed = true;
         }
-        FdSink::sync();
+        FdSink::sync( force );
     }
 
     ~FileSink() {
@@ -561,12 +561,12 @@ struct IO : Sink {
             (*i)->push( x );
     }
 
-    void sync() {
+    void sync( bool force ) {
         for ( Sources::iterator i = sources.begin(); i != sources.end(); ++i )
             (*i)->sync( this );
 
         for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
-            (*i)->sync();
+            (*i)->sync( force );
     }
 
     void close() {
@@ -717,7 +717,7 @@ struct TestCase {
         }
 
         if ( wait4(pid, &status, WNOHANG, &usage) != 0 ) {
-            io.sync();
+            io.sync( true );
             return false;
         }
 
@@ -732,7 +732,7 @@ struct TestCase {
                     waitpid( pid, &status, 0 );
                 }
                 timeout = true;
-                io.sync();
+                io.sync( true );
                 return false;
             }
 
@@ -755,7 +755,7 @@ struct TestCase {
         if ( select( nfds, &set, NULL, NULL, &wait ) > 0 )
             silent_start = end; /* something happened */
 
-        io.sync();
+        io.sync( false );
 
         return true;
     }


