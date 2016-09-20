From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Sep 2016 20:48:38 +0000 (UTC)
Subject: master - tests: read messages instead of syslog
Message-ID: <20160920204838.AD17B605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=994df22b608c40967c5327d5850af9a2a1b3eea3
Commit:        994df22b608c40967c5327d5850af9a2a1b3eea3
Parent:        a9c2a62939e1c215126fa499a8ed7c0550b21f6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 20 22:36:29 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 20 22:36:29 2016 +0200

tests: read messages instead of syslog

Since on those older system there is rather 'fight' over
syslog reading buffer - lets read output from /var/log/messages
intead.
---
 test/lib/brick-shelltest.h |   40 +++++++++++++++++++---------------------
 1 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index a8df900..1c9a1f3 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -558,7 +558,6 @@ struct FileSource : Source {
 
 struct KMsg : Source {
     bool can_clear;
-    bool syslog;
     ssize_t buffer_size;
 
     KMsg() : can_clear( strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0") ),
@@ -567,21 +566,24 @@ struct KMsg : Source {
 #ifdef __unix
         struct utsname uts;
         unsigned kmaj, kmin, krel;
-
-        // Can't use kmsg on kernels pre 3.5, relay on syslog for that case
-        syslog = ( ( ::uname(&uts) == 0 ) &&
-                   ( ::sscanf( uts.release, "%u.%u.%u", &kmaj, &kmin, &krel ) == 3 ) &&
-                   ( ( kmaj < 3 ) || ( ( kmaj == 3 ) && ( kmin < 5 ) ) ) );
-
-        if ( syslog )
-            buffer_size = klogctl( BRICK_SYSLOG_ACTION_SIZE_BUFFER, NULL, 0 );
-        else if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
-            if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
-                perror("opening /dev/kmsg");
-            if ( klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 ) < 0 )
+        const char *read_msg = "/dev/kmsg";
+
+        // Can't use kmsg on kernels pre 3.5, read /var/log/messages
+        if ( ( ::uname(&uts) == 0 ) &&
+            ( ::sscanf( uts.release, "%u.%u.%u", &kmaj, &kmin, &krel ) == 3 ) &&
+            ( ( kmaj < 5 ) || ( ( kmaj == 3 ) && ( kmin < 5 ) ) ) )
+            can_clear = false, read_msg = "/var/log/messages";
+
+        if ( ( fd = open(read_msg, O_RDONLY | O_NONBLOCK)) < 0 ) {
+            if ( errno != ENOENT ) /* Older kernels (<3.5) do not support /dev/kmsg */
+                fprintf( stderr, "open log %s %s\n", read_msg, strerror( errno ) );
+            if ( can_clear && ( klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 ) < 0 ) )
                 can_clear = false;
-        } else if (lseek(fd, 0L, SEEK_END) == (off_t) -1)
-            perror("lseek /dev/kmsg");
+        } else if ( lseek( fd, 0L, SEEK_END ) == (off_t) -1 ) {
+            fprintf( stderr, "lseek log %s %s\n", read_msg, strerror( errno ) );
+            close(fd);
+            fd = -1;
+        }
 #endif
     }
 
@@ -594,16 +596,12 @@ struct KMsg : Source {
         ssize_t sz;
         char buf[ buffer_size ];
 
-        if ( syslog ) {
-            while ( klogctl(BRICK_SYSLOG_ACTION_SIZE_UNREAD, NULL, 0 ) > 0 &&
-                    ( sz = klogctl( BRICK_SYSLOG_ACTION_READ, buf, ( int ) buffer_size ) ) > 0 )
-                s->push( std::string( buf, sz ) );
-        } else if ( dev_kmsg() ) {
+        if ( dev_kmsg() ) {
             while ( (sz = ::read(fd, buf, buffer_size)) > 0 )
                 s->push( std::string( buf, sz ) );
         } else if ( can_clear ) {
             while ( ( sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf,
-                                   ( int)  buffer_size ) ) > 0 )
+                                   ( int) buffer_size ) ) > 0 )
                 s->push( std::string( buf, sz ) );
             if ( sz < 0 && errno == EPERM )
                 can_clear = false;


