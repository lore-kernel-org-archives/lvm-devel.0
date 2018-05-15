From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:05 -0400
Subject: master - build: configure detect libaio
Message-ID: <201805152005.w4FK55oU001398@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad756bb7083743b612d3fc66b268b605576f448a
Commit:        ad756bb7083743b612d3fc66b268b605576f448a
Parent:        c1abcee1424022b308fa265037af5826ae2af82d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:43:03 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

build: configure detect libaio

No point to start building lvm without this header file.

Although there could be 'some point' in supporting standalone build
of 'just' libdm  where the libaio might be avoided.

TODO: think about configure option for building libdm only.
---
 configure              |    2 +-
 configure.ac           |    2 +-
 include/configure.h.in |    3 +++
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index ed00809..ce70d92 100755
--- a/configure
+++ b/configure
@@ -6141,7 +6141,7 @@ fi
 
 
 for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h \
-  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
+  getopt.h inttypes.h langinfo.h libaio.h libgen.h limits.h locale.h paths.h \
   signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
   sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
diff --git a/configure.ac b/configure.ac
index 41e612f..7b517ef 100644
--- a/configure.ac
+++ b/configure.ac
@@ -103,7 +103,7 @@ AC_HEADER_SYS_WAIT
 AC_HEADER_TIME
 
 AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
-  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
+  getopt.h inttypes.h langinfo.h libaio.h libgen.h limits.h locale.h paths.h \
   signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
   sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
diff --git a/include/configure.h.in b/include/configure.h.in
index 66cc27c..15fd150 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -245,6 +245,9 @@
 /* Define to 1 if you have the <langinfo.h> header file. */
 #undef HAVE_LANGINFO_H
 
+/* Define to 1 if you have the <libaio.h> header file. */
+#undef HAVE_LIBAIO_H
+
 /* Define to 1 if you have the <libcman.h> header file. */
 #undef HAVE_LIBCMAN_H
 


