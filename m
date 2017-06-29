From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:49 -0400
Subject: master - lvm2_cluster_activation_red_hat.sh: double quote
Message-ID: <201706292026.v5TKQnxS026531@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d34bc65dd05beb734c8ae65b86a11b37c3c2c94
Commit:        4d34bc65dd05beb734c8ae65b86a11b37c3c2c94
Parent:        051c7f88cf8968feab241604cb09547e23a79599
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 22:12:23 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvm2_cluster_activation_red_hat.sh: double quote

---
 scripts/lvm2_cluster_activation_red_hat.sh.in |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
index abea026..04d2cc6 100644
--- a/scripts/lvm2_cluster_activation_red_hat.sh.in
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -2,30 +2,30 @@
 
 sbindir=@sbindir@
 
-lvm_vgchange=${sbindir}/vgchange
-lvm_vgscan=${sbindir}/vgscan
-lvm_vgs=${sbindir}/vgs
-lvm_lvm=${sbindir}/lvm
+lvm_vgchange="${sbindir}/vgchange"
+lvm_vgscan="${sbindir}/vgscan"
+lvm_vgs="${sbindir}/vgs"
+lvm_lvm="${sbindir}/lvm"
 
 clustered_vgs() {
-	${lvm_vgs} --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
+	"${lvm_vgs}" --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
 }
 
 activate() {
-	eval local $(${lvm_lvm} dumpconfig devices/obtain_device_list_from_udev 2>/dev/null) 2>/dev/null
+	eval local "$("${lvm_lvm}" dumpconfig devices/obtain_device_list_from_udev 2>/dev/null)" 2>/dev/null
 	if [ $? -ne 0 ]; then
 		echo "Warning: expected single couple of key=value in output of dumpconfig"
 	fi
 
-	if [ -z $obtain_device_list_from_udev -o $obtain_device_list_from_udev -ne 1 ]; then
+	if [ -z "$obtain_device_list_from_udev" ] || [ "$obtain_device_list_from_udev" -ne 1 ]; then
 		echo -n "lvm.conf option obtain_device_list_from_udev!=1: Executing vgscan"
-		${lvm_vgscan} > /dev/null 2>&1
+		"${lvm_vgscan}" > /dev/null 2>&1
 	fi
 
 	echo -n "Activating ${LVM_VGS:-"all VG(s)"}: "
 	# Respect activation/auto_activation_volume_list!
 	# Call "-aay" which is equal to "-aly" but respects this list.
-        ${lvm_vgchange} -aay $LVM_VGS || return 1
+        "${lvm_vgchange}" -aay $LVM_VGS || return 1
 
 	return 0
 }
@@ -35,10 +35,10 @@ deactivate()
 	# NOTE: following section will be replaced by blkdeactivate script
 	# with option supporting request to deactivate all clustered volume
 	# groups in the system
-	[ -z $LVM_VGS ] && LVM_VGS="$(clustered_vgs)"
+	[ -z "$LVM_VGS" ] && LVM_VGS="$(clustered_vgs)"
 	if [ -n "$LVM_VGS" ]; then
 		echo -n "Deactivating clustered VG(s): "
-		${lvm_vgchange} -anl $LVM_VGS || return 1
+		"${lvm_vgchange}" -anl $LVM_VGS || return 1
 	fi
 
 	return 0
@@ -59,4 +59,4 @@ case "$1" in
 	;;
 esac
 
-exit $rtrn
+exit "$rtrn"


