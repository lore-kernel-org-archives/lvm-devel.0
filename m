From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 29 Jul 2015 18:31:39 +0000 (UTC)
Subject: master - libdm: Require librt for new dm_timestamp.
Message-ID: <20150729183139.DB4C460A6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cd644aeb5cac432a92ad50584973a3430168ed6
Commit:        3cd644aeb5cac432a92ad50584973a3430168ed6
Parent:        a28fb37b9e0e5b3a754e897887a8fdb22fd2d98d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 29 19:30:22 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 29 19:30:22 2015 +0100

libdm: Require librt for new dm_timestamp.

---
 configure                |    3 +++
 configure.in             |    2 ++
 libdm/libdevmapper.pc.in |    2 +-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 97fe8f2..07059b8 100755
--- a/configure
+++ b/configure
@@ -659,6 +659,7 @@ SELINUX_PC
 SELINUX_LIBS
 REPLICATORS
 READLINE_LIBS
+RT_PC
 RAID
 PYTHON_LIBDIRS
 PYTHON_INCDIRS
@@ -12794,6 +12795,7 @@ fi
 $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 
 		LIBS="-lrt $LIBS"
+		RT_PC="librt"
 	else
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
@@ -14143,6 +14145,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index e273e1d..1825fb7 100644
--- a/configure.in
+++ b/configure.in
@@ -1570,6 +1570,7 @@ if test "$REALTIME" = yes; then
 	if test "$HAVE_REALTIME" = yes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
 		LIBS="-lrt $LIBS"
+		RT_PC="librt"
 	else
 		AC_MSG_WARN(Disabling realtime clock)
 	fi
@@ -1984,6 +1985,7 @@ AC_SUBST(PYTHON_LIBDIRS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
+AC_SUBST(RT_PC)
 AC_SUBST(READLINE_LIBS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index eb7071d..63c0720 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -8,4 +8,4 @@ Description: device-mapper library
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Requires.private: @SELINUX_PC@ @UDEV_PC@
+Requires.private: @SELINUX_PC@ @UDEV_PC@ @RT_PC@


