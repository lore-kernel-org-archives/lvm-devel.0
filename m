From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 10 Feb 2015 16:08:02 +0000 (UTC)
Subject: master - test: Fix harness not building on RHEL5
Message-ID: <20150210160802.AFB4760268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8b45b7a4c512137be1c919b6d247e2fe889edb4
Commit:        a8b45b7a4c512137be1c919b6d247e2fe889edb4
Parent:        7f2eebf519c039eea4d8d4f41fd44b04182093f2
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 10 14:51:45 2015 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 10 17:02:01 2015 +0100

test: Fix harness not building on RHEL5

---
 test/lib/brick-shelltest.h |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 99e6639..335ef85 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -431,7 +431,13 @@ struct FileSink : FdSink {
 
     void sync( bool force ) {
         if ( fd < 0 && !killed ) {
+#ifdef O_CLOEXEC
             fd = open( file.c_str(), O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644 );
+#else
+            fd = open( file.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644 );
+            if ( fcntl( fd, F_SETFD, FD_CLOEXEC ) < 0 )
+                perror("failed to set FD_CLOEXEC on file");
+#endif
             if ( fd < 0 )
                 killed = true;
         }
@@ -463,7 +469,7 @@ struct Source {
 
     virtual void reset() {}
 
-    virtual int fd_set( fd_set *set ) {
+    virtual int fd_set_( fd_set *set ) {
         if ( fd >= 0 ) {
             FD_SET( fd, set );
             return fd;
@@ -482,10 +488,16 @@ struct FileSource : Source {
     std::string file;
     FileSource( std::string n ) : Source( -1 ), file( n ) {}
 
-    int fd_set( ::fd_set * ) { return -1; } /* reading a file is always non-blocking */
+    int fd_set_( ::fd_set * ) { return -1; } /* reading a file is always non-blocking */
     void sync( Sink *s ) {
         if ( fd < 0 ) {
+#ifdef O_CLOEXEC
             fd = open( file.c_str(), O_RDONLY | O_CLOEXEC | O_NONBLOCK );
+#else
+            fd = open( file.c_str(), O_RDONLY | O_NONBLOCK );
+            if ( fcntl( fd, F_SETFD, FD_CLOEXEC ) < 0 )
+                perror("failed to set FD_CLOEXEC on file");
+#endif
             if ( fd >= 0 )
                 lseek( fd, 0, SEEK_END );
         }
@@ -505,8 +517,6 @@ struct KMsg : Source {
 
     void reset() {
 #ifdef __unix
-        int sz;
-
         if ( dev_kmsg() ) {
             if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
                 if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
@@ -589,11 +599,11 @@ struct IO : Sink {
         sources.clear();
     }
 
-    int fd_set( fd_set *set ) {
+    int fd_set_( fd_set *set ) {
         int max = -1;
 
         for ( Sources::iterator i = sources.begin(); i != sources.end(); ++i )
-            max = std::max( (*i)->fd_set( set ), max );
+            max = std::max( (*i)->fd_set_( set ), max );
         return max + 1;
     }
 
@@ -755,7 +765,7 @@ struct TestCase {
         fd_set set;
 
         FD_ZERO( &set );
-        int nfds = io.fd_set( &set );
+        int nfds = io.fd_set_( &set );
         wait.tv_sec = 0;
         wait.tv_usec = 500000; /* timeout 0.5s */
 


