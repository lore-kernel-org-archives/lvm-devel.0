From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 13:47:28 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20100520134728.25433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 13:47:22

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	                 make.tmpl.in 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/misc       : configure.h.in 
	man            : Makefile.in lvm.8.in lvm.conf.5.in 
	                 vgcfgbackup.8.in 

Log message:
	Add install_system_dirs makefile target.
	Add configure options for system and locking directories.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1569&r2=1.1570
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgbackup.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/Makefile.in	2010/04/13 13:28:52	1.52
+++ LVM2/Makefile.in	2010/05/20 13:47:21	1.53
@@ -78,6 +78,14 @@
 check check_cluster check_local: all
 	$(MAKE) -C test $(@)
 
+install_system_dirs:
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_SYS_DIR)
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_ARCHIVE_DIR)
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_BACKUP_DIR)
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_CACHE_DIR)
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_LOCK_DIR)
+	$(INSTALL_ROOT_DATA) /dev/null $(DESTDIR)$(DEFAULT_CACHE_DIR)/.cache
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)
--- LVM2/WHATS_NEW	2010/05/20 11:45:56	1.1569
+++ LVM2/WHATS_NEW	2010/05/20 13:47:21	1.1570
@@ -1,5 +1,7 @@
 Version 2.02.66 - 
 ===============================
+  Add install_system_dirs makefile target.
+  Add configure options for system and locking directories.
   Generate example.conf so default lvm.conf contents can be configured.
   Install lvmconf script by default.
   Remove unnecessary versioned dmeventd plugin symlinks.
--- LVM2/configure	2010/05/20 11:45:56	1.128
+++ LVM2/configure	2010/05/20 13:47:21	1.129
@@ -689,6 +689,11 @@
 DMEVENTD
 DL_LIBS
 DEVMAPPER
+DEFAULT_LOCK_DIR
+DEFAULT_CACHE_SUBDIR
+DEFAULT_BACKUP_SUBDIR
+DEFAULT_ARCHIVE_SUBDIR
+DEFAULT_SYS_DIR
 DEBUG
 COPTIMISE_FLAG
 CONFDIR
@@ -851,6 +856,11 @@
 with_udevdir
 with_dmeventd_pidfile
 with_dmeventd_path
+with_default_system_dir
+with_default_archive_subdir
+with_default_backup_subdir
+with_default_cache_subdir
+with_default_locking_dir
 with_interface
 '
       ac_precious_vars='build_alias
@@ -1573,6 +1583,11 @@
   --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
   --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
   --with-dmeventd-path=PATH       dmeventd path [EPREFIX/sbin/dmeventd]
+  --with-default-system-dir=DIR        Default LVM system directory [/etc/lvm]
+  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [archive]
+  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [backup]
+  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [cache]
+  --with-default-locking-dir=DIR       Default locking directory [/var/lock/lvm]
   --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
@@ -15485,6 +15500,82 @@
 fi
 
 ################################################################################
+
+
+
+# Check whether --with-default-system-dir was given.
+if test "${with_default_system_dir+set}" = set; then
+  withval=$with_default_system_dir;  DEFAULT_SYS_DIR="$withval"
+else
+   DEFAULT_SYS_DIR="/etc/lvm"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_SYS_DIR "$DEFAULT_SYS_DIR"
+_ACEOF
+
+
+
+
+
+# Check whether --with-default-archive-subdir was given.
+if test "${with_default_archive_subdir+set}" = set; then
+  withval=$with_default_archive_subdir;  DEFAULT_ARCHIVE_SUBDIR="$withval"
+else
+   DEFAULT_ARCHIVE_SUBDIR="archive"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_ARCHIVE_SUBDIR "$DEFAULT_ARCHIVE_SUBDIR"
+_ACEOF
+
+
+
+
+
+# Check whether --with-default-backup-subdir was given.
+if test "${with_default_backup_subdir+set}" = set; then
+  withval=$with_default_backup_subdir;  DEFAULT_BACKUP_SUBDIR="$withval"
+else
+   DEFAULT_BACKUP_SUBDIR="backup"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_BACKUP_SUBDIR "$DEFAULT_BACKUP_SUBDIR"
+_ACEOF
+
+
+
+
+
+# Check whether --with-default-cache-subdir was given.
+if test "${with_default_cache_subdir+set}" = set; then
+  withval=$with_default_cache_subdir;  DEFAULT_CACHE_SUBDIR="$withval"
+else
+   DEFAULT_CACHE_SUBDIR="cache"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_CACHE_SUBDIR "$DEFAULT_CACHE_SUBDIR"
+_ACEOF
+
+
+
+
+
+# Check whether --with-default-locking-dir was given.
+if test "${with_default_locking_dir+set}" = set; then
+  withval=$with_default_locking_dir;  DEFAULT_LOCK_DIR="$withval"
+else
+   DEFAULT_LOCK_DIR="/var/lock/lvm"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_LOCK_DIR "$DEFAULT_LOCK_DIR"
+_ACEOF
+
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking for kernel interface choice" >&5
 $as_echo_n "checking for kernel interface choice... " >&6; }
 
