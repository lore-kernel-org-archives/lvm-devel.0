From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 18 Oct 2013 09:38:59 +0000 (UTC)
Subject: master - udev+systemd: make pvscan --cache -aay run as systemd background job from udev
Message-ID: <20131018093859.12D9A61328@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=546db1c4be55d47d41082a345e15a35055223154
Commit:        546db1c4be55d47d41082a345e15a35055223154
Parent:        9f406ce252c40a29c06dba4bebe92b570207df93
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 18 11:07:21 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 18 11:38:49 2013 +0200

udev+systemd: make pvscan --cache -aay run as systemd background job from udev

The new lvm2-pvscan at .service is responsible for on-demand execution
of "pvscan --cache --activate ay" which causes lvmetad to be
updated and LVM activation done if the VG is complete.

Also, use udev-systemd mechanism to instantiate the job as the
lvm2-pvscan@$devnode.service on each newly appeared PV in the system.
This prevents the background job to be killed (that would happen
if it was directly forked from udev rule - this behaviour is seen
in recent versions of udev with the help of systemd that can track
detached processes - the detached process would still be in the same
cgroup).

To enable this official udev-systemd protocol for instantiating
background jobs, use new --enable-udev-systemd-background-jobs
configure switch (it's disabled by default). This option is highly
recommended wherever systemd is used!
---
 WHATS_NEW                                       |    2 +
 configure                                       |   26 +++++++++++++++++++---
 configure.in                                    |   11 +++++++++
 scripts/Makefile.in                             |    2 +
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |   11 +++++++++
 udev/69-dm-lvm-metad.rules.in                   |    2 +-
 udev/Makefile.in                                |    8 ++++++-
 7 files changed, 56 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79a960c..96e6775 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.104
 ===================================
+  Add configure --enable-udev-systemd-background-jobs.
+  Add lvm2-pvscan at .service to run pvscan as a service for lvmetad/autoactivation.
   Fix lvconvert swap of poolmetadata volume for active thin pool.
   Check for open count with a timeout before removal/deactivation of an LV.
   Report RAID images split with tracking as out-of-sync ("I").
diff --git a/configure b/configure
index 20a706a..002a7d2 100755
--- a/configure
+++ b/configure
@@ -613,6 +613,7 @@ DMEVENTD_PIDFILE
 WRITE_INSTALL
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
+UDEV_SYSTEMD_BACKGROUND_JOBS
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
@@ -849,6 +850,7 @@ enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
 with_lvmetad_pidfile
+enable_udev_systemd_background_jobs
 enable_udev_sync
 enable_udev_rules
 enable_udev_rule_exec_detection
@@ -1552,6 +1554,9 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
+  --enable-udev-systemd-background-jobs
+                          enable udev-systemd protocol to instantiate a
+                          service for background job
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
   --enable-udev-rule-exec-detection
@@ -9090,6 +9095,19 @@ _ACEOF
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
+$as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
+# Check whether --enable-udev-systemd-background-jobs was given.
+if test "${enable_udev_systemd_background_jobs+set}" = set; then :
+  enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
+else
+  UDEV_SYSTEMD_BACKGROUND_JOBS=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
+$as_echo "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
 $as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
 # Check whether --enable-udev_sync was given.
@@ -9668,8 +9686,7 @@ if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
 fi
 
 ################################################################################
-if [ "$DMEVENTD" = yes -o "$CLVMD" != none ] ; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
 $as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
 if test "${ac_cv_lib_pthread_pthread_mutex_lock+set}" = set; then :
   $as_echo_n "(cached) " >&6
@@ -9711,7 +9728,6 @@ else
   hard_bailout
 fi
 
-fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable selinux support" >&5
@@ -10933,8 +10949,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_
 init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_
 init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11671,6 +11688,7 @@ do
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
+    "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat at .service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
diff --git a/configure.in b/configure.in
index 3bd2439..07b0afc 100644
--- a/configure.in
+++ b/configure.in
@@ -940,6 +940,15 @@ if test x$BUILD_LVMETAD = xyes; then
 fi
 
 ################################################################################
+dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
+AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
+AC_ARG_ENABLE(udev-systemd-background-jobs,
+	      AC_HELP_STRING([--enable-udev-systemd-background-jobs],
+			     [enable udev-systemd protocol to instantiate a service for background job]),
+	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval, UDEV_SYSTEMD_BACKGROUND_JOBS=no)
+AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
+
+################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
 AC_ARG_ENABLE(udev_sync,
@@ -1626,6 +1635,7 @@ AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(CUNIT_LIBS)
@@ -1700,6 +1710,7 @@ scripts/cmirrord_init_red_hat
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
+scripts/lvm2_pvscan_systemd_red_hat at .service
 scripts/lvm2_monitoring_init_red_hat
 scripts/dm_event_systemd_red_hat.socket
 scripts/dm_event_systemd_red_hat.service
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index a658903..fac7e40 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -107,6 +107,7 @@ endif
 ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmetad.socket
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
+	$(INSTALL_DATA) lvm2_pvscan_systemd_red_hat at .service $(systemd_unit_dir)/lvm2-pvscan at .service
 endif
 
 install_tmpfiles_configuration:
@@ -118,6 +119,7 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
 		     lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
+		     lvm2_lvmetad_systemd_red_hat at .service \
 		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
 		     blk_availability_systemd_red_hat.service \
 		     blkdeactivate.sh
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
new file mode 100644
index 0000000..9d91b5e
--- /dev/null
+++ b/scripts/lvm2_pvscan_systemd_red_hat@.service.in
@@ -0,0 +1,11 @@
+[Unit]
+Description=LVM2 PV scan on %I
+Documentation=man:pvscan(8)
+DefaultDependencies=no
+After=lvm2-lvmetad.socket %i.device
+Before=shutdown.target
+Conflicts=shutdown.target
+
+[Service]
+Type=simple
+ExecStart=@sbindir@/pvscan --cache --activate ay %I
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 3303f4d..3e303b1 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -79,6 +79,6 @@ LABEL="lvm_scan"
 #  MD    |          |      X      |       X*       |                   |
 #  loop  |          |      X      |       X*       |                   |
 #  other |    X     |             |       X        |                   |   X
-RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
+(PVSCAN_RULE)
 
 LABEL="lvm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 5c15bdb..fdf43df 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -46,8 +46,14 @@ else
 BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
+ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
+PVSCAN_RULE=ENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$devnode.service\"
+else
+PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
+endif
+
 %.rules: %.rules.in
-	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)


