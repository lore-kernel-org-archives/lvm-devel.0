From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 10:38:49 -0400
Subject: master - configure.ac: bad configure generated due to stray ; ;
Message-ID: <201805031438.w43EcnSr025980@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b393fbec00bbe1fb8d546ee3f360f8d2eb19540e
Commit:        b393fbec00bbe1fb8d546ee3f360f8d2eb19540e
Parent:        2bb02e24bf9bd8467e75ba6e644daab3de2b4c77
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 15:38:05 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 15:38:05 2018 +0100

configure.ac: bad configure generated due to stray ;;

---
 configure    |   30 +++---------------------------
 configure.ac |    2 +-
 2 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/configure b/configure
index 6400e82..e874932 100755
--- a/configure
+++ b/configure
@@ -663,7 +663,6 @@ SBINDIR
 REPLICATORS
 READLINE_LIBS
 RT_LIBS
-RAID
 PYTHON3DIR
 PYTHON2DIR
 PYTHON3_LIBDIRS
@@ -912,7 +911,6 @@ with_default_name_mangling
 with_cluster
 with_snapshots
 with_mirrors
-with_raid
 with_default_mirror_segtype
 with_default_raid10_segtype
 with_default_sparse_segtype
@@ -1745,7 +1743,6 @@ Optional Packages:
                           [internal]
   --with-snapshots=TYPE   snapshot support: internal/shared/none [internal]
   --with-mirrors=TYPE     mirror support: internal/shared/none [internal]
-  --with-raid=TYPE        raid support: internal/shared/none [internal]
   --with-default-mirror-segtype=TYPE
                           default mirror segtype: raid1/mirror [raid1]
   --with-default-raid10-segtype=TYPE
@@ -8439,19 +8436,6 @@ $as_echo "#define MIRRORED_INTERNAL 1" >>confdefs.h
 esac
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include raid" >&5
-$as_echo_n "checking whether to include raid... " >&6; }
-
-# Check whether --with-raid was given.
-if test "${with_raid+set}" = set; then :
-  withval=$with_raid; RAID=$withval
-else
-  RAID=internal
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $RAID" >&5
-$as_echo "$RAID" >&6; }
-
 
 # Check whether --with-default-mirror-segtype was given.
 if test "${with_default_mirror_segtype+set}" = set; then :
@@ -8468,15 +8452,10 @@ else
   DEFAULT_RAID10_SEGTYPE="raid10"
 fi
 
-case "$RAID" in
-  none)  test "$DEFAULT_MIRROR_SEGTYPE" = "raid1" && DEFAULT_MIRROR_SEGTYPE="mirror"
-	test "$DEFAULT_RAID10_SEGTYPE" = "raid10" && DEFAULT_RAID10_SEGTYPE="mirror" ;;
-  shared) ;;
-  internal)
+
+
 $as_echo "#define RAID_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-raid parameter invalid" "$LINENO" 5 ;;
-esac
+
 
 
 cat >>confdefs.h <<_ACEOF
@@ -13883,8 +13862,6 @@ fi
 
 ################################################################################
 if [ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
-      -o "$SNAPSHOTS" = shared -o "$MIRRORS" = shared \
-      -o "$RAID" = shared -o "$CACHE" = shared \
       \) -a "$STATIC_LINK" = yes ]; then
 	as_fn_error $? "Features cannot be 'shared' when building statically" "$LINENO" 5
 fi
@@ -15581,7 +15558,6 @@ _ACEOF
 
 
 
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/
 Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lv
 m2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat@.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
diff --git a/configure.ac b/configure.ac
index 6df883b..5738b05 100644
--- a/configure.ac
+++ b/configure.ac
@@ -342,7 +342,7 @@ AC_ARG_WITH(default-raid10-segtype,
 			   DEFAULT_RAID10_SEGTYPE=$withval, DEFAULT_RAID10_SEGTYPE="raid10")
 
 AC_DEFINE([RAID_INTERNAL], 1,
-	  [Define to 1 to include built-in support for raid.]) ;;
+	  [Define to 1 to include built-in support for raid.])
 
 AC_DEFINE_UNQUOTED([DEFAULT_MIRROR_SEGTYPE], ["$DEFAULT_MIRROR_SEGTYPE"],
 		   [Default segtype used for mirror volumes.])


