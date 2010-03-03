From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:43:00 +0100
Subject: [PATCH 14/15] Introduce UDEV_LIBS
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <ba450cd7abc8d7abd8a180f88364f5bedff1de56.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Link libudev only to object files that really needs this library.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in      |    4 +++-
 libdm/Makefile.in |    2 +-
 make.tmpl.in      |    3 ++-
 tools/Makefile.in |    2 ++
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure.in b/configure.in
index f632420..3473d95 100644
--- a/configure.in
+++ b/configure.in
@@ -668,8 +668,9 @@ if test x$UDEV_SYNC = xyes; then
 		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
 			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
 			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
-			LIBS="-ludev $LIBS"
+			UDEV_LIBS="-ludev"
 		else
+			UDEV_LIBS=
 			AC_MSG_WARN(It won't be possible to get udev state. We will assume that udev is not running.)
 		fi
 fi
@@ -1120,6 +1121,7 @@ AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
+AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(interface)
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 7ea0604..85e19ea 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -52,7 +52,7 @@ include $(top_builddir)/make.tmpl
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-LIBS += $(SELINUX_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS)
 
 device-mapper: all
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 48f145d..ff4d1b2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -31,7 +31,7 @@ CFLOW_CMD = @CFLOW_CMD@
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(SELINUX_LIBS)
+STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS)
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
@@ -43,6 +43,7 @@ DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+UDEV_LIBS = @UDEV_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index c7cd1d5..5106327 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -107,6 +107,8 @@ DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
 include $(top_builddir)/make.tmpl
 
+LIBS += $(UDEV_LIBS)
+
 device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-- 
1.7.0


