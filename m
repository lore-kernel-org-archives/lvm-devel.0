From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:32 +0000 (UTC)
Subject: master - configure: autoreconf
Message-ID: <20141030230032.B516260654@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6e647489d49e02dbe9795371df7b154d30baf74
Commit:        e6e647489d49e02dbe9795371df7b154d30baf74
Parent:        e0164f21886a5b4964110bcac65535a670fdf6f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 17:07:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:48 2014 +0100

configure: autoreconf

Just rebuild after configure.in update.
---
 aclocal.m4 |    2 +-
 configure  |  194 +++++++++++++++++++++++++++++++++++++++---------------------
 2 files changed, 127 insertions(+), 69 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 6f752f2..2325191 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,4 +1,4 @@
-# generated automatically by aclocal 1.13.4 -*- Autoconf -*-
+# generated automatically by aclocal 1.14.1 -*- Autoconf -*-
 
 # Copyright (C) 1996-2013 Free Software Foundation, Inc.
 
diff --git a/configure b/configure
index 6a15ed8..28651ac 100755
--- a/configure
+++ b/configure
@@ -697,16 +697,19 @@ DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
 DEVMAPPER
+DEFAULT_SYS_DIR
+DEFAULT_SPARSE_SEGTYPE
 DEFAULT_RUN_DIR
+DEFAULT_RAID10_SEGTYPE
+DEFAULT_PROFILE_SUBDIR
 DEFAULT_PID_DIR
-DEFAULT_DM_RUN_DIR
+DEFAULT_MIRROR_SEGTYPE
 DEFAULT_LOCK_DIR
+DEFAULT_DM_RUN_DIR
 DEFAULT_DATA_ALIGNMENT
-DEFAULT_PROFILE_SUBDIR
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
 DEFAULT_ARCHIVE_SUBDIR
-DEFAULT_SYS_DIR
 DEBUG
 COPTIMISE_FLAG
 CONFDIR
@@ -870,7 +873,10 @@ with_cluster
 with_snapshots
 with_mirrors
 with_raid
+with_default_mirror_segtype
+with_default_raid10r_segtype
 with_replicators
+with_default_sparse_segtype
 with_thin
 with_thin_check
 with_thin_dump
@@ -1638,52 +1644,53 @@ Optional Features:
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
-  --with-user=USER        set the owner of installed files [[USER=]]
-  --with-group=GROUP      set the group owner of installed files [[GROUP=]]
-  --with-device-uid=UID   set the owner used for new device nodes [[UID=0]]
-  --with-device-gid=GID   set the group used for new device nodes [[GID=0]]
-  --with-device-mode=MODE set the mode used for new device nodes [[MODE=0600]]
+  --with-user=USER        set the owner of installed files [USER=]
+  --with-group=GROUP      set the group owner of installed files [GROUP=]
+  --with-device-uid=UID   set the owner used for new device nodes [UID=0]
+  --with-device-gid=GID   set the group used for new device nodes [GID=0]
+  --with-device-mode=MODE set the mode used for new device nodes [MODE=0600]
   --with-device-nodes-on=ON
-                          create nodes on resume or create [[ON=resume]]
+                          create nodes on resume or create [ON=resume]
   --with-default-name-mangling=MANGLING
-                          default name mangling: auto/none/hex
-                          [[MANGLING=auto]]
+                          default name mangling: auto/none/hex [auto]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
-                          [[TYPE=internal]]
+                          [internal]
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
-                          [[TYPE=internal]]
+                          [internal]
   --with-cluster=TYPE     cluster LVM locking support: internal/shared/none
-                          [[TYPE=internal]]
-  --with-snapshots=TYPE   snapshot support: internal/shared/none
-                          [[TYPE=internal]]
-  --with-mirrors=TYPE     mirror support: internal/shared/none
-                          [[TYPE=internal]]
-  --with-raid=TYPE        raid support: internal/shared/none [[TYPE=internal]]
-  --with-replicators=TYPE replicator support: internal/shared/none
-                          [[TYPE=none]]
+                          [internal]
+  --with-snapshots=TYPE   snapshot support: internal/shared/none [internal]
+  --with-mirrors=TYPE     mirror support: internal/shared/none [internal]
+  --with-raid=TYPE        raid support: internal/shared/none [internal]
+  --with-default-mirror-segtype=TYPE
+                          default mirror segtype: raid1/mirror [raid1]
+  --with-default-raid10-segtype=TYPE
+                          default mirror segtype: raid10/mirror [raid10]
+  --with-replicators=TYPE replicator support: internal/shared/none [none]
+  --with-default-sparse-segtype=TYPE
+                          default sparse segtype: thin/snapshot [thin]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
-                          [[TYPE=internal]]
-  --with-thin-check=PATH  thin_check tool: [[autodetect]]
-  --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
-  --with-thin-repair=PATH thin_repair tool: [[autodetect]]
+                          [internal]
+  --with-thin-check=PATH  thin_check tool: [autodetect]
+  --with-thin-dump=PATH   thin_dump tool: [autodetect]
+  --with-thin-repair=PATH thin_repair tool: [autodetect]
   --with-thin-restore=PATH
