From: Marian Csontos <mcsontos@sourceware.org>
Date: Sun,  9 Aug 2020 15:01:22 +0000 (GMT)
Subject: master - build: make generate
Message-ID: <20200809150122.E58A43857C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f8c331760c08d4da0bb03c4fce4946b0236c0ac
Commit:        9f8c331760c08d4da0bb03c4fce4946b0236c0ac
Parent:        4f44841045ec9420a4bb9a141fab55cb95260b45
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Sun Aug 9 15:20:22 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sun Aug 9 15:20:22 2020 +0200

build: make generate

---
 include/configure.h.in | 6 +++---
 man/lvconvert.8_pregen | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/configure.h.in b/include/configure.h.in
index 57736cc3b..540cee7cf 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -531,6 +531,9 @@
 /* Define to 1 if the system has the `__builtin_clzll' built-in function */
 #undef HAVE___BUILTIN_CLZLL
 
+/* Define to 1 to include built-in support for integrity. */
+#undef INTEGRITY_INTERNAL
+
 /* Internalization package */
 #undef INTL_PACKAGE
 
@@ -678,9 +681,6 @@
 /* Define to 1 to include built-in support for writecache. */
 #undef WRITECACHE_INTERNAL
 
-/* Define to 1 to include built-in support for integrity. */
-#undef INTEGRITY_INTERNAL
-
 /* Define to get access to GNU/Linux extension */
 #undef _GNU_SOURCE
 
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 37b0a47d2..b3902a51c 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -749,7 +749,7 @@ Attach a cache to an LV, converts the LV to type cache.
 Add a writecache to an LV, using a specified cache device.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP\fI_linear_striped_raid\fP
 .br
 .RS 4
 .ad l
@@ -768,7 +768,7 @@ Add a writecache to an LV, using a specified cache device.
 Add a cache to an LV, using a specified cache device.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
 .br
 .RS 4
 .ad l


