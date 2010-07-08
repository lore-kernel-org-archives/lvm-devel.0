From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 12:02:50 -0000
Subject: LVM2 configure.in configure
Message-ID: <20100708120250.23525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 12:02:49

Modified files:
	.              : configure.in configure 

Log message:
	Cleanups for configure:
	Indent updates.
	Use AC_HELP_STRING for help string.
	Start help string with lower letter.
	Add [] around some default values i.e. [TYPE=internal].
	Skip some "" around shell assigment when not needed.
	Fix typo --with-device-gid=UID string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/configure.in	2010/07/05 22:23:15	1.144
+++ LVM2/configure.in	2010/07/08 12:02:48	1.145
@@ -148,9 +148,10 @@
 dnl -- Enables statically-linked tools
 AC_MSG_CHECKING(whether to use static linking)
 AC_ARG_ENABLE(static_link,
-  [  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking],
-  STATIC_LINK=$enableval, STATIC_LINK=no)
+	      AC_HELP_STRING([--enable-static_link],
+			     [use this to link the tools to their libraries
+			      statically (default is dynamic linking]),
+	      STATIC_LINK=$enableval, STATIC_LINK=no)
 AC_MSG_RESULT($STATIC_LINK)
 
 ################################################################################
@@ -161,8 +162,9 @@
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
 AC_ARG_WITH(user,
-  [  --with-user=USER        Set the owner of installed files [[USER=]] ],
-  [ OWNER="$withval" ])
+	    AC_HELP_STRING([--with-user=USER],
+			   [set the owner of installed files [[USER=]]]),
+	    OWNER=$withval)
 AC_MSG_RESULT($OWNER)
 
 if test x$OWNER != x; then
@@ -173,8 +175,9 @@
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
 AC_ARG_WITH(group,
-  [  --with-group=GROUP      Set the group owner of installed files [[GROUP=]] ],
-  [ GROUP="$withval" ])
+	    AC_HELP_STRING([--with-group=GROUP],
+			   [set the group owner of installed files [[GROUP=]]]),
+	    GROUP=$withval)
 AC_MSG_RESULT($GROUP)
 
 if test x$GROUP != x; then
@@ -186,8 +189,9 @@
 AC_MSG_CHECKING(device node uid)
 
 AC_ARG_WITH(device-uid,
-  [  --with-device-uid=UID   Set the owner used for new device nodes [[UID=0]] ],
-  [ DM_DEVICE_UID="$withval" ], [ DM_DEVICE_UID="0" ] )
+	    AC_HELP_STRING([--with-device-uid=UID],
+			   [set the owner used for new device nodes [[UID=0]]]),
+	    DM_DEVICE_UID=$withval, DM_DEVICE_UID=0)
 AC_MSG_RESULT($DM_DEVICE_UID)
 
 ################################################################################
@@ -195,8 +199,9 @@
 AC_MSG_CHECKING(device node gid)
 
 AC_ARG_WITH(device-gid,
-  [  --with-device-gid=UID   Set the group used for new device nodes [[GID=0]] ],
-  [ DM_DEVICE_GID="$withval" ], [ DM_DEVICE_GID="0" ] )
+	    AC_HELP_STRING([--with-device-gid=GID],
+			   [set the group used for new device nodes [[GID=0]]]),
+	    DM_DEVICE_GID=$withval, DM_DEVICE_GID=0)
 AC_MSG_RESULT($DM_DEVICE_GID)
 
 ################################################################################
@@ -204,15 +209,19 @@
 AC_MSG_CHECKING(device node mode)
 
 AC_ARG_WITH(device-mode,
-  [  --with-device-mode=MODE Set the mode used for new device nodes [[MODE=0600]] ],
-  [ DM_DEVICE_MODE="$withval" ], [ DM_DEVICE_MODE="0600" ] )
+	    AC_HELP_STRING([--with-device-mode=MODE],
+			   [set the mode used for new device nodes [[MODE=0600]]]),
+	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
 AC_MSG_RESULT($DM_DEVICE_MODE)
 
 ################################################################################
 dnl -- LVM1 tool fallback option
 AC_MSG_CHECKING(whether to enable lvm1 fallback)
-AC_ARG_ENABLE(lvm1_fallback, [  --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
-                          device-mapper is missing from the kernel],  LVM1_FALLBACK=$enableval, LVM1_FALLBACK=no)
+AC_ARG_ENABLE(lvm1_fallback,
+	      AC_HELP_STRING([--enable-lvm1_fallback],
+			     [use this to fall back and use LVM1 binaries if
+			      device-mapper is missing from the kernel]),
+	      LVM1_FALLBACK=$enableval, LVM1_FALLBACK=no)
 AC_MSG_RESULT($LVM1_FALLBACK)
 
 if test x$LVM1_FALLBACK = xyes; then
