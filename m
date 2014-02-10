From: okozina <okozina@fedoraproject.org>
Date: Mon, 10 Feb 2014 16:14:01 +0000 (UTC)
Subject: master - Add systemd native service for clvmd and cluster activation
Message-ID: <20140210161401.518A76168B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd41dd8f9ca38a31144ab7f8ed6a14b455dd7611
Commit:        fd41dd8f9ca38a31144ab7f8ed6a14b455dd7611
Parent:        ffa623c53d94a75e40067a2d186ac65a64abb890
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Feb 10 17:05:10 2014 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Feb 10 17:13:49 2014 +0100

Add systemd native service for clvmd and cluster activation

The commit splits original clvmd service in two new native services
for systemd enabled systems while original init scripts remain unaltered.

New systemd native services:

  1) clvmd daemon itself (lvm2_clvmd_red_hat.service.in)
  2) (de)activation of clustered VGs (lvm2_cluster_activation_red_hat.service.in)

There're several reasons to split it. First, there's no support for conditional
stop in systemd and AFAIK they don't plan to support it. In other words:
if the deactivation fails for some reason, systemd doesn't care and will simply
kill all remaining processes in original cgroup (by default). Killing the
remaining procs can be suppressed however it doesn't solve the following problem:

You can't repeat the stop command of a failed service. The repeated stop command
is simply not propagated to the service in a failed state. You would have to start
and then try to stop the service again. Unfortunately, this can't be done while
the daemon is still running (and we need the daemon to stay active until all
clustered VGs are deactivated properly).

In a separated setup we need only to restart the failed activation service and
that's fine.
---
 WHATS_NEW                                          |    1 +
 configure.in                                       |    3 +
 make.tmpl.in                                       |    1 +
 scripts/Makefile.in                                |    8 ++-
 scripts/lvm2_cluster_activation_red_hat.service.in |   16 +++++
 scripts/lvm2_cluster_activation_red_hat.sh.in      |   68 ++++++++++++++++++++
 scripts/lvm2_clvmd_red_hat.service.in              |   21 ++++++
 7 files changed, 117 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c4a3dcb..1b24781 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -17,6 +17,7 @@ Version 2.02.106 -
   Issue error if libbblkid detects signature and fails to return offset/length.
   Update autoconf config.guess/sub to 2014-01-01.
   Online thin pool metadata resize requires 1.10 kernel thin pool target.
+  Add systemd native service for the clvmd and cluster activation.
 
 Version 2.02.105 - 20th January 2014
 ====================================
diff --git a/configure.in b/configure.in
index 7b56b13..60b816f 100644
--- a/configure.in
+++ b/configure.in
@@ -1788,7 +1788,10 @@ python/setup.py
 scripts/blkdeactivate.sh
 scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
+scripts/lvm2_cluster_activation_red_hat.sh
+scripts/lvm2_cluster_activation_red_hat.service
 scripts/clvmd_init_red_hat
+scripts/lvm2_clvmd_red_hat.service
 scripts/cmirrord_init_red_hat
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
diff --git a/make.tmpl.in b/make.tmpl.in
index 65b1da0..7d7d701 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -84,6 +84,7 @@ pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)$(sysconfdir)/rc.d/init.d
 systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
 systemd_generator_dir = $(DESTDIR)@systemdutildir@/system-generators
+systemd_dir = $(DESTDIR)@systemdutildir@
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 pyexecdir = $(DESTDIR)$(prefix)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ed587ca..2f1fb2a 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -111,6 +111,11 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
 	$(INSTALL_DATA) lvm2_pvscan_systemd_red_hat at .service $(systemd_unit_dir)/lvm2-pvscan at .service
 endif
+ifneq ("@CLVMD@", "none")
+	$(INSTALL_DATA) lvm2_clvmd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
+	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
+	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
@@ -124,4 +129,5 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     lvm2_pvscan_systemd_red_hat at .service \
 		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
 		     blk_availability_systemd_red_hat.service \
