From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Mar 2014 15:32:10 +0000 (UTC)
Subject: master - autoreconf: sync configure with current configure.in
Message-ID: <20140311153210.3C41B61050@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7574b3bc80c8b2db5f4a9da9e7de00c0a3239e26
Commit:        7574b3bc80c8b2db5f4a9da9e7de00c0a3239e26
Parent:        6c892be4a50049adbaa99c2a8c031a4acb6410f5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 11 16:32:02 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 11 16:32:02 2014 +0100

autoreconf: sync configure with current configure.in

---
 configure |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/configure b/configure
index ab4f534..d9df1ed 100755
--- a/configure
+++ b/configure
@@ -1624,8 +1624,7 @@ Optional Packages:
   --with-thin-check=PATH  thin_check tool: [[autodetect]]
   --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
   --with-thin-repair=PATH thin_repair tool: [[autodetect]]
-  --with-cache=TYPE       cache support: internal/shared/none
-                          [[TYPE=none]]
+  --with-cache=TYPE       cache support: internal/shared/none [[TYPE=none]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -10440,7 +10439,7 @@ done
 
 
 ################################################################################
-if test x$READLINE != xno; then
+if test "$READLINE" != no; then
 	lvm_saved_libs=$LIBS
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing tgetent" >&5
 $as_echo_n "checking for library containing tgetent... " >&6; }
@@ -11449,10 +11448,6 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
-
-
-
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


