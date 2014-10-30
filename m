From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:28 +0000 (UTC)
Subject: master - configure: option cleanup
Message-ID: <20141030230028.8714760654@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87f59af15ce315bb76ebaa176dd458295f607816
Commit:        87f59af15ce315bb76ebaa176dd458295f607816
Parent:        7049eeeb839b59314d07c0bac250c89cf8ac78f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 17:13:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:51:39 2014 +0100

configure: option cleanup

Drop double [[ ]] around default args.
(AC_HELP_STRING is already quoted so double [[]] are not needed).
---
 configure.in |  111 ++++++++++++++++++++++++++-------------------------------
 1 files changed, 51 insertions(+), 60 deletions(-)

diff --git a/configure.in b/configure.in
index 3956ff0..8d47bc7 100644
--- a/configure.in
+++ b/configure.in
@@ -173,7 +173,7 @@ dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
 AC_ARG_WITH(user,
 	    AC_HELP_STRING([--with-user=USER],
-			   [set the owner of installed files [[USER=]]]),
+			   [set the owner of installed files [USER=]]),
 	    OWNER=$withval)
 AC_MSG_RESULT($OWNER)
 test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
@@ -183,7 +183,7 @@ dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
 AC_ARG_WITH(group,
 	    AC_HELP_STRING([--with-group=GROUP],
-			   [set the group owner of installed files [[GROUP=]]]),
+			   [set the group owner of installed files [GROUP=]]),
 	    GROUP=$withval)
 AC_MSG_RESULT($GROUP)
 test -n "$GROUP" && INSTALL="$INSTALL -g $GROUP"
@@ -194,7 +194,7 @@ AC_MSG_CHECKING(device node uid)
 
 AC_ARG_WITH(device-uid,
 	    AC_HELP_STRING([--with-device-uid=UID],
-			   [set the owner used for new device nodes [[UID=0]]]),
+			   [set the owner used for new device nodes [UID=0]]),
 	    DM_DEVICE_UID=$withval, DM_DEVICE_UID=0)
 AC_MSG_RESULT($DM_DEVICE_UID)
 
@@ -204,7 +204,7 @@ AC_MSG_CHECKING(device node gid)
 
 AC_ARG_WITH(device-gid,
 	    AC_HELP_STRING([--with-device-gid=GID],
-			   [set the group used for new device nodes [[GID=0]]]),
+			   [set the group used for new device nodes [GID=0]]),
 	    DM_DEVICE_GID=$withval, DM_DEVICE_GID=0)
 AC_MSG_RESULT($DM_DEVICE_GID)
 
@@ -214,14 +214,14 @@ AC_MSG_CHECKING(device node mode)
 
 AC_ARG_WITH(device-mode,
 	    AC_HELP_STRING([--with-device-mode=MODE],
-			   [set the mode used for new device nodes [[MODE=0600]]]),
+			   [set the mode used for new device nodes [MODE=0600]]),
 	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
 AC_MSG_RESULT($DM_DEVICE_MODE)
 
 AC_MSG_CHECKING(when to create device nodes)
 AC_ARG_WITH(device-nodes-on,
 	    AC_HELP_STRING([--with-device-nodes-on=ON],
-			   [create nodes on resume or create [[ON=resume]]]),
+			   [create nodes on resume or create [ON=resume]]),
 	    ADD_NODE=$withval, ADD_NODE=resume)
 case "$ADD_NODE" in
  resume) add_on=DM_ADD_NODE_ON_RESUME;;
@@ -234,7 +234,7 @@ AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation
 AC_MSG_CHECKING(default name mangling)
 AC_ARG_WITH(default-name-mangling,
 	    AC_HELP_STRING([--with-default-name-mangling=MANGLING],
-			   [default name mangling: auto/none/hex [[MANGLING=auto]]]),
+			   [default name mangling: auto/none/hex [auto]]),
 	    MANGLING=$withval, MANGLING=auto)
 case "$MANGLING" in
  auto) mangling=DM_STRING_MANGLING_AUTO;;
