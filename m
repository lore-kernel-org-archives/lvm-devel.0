From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Sep 2016 15:11:17 +0000 (UTC)
Subject: master - tests: kernel message for <3.5 kernels
Message-ID: <20160920151117.B729560D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9c2a62939e1c215126fa499a8ed7c0550b21f6a
Commit:        a9c2a62939e1c215126fa499a8ed7c0550b21f6a
Parent:        67d4b3b7f2be1e15af2d05faa97e8b56ddc9d668
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 20 17:09:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 20 17:09:46 2016 +0200

tests: kernel message for <3.5 kernels

Since /dev/kmsg is useless on kernel <3.5 user there automatically
syslog to obtain traces from kernel log buffer during test.
---
 test/lib/brick-shelltest.h |   37 ++++++++++++++++++++++++++++++-------
 test/lib/utils.sh          |    1 +
 2 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index b48253b..a8df900 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -75,6 +75,7 @@
 #include <sys/types.h>
 #include <sys/wait.h>
 #include <sys/klog.h>
+#include <sys/utsname.h>
 #include <time.h>
 #include <unistd.h>
 #endif
@@ -484,8 +485,12 @@ struct FileSink : FdSink {
     }
 };
 
+#define BRICK_SYSLOG_ACTION_READ           2
+#define BRICK_SYSLOG_ACTION_READ_ALL       3
 #define BRICK_SYSLOG_ACTION_READ_CLEAR     4
 #define BRICK_SYSLOG_ACTION_CLEAR          5
+#define BRICK_SYSLOG_ACTION_SIZE_UNREAD    9
+#define BRICK_SYSLOG_ACTION_SIZE_BUFFER   10
 
 struct Source {
     int fd;
@@ -553,10 +558,24 @@ struct FileSource : Source {
 
 struct KMsg : Source {
     bool can_clear;
+    bool syslog;
+    ssize_t buffer_size;
 
-    KMsg() : can_clear( strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0") ) {
+    KMsg() : can_clear( strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0") ),
+        buffer_size(128 * 1024)
+    {
 #ifdef __unix
-        if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
+        struct utsname uts;
+        unsigned kmaj, kmin, krel;
+
+        // Can't use kmsg on kernels pre 3.5, relay on syslog for that case
+        syslog = ( ( ::uname(&uts) == 0 ) &&
+                   ( ::sscanf( uts.release, "%u.%u.%u", &kmaj, &kmin, &krel ) == 3 ) &&
+                   ( ( kmaj < 3 ) || ( ( kmaj == 3 ) && ( kmin < 5 ) ) ) );
+
+        if ( syslog )
+            buffer_size = klogctl( BRICK_SYSLOG_ACTION_SIZE_BUFFER, NULL, 0 );
+        else if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
             if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
                 perror("opening /dev/kmsg");
             if ( klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 ) < 0 )
@@ -573,14 +592,18 @@ struct KMsg : Source {
     void sync( Sink *s ) {
 #ifdef __unix
         ssize_t sz;
-        char buf[ 128 * 1024 ];
+        char buf[ buffer_size ];
 
-        if ( dev_kmsg() ) {
-            while ( (sz = ::read(fd, buf, sizeof(buf) - 1)) > 0 )
+        if ( syslog ) {
+            while ( klogctl(BRICK_SYSLOG_ACTION_SIZE_UNREAD, NULL, 0 ) > 0 &&
+                    ( sz = klogctl( BRICK_SYSLOG_ACTION_READ, buf, ( int ) buffer_size ) ) > 0 )
+                s->push( std::string( buf, sz ) );
+        } else if ( dev_kmsg() ) {
+            while ( (sz = ::read(fd, buf, buffer_size)) > 0 )
                 s->push( std::string( buf, sz ) );
         } else if ( can_clear ) {
-            while ( (sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf,
-                                   sizeof(buf) - 1 )) > 0 )
+            while ( ( sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf,
+                                   ( int)  buffer_size ) ) > 0 )
                 s->push( std::string( buf, sz ) );
             if ( sz < 0 && errno == EPERM )
                 can_clear = false;
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index a3b5e2e..ce90cdc 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -219,6 +219,7 @@ dm_table() {
 }
 
 skip() {
+	set +vx # debug off
 	if test "$#" -eq 0; then
 		stacktrace
 	else


