From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:32 +0200
Subject: [PATCH 2/6] configure changes - AC_HELP_STRING, AH_TEMPLATE
In-Reply-To: <cover.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
Message-ID: <5cfe7427aaec8d94c2359c36321607f6cb0ba26b.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

change don't -> do not

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure    |  100 +++++++++++++++++++++++++++------------------------------
 configure.in |   76 ++++++++++++++++++++++++--------------------
 2 files changed, 89 insertions(+), 87 deletions(-)

diff --git a/configure b/configure
index d11af6a..62e4588 100755
--- a/configure
+++ b/configure
@@ -1535,7 +1535,7 @@ Optional Features:
   --enable-udev_rules     Install rule files needed for udev synchronisation
   --enable-compat         Enable support for old device-mapper versions
   --enable-units-compat   Enable output compatibility with old versions that
-                          that don't use KiB-style unit suffixes
+                          that do not use KiB-style unit suffixes
   --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
   --enable-applib         Build application library
@@ -1575,7 +1575,8 @@ Optional Packages:
                            * all                   (autodetect)
                            * none                  (disable build)
                           TYPE=none
-  --with-cmirrord-pidfile=PATH    cmirrord pidfile [/var/run/cmirrord.pid]
+  --with-cmirrord-pidfile=PATH
+                          cmirrord pidfile [/var/run/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
   --with-confdir=DIR      Configuration files in DIR [/etc]
@@ -1584,13 +1585,20 @@ Optional Packages:
   --with-usrsbindir=DIR
   --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [EPREFIX]
   --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
-  --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
-  --with-dmeventd-path=PATH       dmeventd path [EPREFIX/sbin/dmeventd]
-  --with-default-system-dir=DIR        Default LVM system directory [/etc/lvm]
-  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [archive]
-  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [backup]
-  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [cache]
-  --with-default-locking-dir=DIR       Default locking directory [/var/lock/lvm]
+  --with-dmeventd-pidfile=PATH
+                          dmeventd pidfile [/var/run/dmeventd.pid]
+  --with-dmeventd-path=PATH
+                          dmeventd path [EPREFIX/sbin/dmeventd]
+  --with-default-system-dir=DIR
+                          Default LVM system directory [/etc/lvm]
+  --with-default-archive-subdir=SUBDIR
+                          Default metadata archive subdir [archive]
+  --with-default-backup-subdir=SUBDIR
+                          Default metadata backup subdir [backup]
+  --with-default-cache-subdir=SUBDIR
+                          Default metadata cache subdir [cache]
+  --with-default-locking-dir=DIR
+                          Default locking directory [/var/lock/lvm]
   --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
@@ -13836,23 +13844,20 @@ $as_echo "$CMIRRORD" >&6; }
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
+  withval=$with_cmirrord_pidfile;  CMIRRORD_PIDFILE=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define CMIRRORD_PIDFILE "/var/run/cmirrord.pid"
-_ACEOF
-
+   CMIRRORD_PIDFILE="/var/run/cmirrord.pid"
 fi
 
+
+cat >>confdefs.h <<_ACEOF
+#define CMIRRORD_PIDFILE "$CMIRRORD_PIDFILE"
+_ACEOF
+
 fi
 
 ################################################################################
@@ -17651,115 +17656,104 @@ _ACEOF
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
+  withval=$with_dmeventd_pidfile;  DMEVENTD_PIDFILE=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PIDFILE "/var/run/dmeventd.pid"
-_ACEOF
-
+   DMEVENTD_PIDFILE="/var/run/dmeventd.pid"
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
+  withval=$with_dmeventd_path;  DMEVENTD_PATH=$withval
 else
-   cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PATH "$lvm_exec_prefix/sbin/dmeventd"
-_ACEOF
-
+   DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd"
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
+  withval=$with_default_system_dir;  DEFAULT_SYS_DIR=$withval
 else
    DEFAULT_SYS_DIR="/etc/lvm"
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
+  withval=$with_default_archive_subdir;  DEFAULT_ARCHIVE_SUBDIR=$withval
 else
    DEFAULT_ARCHIVE_SUBDIR="archive"
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
+  withval=$with_default_backup_subdir;  DEFAULT_BACKUP_SUBDIR=$withval
 else
    DEFAULT_BACKUP_SUBDIR="backup"
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
+  withval=$with_default_cache_subdir;  DEFAULT_CACHE_SUBDIR=$withval
 else
    DEFAULT_CACHE_SUBDIR="cache"
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
+  withval=$with_default_locking_dir;  DEFAULT_LOCK_DIR=$withval
 else
    DEFAULT_LOCK_DIR="/var/lock/lvm"
 fi
 
+
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_LOCK_DIR "$DEFAULT_LOCK_DIR"
 _ACEOF
diff --git a/configure.in b/configure.in
index a8a5b92..e35b027 100644
--- a/configure.in
+++ b/configure.in
@@ -599,12 +599,11 @@ BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
 dnl -- cmirrord pidfile