@@ -223,10 +232,10 @@
 dnl -- format1 inclusion type
 AC_MSG_CHECKING(whether to include support for lvm1 metadata)
 AC_ARG_WITH(lvm1,
-  [  --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
-                          [TYPE=internal] ],
-  [ LVM1="$withval" ],
-  [ LVM1="internal" ])
+	    AC_HELP_STRING([--with-lvm1=TYPE],
+			   [LVM1 metadata support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    LVM1=$withval, LVM1=internal)
 AC_MSG_RESULT($LVM1)
 
 if [[ "x$LVM1" != xnone -a "x$LVM1" != xinternal -a "x$LVM1" != xshared ]];
@@ -243,10 +252,10 @@
 dnl -- format_pool inclusion type
 AC_MSG_CHECKING(whether to include support for GFS pool metadata)
 AC_ARG_WITH(pool,
-  [  --with-pool=TYPE        GFS pool read-only support: internal/shared/none
-                          [TYPE=internal] ],
-  [ POOL="$withval" ],
-  [ POOL="internal" ])
+	    AC_HELP_STRING([--with-pool=TYPE],
+			   [GFS pool read-only support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    POOL=$withval, POOL=internal)
 AC_MSG_RESULT($POOL)
 
 if [[ "x$POOL" != xnone -a "x$POOL" != xinternal -a "x$POOL" != xshared ]];
@@ -263,9 +272,10 @@
 dnl -- cluster_locking inclusion type
 AC_MSG_CHECKING(whether to include support for cluster locking)
 AC_ARG_WITH(cluster,
-  [  --with-cluster=TYPE     Cluster LVM locking support: internal/shared/none
-                          [TYPE=internal] ],
-  [ CLUSTER="$withval" ])
+	    AC_HELP_STRING([--with-cluster=TYPE],
+			   [cluster LVM locking support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    CLUSTER=$withval)
 AC_MSG_RESULT($CLUSTER)
 
 if [[ "x$CLUSTER" != xnone -a "x$CLUSTER" != xinternal -a "x$CLUSTER" != xshared ]];
@@ -282,10 +292,10 @@
 dnl -- snapshots inclusion type
 AC_MSG_CHECKING(whether to include snapshots)
 AC_ARG_WITH(snapshots,
-  [  --with-snapshots=TYPE   Snapshot support: internal/shared/none
-                          [TYPE=internal] ],
-  [ SNAPSHOTS="$withval" ],
-  [ SNAPSHOTS="internal" ])
+	    AC_HELP_STRING([--with-snapshots=TYPE],
+			   [snapshot support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
 
 if [[ "x$SNAPSHOTS" != xnone -a "x$SNAPSHOTS" != xinternal -a "x$SNAPSHOTS" != xshared ]];
@@ -302,10 +312,10 @@
 dnl -- mirrors inclusion type
 AC_MSG_CHECKING(whether to include mirrors)
 AC_ARG_WITH(mirrors,
-  [  --with-mirrors=TYPE     Mirror support: internal/shared/none
-                          [TYPE=internal] ],
-  [ MIRRORS="$withval" ],
-  [ MIRRORS="internal" ])
+	    AC_HELP_STRING([--with-mirrors=TYPE],
+			   [mirror support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
 
 if [[ "x$MIRRORS" != xnone -a "x$MIRRORS" != xinternal -a "x$MIRRORS" != xshared ]];
@@ -321,9 +331,11 @@
 ################################################################################
 dnl -- asynchronous volume replicator inclusion type
 AC_MSG_CHECKING(whether to include replicators)
-AC_ARG_WITH(replicators, AC_HELP_STRING([--with-replicators=TYPE],
-	[Replicator support: internal/shared/none [TYPE=none] ]),
-	[REPLICATORS=$withval], [REPLICATORS="none"])
+AC_ARG_WITH(replicators,
+	    AC_HELP_STRING([--with-replicators=TYPE],
+			   [replicator support: internal/shared/none
+			    [[TYPE=none]]]),
+	    REPLICATORS=$withval, REPLICATORS=none)
 AC_MSG_RESULT($REPLICATORS)
 
 case "$REPLICATORS" in
@@ -337,15 +349,16 @@
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
-  [  --disable-readline      Disable readline support],
-  [READLINE=$enableval], [READLINE=maybe])
+	      AC_HELP_STRING([--disable-readline], [disable readline support]),
+	      READLINE=$enableval, READLINE=maybe)
 AC_MSG_RESULT($READLINE)
 
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
-AC_ARG_ENABLE(realtime, [  --enable-realtime       Enable realtime clock support],
-REALTIME=$enableval)
+AC_ARG_ENABLE(realtime,
+	      AC_HELP_STRING([--enable-realtime], [enable realtime clock support]),
+	      REALTIME=$enableval)
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
@@ -363,7 +376,7 @@
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
-  [  --with-clvmd=TYPE       Build cluster LVM Daemon.
+  [  --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
@@ -371,9 +384,8 @@
                            * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
-                          [TYPE=none] ],
-  [ CLVMD="$withval" ],
-  [ CLVMD="none" ])
+                          [[TYPE=none]]],
+	    CLVMD=$withval, CLVMD=none)
 if test x$CLVMD = xyes; then
 	CLVMD=all
 fi
@@ -591,20 +603,24 @@
 ################################################################################
 dnl -- Build cluster mirror log daemon
 AC_MSG_CHECKING(whether to build cluster mirror log daemon)
-AC_ARG_ENABLE(cmirrord, [  --enable-cmirrord       Enable the cluster mirror log daemon],
-CMIRRORD=$enableval, CMIRRORD=no)
+AC_ARG_ENABLE(cmirrord,
+	      AC_HELP_STRING([--enable-cmirrord],
+			     [enable the cluster mirror log daemon]),
+	      CMIRRORD=$enableval, CMIRRORD=no)
 AC_MSG_RESULT($CMIRRORD)
 
 BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
 dnl -- cmirrord pidfile
-AH_TEMPLATE(CMIRRORD_PIDFILE, [Path to cmirrord pidfile.])
 if test "x$BUILD_CMIRRORD" = xyes; then
 	AC_ARG_WITH(cmirrord-pidfile,
-		    [  --with-cmirrord-pidfile=PATH    cmirrord pidfile [[/var/run/cmirrord.pid]] ],
-		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"$withval") ],
-		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"/var/run/cmirrord.pid") ])
+		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
+				   [cmirrord pidfile [[/var/run/cmirrord.pid]]]),
+		    CMIRRORD_PIDFILE=$withval,
+		    CMIRRORD_PIDFILE="/var/run/cmirrord.pid")
+	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
+			   [Path to cmirrord pidfile.])
 fi
 
 ################################################################################
@@ -623,8 +639,8 @@
 ################################################################################
 dnl -- Enable debugging
 AC_MSG_CHECKING(whether to enable debugging)
-AC_ARG_ENABLE(debug,    [  --enable-debug          Enable debugging],
-  DEBUG=$enableval, DEBUG=no)
+AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug], [enable debugging]),
+	      DEBUG=$enableval, DEBUG=no)
 AC_MSG_RESULT($DEBUG)
 
 dnl -- Normally turn off optimisation for debug builds
@@ -638,16 +654,17 @@
 dnl -- Override optimisation
 AC_MSG_CHECKING(for C optimisation flag)
 AC_ARG_WITH(optimisation,
-  [  --with-optimisation=OPT C optimisation flag [[OPT=-O2]] ],
-  [ COPTIMISE_FLAG="$withval" ])
+	    AC_HELP_STRING([--with-optimisation=OPT],
+			   [C optimisation flag [[OPT=-O2]]]),
+	    COPTIMISE_FLAG=$withval)
 AC_MSG_RESULT($COPTIMISE_FLAG)
 
 ################################################################################
 dnl -- Enable profiling
 AC_MSG_CHECKING(whether to gather gcov profiling data)
 AC_ARG_ENABLE(profiling,
-  AC_HELP_STRING(--enable-profiling, [Gather gcov profiling data]),
-  PROFILING=$enableval, PROFILING=no)
+	      AC_HELP_STRING(--enable-profiling, [gather gcov profiling data]),
+	      PROFILING=$enableval, PROFILING=no)
 AC_MSG_RESULT($PROFILING)
 
 if test "x$PROFILING" = xyes; then
@@ -674,8 +691,10 @@
 ################################################################################
 dnl -- Disable devmapper
 AC_MSG_CHECKING(whether to use device-mapper)
-AC_ARG_ENABLE(devmapper, [  --disable-devmapper     Disable LVM2 device-mapper interaction],
-DEVMAPPER=$enableval)
+AC_ARG_ENABLE(devmapper,
+	      AC_HELP_STRING([--disable-devmapper],
+			     [disable LVM2 device-mapper interaction]),
+	      DEVMAPPER=$enableval)
 AC_MSG_RESULT($DEVMAPPER)
 
 if test x$DEVMAPPER = xyes; then
