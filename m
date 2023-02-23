From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:58 +0000 (GMT)
Subject: main - configure.ac: misc
Message-ID: <20230223154858.052E53858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b592a67d69bc22ec32929052320731abd8aad61
Commit:        2b592a67d69bc22ec32929052320731abd8aad61
Parent:        255e8c8eaa0ca76de9ce8da0ebc78e8e0c9a4482
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 22 14:11:50 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure.ac: misc

---
 configure.ac | 122 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 59 insertions(+), 63 deletions(-)

diff --git a/configure.ac b/configure.ac
index 71006d895..cee24c93c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -37,7 +37,6 @@ AS_CASE(["$host_os"],
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LIB_SUFFIX="so"
 		DEVMAPPER="yes"
-		BUILD_LVMPOLLD="no"
 		ODIRECT="yes"
 		DM_IOCTLS="yes"
 		SELINUX="yes"
@@ -671,14 +670,6 @@ AS_CASE(["$INTEGRITY"],
 		AC_DEFINE([INTEGRITY_INTERNAL], 1, [Define to 1 to include built-in support for integrity.])],
 	[AC_MSG_ERROR([--with-integrity parameter invalid])])
 
-################################################################################
-# Allow users to override default location for libaio
-# there seems to be no pkg-config support available
-AIO_CFLAGS=
-AIO_LIBS=${AIO_LIBS:--laio}
-AC_ARG_VAR([AIO_CFLAGS], [C compiler flags for AIO])
-AC_ARG_VAR([AIO_LIBS], [linker flags for AIO])
-
 ################################################################################
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
@@ -715,7 +706,7 @@ AC_ARG_WITH(ocfdir,
 ################################################################################
 AC_MSG_CHECKING([for default run directory])
 RUN_DIR="/run"
-test -d "/run" || RUN_DIR="/var/run"
+AS_IF([test ! -d "$RUN_DIR"], [RUN_DIR="/var/run"])
 AC_MSG_RESULT([$RUN_DIR])
 dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
@@ -748,10 +739,8 @@ AC_MSG_CHECKING([whether to build cluster mirror log daemon])
 AC_ARG_ENABLE(cmirrord,
 	      AS_HELP_STRING([--enable-cmirrord],
 			     [enable the cluster mirror log daemon]),
-	      CMIRRORD=$enableval, CMIRRORD="no")
-AC_MSG_RESULT([$CMIRRORD])
-
-BUILD_CMIRRORD=$CMIRRORD
+	      BUILD_CMIRRORD=$enableval, BUILD_CMIRRORD="no")
+AC_MSG_RESULT([$BUILD_CMIRRORD])
 
 ################################################################################
 dnl -- cmirrord pidfile
@@ -896,8 +885,7 @@ AC_MSG_CHECKING([whether to build lvmpolld])
 AC_ARG_ENABLE(lvmpolld,
 	      AS_HELP_STRING([--enable-lvmpolld],
 			     [enable the LVM Polling Daemon]),
-	      LVMPOLLD=$enableval, LVMPOLLD="no")
-test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
+	      BUILD_LVMPOLLD=$enableval, BUILD_LVMPOLLD="no")
 AC_MSG_RESULT([$BUILD_LVMPOLLD])
 
 ################################################################################
