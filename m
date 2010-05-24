From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 May 2010 08:59:31 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20100524085931.5827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-24 08:59:30

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Replicator: VG with cmd_missing_vgs does not generate output
	
	Do not print message if missing VG is found.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1591&r2=1.1592
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/WHATS_NEW	2010/05/21 15:28:16	1.1591
+++ LVM2/WHATS_NEW	2010/05/24 08:59:29	1.1592
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Avoid print activation message if there is a missing VG (Replicator).
   Fixed scripts/relpath.awk to work in mawk
   Add _add_partial_replicator_to_dtree().
   Activation code read and releases also remote VGs (Replicator).
--- LVM2/tools/vgchange.c	2010/05/06 11:15:56	1.102
+++ LVM2/tools/vgchange.c	2010/05/24 08:59:30	1.103
@@ -224,8 +224,10 @@
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	/* Print message only if there was not found a missing VG */
+	if (!vg->cmd_missing_vgs)
+		log_print("%d logical volume(s) in volume group \"%s\" now active",
+			  lvs_in_vg_activated(vg), vg->name);
 	return ret;
 }
 