@@ -685,8 +704,10 @@
 ################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
-AC_ARG_ENABLE(udev_sync, [  --enable-udev_sync      Enable synchronisation with udev processing],
-UDEV_SYNC=$enableval, UDEV_SYNC=no)
+AC_ARG_ENABLE(udev_sync,
+	      AC_HELP_STRING([--enable-udev_sync], 
+			     [enable synchronisation with udev processing]),
+	      UDEV_SYNC=$enableval, UDEV_SYNC=no)
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
@@ -698,21 +719,26 @@
 
 dnl -- Enable udev rules
 AC_MSG_CHECKING(whether to enable installation of udev rules required for synchronisation)
-AC_ARG_ENABLE(udev_rules, [  --enable-udev_rules     Install rule files needed for udev synchronisation],
-UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
+AC_ARG_ENABLE(udev_rules,
+	      AC_HELP_STRING([--enable-udev_rules],
+			     [install rule files needed for udev synchronisation]),
+	      UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
 AC_MSG_RESULT($UDEV_RULES)
 
 ################################################################################
 dnl -- Compatibility mode
-AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
-  DM_COMPAT=$enableval, DM_COMPAT=no)
+AC_ARG_ENABLE(compat,
+	      AC_HELP_STRING([--enable-compat],
+			     [enable support for old device-mapper versions]),
+	      DM_COMPAT=$enableval, DM_COMPAT=no)
 
 ################################################################################
 dnl -- Compatible units suffix mode
 AC_ARG_ENABLE(units-compat,
-  [  --enable-units-compat   Enable output compatibility with old versions that
-                          that don't use KiB-style unit suffixes],
-  UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
+	      AC_HELP_STRING([--enable-units-compat],
+			     [enable output compatibility with old versions that
+			      that do not use KiB-style unit suffixes]),
+	      UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
 
 if test x$UNITS_COMPAT = xyes; then
 	AC_DEFINE([DEFAULT_SI_UNIT_CONSISTENCY], 0, [Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes.])
@@ -720,14 +746,17 @@
 
 ################################################################################
 dnl -- Disable ioctl
-AC_ARG_ENABLE(ioctl,   [  --disable-driver        Disable calls to device-mapper in the kernel],
-  DM_IOCTLS=$enableval)
+AC_ARG_ENABLE(ioctl,
+	      AC_HELP_STRING([--disable-driver],
+			     [disable calls to device-mapper in the kernel]),
+	      DM_IOCTLS=$enableval)
 
 ################################################################################
 dnl -- Disable O_DIRECT
 AC_MSG_CHECKING(whether to enable O_DIRECT)
-AC_ARG_ENABLE(o_direct, [  --disable-o_direct      Disable O_DIRECT],
-ODIRECT=$enableval)
+AC_ARG_ENABLE(o_direct,
+	      AC_HELP_STRING([--disable-o_direct], [disable O_DIRECT]),
+	      ODIRECT=$enableval)
 AC_MSG_RESULT($ODIRECT)
 
 if test x$ODIRECT = xyes; then
@@ -738,8 +767,8 @@
 dnl -- Enable liblvm2app.so
 AC_MSG_CHECKING(whether to build liblvm2app.so application library)
 AC_ARG_ENABLE(applib,
-  [  --enable-applib         Build application library],
-  APPLIB=$enableval, APPLIB=no)
+	      AC_HELP_STRING([--enable-applib], [build application library]),
+	      APPLIB=$enableval, APPLIB=no)
 AC_MSG_RESULT($APPLIB)
 AC_SUBST([LVM2APP_LIB])
 test x$APPLIB = xyes \
@@ -749,8 +778,9 @@
 ################################################################################
 dnl -- Enable cmdlib
 AC_MSG_CHECKING(whether to compile liblvm2cmd.so)
-AC_ARG_ENABLE(cmdlib, [  --enable-cmdlib         Build shared command library],
-CMDLIB=$enableval, CMDLIB=no)
+AC_ARG_ENABLE(cmdlib,
+	      AC_HELP_STRING([--enable-cmdlib], [build shared command library]),
+	      CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
 AC_SUBST([LVM2CMD_LIB])
 test x$CMDLIB = xyes \
@@ -759,27 +789,30 @@
 
 ################################################################################
 dnl -- Enable pkg-config
-AC_ARG_ENABLE(pkgconfig,   [  --enable-pkgconfig      Install pkgconfig support],
-  PKGCONFIG=$enableval, PKGCONFIG=no)
+AC_ARG_ENABLE(pkgconfig,
+	      AC_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
+	      PKGCONFIG=$enableval, PKGCONFIG=no)
 
 ################################################################################
 dnl -- Enable installation of writable files by user
-AC_ARG_ENABLE(write_install, AC_HELP_STRING([--enable-write_install],
-	[Install user writable files]), 
-	[WRITE_INSTALL=$enableval], [WRITE_INSTALL=no])
+AC_ARG_ENABLE(write_install,
+	      AC_HELP_STRING([--enable-write_install],
+			     [install user writable files]),
+	      WRITE_INSTALL=$enableval, WRITE_INSTALL=no)
 
 ################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
-AC_ARG_ENABLE(fsadm, [AC_HELP_STRING([--disable-fsadm], [Disable fsadm])],
-	FSADM=$enableval)
+AC_ARG_ENABLE(fsadm, AC_HELP_STRING([--disable-fsadm], [disable fsadm]),
+	      FSADM=$enableval)
 AC_MSG_RESULT($FSADM)
 
 ################################################################################
 dnl -- enable dmeventd handling
 AC_MSG_CHECKING(whether to use dmeventd)
-AC_ARG_ENABLE(dmeventd, [  --enable-dmeventd       Enable the device-mapper event daemon],
-DMEVENTD=$enableval)
+AC_ARG_ENABLE(dmeventd, AC_HELP_STRING([--enable-dmeventd],
+				       [enable the device-mapper event daemon]),
+	      DMEVENTD=$enableval)
 AC_MSG_RESULT($DMEVENTD)
 
 BUILD_DMEVENTD=$DMEVENTD
@@ -849,8 +882,9 @@
 ################################################################################
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
-AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
-  SELINUX=$enableval)
+AC_ARG_ENABLE(selinux,
+	      AC_HELP_STRING([--disable-selinux], [disable selinux support]),
+	      SELINUX=$enableval)
 AC_MSG_RESULT($SELINUX)
 
 ################################################################################
@@ -935,8 +969,9 @@
 ################################################################################
 dnl -- Internationalisation stuff
 AC_MSG_CHECKING(whether to enable internationalisation)
-AC_ARG_ENABLE(nls, [  --enable-nls            Enable Native Language Support],
-		INTL=$enableval, INTL=no)
+AC_ARG_ENABLE(nls,
+	      AC_HELP_STRING([--enable-nls], [enable Native Language Support]),
+	      INTL=$enableval, INTL=no)
 AC_MSG_RESULT($INTL)
 
 if test x$INTL = xyes; then
@@ -950,42 +985,43 @@
 	fi;
 
 	AC_ARG_WITH(localedir,
-		    [  --with-localedir=DIR    Translation files in DIR [[PREFIX/share/locale]] ],
-		    [ LOCALEDIR="$withval" ],
-		    [ LOCALEDIR='${prefix}/share/locale' ])
+		    AC_HELP_STRING([--with-localedir=DIR],
+				   [translation files in DIR
+				    [[PREFIX/share/locale]]]),
+		    LOCALEDIR=$withval, LOCALEDIR='${prefix}/share/locale')
 fi
 
 ################################################################################
 AC_ARG_WITH(confdir,
-	    [  --with-confdir=DIR      Configuration files in DIR [[/etc]]],
-	    [ CONFDIR="$withval" ],
-	    [ CONFDIR='/etc' ])
+	    AC_HELP_STRING([--with-confdir=DIR],
+			   [configuration files in DIR [[/etc]]]),
+	    CONFDIR=$withval, CONFDIR="/etc")
 
 AC_ARG_WITH(staticdir,
-	    [  --with-staticdir=DIR    Static binary in DIR [[EPREFIX/sbin]]],
-	    [ STATICDIR="$withval" ],
-	    [ STATICDIR='${exec_prefix}/sbin' ])
+	    AC_HELP_STRING([--with-staticdir=DIR],
+			   [static binaries in DIR [[EPREFIX/sbin]]]),
+	    STATICDIR=$withval, STATICDIR='${exec_prefix}/sbin')
 
 AC_ARG_WITH(usrlibdir,
-	    [  --with-usrlibdir=DIR],
-	    [ usrlibdir="$withval"],
-	    [ usrlibdir='${prefix}/lib' ])
+	    AC_HELP_STRING([--with-usrlibdir=DIR],
+			   [usrlib in DIR [[PREFIX/lib]]]),
+	    usrlibdir=$withval, usrlibdir='${prefix}/lib')
 
 AC_ARG_WITH(usrsbindir,
-	    [  --with-usrsbindir=DIR],
-	    [ usrsbindir="$withval"],
-	    [ usrsbindir='${prefix}/sbin' ])
+	    AC_HELP_STRING([--with-usrsbindir=DIR],
+			   [usrsbin executables in DIR [[PREFIX/sbin]]]),
+	    usrsbindir=$withval, usrsbindir='${prefix}/sbin')
 
 ################################################################################
 AC_ARG_WITH(udev_prefix,
-	    [  --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [[EPREFIX]]],
-            [ udev_prefix="$withval"],
-            [ udev_prefix='${exec_prefix}' ])
+	    AC_HELP_STRING([--with-udev-prefix=UPREFIX],
+			   [install udev rule files in UPREFIX [[EPREFIX]]]),
+	    udev_prefix=$withval, udev_prefix='${exec_prefix}')
 
 AC_ARG_WITH(udevdir,
-	    [  --with-udevdir=DIR      udev rules in DIR [[UPREFIX/lib/udev/rules.d]]],
-	    [ udevdir="$withval"],
-	    [ udevdir='${udev_prefix}/lib/udev/rules.d' ])
+	    AC_HELP_STRING([--with-udevdir=DIR],
+			   [udev rules in DIR [[UPREFIX/lib/udev/rules.d]]]),
+	    udevdir=$withval, udevdir='${udev_prefix}/lib/udev/rules.d')
 
 ################################################################################
 dnl -- Ensure additional headers required