@@ -1686,22 +1674,20 @@ AC_DEFINE_UNQUOTED(LVRESIZE_FS_HELPER_PATH, ["$LVRESIZE_FS_HELPER_PATH"], [Path
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
+AC_ARG_WITH(dmeventd-pidfile,
+	    AS_HELP_STRING([--with-dmeventd-pidfile=PATH],
+			   [dmeventd pidfile [PID_DIR/dmeventd.pid]]),
+	    DMEVENTD_PIDFILE=$withval,
+	    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
+AC_ARG_WITH(dmeventd-path,
+	    AS_HELP_STRING([--with-dmeventd-path=PATH],
+			   [dmeventd path [EPREFIX/sbin/dmeventd]]),
+	    DMEVENTD_PATH=$withval,
+	    DMEVENTD_PATH="$SBINDIR/dmeventd")
+
 AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
-	AC_ARG_WITH(dmeventd-pidfile,
-		    AS_HELP_STRING([--with-dmeventd-pidfile=PATH],
-				   [dmeventd pidfile [PID_DIR/dmeventd.pid]]),
-		    DMEVENTD_PIDFILE=$withval,
-		    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
-])
-
-AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
-	AC_ARG_WITH(dmeventd-path,
-		    AS_HELP_STRING([--with-dmeventd-path=PATH],
-				   [dmeventd path [EPREFIX/sbin/dmeventd]]),
-		    DMEVENTD_PATH=$withval,
-		    DMEVENTD_PATH="$SBINDIR/dmeventd")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
 			   [Path to dmeventd binary.])
 ])
@@ -1766,14 +1752,15 @@ AC_ARG_WITH(interface,
 	    AS_HELP_STRING([--with-interface=IFACE],
 			   [choose kernel interface (ioctl) [ioctl]]),
 	    interface=$withval, interface="ioctl")
-test "$interface" != "ioctl" && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])
+AS_IF([test "$interface" != "ioctl"],
+      [AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])])
 AC_MSG_RESULT([$interface])
 
 ################################################################################
 read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION="Unknown"
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, "$DM_LIB_VERSION", [Library version])
 
-DM_LIB_PATCHLEVEL=$(cat "$srcdir"/VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}')
+DM_LIB_PATCHLEVEL=$($AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}' "$srcdir"/VERSION_DM)
 
 read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
@@ -1789,23 +1776,36 @@ LVM_LIBAPI=$(echo "$VER" | $AWK -F '[[()]]' '{print $2}')
 
 AC_DEFINE_UNQUOTED(LVM_CONFIGURE_LINE, "$CONFIGURE_LINE", [configure command line used])
 
+################################################################################
+# Allow users to override default location for libaio
+# there seems to be no pkg-config support available
+AIO_CFLAGS=${AIO_CFLAGS:-}
+AIO_LIBS=${AIO_LIBS:--laio}
+AC_ARG_VAR([AIO_CFLAGS], [C compiler flags for AIO])
+AC_ARG_VAR([AIO_LIBS], [linker flags for AIO])
+
 AC_ARG_VAR([READLINE_CFLAGS], [C compiler flags for readline])
 AC_ARG_VAR([READLINE_LIBS], [linker flags for readline])
 
 ################################################################################
 AC_SUBST(AWK)
+AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(BLKID_PC)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
-AC_SUBST(BUILD_LVMDBUSD)
-AC_SUBST(BUILD_LVMPOLLD)
-AC_SUBST(BUILD_LVMLOCKD)
-AC_SUBST(BUILD_LOCKDSANLOCK)
+AC_SUBST(BUILD_DMFILEMAPD)
 AC_SUBST(BUILD_LOCKDDLM)
 AC_SUBST(BUILD_LOCKDDLM_CONTROL)
 AC_SUBST(BUILD_LOCKDIDM)
-AC_SUBST(BUILD_DMFILEMAPD)
+AC_SUBST(BUILD_LOCKDSANLOCK)
+AC_SUBST(BUILD_LVMDBUSD)
+AC_SUBST(BUILD_LVMLOCKD)
+AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(CACHE)
+AC_SUBST(CACHE_CHECK_CMD)
+AC_SUBST(CACHE_DUMP_CMD)
+AC_SUBST(CACHE_REPAIR_CMD)
+AC_SUBST(CACHE_RESTORE_CMD)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CHMOD)
@@ -1813,8 +1813,10 @@ AC_SUBST(CLDFLAGS)
 AC_SUBST(CLDNOWHOLEARCHIVE)
 AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CMDLIB)
+AC_SUBST(CMIRRORD_PIDFILE)
 AC_SUBST(CONFDIR)
 AC_SUBST(COPTIMISE_FLAG)
