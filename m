From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Nov 2011 12:19:54 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20111108121954.23979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-08 12:19:53

Modified files:
	tools          : lvresize.c 

Log message:
	Thin ensure pool table is update after resize
	
	Always make sure table gets reloaded.
	For now activate and deactivate pool volume if it's not active.
	
	FIXME: we could do this only if we are sure some thin volume is alive.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/tools/lvresize.c	2011/11/07 10:58:13	1.142
+++ LVM2/tools/lvresize.c	2011/11/08 12:19:53	1.143
@@ -781,6 +781,20 @@
 
 	backup(vg);
 
+	/*
+	 * Update lvm pool metadata (drop messages) if the pool has been
+	 * resumed and do a pool active/deactivate in other case.
+	 *
+	 * Note: Active thin pool can be waiting for resize.
+	 *
+	 * FIXME: Activate only when thin volume is active
+	 */
+	if (lv_is_thin_pool(lv) &&
+	    !update_pool_lv(lv, !lv_is_active(lv))) {
+		stack;
+		return ECMD_FAILED;
+	}
+
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&