-AH_TEMPLATE(CMIRRORD_PIDFILE, [Path to cmirrord pidfile.])
 if test "x$BUILD_CMIRRORD" = xyes; then
 	AC_ARG_WITH(cmirrord-pidfile,
-		    [  --with-cmirrord-pidfile=PATH    cmirrord pidfile [[/var/run/cmirrord.pid]] ],
-		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"$withval") ],
-		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"/var/run/cmirrord.pid") ])
+		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH], [cmirrord pidfile [[/var/run/cmirrord.pid]] ]),
+		    [ CMIRRORD_PIDFILE=$withval ], [ CMIRRORD_PIDFILE="/var/run/cmirrord.pid" ])
+	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"], [Path to cmirrord pidfile.])
 fi
 
 ################################################################################
@@ -710,8 +709,8 @@ AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device
 ################################################################################
 dnl -- Compatible units suffix mode
 AC_ARG_ENABLE(units-compat,
-  [  --enable-units-compat   Enable output compatibility with old versions that
-                          that don't use KiB-style unit suffixes],
+  AC_HELP_STRING([--enable-units-compat], 
+		 [Enable output compatibility with old versions that that do not use KiB-style unit suffixes]),
   UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
 
 if test x$UNITS_COMPAT = xyes; then
@@ -1042,58 +1041,67 @@ fi
 
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
+		    [ DMEVENTD_PIDFILE=$withval ],
+		    [ DMEVENTD_PIDFILE="/var/run/dmeventd.pid" ])
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
+		    [ DMEVENTD_PATH=$withval ], 
+		    [ DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd" ])
+	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
+			   [Path to dmeventd binary.])
 fi
 
 ################################################################################
 dnl -- various defaults
-AH_TEMPLATE(DEFAULT_SYS_DIR, [Path to LVM system directory.])
 AC_ARG_WITH(default-system-dir,
-	    [  --with-default-system-dir=DIR        Default LVM system directory [[/etc/lvm]] ],
-	    [ DEFAULT_SYS_DIR="$withval" ],
+	    AC_HELP_STRING([--with-default-system-dir=DIR],
+			   [Default LVM system directory [[/etc/lvm]]]),
+	    [ DEFAULT_SYS_DIR=$withval ],
 	    [ DEFAULT_SYS_DIR="/etc/lvm" ])
-AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR,["$DEFAULT_SYS_DIR"] )
+AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
+		   [Path to LVM system directory.])
 
-AH_TEMPLATE(DEFAULT_ARCHIVE_SUBDIR, [Name of default metadata archive subdirectory.])
 AC_ARG_WITH(default-archive-subdir,
-	    [  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [[archive]] ],
-	    [ DEFAULT_ARCHIVE_SUBDIR="$withval" ],
+	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
+			   [Default metadata archive subdir [[archive]]]),
+	    [ DEFAULT_ARCHIVE_SUBDIR=$withval ],
 	    [ DEFAULT_ARCHIVE_SUBDIR="archive" ])
-AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR,["$DEFAULT_ARCHIVE_SUBDIR"])
+AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR, ["$DEFAULT_ARCHIVE_SUBDIR"],
+		   [Name of default metadata archive subdirectory.])
 
-AH_TEMPLATE(DEFAULT_BACKUP_SUBDIR, [Name of default metadata backup subdirectory.])
 AC_ARG_WITH(default-backup-subdir,
-	    [  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [[backup]] ],
-	    [ DEFAULT_BACKUP_SUBDIR="$withval" ],
+	    AC_HELP_STRING([--with-default-backup-subdir=SUBDIR],
+			   [Default metadata backup subdir [[backup]]]),
+	    [ DEFAULT_BACKUP_SUBDIR=$withval ],
 	    [ DEFAULT_BACKUP_SUBDIR="backup" ])
-AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR,["$DEFAULT_BACKUP_SUBDIR"] )
+AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR, ["$DEFAULT_BACKUP_SUBDIR"],
+                   [Name of default metadata backup subdirectory.])
 
-AH_TEMPLATE(DEFAULT_CACHE_SUBDIR, [Name of default metadata cache subdirectory.])
 AC_ARG_WITH(default-cache-subdir,
-	    [  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [[cache]] ],
-	    [ DEFAULT_CACHE_SUBDIR="$withval" ],
+	    AC_HELP_STRING([--with-default-cache-subdir=SUBDIR],
+			   [Default metadata cache subdir [[cache]]]),
+	    [ DEFAULT_CACHE_SUBDIR=$withval ],
 	    [ DEFAULT_CACHE_SUBDIR="cache" ])
-AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR,["$DEFAULT_CACHE_SUBDIR"] )
+AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
+		   [Name of default metadata cache subdirectory.])
 
-AH_TEMPLATE(DEFAULT_LOCK_DIR, [Name of default locking directory.])
 AC_ARG_WITH(default-locking-dir,
-	    [  --with-default-locking-dir=DIR       Default locking directory [[/var/lock/lvm]] ],
-	    [ DEFAULT_LOCK_DIR="$withval" ],
+	    AC_HELP_STRING([--with-default-locking-dir=DIR],
+			   [Default locking directory [[/var/lock/lvm]]]),
+	    [ DEFAULT_LOCK_DIR=$withval ],
 	    [ DEFAULT_LOCK_DIR="/var/lock/lvm" ])
-AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR,["$DEFAULT_LOCK_DIR"] )
+AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
+		   [Name of default locking directory.])
 
 ################################################################################
 dnl -- which kernel interface to use (ioctl only)
-- 
1.7.1.1


