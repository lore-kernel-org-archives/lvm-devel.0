From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:09 +0000 (GMT)
Subject: main - configure.ac: improvement
Message-ID: <20211014213709.ACFAF3858427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6635ff77e3680290c464a90ba9b2ee0170a2dc84
Commit:        6635ff77e3680290c464a90ba9b2ee0170a2dc84
Parent:        32cb1c4cdde64ea8f2e0a9ff77ae95e9821904de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 22:36:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

configure.ac: improvement

Handle automatically new setttings

--disable-systemd-journal
--disable-appmachineid

Both setting will check presence of apropriate header files.
In case they are present, build will try to automatically build with
them (adding systemd dependency)

User can anytime disabled them and drop systemd dependency.

Also add --with-default-use-devices-file  configure option to
select automatically default value for this option.
For this moment keep default upstream as 0
---
 configure.ac | 84 +++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 58 insertions(+), 26 deletions(-)

diff --git a/configure.ac b/configure.ac
index 31196d96c..2cff45fdc 100644
--- a/configure.ac
+++ b/configure.ac
@@ -219,7 +219,6 @@ test "x$prefix" = xNONE && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
 test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
 
-
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
@@ -286,6 +285,20 @@ esac
 AC_MSG_RESULT(on $ADD_NODE)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
 
+
+dnl -- Default settings for lvm.conf { devices/use_devicesfile }
+AC_MSG_CHECKING(default for use_devicesfile)
+AC_ARG_WITH(default-use-devices-file,
+	      AS_HELP_STRING([--with-default-use-devices-file], [default for lvm.conf devices/use_devicesfile = [0]]),
+	      DEFAULT_USE_DEVICES_FILE=$enableval, DEFAULT_USE_DEVICES_FILE=0)
+case "$DEFAULT_USE_DEVICES_FILE" in
+ 0|1);;
+ *) AC_MSG_ERROR([--with-default-use-devices-file parameter invalid]);;
+esac
+AC_MSG_RESULT($DEFAULT_USE_DEVICES_FILE)
+AC_DEFINE_UNQUOTED(DEFAULT_USE_DEVICES_FILE, [$DEFAULT_USE_DEVICES_FILE],
+		   [Default for lvm.conf use_devicefile.])
+
 AC_MSG_CHECKING(default name mangling)
 AC_ARG_WITH(default-name-mangling,
 	    AS_HELP_STRING([--with-default-name-mangling=MANGLING],
@@ -1085,6 +1098,7 @@ if test "$BUILD_DMFILEMAPD" = yes; then
    AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
 fi
 
+SYSTEMD_MIN_VERSION=
 ################################################################################
 dnl -- Build notifydbus
 AC_MSG_CHECKING(whether to build notifydbus)
@@ -1094,36 +1108,46 @@ AC_ARG_ENABLE(notify-dbus,
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
 AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
 
-if test "$NOTIFYDBUS_SUPPORT" = yes; then
-	AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])
-	SYSTEMD_LIBS="-lsystemd"
-fi
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes],
+      AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])
+      SYSTEMD_MIN_VERSION=221)
 
 ################################################################################
-dnl -- Look for dbus libraries
-if test "$NOTIFYDBUS_SUPPORT" = yes; then
-	PKG_CHECK_MODULES(NOTIFY_DBUS, systemd >= 221, [HAVE_NOTIFY_DBUS=yes], $bailout)
-fi
+dnl -- Build with systemd journaling when the header file is present
+AC_CHECK_HEADER([systemd/sd-journal.h], [SYSTEMD_JOURNAL_SUPPORT=yes], [SYSTEMD_JOURNAL_SUPPORT=no])
+AC_MSG_CHECKING(whether to log to systemd journal)
+AC_ARG_ENABLE(systemd-journal,
+	      AS_HELP_STRING([--disable-systemd-journal],
+			     [disable LVM systemd journaling]),
+	      AS_IF([test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no],
+		    [AC_MSG_ERROR([Enabling systemd journaling requires systemd/sd-journal.h.])])
+	      SYSTEMD_JOURNAL_SUPPORT=$enableval, [])
+AC_MSG_RESULT($SYSTEMD_JOURNAL_SUPPORT)
+
+AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = yes],
+      AC_DEFINE([SYSTEMD_JOURNAL_SUPPORT], 1, [Define to 1 to include code that uses systemd journal.])
+      SYSTEMD_MIN_VERSION=221)
 
 ################################################################################