@@ -264,8 +264,7 @@ dnl -- format1 inclusion type
 AC_MSG_CHECKING(whether to include support for lvm1 metadata)
 AC_ARG_WITH(lvm1,
 	    AC_HELP_STRING([--with-lvm1=TYPE],
-			   [LVM1 metadata support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [LVM1 metadata support: internal/shared/none [internal]]),
 	    LVM1=$withval, LVM1=internal)
 
 AC_MSG_RESULT($LVM1)
@@ -282,8 +281,7 @@ dnl -- format_pool inclusion type
 AC_MSG_CHECKING(whether to include support for GFS pool metadata)
 AC_ARG_WITH(pool,
 	    AC_HELP_STRING([--with-pool=TYPE],
-			   [GFS pool read-only support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [GFS pool read-only support: internal/shared/none [internal]]),
 	    POOL=$withval, POOL=internal)
 AC_MSG_RESULT($POOL)
 
@@ -299,8 +297,7 @@ dnl -- cluster_locking inclusion type
 AC_MSG_CHECKING(whether to include support for cluster locking)
 AC_ARG_WITH(cluster,
 	    AC_HELP_STRING([--with-cluster=TYPE],
-			   [cluster LVM locking support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [cluster LVM locking support: internal/shared/none [internal]]),
 	    CLUSTER=$withval)
 AC_MSG_RESULT($CLUSTER)
 
@@ -316,8 +313,7 @@ dnl -- snapshots inclusion type
 AC_MSG_CHECKING(whether to include snapshots)
 AC_ARG_WITH(snapshots,
 	    AC_HELP_STRING([--with-snapshots=TYPE],
-			   [snapshot support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [snapshot support: internal/shared/none [internal]]),
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
 
@@ -333,8 +329,7 @@ dnl -- mirrors inclusion type
 AC_MSG_CHECKING(whether to include mirrors)
 AC_ARG_WITH(mirrors,
 	    AC_HELP_STRING([--with-mirrors=TYPE],
-			   [mirror support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [mirror support: internal/shared/none [internal]]),
 	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
 
@@ -350,8 +345,7 @@ dnl -- raid inclusion type
 AC_MSG_CHECKING(whether to include raid)
 AC_ARG_WITH(raid,
 	    AC_HELP_STRING([--with-raid=TYPE],
-			   [raid support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [raid support: internal/shared/none [internal]]),
 	    RAID=$withval, RAID=internal)
 AC_MSG_RESULT($RAID)
 
@@ -367,8 +361,7 @@ dnl -- asynchronous volume replicator inclusion type
 AC_MSG_CHECKING(whether to include replicators)
 AC_ARG_WITH(replicators,
 	    AC_HELP_STRING([--with-replicators=TYPE],
-			   [replicator support: internal/shared/none
-			    [[TYPE=none]]]),
+			   [replicator support: internal/shared/none [none]]),
 	    REPLICATORS=$withval, REPLICATORS=none)
 AC_MSG_RESULT($REPLICATORS)
 
@@ -384,24 +377,23 @@ dnl -- thin provisioning
 AC_MSG_CHECKING(whether to include thin provisioning)
 AC_ARG_WITH(thin,
 	    AC_HELP_STRING([--with-thin=TYPE],
-			   [thin provisioning support: internal/shared/none
-			    [[TYPE=internal]]]),
+			   [thin provisioning support: internal/shared/none [internal]]),
 	    THIN=$withval, THIN=internal)
 AC_ARG_WITH(thin-check,
 	    AC_HELP_STRING([--with-thin-check=PATH],
-			   [thin_check tool: [[autodetect]]]),
+			   [thin_check tool: [autodetect]]),
 			   THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="autodetect")
 AC_ARG_WITH(thin-dump,
 	    AC_HELP_STRING([--with-thin-dump=PATH],
-			   [thin_dump tool: [[autodetect]]]),
+			   [thin_dump tool: [autodetect]]),
 			   THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="autodetect")
 AC_ARG_WITH(thin-repair,
 	    AC_HELP_STRING([--with-thin-repair=PATH],
-			   [thin_repair tool: [[autodetect]]]),
+			   [thin_repair tool: [autodetect]]),
 			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
 AC_ARG_WITH(thin-restore,
 	    AC_HELP_STRING([--with-thin-restore=PATH],
-			   [thin_restore tool: [[autodetect]]]),
+			   [thin_restore tool: [autodetect]]),
 			   THIN_RESTORE_CMD=$withval, THIN_RESTORE_CMD="autodetect")
 
 AC_MSG_RESULT($THIN)
@@ -500,23 +492,23 @@ dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
 	    AC_HELP_STRING([--with-cache=TYPE],
-			   [cache support: internal/shared/none [[TYPE=internal]]]),
+			   [cache support: internal/shared/none [internal]]),
 			   CACHE=$withval, CACHE="internal")
 AC_ARG_WITH(cache-check,
 	    AC_HELP_STRING([--with-cache-check=PATH],
-			   [cache_check tool: [[autodetect]]]),
+			   [cache_check tool: [autodetect]]),
 			   CACHE_CHECK_CMD=$withval, CACHE_CHECK_CMD="autodetect")
 AC_ARG_WITH(cache-dump,
 	    AC_HELP_STRING([--with-cache-dump=PATH],
-			   [cache_dump tool: [[autodetect]]]),
+			   [cache_dump tool: [autodetect]]),
 			   CACHE_DUMP_CMD=$withval, CACHE_DUMP_CMD="autodetect")
 AC_ARG_WITH(cache-repair,
 	    AC_HELP_STRING([--with-cache-repair=PATH],
-			   [cache_repair tool: [[autodetect]]]),
+			   [cache_repair tool: [autodetect]]),
 			   CACHE_REPAIR_CMD=$withval, CACHE_REPAIR_CMD="autodetect")
 AC_ARG_WITH(cache-restore,
 	    AC_HELP_STRING([--with-cache-restore=PATH],
-			   [cache_restore tool: [[autodetect]]]),
+			   [cache_restore tool: [autodetect]]),
 			   CACHE_RESTORE_CMD=$withval, CACHE_RESTORE_CMD="autodetect")
 AC_MSG_RESULT($CACHE)
 
