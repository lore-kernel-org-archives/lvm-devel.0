From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  9 May 2015 07:18:27 +0000 (UTC)
Subject: master - tests: avoid clobering dmesg
Message-ID: <20150509071827.57B9E60F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abcab54cca4b4f9ff157a5f51718c69ffdf34c7a
Commit:        abcab54cca4b4f9ff157a5f51718c69ffdf34c7a
Parent:        3d845e492adab0aba279f24e244d8617faa3279d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 8 22:43:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 9 09:17:26 2015 +0200

tests: avoid clobering dmesg

Restore old harness access to /dev/kmsg.
---
 test/lib/brick-shelltest.h |   28 ++++++++++------------------
 1 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index af8051e..e64a166 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -541,26 +541,22 @@ struct FileSource : Source {
 struct KMsg : Source {
     bool can_clear;
 
-    KMsg() : can_clear( true ) {}
-
-    bool dev_kmsg() {
-        return fd >= 0;
-    }
-
-    void reset() {
+    KMsg() : can_clear( strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0") ) {
 #ifdef __unix
-        if ( dev_kmsg() ) {
-            if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
-                if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
-                    perror("opening /dev/kmsg");
-            } else if (lseek(fd, 0L, SEEK_END) == (off_t) -1)
-                perror("lseek /dev/kmsg");
-        } else
+        if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
+            if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
+                perror("opening /dev/kmsg");
             if ( klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 ) < 0 )
                 can_clear = false;
+        } else if (lseek(fd, 0L, SEEK_END) == (off_t) -1)
+            perror("lseek /dev/kmsg");
 #endif
     }
 
+    bool dev_kmsg() {
+        return fd >= 0;
+    }
+
     void sync( Sink *s ) {
 #ifdef __unix
         ssize_t sz;
@@ -569,10 +565,6 @@ struct KMsg : Source {
         if ( dev_kmsg() ) {
             while ( (sz = ::read(fd, buf, sizeof(buf) - 1)) > 0 )
                 s->push( std::string( buf, sz ) );
-            if ( sz < 0 ) {
-                fd = -1;
-                sync( s );
-            }
         } else if ( can_clear ) {
             while ( (sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf,
                                    sizeof(buf) - 1 )) > 0 )


