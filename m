From: Ondrej Kozina <okozina@redhat.com>
Date: Thu,  1 Nov 2012 18:22:16 +0100
Subject: [PATCH 2/3] - add clvmd activation systemd service
In-Reply-To: <1351790537-10199-1-git-send-email-okozina@redhat.com>
References: <1351790537-10199-1-git-send-email-okozina@redhat.com>
Message-ID: <1351790537-10199-3-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OnFailure=clvmd-daemon.service - this will prevent the daemon to be killed if the (de)activation fails (yup, ugly hack).

clvmd_activation_script_red_hat.sh.in - It's a very simple rewrite of the original inititscript (no waiting in a loop, no awk)

---
 scripts/clvmd_activation_script_red_hat.sh.in      | 71 ++++++++++++++++++++++
 .../clvmd_activation_systemd_red_hat.service.in    | 14 +++++
 2 files changed, 85 insertions(+)
 create mode 100755 scripts/clvmd_activation_script_red_hat.sh.in
 create mode 100644 scripts/clvmd_activation_systemd_red_hat.service.in

diff --git a/scripts/clvmd_activation_script_red_hat.sh.in b/scripts/clvmd_activation_script_red_hat.sh.in
new file mode 100755
index 0000000..07eadec
--- /dev/null
+++ b/scripts/clvmd_activation_script_red_hat.sh.in
@@ -0,0 +1,71 @@
+#!/bin/bash
+
+sbindir=/usr/sbin
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
+                ${lvm_vgchange} -anl $LVM_VGS || return 1
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
+  reload)
+	rtrn=0;
+	;;
+  *)
+	echo $"Usage: $0 {activate|deactivate|reload}"
+	rtrn=3
+	;;
+esac
+
+exit $rtrn
diff --git a/scripts/clvmd_activation_systemd_red_hat.service.in b/scripts/clvmd_activation_systemd_red_hat.service.in
new file mode 100644
index 0000000..b5bd963
--- /dev/null
+++ b/scripts/clvmd_activation_systemd_red_hat.service.in
@@ -0,0 +1,14 @@
+[Unit]
+Description=Clustered LVM volumes activation service
+Requires=clvmd-daemon.service
+After=clvmd-daemon.service
+OnFailure=clvmd-daemon.service
+PropagatesReloadTo=clvmd-daemon.service
+
+[Service]
+Type=simple
+RemainAfterExit=yes
+EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
+ExecStart=@libexecdir@/clvmd/clvmd.sh activate
+ExecStop=@libexecdir@/clvmd/clvmd.sh deactivate
+ExecReload=@libexecdir@/clvmd/clvmd.sh reload
-- 
1.7.12.4