@@ -1037,71 +1073,76 @@
 if  test "$CLVMD" != none; then
         clvmd_prefix=$ac_default_prefix
         test "$prefix" != NONE && clvmd_prefix=$prefix
-	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$clvmd_prefix/sbin/clvmd"], [Path to clvmd binary.])
+	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$clvmd_prefix/sbin/clvmd"],
+			   [Path to clvmd binary.])
 fi
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
-AH_TEMPLATE(DMEVENTD_PIDFILE, [Path to dmeventd pidfile.])
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
-		    [  --with-dmeventd-pidfile=PATH    dmeventd pidfile [[/var/run/dmeventd.pid]] ],
-		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE,"$withval") ],
-		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE,"/var/run/dmeventd.pid") ])
+		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
+				   [dmeventd pidfile [[/var/run/dmeventd.pid]]]),
+		    DMEVENTD_PIDFILE=$withval,
+		    DMEVENTD_PIDFILE="/var/run/dmeventd.pid")
+	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
+			   [Path to dmeventd pidfile.])
 fi
 
-AH_TEMPLATE(DMEVENTD_PATH, [Path to dmeventd binary.])
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-path,
-		    [  --with-dmeventd-path=PATH       dmeventd path [[EPREFIX/sbin/dmeventd]] ],
-		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$withval") ],
-		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$lvm_exec_prefix/sbin/dmeventd") ])
+		    AC_HELP_STRING([--with-dmeventd-path=PATH],
+				   [dmeventd path [[EPREFIX/sbin/dmeventd]]]),
+		    DMEVENTD_PATH=$withval,
+		    DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd")
+	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
+			   [Path to dmeventd binary.])
 fi
 
 ################################################################################
 dnl -- various defaults
-AH_TEMPLATE(DEFAULT_SYS_DIR, [Path to LVM system directory.])
 AC_ARG_WITH(default-system-dir,
-	    [  --with-default-system-dir=DIR        Default LVM system directory [[/etc/lvm]] ],
-	    [ DEFAULT_SYS_DIR="$withval" ],
-	    [ DEFAULT_SYS_DIR="/etc/lvm" ])
-AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR,["$DEFAULT_SYS_DIR"] )
+	    AC_HELP_STRING([--with-default-system-dir=DIR],
+			   [default LVM system directory [[/etc/lvm]]]),
+	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="/etc/lvm")
+AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
+		   [Path to LVM system directory.])
 
-AH_TEMPLATE(DEFAULT_ARCHIVE_SUBDIR, [Name of default metadata archive subdirectory.])
 AC_ARG_WITH(default-archive-subdir,
-	    [  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [[archive]] ],
-	    [ DEFAULT_ARCHIVE_SUBDIR="$withval" ],
-	    [ DEFAULT_ARCHIVE_SUBDIR="archive" ])
-AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR,["$DEFAULT_ARCHIVE_SUBDIR"])
+	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
+			   [default metadata archive subdir [[archive]]]),
+	    DEFAULT_ARCHIVE_SUBDIR=$withval, DEFAULT_ARCHIVE_SUBDIR=archive)
+AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR, ["$DEFAULT_ARCHIVE_SUBDIR"],
+		   [Name of default metadata archive subdirectory.])
 
