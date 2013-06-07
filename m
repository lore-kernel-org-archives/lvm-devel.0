From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  7 Jun 2013 12:13:37 +0000 (UTC)
Subject: master - initscripts: add pidfile reference in chkconfig header for clvmd and cmirrord
Message-ID: <20130607121337.8E22B613AC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9fc137fd1de88d8713be53989e4a41ff9c9bac8
Commit:        a9fc137fd1de88d8713be53989e4a41ff9c9bac8
Parent:        b24aad1622a540ab71bc9e9425bdecfc17f443c9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 7 14:07:56 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 7 14:07:56 2013 +0200

initscripts: add pidfile reference in chkconfig header for clvmd and cmirrord

When the init scripts are run from within systemd, the systemd
needs to know the pidfile for it to work correctly when the
daemon itself is killed. Otherwise, systemd keeps these services
in "active" and "exited state" at the same time
(it assumes RemainAfterExit=yes without the pidfile reference in
chkconfig header).

See also https://bugzilla.redhat.com/show_bug.cgi?id=971819#c5.
---
 configure                        |    7 +++++--
 configure.in                     |    2 ++
 scripts/clvmd_init_red_hat.in    |    1 +
 scripts/cmirrord_init_red_hat.in |    1 +
 4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index b167274..e8ef786 100755
--- a/configure
+++ b/configure
@@ -606,6 +606,8 @@ kernelvsn
 missingkernel
 kerneldir
 interface
+CMIRRORD_PIDFILE
+CLVMD_PIDFILE
 LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
@@ -1588,8 +1590,7 @@ Optional Packages:
                           [[TYPE=internal]]
   --with-mirrors=TYPE     mirror support: internal/shared/none
                           [[TYPE=internal]]
-  --with-raid=TYPE        raid support: internal/shared/none
-                          [[TYPE=internal]]
+  --with-raid=TYPE        raid support: internal/shared/none [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
@@ -10787,6 +10788,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/bl
 k_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index b4dfc19..b286358 100644
--- a/configure.in
+++ b/configure.in
@@ -1599,6 +1599,8 @@ AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)
+AC_SUBST(CLVMD_PIDFILE)
+AC_SUBST(CMIRRORD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index 4170094..86dea4c 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -4,6 +4,7 @@
 #
 # chkconfig: - 24 76
 # description: Cluster daemon for userland logical volume management tools.
+# pidfile: @CLVMD_PIDFILE@
 #
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
 #
diff --git a/scripts/cmirrord_init_red_hat.in b/scripts/cmirrord_init_red_hat.in
index a715078..d4b7e37 100755
--- a/scripts/cmirrord_init_red_hat.in
+++ b/scripts/cmirrord_init_red_hat.in
@@ -2,6 +2,7 @@
 #
 # chkconfig: - 22 78
 # description: Starts and stops cmirrord
+# pidfile: @CMIRRORD_PIDFILE@
 #
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
 #