@@ -608,7 +600,7 @@ AC_ARG_ENABLE(ocf,
 AC_MSG_RESULT($OCF)
 AC_ARG_WITH(ocfdir,
 	    AC_HELP_STRING([--with-ocfdir=DIR],
-			   [install OCF files in DIR [[PREFIX/lib/ocf/resource.d/lvm2]]]),
+			   [install OCF files in [PREFIX/lib/ocf/resource.d/lvm2]]),
 	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
@@ -629,7 +621,7 @@ dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
 	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
-			   [Default directory to keep PID files in. [[/var/run]]]),
+			   [Default directory to keep PID files in. [/var/run]]),
 	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR="/var/run")
 AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 		   [Default directory to keep PID files in.])
@@ -637,7 +629,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
 AC_ARG_WITH(default-dm-run-dir,
 	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
-			   [ Default DM run directory. [[/var/run]]]),
+			   [ Default DM run directory. [/var/run]]),
 	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR="/var/run")
 AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 		   [Default DM run directory.])
@@ -645,7 +637,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
 AC_ARG_WITH(default-run-dir,
 	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
-			   [Default LVM run directory. [[/var/run/lvm]]]),
+			   [Default LVM run directory. [/var/run/lvm]]),
 	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="/var/run/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 		   [Default LVM run directory.])
@@ -661,7 +653,7 @@ AC_ARG_WITH(clvmd,
                            * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
-                          [[TYPE=none]]],
+                          [[none]]],
 	    CLVMD=$withval, CLVMD=none)
 test "$CLVMD" = yes && CLVMD=all
 AC_MSG_RESULT($CLVMD)
@@ -878,7 +870,7 @@ dnl -- clvmd pidfile
 if test "$CLVMD" != none; then
 	AC_ARG_WITH(clvmd-pidfile,
 		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
-				   [clvmd pidfile [[PID_DIR/clvmd.pid]]]),
+				   [clvmd pidfile [PID_DIR/clvmd.pid]]),
 		    CLVMD_PIDFILE=$withval,
 		    CLVMD_PIDFILE="$DEFAULT_PID_DIR/clvmd.pid")
 	AC_DEFINE_UNQUOTED(CLVMD_PIDFILE, ["$CLVMD_PIDFILE"],
@@ -901,7 +893,7 @@ dnl -- cmirrord pidfile
 if test "$BUILD_CMIRRORD" = yes; then
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
-				   [cmirrord pidfile [[PID_DIR/cmirrord.pid]]]),
+				   [cmirrord pidfile [PID_DIR/cmirrord.pid]]),
 		    CMIRRORD_PIDFILE=$withval,
 		    CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid")
 	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