-                          thin_restore tool: [[autodetect]]
-  --with-cache=TYPE       cache support: internal/shared/none
-                          [[TYPE=internal]]
-  --with-cache-check=PATH cache_check tool: [[autodetect]]
-  --with-cache-dump=PATH  cache_dump tool: [[autodetect]]
+                          thin_restore tool: [autodetect]
+  --with-cache=TYPE       cache support: internal/shared/none [internal]
+  --with-cache-check=PATH cache_check tool: [autodetect]
+  --with-cache-dump=PATH  cache_dump tool: [autodetect]
   --with-cache-repair=PATH
-                          cache_repair tool: [[autodetect]]
+                          cache_repair tool: [autodetect]
   --with-cache-restore=PATH
-                          cache_restore tool: [[autodetect]]
-  --with-ocfdir=DIR       install OCF files in DIR
-                          [[PREFIX/lib/ocf/resource.d/lvm2]]
+                          cache_restore tool: [autodetect]
+  --with-ocfdir=DIR       install OCF files in
+                          [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
-                          Default directory to keep PID files in. [[/var/run]]
+                          Default directory to keep PID files in. [/var/run]
   --with-default-dm-run-dir=DM_RUN_DIR
-                          Default DM run directory. [[/var/run]]
+                          Default DM run directory. [/var/run]
   --with-default-run-dir=RUN_DIR
-                          Default LVM run directory. [[/var/run/lvm]]
+                          Default LVM run directory. [/var/run/lvm]
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman                  (RHEL5 or equivalent)
@@ -1691,46 +1698,46 @@ Optional Packages:
                            * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
-                          [TYPE=none]
+                          [none]
   --with-clvmd-pidfile=PATH
-                          clvmd pidfile [[PID_DIR/clvmd.pid]]
+                          clvmd pidfile [PID_DIR/clvmd.pid]
   --with-cmirrord-pidfile=PATH
-                          cmirrord pidfile [[PID_DIR/cmirrord.pid]]
-  --with-optimisation=OPT C optimisation flag [[OPT=-O2]]
+                          cmirrord pidfile [PID_DIR/cmirrord.pid]
+  --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-lvmetad-pidfile=PATH
-                          lvmetad pidfile [[PID_DIR/lvmetad.pid]]
-  --with-localedir=DIR    translation files in DIR [[PREFIX/share/locale]]
-  --with-confdir=DIR      configuration files in DIR [[/etc]]
-  --with-staticdir=DIR    static binaries in DIR [[EPREFIX/sbin]]
-  --with-usrlibdir=DIR    usrlib in DIR [[PREFIX/lib]]
-  --with-usrsbindir=DIR   usrsbin executables in DIR [[PREFIX/sbin]]
+                          lvmetad pidfile [PID_DIR/lvmetad.pid]
+  --with-localedir=DIR    translation files in DIR [PREFIX/share/locale]
+  --with-confdir=DIR      configuration files in DIR [/etc]
+  --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
+  --with-usrlibdir=DIR    usrlib in DIR [PREFIX/lib]
+  --with-usrsbindir=DIR   usrsbin executables in DIR [PREFIX/sbin]
   --with-udev-prefix=UPREFIX
-                          install udev rule files in UPREFIX [[EPREFIX]]
-  --with-udevdir=DIR      udev rules in DIR [[UPREFIX/lib/udev/rules.d]]
+                          install udev rule files in UPREFIX [EPREFIX]
+  --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
   --with-systemdsystemunitdir=DIR
                           systemd service files in DIR
   --with-tmpfilesdir=DIR  install configuration files for management of
                           volatile files and directories in DIR
-                          [[PREFIX/lib/tmpfiles.d]]
+                          [PREFIX/lib/tmpfiles.d]
   --with-dmeventd-pidfile=PATH
-                          dmeventd pidfile [[PID_DIR/dmeventd.pid]]
+                          dmeventd pidfile [PID_DIR/dmeventd.pid]
   --with-dmeventd-path=PATH
-                          dmeventd path [[EPREFIX/sbin/dmeventd]]
+                          dmeventd path [EPREFIX/sbin/dmeventd]
   --with-default-system-dir=DIR
-                          default LVM system directory [[/etc/lvm]]
+                          default LVM system directory [/etc/lvm]
   --with-default-profile-subdir=SUBDIR
-                          default configuration profile subdir [[profile]]
+                          default configuration profile subdir [profile]
   --with-default-archive-subdir=SUBDIR
-                          default metadata archive subdir [[archive]]
+                          default metadata archive subdir [archive]
   --with-default-backup-subdir=SUBDIR
-                          default metadata backup subdir [[backup]]
+                          default metadata backup subdir [backup]
   --with-default-cache-subdir=SUBDIR
-                          default metadata cache subdir [[cache]]
+                          default metadata cache subdir [cache]
   --with-default-locking-dir=DIR
-                          default locking directory [[/var/lock/lvm]]
+                          default locking directory [/var/lock/lvm]
   --with-default-data-alignment=NUM
-                          set the default data alignment in MiB [[1]]
-  --with-interface=IFACE  choose kernel interface (ioctl) [[ioctl]]
+                          set the default data alignment in MiB [1]
+  --with-interface=IFACE  choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
   CC          C compiler command
@@ -7244,14 +7251,44 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $RAID" >&5
 $as_echo "$RAID" >&6; }
 
