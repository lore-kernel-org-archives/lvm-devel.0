From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 17 May 2010 03:18:28 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20100517031828.8171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2010-05-17 03:18:28

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix clvmd init script stop function to not deactive non-clustered volume groups.
	
	https://bugzilla.redhat.com/show_bug.cgi?id=592362

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1559&r2=1.1560
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/05/14 15:19:42	1.1559
+++ LVM2/WHATS_NEW	2010/05/17 03:18:27	1.1560
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Fix clvmd init script to not deactive non-clustered volume groups.
   Disallow cluster attr toggling if there are active mirrors or snapshots.
   Use /bin/bash for scripts with bashisms.
   Skip internal lvm devices in scan if ignore suspended devices is requested.
--- LVM2/scripts/clvmd_init_red_hat.in	2010/04/20 14:07:38	1.6
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/05/17 03:18:28	1.7
@@ -109,7 +109,10 @@
 {
 	rh_status_q || return 0
 
-	action "Deactivating clusterd VG(s):" ${lvm_vgchange} -anl ${LVM_VGS:-$(clustered_vgs)} || return $?
+	[ -z "$LVM_VGS" ] && LVM_VGS="$(clustered_vgs)"
+	if [ -n "$LVM_VGS" ]; then
+		action "Deactivating clustered VG(s):" ${lvm_vgchange} -anl $LVM_VGS || return $?
+	fi
 
 	action "Signaling $DAEMON to exit" kill -TERM $(pidofproc $DAEMON) || return $?
 