@@ -948,7 +940,7 @@ dnl -- Override optimisation
 AC_MSG_CHECKING(for C optimisation flag)
 AC_ARG_WITH(optimisation,
 	    AC_HELP_STRING([--with-optimisation=OPT],
-			   [C optimisation flag [[OPT=-O2]]]),
+			   [C optimisation flag [OPT=-O2]]),
 	    COPTIMISE_FLAG=$withval)
 AC_MSG_RESULT($COPTIMISE_FLAG)
 
@@ -1040,7 +1032,7 @@ if test "$BUILD_LVMETAD" = yes; then
 
 	AC_ARG_WITH(lvmetad-pidfile,
 		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
-				   [lvmetad pidfile [[PID_DIR/lvmetad.pid]]]),
+				   [lvmetad pidfile [PID_DIR/lvmetad.pid]]),
 		    LVMETAD_PIDFILE=$withval,
 		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
 	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
@@ -1405,8 +1397,7 @@ if test "$INTL" = yes; then
 
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
-				   [translation files in DIR
-				    [[PREFIX/share/locale]]]),
+				   [translation files in DIR [PREFIX/share/locale]]),
 		    LOCALEDIR=$withval, LOCALEDIR='${prefix}/share/locale')
 fi
 
@@ -1414,33 +1405,33 @@ fi
 dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(confdir,
 	    AC_HELP_STRING([--with-confdir=DIR],
-			   [configuration files in DIR [[/etc]]]),
+			   [configuration files in DIR [/etc]]),
 	    CONFDIR=$withval, CONFDIR='/etc')
 
 AC_ARG_WITH(staticdir,
 	    AC_HELP_STRING([--with-staticdir=DIR],
-			   [static binaries in DIR [[EPREFIX/sbin]]]),
+			   [static binaries in DIR [EPREFIX/sbin]]),
 	    STATICDIR=$withval, STATICDIR='${exec_prefix}/sbin')
 
 AC_ARG_WITH(usrlibdir,
 	    AC_HELP_STRING([--with-usrlibdir=DIR],
-			   [usrlib in DIR [[PREFIX/lib]]]),
+			   [usrlib in DIR [PREFIX/lib]]),
 	    usrlibdir=$withval, usrlibdir='${prefix}/lib')
 
 AC_ARG_WITH(usrsbindir,
 	    AC_HELP_STRING([--with-usrsbindir=DIR],
-			   [usrsbin executables in DIR [[PREFIX/sbin]]]),
+			   [usrsbin executables in DIR [PREFIX/sbin]]),
 	    usrsbindir=$withval, usrsbindir='${prefix}/sbin')
 
 ################################################################################
 AC_ARG_WITH(udev_prefix,
 	    AC_HELP_STRING([--with-udev-prefix=UPREFIX],
-			   [install udev rule files in UPREFIX [[EPREFIX]]]),
+			   [install udev rule files in UPREFIX [EPREFIX]]),
 	    udev_prefix=$withval, udev_prefix='${exec_prefix}')
 
 AC_ARG_WITH(udevdir,
 	    AC_HELP_STRING([--with-udevdir=DIR],
-			   [udev rules in DIR [[UPREFIX/lib/udev/rules.d]]]),
+			   [udev rules in DIR [UPREFIX/lib/udev/rules.d]]),
 	    udevdir=$withval, udevdir='${udev_prefix}/lib/udev/rules.d')
 
 ################################################################################
@@ -1462,7 +1453,7 @@ test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
 	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
-			   [install configuration files for management of volatile files and directories in DIR [[PREFIX/lib/tmpfiles.d]]]),
+			   [install configuration files for management of volatile files and directories in DIR [PREFIX/lib/tmpfiles.d]]),
 			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
 dnl -- Ensure additional headers required
@@ -1524,7 +1515,7 @@ dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
 		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