@@ -15616,6 +15707,11 @@
 
 
 
+
+
+
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/05/20 11:45:57	1.138
+++ LVM2/configure.in	2010/05/20 13:47:21	1.139
@@ -1020,6 +1020,43 @@
 fi
 
 ################################################################################
+dnl -- various defaults
+AH_TEMPLATE(DEFAULT_SYS_DIR, [Path to LVM system directory.])
+AC_ARG_WITH(default-system-dir,
+	    [  --with-default-system-dir=DIR        Default LVM system directory [[/etc/lvm]] ],
+	    [ DEFAULT_SYS_DIR="$withval" ],
+	    [ DEFAULT_SYS_DIR="/etc/lvm" ])
+AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR,["$DEFAULT_SYS_DIR"] )
+
+AH_TEMPLATE(DEFAULT_ARCHIVE_SUBDIR, [Name of default metadata archive subdirectory.])
+AC_ARG_WITH(default-archive-subdir,
+	    [  --with-default-archive-subdir=SUBDIR Default metadata archive subdir [[archive]] ],
+	    [ DEFAULT_ARCHIVE_SUBDIR="$withval" ],
+	    [ DEFAULT_ARCHIVE_SUBDIR="archive" ])
+AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR,["$DEFAULT_ARCHIVE_SUBDIR"])
+
+AH_TEMPLATE(DEFAULT_BACKUP_SUBDIR, [Name of default metadata backup subdirectory.])
+AC_ARG_WITH(default-backup-subdir,
+	    [  --with-default-backup-subdir=SUBDIR  Default metadata backup subdir [[backup]] ],
+	    [ DEFAULT_BACKUP_SUBDIR="$withval" ],
+	    [ DEFAULT_BACKUP_SUBDIR="backup" ])
+AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR,["$DEFAULT_BACKUP_SUBDIR"] )
+
+AH_TEMPLATE(DEFAULT_CACHE_SUBDIR, [Name of default metadata backup subdirectory.])
+AC_ARG_WITH(default-cache-subdir,
+	    [  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [[cache]] ],
+	    [ DEFAULT_CACHE_SUBDIR="$withval" ],
+	    [ DEFAULT_CACHE_SUBDIR="cache" ])
+AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR,["$DEFAULT_CACHE_SUBDIR"] )
+
+AH_TEMPLATE(DEFAULT_LOCK_DIR, [Name of default locking directory.])
+AC_ARG_WITH(default-locking-dir,
+	    [  --with-default-locking-dir=DIR       Default locking directory [[/var/lock/lvm]] ],
+	    [ DEFAULT_LOCK_DIR="$withval" ],
+	    [ DEFAULT_LOCK_DIR="/var/lock/lvm" ])
+AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR,["$DEFAULT_LOCK_DIR"] )
+
+################################################################################
 dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
