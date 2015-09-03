From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Sep 2015 07:31:56 +0000 (UTC)
Subject: master - libdm: pkgconfig: fix devmapper.pc to not reference nonexistent rt.pc file
Message-ID: <20150903073156.C976F611FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc35b6988d65fe3f11a3f668cd8f01fe3294b562
Commit:        fc35b6988d65fe3f11a3f668cd8f01fe3294b562
Parent:        b86bd3b074e2f2e7574487b35a6559893bb5a44a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 3 09:28:42 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 3 09:28:42 2015 +0200

libdm: pkgconfig: fix devmapper.pc to not reference nonexistent rt.pc file

librt doesn't have a pkgconfig file so use Libs.private: -lrt instead
to declare the dependency directly.

The same applies for -lm which is also used and which hasn't been
defined in the devmapper.pc file yet.
---
 WHATS_NEW_DM             |    1 +
 configure                |    4 ++--
 configure.in             |    4 ++--
 libdm/libdevmapper.pc.in |    3 ++-
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6852e61..8d74222 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.107 - 
 ===================================
+  Fix devmapper.pc pkgconfig file to not reference non-existent rt.pc file.
   Reinstate dm_task_get_info at Base to libdevmapper exports. (1.02.106)
 
 Version 1.02.106 - 26th August 2015
diff --git a/configure b/configure
index ff914d8..f4820c4 100755
--- a/configure
+++ b/configure
@@ -659,7 +659,7 @@ SELINUX_PC
 SELINUX_LIBS
 REPLICATORS
 READLINE_LIBS
-RT_PC
+RT_LIB
 RAID
 PYTHON_LIBDIRS
 PYTHON_INCDIRS
@@ -12847,7 +12847,7 @@ fi
 $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 
 		LIBS="-lrt $LIBS"
-		RT_PC="librt"
+		RT_LIB="-lrt"
 	else
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
diff --git a/configure.in b/configure.in
index dfd105a..3d83af5 100644
--- a/configure.in
+++ b/configure.in
@@ -1581,7 +1581,7 @@ if test "$REALTIME" = yes; then
 	if test "$HAVE_REALTIME" = yes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
 		LIBS="-lrt $LIBS"
-		RT_PC="librt"
+		RT_LIB="-lrt"
 	else
 		AC_MSG_WARN(Disabling realtime clock)
 	fi
@@ -1995,7 +1995,7 @@ AC_SUBST(PYTHON_LIBDIRS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
-AC_SUBST(RT_PC)
+AC_SUBST(RT_LIB)
 AC_SUBST(READLINE_LIBS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index 63c0720..f29f920 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -8,4 +8,5 @@ Description: device-mapper library
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Requires.private: @SELINUX_PC@ @UDEV_PC@ @RT_PC@
+Requires.private: @SELINUX_PC@ @UDEV_PC@
+Libs.private: -lm @RT_LIB@