-AH_TEMPLATE(DEFAULT_BACKUP_SUBDIR, [Name of default metadata backup subdirectory.])
 AC_ARG_WITH(default-backup-subdir,
-	    [  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [[backup]] ],
-	    [ DEFAULT_BACKUP_SUBDIR="$withval" ],
-	    [ DEFAULT_BACKUP_SUBDIR="backup" ])
-AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR,["$DEFAULT_BACKUP_SUBDIR"] )
+	    AC_HELP_STRING([--with-default-backup-subdir=SUBDIR],
+			   [default metadata backup subdir [[backup]]]),
+	    DEFAULT_BACKUP_SUBDIR=$withval, DEFAULT_BACKUP_SUBDIR=backup)
+AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR, ["$DEFAULT_BACKUP_SUBDIR"],
+                   [Name of default metadata backup subdirectory.])
 
-AH_TEMPLATE(DEFAULT_CACHE_SUBDIR, [Name of default metadata cache subdirectory.])
 AC_ARG_WITH(default-cache-subdir,
-	    [  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [[cache]] ],
-	    [ DEFAULT_CACHE_SUBDIR="$withval" ],
-	    [ DEFAULT_CACHE_SUBDIR="cache" ])
-AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR,["$DEFAULT_CACHE_SUBDIR"] )
+	    AC_HELP_STRING([--with-default-cache-subdir=SUBDIR],
+			   [default metadata cache subdir [[cache]]]),
+	    DEFAULT_CACHE_SUBDIR=$withval, DEFAULT_CACHE_SUBDIR=cache)
+AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
+		   [Name of default metadata cache subdirectory.])
 
-AH_TEMPLATE(DEFAULT_LOCK_DIR, [Name of default locking directory.])
 AC_ARG_WITH(default-locking-dir,
-	    [  --with-default-locking-dir=DIR       Default locking directory [[/var/lock/lvm]] ],
-	    [ DEFAULT_LOCK_DIR="$withval" ],
-	    [ DEFAULT_LOCK_DIR="/var/lock/lvm" ])
-AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR,["$DEFAULT_LOCK_DIR"] )
+	    AC_HELP_STRING([--with-default-locking-dir=DIR],
+			   [default locking directory [[/var/lock/lvm]]]),
+	    DEFAULT_LOCK_DIR=$withval, DEFAULT_LOCK_DIR="/var/lock/lvm")
+AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
+		   [Name of default locking directory.])
 
 ################################################################################
 dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
-  [  --with-interface=IFACE  Choose kernel interface (ioctl) [[ioctl]] ],
-  [ interface="$withval" ],
-  [ interface=ioctl ])
+	    AC_HELP_STRING([--with-interface=IFACE],
+			   [choose kernel interface (ioctl) [[ioctl]]]),
+	    interface=$withval, interface=ioctl)
 if [[ "x$interface" != xioctl ]];
 then
   AC_MSG_ERROR(--with-interface=ioctl required. fs no longer supported.)
--- LVM2/configure	2010/07/05 22:23:15	1.133
+++ LVM2/configure	2010/07/08 12:02:48	1.134
@@ -736,6 +736,8 @@
 CCS_CFLAGS
 PKGCONFIGINIT_LIBS
 PKGCONFIGINIT_CFLAGS
+PKG_CONFIG_LIBDIR
+PKG_CONFIG_PATH
 PKG_CONFIG
 POW_LIB
 LIBOBJS
@@ -875,6 +877,8 @@
 CPPFLAGS
 CPP
 PKG_CONFIG
+PKG_CONFIG_PATH
+PKG_CONFIG_LIBDIR
 PKGCONFIGINIT_CFLAGS
 PKGCONFIGINIT_LIBS
 CCS_CFLAGS
