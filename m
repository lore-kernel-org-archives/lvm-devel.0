From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Jun 2010 16:24:16 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20100623162416.4879.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-23 16:24:14

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix clvmd init script status
	
	- s/Active clustred VG/clustered VG/ (only LV can be active)
	
	- print only active LVs (not all) in status command
	(In the lvdisplay form /dev/vg/lv.)
	
	For now, still use awk (already used in clustered_vgs).
	
	https://bugzilla.redhat.com/show_bug.cgi?id=598495

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1629&r2=1.1630
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2010/06/23 12:54:46	1.1629
+++ LVM2/WHATS_NEW	2010/06/23 16:24:13	1.1630
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix clvmd initscript status to print only active clustered LVs.
   Fix typo "INTERNAL ERROR" -> "INTERNAL_ERROR" in libdm-iface.c.
   Add lv_path to reports to offer full /dev pathname.
   Fix typo in warning message about missing device with allocated data areas.
--- LVM2/scripts/clvmd_init_red_hat.in	2010/06/03 21:03:54	1.8
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/06/23 16:24:14	1.9
@@ -25,7 +25,7 @@
 lvm_vgchange=${sbindir}/vgchange
 lvm_vgdisplay=${sbindir}/vgdisplay
 lvm_vgscan=${sbindir}/vgscan
-lvm_lvs=${sbindir}/lvs
+lvm_lvdisplay=${sbindir}/lvdisplay
 
 CLVMDOPTS="-T30"
 
@@ -47,9 +47,10 @@
 		awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
 }
 
-clustered_lvs() {
+clustered_active_lvs() {
 	for i in $(clustered_vgs); do
-		${lvm_lvs} -o lv_name --noheadings $i
+		${lvm_lvdisplay} $i 2>/dev/null | \
+		awk 'BEGIN {RS="LV Name"} {if (/[^N^O^T] available/) print $1;}'
 	done
 }
 
@@ -197,8 +198,8 @@
 	rtrn=$?
 	if [ $rtrn = 0 ]; then
 		cvgs="$(clustered_vgs)"
-		echo Active clustered Volume Groups: ${cvgs:-"(none)"}
-		clvs="$(clustered_lvs)"
+		echo Clustered Volume Groups: ${cvgs:-"(none)"}
+		clvs="$(clustered_active_lvs)"
 		echo Active clustered Logical Volumes: ${clvs:-"(none)"}
 	fi
 	;;