+
+# Check whether --with-default-mirror-segtype was given.
+if test "${with_default_mirror_segtype+set}" = set; then :
+  withval=$with_default_mirror_segtype; DEFAULT_MIRROR_SEGTYPE=$withval
+else
+  DEFAULT_MIRROR_SEGTYPE="raid1"
+fi
+
+
+# Check whether --with-default-raid10r-segtype was given.
+if test "${with_default_raid10r_segtype+set}" = set; then :
+  withval=$with_default_raid10r_segtype; DEFAULT_RAID10_SEGTYPE=$withval
+else
+  DEFAULT_RAID10_SEGTYPE="raid10"
+fi
+
 case "$RAID" in
-  none|shared) ;;
+  none)  test "$DEFAULT_MIRROR_SEGTYPE" = "raid1" && DEFAULT_MIRROR_SEGTYPE="mirror"
+	test "$DEFAULT_RAID10_SEGTYPE" = "raid10" && DEFAULT_RAID10_SEGTYPE="mirror" ;;
+  shared) ;;
   internal)
 $as_echo "#define RAID_INTERNAL 1" >>confdefs.h
  ;;
   *) as_fn_error $? "--with-raid parameter invalid" "$LINENO" 5 ;;
 esac
 
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_MIRROR_SEGTYPE "$DEFAULT_MIRROR_SEGTYPE"
+_ACEOF
+
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_RAID10_SEGTYPE "$DEFAULT_RAID10_SEGTYPE"
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include replicators" >&5
 $as_echo_n "checking whether to include replicators... " >&6; }
@@ -7274,6 +7311,16 @@ $as_echo "#define REPLICATOR_INTERNAL 1" >>confdefs.h
   *) as_fn_error $? "--with-replicators parameter invalid ($REPLICATORS)" "$LINENO" 5 ;;
 esac
 
+
+
+# Check whether --with-default-sparse-segtype was given.
+if test "${with_default_sparse_segtype+set}" = set; then :
+  withval=$with_default_sparse_segtype; DEFAULT_SPARSE_SEGTYPE=$withval
+else
+  DEFAULT_SPARSE_SEGTYPE="thin"
+fi
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include thin provisioning" >&5
 $as_echo_n "checking whether to include thin provisioning... " >&6; }
@@ -7322,13 +7369,20 @@ fi
 $as_echo "$THIN" >&6; }
 
 case "$THIN" in
-  none|shared) ;;
+  none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
+  shared) ;;
   internal)
 $as_echo "#define THIN_INTERNAL 1" >>confdefs.h
  ;;
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_SPARSE_SEGTYPE "$DEFAULT_SPARSE_SEGTYPE"
+_ACEOF
+
+
 # Check whether --enable-thin_check_needs_check was given.
 if test "${enable_thin_check_needs_check+set}" = set; then :
   enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
@@ -7786,18 +7840,19 @@ $as_echo "$as_me: WARNING: thin_restore not found in path $PATH" >&2;}
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
-	;;
-esac
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
 $as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
 $as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
-if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
 
 $as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
-fi
+	fi
+
+	;;
+esac
 
 
 cat >>confdefs.h <<_ACEOF
@@ -12602,6 +12657,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat@.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


