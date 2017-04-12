From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Apr 2017 19:39:10 -0400
Subject: master - autoconf
Message-ID: <201704122339.v3CNdACi009683@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ed518f19fff387d3b843bcdf4fa900f89ab98d8
Commit:        9ed518f19fff387d3b843bcdf4fa900f89ab98d8
Parent:        5ac230095c72c578cb76996b5b8ae687d04e98a9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 13 00:38:46 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 13 00:38:46 2017 +0100

autoconf

---
 configure    |    4 +++-
 configure.in |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index e691805..4b83118 100755
--- a/configure
+++ b/configure
@@ -699,6 +699,7 @@ HAVE_VALGRIND
 HAVE_REALTIME
 HAVE_LIBDL
 BLKDEACTIVATE
+FSADM_PATH
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
@@ -821,8 +822,8 @@ THIN_CHECK_CMD
 HAVE_FULL_RELRO
 HAVE_PIE
 POW_LIB
-LIBOBJS
 ALLOCA
+LIBOBJS
 SORT
 WC
 CHMOD
@@ -15669,6 +15670,7 @@ _ACEOF
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon
 /client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/
 lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 9c1dabe..7dc3095 100644
--- a/configure.in
+++ b/configure.in
@@ -2075,6 +2075,7 @@ AC_SUBST(DMFILEMAPD)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
+AC_SUBST(FSADM_PATH)
 AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)