-		     blkdeactivate.sh
+		     blkdeactivate.sh lvm2_clvmd_red_hat.service \
+		     lvm2_cluster_activation_red_hat.service lvm2_cluster_activation_red_hat.sh
diff --git a/scripts/lvm2_cluster_activation_red_hat.service.in b/scripts/lvm2_cluster_activation_red_hat.service.in
new file mode 100644
index 0000000..b6887c3
--- /dev/null
+++ b/scripts/lvm2_cluster_activation_red_hat.service.in
@@ -0,0 +1,16 @@
+[Unit]
+Description=Clustered LVM volumes activation service
+Requires=lvm2-clvmd.service
+After=lvm2-clvmd.service cmirrord.service
+OnFailure=lvm2-clvmd.service
+DefaultDependencies=false
+
+[Service]
+Type=simple
+RemainAfterExit=yes
+EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
+ExecStart=@systemdutildir@/lvm2-cluster-activation activate
+ExecStop=@systemdutildir@/lvm2-cluster-activation deactivate
+
+[Install]
+WantedBy=sysinit.target
diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
new file mode 100644
index 0000000..2531ef2
--- /dev/null
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -0,0 +1,68 @@
+#!/bin/bash
+
+sbindir=@sbindir@
+
+lvm_vgchange=${sbindir}/vgchange
+lvm_vgscan=${sbindir}/vgscan
+lvm_vgs=${sbindir}/vgs
+lvm_lvm=${sbindir}/lvm
+
+parse_clustered_vgs() {
+	while read -r name attrs;
+	do
+		test "${attrs:5:1}" == 'c' && echo -n "$name "
+	done
+}
+
+# NOTE: replace this with vgs, once display filter per attr is implemented.
+clustered_vgs() {
+	${lvm_vgs} -o vg_name,vg_attr --noheadings | parse_clustered_vgs
+}
+
+activate() {
+	eval local $(${lvm_lvm} dumpconfig devices/obtain_device_list_from_udev 2>/dev/null) 2>/dev/null
+	if [ $? -ne 0 ]; then
+		echo "Warning: expected single couple of key=value in output of dumpconfig"
+	fi
+
+	if [ -z $obtain_device_list_from_udev -o $obtain_device_list_from_udev -ne 1 ]; then
+		echo -n "lvm.conf option obtain_device_list_from_udev!=1: Executing vgscan"
+		${lvm_vgscan} > /dev/null 2>&1
+	fi
+
+	echo -n "Activating ${LVM_VGS:-"all VG(s)"}: "
+        ${lvm_vgchange} -ayl $LVM_VGS || return 1
+
+	return 0
+}
+
+deactivate()
+{
+	# NOTE: following section will be replaced by blkdeactivate script
+	# with option supporting request to deactivate all clustered volume
+	# groups in the system
+	[ -z $LVM_VGS ] && LVM_VGS="$(clustered_vgs)"
+	if [ -n "$LVM_VGS" ]; then
+		echo -n "Deactivating clustered VG(s): "
+		${lvm_vgchange} -anl $LVM_VGS || return 1
+	fi
+
+	return 0
+}
+
+case "$1" in
+  deactivate)
+	deactivate
+	rtrn=$?
+	;;
+  activate)
+	activate
+	rtrn=$?
+	;;
+  *)
+	echo $"Usage: $0 {activate|deactivate}"
+	rtrn=3
+	;;
+esac
+
+exit $rtrn
diff --git a/scripts/lvm2_clvmd_red_hat.service.in b/scripts/lvm2_clvmd_red_hat.service.in
new file mode 100644
index 0000000..c10bdc4
--- /dev/null
+++ b/scripts/lvm2_clvmd_red_hat.service.in
@@ -0,0 +1,21 @@
+[Unit]
+Description=Clustered LVM daemon
+Documentation=man:clvmd(8)
+After=dlm.service corosync.service
+Before=remote-fs.target
+Requires=network.target dlm.service corosync.service
+RefuseManualStart=true
+RefuseManualStop=true
+StopWhenUnneeded=true
+
+[Service]
+Type=forking
+Environment=CLVMD_OPTS=-T30
+EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
+ExecStart=@sbindir@/clvmd $CLVMD_OPTS
+SuccessExitStatus=5
+TimeoutStartSec=30
+TimeoutStopSec=10
+OOMScoreAdjust=-1000
+Restart=on-abort
+PIDFile=@CLVMD_PIDFILE@