+AC_SUBST(CPPFLAGS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
@@ -1832,24 +1834,27 @@ AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_SYS_LOCK_DIR)
 AC_SUBST(DEFAULT_USE_BLKID_WIPING)
 AC_SUBST(DEFAULT_USE_DEVICES_FILE)
-AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
+AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD_PATH)
+AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
 AC_SUBST(FSADM_PATH)
-AC_SUBST(LVRESIZE_FS_HELPER_PATH)
-AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(INTEGRITY)
 AC_SUBST(INTL)
 AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
 AC_SUBST(LIB_SUFFIX)
-AC_SUBST(LVM_VERSION)
+AC_SUBST(localedir)
+AC_SUBST(LVMIMPORTVDO)
+AC_SUBST(LVMIMPORTVDO_PATH)
+AC_SUBST(LVMLOCKD_PIDFILE)
+AC_SUBST(LVMPOLLD_PIDFILE)
 AC_SUBST(LVM_LIBAPI)
 AC_SUBST(LVM_MAJOR)
 AC_SUBST(LVM_MINOR)
@@ -1857,48 +1862,43 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
-AC_SUBST(LVMIMPORTVDO)
-AC_SUBST(LVMIMPORTVDO_PATH)
-AC_SUBST(localedir)
+AC_SUBST(LVM_VERSION)
+AC_SUBST(LVRESIZE_FS_HELPER_PATH)
 AC_SUBST(MANGLING)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
+AC_SUBST(M_LIBS)
 AC_SUBST(OCF)
 AC_SUBST(OCFDIR)
 AC_SUBST(ODIRECT)
 AC_SUBST(PKGCONFIG)
-AC_SUBST(M_LIBS)
 AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(PYTHON2)
-AC_SUBST(PYTHON3)
 AC_SUBST(PYTHON2DIR)
+AC_SUBST(PYTHON3)
 AC_SUBST(PYTHON3DIR)
 AC_SUBST(RT_LIBS)
 AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
-AC_SUBST(SYSCONFDIR)
-AC_SUBST(SYSTEMD_RUN_CMD)
+AC_SUBST(SILENT_RULES)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
+AC_SUBST(SYSCONFDIR)
+AC_SUBST(SYSTEMD_RUN_CMD)
 AC_SUBST(TESTSUITE_DATA)
 AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(THIN_DUMP_CMD)
 AC_SUBST(THIN_REPAIR_CMD)
 AC_SUBST(THIN_RESTORE_CMD)
-AC_SUBST(CACHE_CHECK_CMD)
-AC_SUBST(CACHE_DUMP_CMD)
-AC_SUBST(CACHE_REPAIR_CMD)
-AC_SUBST(CACHE_RESTORE_CMD)
+AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
-AC_SUBST(UDEV_SYNC)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
-AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
+AC_SUBST(UDEV_SYNC)
 AC_SUBST(USE_TRACKING)
-AC_SUBST(SILENT_RULES)
 AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(VDO)
@@ -1907,23 +1907,19 @@ AC_SUBST(VDO_INCLUDE)
 AC_SUBST(VDO_LIB)
 AC_SUBST(WRITECACHE)
 AC_SUBST(WRITE_INSTALL)
-AC_SUBST(DMEVENTD_PIDFILE)
-AC_SUBST(LVMPOLLD_PIDFILE)
-AC_SUBST(LVMLOCKD_PIDFILE)
-AC_SUBST(CMIRRORD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
-AC_SUBST(missingkernel)
 AC_SUBST(kernelvsn)
-AC_SUBST(tmpdir)
-AC_SUBST(udev_prefix)
-AC_SUBST(udevdir)
+AC_SUBST(libexecdir)
+AC_SUBST(missingkernel)
 AC_SUBST(systemdsystemunitdir)
 AC_SUBST(systemdutildir)
+AC_SUBST(tmpdir)
 AC_SUBST(tmpfilesdir)
+AC_SUBST(udevdir)
+AC_SUBST(udev_prefix)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
-AC_SUBST(libexecdir)
 
 ################################################################################
 dnl -- First and last lines should not contain files to generate in order to