-dnl -- Build appmachineid
+dnl -- Build appmachineid when header file sd-id128.h is present
+AC_CHECK_HEADER([systemd/sd-id128.h], [APP_MACHINEID_SUPPORT=yes], [APP_MACHINEID_SUPPORT=no])
 AC_MSG_CHECKING(whether to build appmachineid)
 AC_ARG_ENABLE(app-machineid,
-	      AC_HELP_STRING([--enable-app-machineid],
-			     [enable LVM system ID using app-specific machine-id]),
-	      APP_MACHINEID_SUPPORT=$enableval, APP_MACHINEID_SUPPORT=no)
+	      AC_HELP_STRING([--disable-app-machineid],
+			     [disable LVM system ID using app-specific machine-id]),
+	      AS_IF([test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no],
+		    [AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h.])])
+	      APP_MACHINEID_SUPPORT=$enableval, [])
 AC_MSG_RESULT($APP_MACHINEID_SUPPORT)
 
-if test "$APP_MACHINEID_SUPPORT" = yes; then
-	AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.])
-	SYSTEMD_LIBS="-lsystemd"
-fi
+AS_IF([test "$APP_MACHINEID_SUPPORT" = yes],
+      AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.])
+      SYSTEMD_MIN_VERSION=234)
 
-################################################################################
 dnl -- Look for libsystemd libraries
-if test "$APP_MACHINEID_SUPPORT" = yes; then
-	PKG_CHECK_MODULES(APP_MACHINEID, systemd >= 234, [HAVE_APP_MACHINEID=yes], $bailout)
-fi
+AS_IF([test -n "SYSTEMD_MIN_VERSION"],
+      PKG_CHECK_MODULES(SYSTEMD, systemd >= "$SYSTEMD_MIN_VERSION", [], $bailout)
+      SYSTEMD_LIBS="-lsystemd")
 
 ################################################################################
 
@@ -1805,6 +1829,19 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 
 AC_DEFINE_UNQUOTED(LVM_CONFIGURE_LINE, "$CONFIGURE_LINE", [configure command line used])
 
+AC_ARG_VAR([BLKID_CFLAGS], [C compiler flags for blkid])
+AC_ARG_VAR([BLKID_LIBS], [linker flags for blkid])
+AC_ARG_VAR([CPG_CFLAGS], [C compiler flags for cpg])
+AC_ARG_VAR([CPG_LIBS], [linker flags for cpg])
+AC_ARG_VAR([EDITLINE_CFLAGS], [C compiler flags for editline])
+AC_ARG_VAR([EDITLINE_LIBS], [linker flags for editline])
+AC_ARG_VAR([READLINE_CFLAGS], [C compiler flags for readline])
+AC_ARG_VAR([READLINE_LIBS], [linker flags for readline])
+AC_ARG_VAR([SYSTEMD_CFLAGS], [C compiler flags for systemd])
+AC_ARG_VAR([SYSTEMD_LIBS], [linker flags for systemd])
+AC_ARG_VAR([UDEV_CFLAGS], [C compiler flags for udev])
+AC_ARG_VAR([UDEV_LIBS], [linker flags for udev])
+
 ################################################################################
 AC_SUBST(AWK)
 AC_SUBST(BLKID_PC)
@@ -1829,8 +1866,6 @@ AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
 AC_SUBST(CONFDIR)
 AC_SUBST(COPTIMISE_FLAG)
-AC_SUBST(CPG_CFLAGS)
-AC_SUBST(CPG_LIBS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
@@ -1902,8 +1937,6 @@ AC_SUBST(PYTHON3DIR)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RT_LIBS)
-AC_SUBST(READLINE_LIBS)
-AC_SUBST(EDITLINE_LIBS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
@@ -1913,7 +1946,6 @@ AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
 AC_SUBST(SYSCONFDIR)
-AC_SUBST(SYSTEMD_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)