-				   [dmeventd pidfile [[PID_DIR/dmeventd.pid]]]),
+				   [dmeventd pidfile [PID_DIR/dmeventd.pid]]),
 		    DMEVENTD_PIDFILE=$withval,
 		    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
@@ -1534,7 +1525,7 @@ fi
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-path,
 		    AC_HELP_STRING([--with-dmeventd-path=PATH],
-				   [dmeventd path [[EPREFIX/sbin/dmeventd]]]),
+				   [dmeventd path [EPREFIX/sbin/dmeventd]]),
 		    DMEVENTD_PATH=$withval,
 		    DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
@@ -1546,42 +1537,42 @@ dnl -- various defaults
 dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(default-system-dir,
 	    AC_HELP_STRING([--with-default-system-dir=DIR],
-			   [default LVM system directory [[/etc/lvm]]]),
+			   [default LVM system directory [/etc/lvm]]),
 	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="/etc/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 
 AC_ARG_WITH(default-profile-subdir,
 	    AC_HELP_STRING([--with-default-profile-subdir=SUBDIR],
-			   [default configuration profile subdir [[profile]]]),
+			   [default configuration profile subdir [profile]]),
 	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR=profile)
 AC_DEFINE_UNQUOTED(DEFAULT_PROFILE_SUBDIR, ["$DEFAULT_PROFILE_SUBDIR"],
 		   [Name of default configuration profile subdirectory.])
 
 AC_ARG_WITH(default-archive-subdir,
 	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
-			   [default metadata archive subdir [[archive]]]),
+			   [default metadata archive subdir [archive]]),
 	    DEFAULT_ARCHIVE_SUBDIR=$withval, DEFAULT_ARCHIVE_SUBDIR=archive)
 AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR, ["$DEFAULT_ARCHIVE_SUBDIR"],
 		   [Name of default metadata archive subdirectory.])
 
 AC_ARG_WITH(default-backup-subdir,
 	    AC_HELP_STRING([--with-default-backup-subdir=SUBDIR],
-			   [default metadata backup subdir [[backup]]]),
+			   [default metadata backup subdir [backup]]),
 	    DEFAULT_BACKUP_SUBDIR=$withval, DEFAULT_BACKUP_SUBDIR=backup)
 AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR, ["$DEFAULT_BACKUP_SUBDIR"],
                    [Name of default metadata backup subdirectory.])
 
 AC_ARG_WITH(default-cache-subdir,
 	    AC_HELP_STRING([--with-default-cache-subdir=SUBDIR],
-			   [default metadata cache subdir [[cache]]]),
+			   [default metadata cache subdir [cache]]),
 	    DEFAULT_CACHE_SUBDIR=$withval, DEFAULT_CACHE_SUBDIR=cache)
 AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
 		   [Name of default metadata cache subdirectory.])
 
 AC_ARG_WITH(default-locking-dir,
 	    AC_HELP_STRING([--with-default-locking-dir=DIR],
-			   [default locking directory [[/var/lock/lvm]]]),
+			   [default locking directory [/var/lock/lvm]]),
 	    DEFAULT_LOCK_DIR=$withval, DEFAULT_LOCK_DIR="/var/lock/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
@@ -1590,7 +1581,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 dnl -- Setup default data alignment
 AC_ARG_WITH(default-data-alignment,
 	    AC_HELP_STRING([--with-default-data-alignment=NUM],
-			   [set the default data alignment in MiB [[1]]]),
+			   [set the default data alignment in MiB [1]]),
 	    DEFAULT_DATA_ALIGNMENT=$withval, DEFAULT_DATA_ALIGNMENT=1)
 AC_DEFINE_UNQUOTED(DEFAULT_DATA_ALIGNMENT, [$DEFAULT_DATA_ALIGNMENT],
 		   [Default data alignment.])
@@ -1600,7 +1591,7 @@ dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
 	    AC_HELP_STRING([--with-interface=IFACE],
-			   [choose kernel interface (ioctl) [[ioctl]]]),
+			   [choose kernel interface (ioctl) [ioctl]]),
 	    interface=$withval, interface=ioctl)
 test "$interface" != ioctl && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])
 AC_MSG_RESULT($interface)