@@ -1075,6 +1112,11 @@
 AC_SUBST(CPG_LIBS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
+AC_SUBST(DEFAULT_SYS_DIR)
+AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
+AC_SUBST(DEFAULT_BACKUP_SUBDIR)
+AC_SUBST(DEFAULT_CACHE_SUBDIR)
+AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
--- LVM2/make.tmpl.in	2010/05/20 11:20:35	1.99
+++ LVM2/make.tmpl.in	2010/05/20 13:47:21	1.100
@@ -67,6 +67,12 @@
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
+DEFAULT_SYS_DIR = @DEFAULT_SYS_DIR@
+DEFAULT_ARCHIVE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_ARCHIVE_SUBDIR@
+DEFAULT_BACKUP_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_BACKUP_SUBDIR@
+DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
+DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
+
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
 vpath %.in $(srcdir)
@@ -94,6 +100,9 @@
 INSTALL_DATA = $(INSTALL) -p $(M_INSTALL_DATA)
 INSTALL_WDATA = $(INSTALL) -p -m 644
 
+INSTALL_ROOT_DIR = $(INSTALL) -m 0700 -d
+INSTALL_ROOT_DATA = $(INSTALL) -m 0600
+
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
 CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security
--- LVM2/doc/example.conf.in	2010/05/20 11:45:57	1.1
+++ LVM2/doc/example.conf.in	2010/05/20 13:47:21	1.2
@@ -1,10 +1,10 @@
 # This is an example configuration file for the LVM2 system.
 # It contains the default settings that would be used if there was no
-# /etc/lvm/lvm.conf file.
+# @DEFAULT_SYS_DIR@/lvm.conf file.
 #
 # Refer to 'man lvm.conf' for further information including the file layout.
 #
-# To put this file in a different directory and override /etc/lvm set
+# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
 # the environment variable LVM_SYSTEM_DIR before running the tools.
 
 
@@ -66,12 +66,12 @@
 
     # The results of the filtering are cached on disk to avoid
     # rescanning dud devices (which can take a very long time).
-    # By default this cache is stored in the /etc/lvm/cache directory
+    # By default this cache is stored in the @DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@ directory
     # in a file called '.cache'.
     # It is safe to delete the contents: the tools regenerate it.
     # (The old setting 'cache' is still respected if neither of
     # these new ones is present.)
-    cache_dir = "/etc/lvm/cache"
+    cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
     cache_file_prefix = ""
 
     # You can turn off writing this cache file by setting this to 0.
@@ -192,7 +192,7 @@
 
     # Where shall we keep it ?
     # Remember to back up this directory regularly!
-    backup_dir = "/etc/lvm/backup"
+    backup_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
 
     # Should we maintain an archive of old metadata configurations.
     # Use 1 for Yes; 0 for No.
@@ -201,7 +201,7 @@
 
     # Where should archived files go ?
     # Remember to back up this directory regularly!
-    archive_dir = "/etc/lvm/archive"
+    archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
 
     # What is the minimum number of archive files you wish to keep ?
     retain_min = 10
@@ -295,7 +295,7 @@
 
     # Local non-LV directory that holds file-based locks while commands are
     # in progress.  A directory like /tmp that may get wiped on reboot is OK.
-    locking_dir = "/var/lock/lvm"
+    locking_dir = "@DEFAULT_LOCK_DIR@"
 
     # Whenever there are competing read-only and read-write access requests for
     # a volume group's metadata, instead of always granting the read-only
--- LVM2/lib/config/defaults.h	2010/03/05 14:48:34	1.59
+++ LVM2/lib/config/defaults.h	2010/05/20 13:47:21	1.60
@@ -19,15 +19,11 @@
 #define DEFAULT_ARCHIVE_ENABLED 1
 #define DEFAULT_BACKUP_ENABLED 1
 
-#define DEFAULT_ARCHIVE_SUBDIR "archive"
-#define DEFAULT_BACKUP_SUBDIR "backup"
-#define DEFAULT_CACHE_SUBDIR "cache"
 #define DEFAULT_CACHE_FILE_PREFIX ""
 
 #define DEFAULT_ARCHIVE_DAYS 30
 #define DEFAULT_ARCHIVE_NUMBER 10
 
-#define DEFAULT_SYS_DIR "/etc/lvm"
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
 #define DEFAULT_SYSFS_SCAN 1
@@ -37,7 +33,6 @@
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
-#define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
--- LVM2/lib/misc/configure.h.in	2010/03/23 14:44:42	1.19
+++ LVM2/lib/misc/configure.h.in	2010/05/20 13:47:21	1.20
@@ -17,9 +17,24 @@
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
+/* Name of default metadata archive subdirectory. */
+#undef DEFAULT_ARCHIVE_SUBDIR
+
+/* Name of default metadata backup subdirectory. */
+#undef DEFAULT_BACKUP_SUBDIR
+
+/* Name of default metadata backup subdirectory. */
+#undef DEFAULT_CACHE_SUBDIR
+
+/* Name of default locking directory. */
+#undef DEFAULT_LOCK_DIR
+
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
 #undef DEFAULT_SI_UNIT_CONSISTENCY
 
+/* Path to LVM system directory. */
+#undef DEFAULT_SYS_DIR
+
 /* Define to 1 to enable LVM2 device-mapper interaction. */
 #undef DEVMAPPER_SUPPORT
 
--- LVM2/man/Makefile.in	2010/04/09 21:42:51	1.36
+++ LVM2/man/Makefile.in	2010/05/20 13:47:22	1.37
@@ -67,7 +67,7 @@
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
--- LVM2/man/lvm.8.in	2009/09/14 19:42:13	1.4
+++ LVM2/man/lvm.8.in	2010/05/20 13:47:22	1.5
@@ -254,7 +254,7 @@
 \fBLVM_SYSTEM_DIR\fP 
 Directory containing lvm.conf and other LVM
 system files.
-Defaults to "/etc/lvm".
+Defaults to "#DEFAULT_SYS_DIR#".
 .TP
 \fBHOME\fP 
 Directory containing .lvm_history if the internal readline shell
@@ -277,7 +277,7 @@
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
 .SH FILES
-.I /etc/lvm/lvm.conf
+.I #DEFAULT_SYS_DIR#/lvm.conf
 .br
 .I $HOME/.lvm_history
 .SH SEE ALSO
--- LVM2/man/lvm.conf.5.in	2009/09/15 13:49:11	1.7
+++ LVM2/man/lvm.conf.5.in	2010/05/20 13:47:22	1.8
@@ -2,7 +2,7 @@
 .SH NAME
 lvm.conf \- Configuration file for LVM2
 .SH SYNOPSIS
-.B /etc/lvm/lvm.conf
+.B #DEFAULT_SYS_DIR#/lvm.conf
 .SH DESCRIPTION
 lvm.conf is loaded during the initialisation phase of 
 \fBlvm\fP (8).  This file can in turn lead to other files
@@ -105,7 +105,7 @@
 \fBdevices { filter=["r|cdrom|"] }\fP 
 .IP
 \fBcache_dir\fP \(em Persistent filter cache file directory.
-Defaults to "/etc/lvm/cache".
+Defaults to "#DEFAULT_CACHE_DIR#".
 .IP
 \fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the 
 persistent filter cache file when \fBlvm\fP exits.
@@ -206,12 +206,12 @@
 .IP
 \fBarchive_dir\fP \(em Directory used for automatic metadata archives.
 Backup copies of former metadata for each volume group are archived here.
-Defaults to "/etc/lvm/archive".
+Defaults to "#DEFAULT_ARCHIVE_DIR#".
 .IP
 \fBbackup_dir\fP \(em Directory used for automatic metadata backups.
 A single backup copy of the current metadata for each volume group 
 is stored here.
-Defaults to "/etc/lvm/backup".
+Defaults to "#DEFAULT_BACKUP_DIR#".
 .IP
 \fBarchive\fP \(em Whether or not tools automatically archive existing
 metadata into \fBarchive_dir\fP before making changes to it.
@@ -420,11 +420,11 @@
 understand how things work: to make changes you should always use 
 the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
 .SH FILES
-.I /etc/lvm/lvm.conf
-.I /etc/lvm/archive
-.I /etc/lvm/backup
-.I /etc/lvm/cache/.cache
-.I /var/lock/lvm
+.I #DEFAULT_SYS_DIR#/lvm.conf
+.I #DEFAULT_ARCHIVE_DIR#
+.I #DEFAULT_BACKUP_DIR#
+.I #DEFAULT_CACHE_DIR#/.cache
+.I #DEFAULT_LOCK_DIR#
 .SH SEE ALSO
 .BR lvm (8),
 .BR umask (2),
--- LVM2/man/vgcfgbackup.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgcfgbackup.8.in	2010/05/20 13:47:22	1.2
@@ -18,13 +18,13 @@
 will be backed up.
 .sp
 In a default installation, each volume group gets backed up into a separate
-file bearing the name of the volume group in the directory /etc/lvm/backup.
+file bearing the name of the volume group in the directory #DEFAULT_BACKUP_DIR#.
 You can write the backup to an alternative file using -f.  In this case
 if you are backing up more than one volume group the filename is
 treated as a template, and %s gets replaced by the volume group name.
 .sp
 NB. This DOESN'T backup user/system data in logical
-volume(s)!  Backup /etc/lvm regularly too.
+volume(s)!  Backup #DEFAULT_SYS_DIR# regularly too.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH SEE ALSO


