From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 14:35:01 -0000
Subject: LVM2/tools vgmerge.c vgsplit.c
Message-ID: <20110330143501.14414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 14:35:01

Modified files:
	tools          : vgmerge.c vgsplit.c 

Log message:
	Fix free_vg order
	
	As now the FID management is more complex, the code inside free_vg needs
	to access some parts of memory pools which were not needed before.
	
	For this - makes the order of unlock_and_free_vg() unconditional.
	Keek using unlock_and_free_vg() API function.
	
	For properly working VG locking mechanism only the alphabeting locking
	orderer needs to be preserved.
	
	TODO: there could be few more code parts simplified when we 'officially'
	support of referencies between different memory pools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/tools/vgmerge.c	2011/02/18 14:47:31	1.72
+++ LVM2/tools/vgmerge.c	2011/03/30 14:35:00	1.73
@@ -151,13 +151,13 @@
 		  vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
 bad:
-	if (lock_vg_from_first) {
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-	} else {
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
-	}
+	/*
+	 * Note: as vg_to is referencing moved elements from vg_from
+	 * the order of free_vg calls is mandatory.
+	 */
+	unlock_and_free_vg(cmd, vg_to, vg_name_to);
+	unlock_and_free_vg(cmd, vg_from, vg_name_from);
+
 	return r;
 }
 
--- LVM2/tools/vgsplit.c	2011/02/18 14:47:31	1.105
+++ LVM2/tools/vgsplit.c	2011/03/30 14:35:01	1.106
@@ -487,12 +487,12 @@
 	r = ECMD_PROCESSED;
 
 bad:
-	if (lock_vg_from_first) {
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-	} else {
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
-	}
+	/*
+	 * Note: as vg_to is referencing moved elements from vg_from
+	 * the order of free_vg calls is mandatory.
+	 */
+	unlock_and_free_vg(cmd, vg_to, vg_name_to);
+	unlock_and_free_vg(cmd, vg_from, vg_name_from);
+
 	return r;
 }