@@ -1521,52 +1525,53 @@
   --disable-option-checking  ignore unrecognized --enable/--with options
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
-  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking
-  --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
+  --enable-static_link    use this to link the tools to their libraries
+                          statically (default is dynamic linking
+  --enable-lvm1_fallback  use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
-  --disable-readline      Disable readline support
-  --enable-realtime       Enable realtime clock support
-  --enable-cmirrord       Enable the cluster mirror log daemon
-  --enable-debug          Enable debugging
-  --enable-profiling      Gather gcov profiling data
-  --disable-devmapper     Disable LVM2 device-mapper interaction
-  --enable-udev_sync      Enable synchronisation with udev processing
-  --enable-udev_rules     Install rule files needed for udev synchronisation
-  --enable-compat         Enable support for old device-mapper versions
-  --enable-units-compat   Enable output compatibility with old versions that
-                          that don't use KiB-style unit suffixes
-  --disable-driver        Disable calls to device-mapper in the kernel
-  --disable-o_direct      Disable O_DIRECT
-  --enable-applib         Build application library
-  --enable-cmdlib         Build shared command library
-  --enable-pkgconfig      Install pkgconfig support
-  --enable-write_install  Install user writable files
-  --disable-fsadm         Disable fsadm
-  --enable-dmeventd       Enable the device-mapper event daemon
-  --disable-selinux       Disable selinux support
-  --enable-nls            Enable Native Language Support
+  --disable-readline      disable readline support
+  --enable-realtime       enable realtime clock support
+  --enable-cmirrord       enable the cluster mirror log daemon
+  --enable-debug          enable debugging
+  --enable-profiling      gather gcov profiling data
+  --disable-devmapper     disable LVM2 device-mapper interaction
+  --enable-udev_sync      enable synchronisation with udev processing
+  --enable-udev_rules     install rule files needed for udev synchronisation
+  --enable-compat         enable support for old device-mapper versions
+  --enable-units-compat   enable output compatibility with old versions that
+                          that do not use KiB-style unit suffixes
+  --disable-driver        disable calls to device-mapper in the kernel
+  --disable-o_direct      disable O_DIRECT
+  --enable-applib         build application library
+  --enable-cmdlib         build shared command library
+  --enable-pkgconfig      install pkgconfig support
+  --enable-write_install  install user writable files
+  --disable-fsadm         disable fsadm
+  --enable-dmeventd       enable the device-mapper event daemon
+  --disable-selinux       disable selinux support
+  --enable-nls            enable Native Language Support
 
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
-  --with-user=USER        Set the owner of installed files [USER=]
-  --with-group=GROUP      Set the group owner of installed files [GROUP=]
-  --with-device-uid=UID   Set the owner used for new device nodes [UID=0]
-  --with-device-gid=UID   Set the group used for new device nodes [GID=0]
-  --with-device-mode=MODE Set the mode used for new device nodes [MODE=0600]
+  --with-user=USER        set the owner of installed files [USER=]
+  --with-group=GROUP      set the group owner of installed files [GROUP=]
+  --with-device-uid=UID   set the owner used for new device nodes [UID=0]
+  --with-device-gid=GID   set the group used for new device nodes [GID=0]
+  --with-device-mode=MODE set the mode used for new device nodes [MODE=0600]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
-                          TYPE=internal
+                          [TYPE=internal]
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
-                          TYPE=internal
-  --with-cluster=TYPE     Cluster LVM locking support: internal/shared/none
-                          TYPE=internal
-  --with-snapshots=TYPE   Snapshot support: internal/shared/none
-                          TYPE=internal
-  --with-mirrors=TYPE     Mirror support: internal/shared/none
-                          TYPE=internal
-  --with-replicators=TYPE Replicator support: internal/shared/none TYPE=none
-  --with-clvmd=TYPE       Build cluster LVM Daemon.
+                          [TYPE=internal]
+  --with-cluster=TYPE     cluster LVM locking support: internal/shared/none
+                          [TYPE=internal]
+  --with-snapshots=TYPE   snapshot support: internal/shared/none
+                          [TYPE=internal]
+  --with-mirrors=TYPE     mirror support: internal/shared/none
+                          [TYPE=internal]
+  --with-replicators=TYPE replicator support: internal/shared/none
+                          [TYPE=none]
+  --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
@@ -1574,24 +1579,33 @@
                            * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
-                          TYPE=none
-  --with-cmirrord-pidfile=PATH    cmirrord pidfile [/var/run/cmirrord.pid]
+                          [TYPE=none]
+  --with-cmirrord-pidfile=PATH
+                          cmirrord pidfile [/var/run/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
-  --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
-  --with-confdir=DIR      Configuration files in DIR [/etc]
-  --with-staticdir=DIR    Static binary in DIR [EPREFIX/sbin]
-  --with-usrlibdir=DIR
-  --with-usrsbindir=DIR
-  --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [EPREFIX]
+  --with-localedir=DIR    translation files in DIR [PREFIX/share/locale]
+  --with-confdir=DIR      configuration files in DIR [/etc]
+  --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
+  --with-usrlibdir=DIR    usrlib in DIR [PREFIX/lib]
+  --with-usrsbindir=DIR   usrsbin executables in DIR [PREFIX/sbin]
+  --with-udev-prefix=UPREFIX
+                          install udev rule files in UPREFIX [EPREFIX]
   --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
-  --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
-  --with-dmeventd-path=PATH       dmeventd path [EPREFIX/sbin/dmeventd]
-  --with-default-system-dir=DIR        Default LVM system directory [/etc/lvm]
-  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [archive]
-  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [backup]
-  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [cache]
-  --with-default-locking-dir=DIR       Default locking directory [/var/lock/lvm]
-  --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
+  --with-dmeventd-pidfile=PATH
+                          dmeventd pidfile [/var/run/dmeventd.pid]
+  --with-dmeventd-path=PATH
+                          dmeventd path [EPREFIX/sbin/dmeventd]
+  --with-default-system-dir=DIR
+                          default LVM system directory [/etc/lvm]
+  --with-default-archive-subdir=SUBDIR
+                          default metadata archive subdir [archive]
+  --with-default-backup-subdir=SUBDIR
+                          default metadata backup subdir [backup]
+  --with-default-cache-subdir=SUBDIR
+                          default metadata cache subdir [cache]
+  --with-default-locking-dir=DIR
+                          default locking directory [/var/lock/lvm]
+  --with-interface=IFACE  choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
   CC          C compiler command
@@ -1603,6 +1617,10 @@
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
+  PKG_CONFIG_PATH
+              directories to add to pkg-config's search path
+  PKG_CONFIG_LIBDIR
+              path overriding pkg-config's built-in search path
   PKGCONFIGINIT_CFLAGS
               C compiler flags for PKGCONFIGINIT, overriding pkg-config
   PKGCONFIGINIT_LIBS
@@ -11103,7 +11121,7 @@
 
 # Check whether --with-user was given.
 if test "${with_user+set}" = set; then
-  withval=$with_user;  OWNER="$withval"
+  withval=$with_user; OWNER=$withval
 fi
 
 { $as_echo "$as_me:$LINENO: result: $OWNER" >&5
@@ -11119,7 +11137,7 @@
 
 # Check whether --with-group was given.
 if test "${with_group+set}" = set; then
-  withval=$with_group;  GROUP="$withval"
+  withval=$with_group; GROUP=$withval
 fi
 
 { $as_echo "$as_me:$LINENO: result: $GROUP" >&5
@@ -11136,9 +11154,9 @@
 
 # Check whether --with-device-uid was given.
 if test "${with_device_uid+set}" = set; then
-  withval=$with_device_uid;  DM_DEVICE_UID="$withval"
+  withval=$with_device_uid; DM_DEVICE_UID=$withval
 else
-   DM_DEVICE_UID="0"
+  DM_DEVICE_UID=0
 fi
 
 { $as_echo "$as_me:$LINENO: result: $DM_DEVICE_UID" >&5
@@ -11151,9 +11169,9 @@
 
 # Check whether --with-device-gid was given.
 if test "${with_device_gid+set}" = set; then
-  withval=$with_device_gid;  DM_DEVICE_GID="$withval"
+  withval=$with_device_gid; DM_DEVICE_GID=$withval
 else
-   DM_DEVICE_GID="0"
+  DM_DEVICE_GID=0
 fi
 
 { $as_echo "$as_me:$LINENO: result: $DM_DEVICE_GID" >&5
@@ -11166,9 +11184,9 @@
 
 # Check whether --with-device-mode was given.
 if test "${with_device_mode+set}" = set; then
-  withval=$with_device_mode;  DM_DEVICE_MODE="$withval"
+  withval=$with_device_mode; DM_DEVICE_MODE=$withval
 else
-   DM_DEVICE_MODE="0600"
+  DM_DEVICE_MODE=0600
 fi
 
 { $as_echo "$as_me:$LINENO: result: $DM_DEVICE_MODE" >&5
@@ -11201,9 +11219,9 @@
 
 # Check whether --with-lvm1 was given.
 if test "${with_lvm1+set}" = set; then
-  withval=$with_lvm1;  LVM1="$withval"
+  withval=$with_lvm1; LVM1=$withval
 else
-   LVM1="internal"
+  LVM1=internal
 fi
 
 { $as_echo "$as_me:$LINENO: result: $LVM1" >&5
@@ -11231,9 +11249,9 @@
 
 # Check whether --with-pool was given.
 if test "${with_pool+set}" = set; then
-  withval=$with_pool;  POOL="$withval"
+  withval=$with_pool; POOL=$withval
 else
-   POOL="internal"
+  POOL=internal
 fi
 
 { $as_echo "$as_me:$LINENO: result: $POOL" >&5
@@ -11261,7 +11279,7 @@
 
 # Check whether --with-cluster was given.
 if test "${with_cluster+set}" = set; then
-  withval=$with_cluster;  CLUSTER="$withval"
+  withval=$with_cluster; CLUSTER=$withval
 fi
 
 { $as_echo "$as_me:$LINENO: result: $CLUSTER" >&5
@@ -11289,9 +11307,9 @@
 
 # Check whether --with-snapshots was given.
 if test "${with_snapshots+set}" = set; then
-  withval=$with_snapshots;  SNAPSHOTS="$withval"
+  withval=$with_snapshots; SNAPSHOTS=$withval
 else
-   SNAPSHOTS="internal"
+  SNAPSHOTS=internal
 fi
 
 { $as_echo "$as_me:$LINENO: result: $SNAPSHOTS" >&5
@@ -11319,9 +11337,9 @@
 
 # Check whether --with-mirrors was given.
 if test "${with_mirrors+set}" = set; then
-  withval=$with_mirrors;  MIRRORS="$withval"
+  withval=$with_mirrors; MIRRORS=$withval
 else
-   MIRRORS="internal"
+  MIRRORS=internal
 fi
 
 { $as_echo "$as_me:$LINENO: result: $MIRRORS" >&5
@@ -11351,7 +11369,7 @@
 if test "${with_replicators+set}" = set; then
   withval=$with_replicators; REPLICATORS=$withval
 else
-  REPLICATORS="none"
+  REPLICATORS=none
 fi
 
 { $as_echo "$as_me:$LINENO: result: $REPLICATORS" >&5
@@ -11397,6 +11415,10 @@
 pkg_config_init() {
 
 
+
+
+
+
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
@@ -11509,7 +11531,6 @@
 $as_echo "no" >&6; }
 		PKG_CONFIG=""
 	fi
-
 fi
 
 pkg_failed=no
@@ -11552,6 +11573,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11566,11 +11589,11 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 else
@@ -11578,7 +11601,7 @@
 	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	PKGCONFIG_INIT=1
 }
@@ -11589,9 +11612,9 @@
 
 # Check whether --with-clvmd was given.
 if test "${with_clvmd+set}" = set; then
-  withval=$with_clvmd;  CLVMD="$withval"
+  withval=$with_clvmd; CLVMD=$withval
 else
-   CLVMD="none"
+  CLVMD=none
 fi
 
 if test x$CLVMD = xyes; then
@@ -11784,6 +11807,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11798,9 +11823,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CCS_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in ccs.h
 do
@@ -11957,6 +11980,8 @@
 			HAVE_CCS=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in ccs.h
@@ -12161,6 +12186,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12175,9 +12202,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$GULM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libgulm.h
 do
@@ -12334,6 +12359,8 @@
 			HAVE_GULM=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libgulm.h
@@ -12541,6 +12568,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12555,9 +12584,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAN_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libcman.h
 do
@@ -12714,6 +12741,8 @@
 			HAVE_CMAN=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libcman.h
@@ -12924,6 +12953,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12938,10 +12969,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$COROSYNC_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	COROSYNC_CFLAGS=$pkg_cv_COROSYNC_CFLAGS
@@ -12995,6 +13026,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13009,10 +13042,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$QUORUM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
@@ -13067,6 +13100,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13081,10 +13116,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$SALCK_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	SALCK_CFLAGS=$pkg_cv_SALCK_CFLAGS
@@ -13140,6 +13175,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13154,10 +13191,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CONFDB_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                HAVE_CONFDB=no
+	HAVE_CONFDB=no
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	HAVE_CONFDB=no
 else
 	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
@@ -13376,6 +13413,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13390,10 +13429,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
@@ -13446,6 +13485,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13460,9 +13501,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$DLM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libdlm.h
 do
@@ -13619,6 +13658,8 @@
 			HAVE_DLM=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libdlm.h
@@ -13836,23 +13877,20 @@
 BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
-
-
 if test "x$BUILD_CMIRRORD" = xyes; then
 
 # Check whether --with-cmirrord-pidfile was given.
 if test "${with_cmirrord_pidfile+set}" = set; then
-  withval=$with_cmirrord_pidfile;  cat >>confdefs.h <<_ACEOF
-#define CMIRRORD_PIDFILE "$withval"
-_ACEOF
-
+  withval=$with_cmirrord_pidfile; CMIRRORD_PIDFILE=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define CMIRRORD_PIDFILE "/var/run/cmirrord.pid"
-_ACEOF
-
+  CMIRRORD_PIDFILE="/var/run/cmirrord.pid"
 fi
 
+
+cat >>confdefs.h <<_ACEOF
+#define CMIRRORD_PIDFILE "$CMIRRORD_PIDFILE"
+_ACEOF
+
 fi
 
 ################################################################################
@@ -13901,6 +13939,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13924,8 +13964,7 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&5
+See the pkg-config man page for more details." >&5
 $as_echo "$as_me: error: Package requirements (libSaCkpt) were not met:
 
 $SACKPT_PKG_ERRORS
@@ -13935,10 +13974,11 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&2;}
+See the pkg-config man page for more details." >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -13967,7 +14007,7 @@
 	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	if test x$HAVE_CPG != xyes; then
 
@@ -14011,6 +14051,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -14034,8 +14076,7 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&5
+See the pkg-config man page for more details." >&5
 $as_echo "$as_me: error: Package requirements (libcpg) were not met:
 
 $CPG_PKG_ERRORS
@@ -14045,10 +14086,11 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&2;}
+See the pkg-config man page for more details." >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -14077,7 +14119,7 @@
 	CPG_LIBS=$pkg_cv_CPG_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	fi
 fi
@@ -14107,7 +14149,7 @@
 
 # Check whether --with-optimisation was given.
 if test "${with_optimisation+set}" = set; then
-  withval=$with_optimisation;  COPTIMISE_FLAG="$withval"
+  withval=$with_optimisation; COPTIMISE_FLAG=$withval
 fi
 
 { $as_echo "$as_me:$LINENO: result: $COPTIMISE_FLAG" >&5
@@ -15886,9 +15928,9 @@
 
 # Check whether --with-localedir was given.
 if test "${with_localedir+set}" = set; then
-  withval=$with_localedir;  LOCALEDIR="$withval"
+  withval=$with_localedir; LOCALEDIR=$withval
 else
-   LOCALEDIR='${prefix}/share/locale'
+  LOCALEDIR='${prefix}/share/locale'
 fi
 
 fi
@@ -15897,36 +15939,36 @@
 
 # Check whether --with-confdir was given.
 if test "${with_confdir+set}" = set; then
-  withval=$with_confdir;  CONFDIR="$withval"
+  withval=$with_confdir; CONFDIR=$withval
 else
-   CONFDIR='/etc'
+  CONFDIR="/etc"
 fi
 
 
 
 # Check whether --with-staticdir was given.
 if test "${with_staticdir+set}" = set; then
-  withval=$with_staticdir;  STATICDIR="$withval"
+  withval=$with_staticdir; STATICDIR=$withval
 else
-   STATICDIR='${exec_prefix}/sbin'
+  STATICDIR='${exec_prefix}/sbin'
 fi
 
 
 
 # Check whether --with-usrlibdir was given.
 if test "${with_usrlibdir+set}" = set; then
-  withval=$with_usrlibdir;  usrlibdir="$withval"
+  withval=$with_usrlibdir; usrlibdir=$withval
 else
-   usrlibdir='${prefix}/lib'
+  usrlibdir='${prefix}/lib'
 fi
 
 
 
 # Check whether --with-usrsbindir was given.
 if test "${with_usrsbindir+set}" = set; then
-  withval=$with_usrsbindir;  usrsbindir="$withval"
+  withval=$with_usrsbindir; usrsbindir=$withval
 else
-   usrsbindir='${prefix}/sbin'
+  usrsbindir='${prefix}/sbin'
 fi
 
 
@@ -15934,18 +15976,18 @@
 
 # Check whether --with-udev_prefix was given.
 if test "${with_udev_prefix+set}" = set; then
-  withval=$with_udev_prefix;  udev_prefix="$withval"
+  withval=$with_udev_prefix; udev_prefix=$withval
 else
-   udev_prefix='${exec_prefix}'
+  udev_prefix='${exec_prefix}'
 fi
 
 
 
 # Check whether --with-udevdir was given.
 if test "${with_udevdir+set}" = set; then
-  withval=$with_udevdir;  udevdir="$withval"
+  withval=$with_udevdir; udevdir=$withval
 else
-   udevdir='${udev_prefix}/lib/udev/rules.d'
+  udevdir='${udev_prefix}/lib/udev/rules.d'
 fi
 
 
@@ -17651,115 +17693,104 @@
 fi
 
 ################################################################################
-
-
 if test "$BUILD_DMEVENTD" = yes; then
 
 # Check whether --with-dmeventd-pidfile was given.
 if test "${with_dmeventd_pidfile+set}" = set; then
-  withval=$with_dmeventd_pidfile;  cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PIDFILE "$withval"
-_ACEOF
-
+  withval=$with_dmeventd_pidfile; DMEVENTD_PIDFILE=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PIDFILE "/var/run/dmeventd.pid"
-_ACEOF
-
+  DMEVENTD_PIDFILE="/var/run/dmeventd.pid"
 fi
 
-fi
 
+cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PIDFILE "$DMEVENTD_PIDFILE"
+_ACEOF
 
+fi
 
 if test "$BUILD_DMEVENTD" = yes; then
 
 # Check whether --with-dmeventd-path was given.
 if test "${with_dmeventd_path+set}" = set; then
-  withval=$with_dmeventd_path;  cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PATH "$withval"
-_ACEOF
-
+  withval=$with_dmeventd_path; DMEVENTD_PATH=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PATH "$lvm_exec_prefix/sbin/dmeventd"
-_ACEOF
-
+  DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd"
 fi
 
-fi
 
-################################################################################
+cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PATH "$DMEVENTD_PATH"
+_ACEOF
 
+fi
 
+################################################################################
 
 # Check whether --with-default-system-dir was given.
 if test "${with_default_system_dir+set}" = set; then
-  withval=$with_default_system_dir;  DEFAULT_SYS_DIR="$withval"
+  withval=$with_default_system_dir; DEFAULT_SYS_DIR=$withval
 else
-   DEFAULT_SYS_DIR="/etc/lvm"
+  DEFAULT_SYS_DIR="/etc/lvm"
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_SYS_DIR "$DEFAULT_SYS_DIR"
 _ACEOF
 
 
 
-
-
 # Check whether --with-default-archive-subdir was given.
 if test "${with_default_archive_subdir+set}" = set; then
-  withval=$with_default_archive_subdir;  DEFAULT_ARCHIVE_SUBDIR="$withval"
+  withval=$with_default_archive_subdir; DEFAULT_ARCHIVE_SUBDIR=$withval
 else
-   DEFAULT_ARCHIVE_SUBDIR="archive"
+  DEFAULT_ARCHIVE_SUBDIR=archive
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_ARCHIVE_SUBDIR "$DEFAULT_ARCHIVE_SUBDIR"
 _ACEOF
 
 
 
-
-
 # Check whether --with-default-backup-subdir was given.
 if test "${with_default_backup_subdir+set}" = set; then
-  withval=$with_default_backup_subdir;  DEFAULT_BACKUP_SUBDIR="$withval"
+  withval=$with_default_backup_subdir; DEFAULT_BACKUP_SUBDIR=$withval
 else
-   DEFAULT_BACKUP_SUBDIR="backup"
+  DEFAULT_BACKUP_SUBDIR=backup
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_BACKUP_SUBDIR "$DEFAULT_BACKUP_SUBDIR"
 _ACEOF
 
 
 
-
-
 # Check whether --with-default-cache-subdir was given.
 if test "${with_default_cache_subdir+set}" = set; then
-  withval=$with_default_cache_subdir;  DEFAULT_CACHE_SUBDIR="$withval"
+  withval=$with_default_cache_subdir; DEFAULT_CACHE_SUBDIR=$withval
 else
-   DEFAULT_CACHE_SUBDIR="cache"
+  DEFAULT_CACHE_SUBDIR=cache
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_CACHE_SUBDIR "$DEFAULT_CACHE_SUBDIR"
 _ACEOF
 
 
 
-
-
 # Check whether --with-default-locking-dir was given.
 if test "${with_default_locking_dir+set}" = set; then
-  withval=$with_default_locking_dir;  DEFAULT_LOCK_DIR="$withval"
+  withval=$with_default_locking_dir; DEFAULT_LOCK_DIR=$withval
 else
-   DEFAULT_LOCK_DIR="/var/lock/lvm"
+  DEFAULT_LOCK_DIR="/var/lock/lvm"
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_LOCK_DIR "$DEFAULT_LOCK_DIR"
 _ACEOF
@@ -17771,9 +17802,9 @@
 
 # Check whether --with-interface was given.
 if test "${with_interface+set}" = set; then
-  withval=$with_interface;  interface="$withval"
+  withval=$with_interface; interface=$withval
 else
-   interface=ioctl
+  interface=ioctl
 fi
 
 if [ "x$interface" != xioctl ];


