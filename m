From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 02:15:56 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080410021556.2212.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 02:15:56

Modified files:
	tools          : vgsplit.c 

Log message:
	Minor vgsplit cleanups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/tools/vgsplit.c	2008/04/10 01:30:22	1.59
+++ LVM2/tools/vgsplit.c	2008/04/10 02:15:56	1.60
@@ -33,7 +33,7 @@
 	vg_from->pv_count--;
 	vg_to->pv_count++;
 
-	pv = list_item(pvl, struct pv_list)->pv;
+	pv = pvl->pv;
 
 	vg_from->extent_count -= pv_pe_count(pv);
 	vg_to->extent_count += pv_pe_count(pv);
@@ -100,8 +100,7 @@
 	struct logical_volume *lv;
 
 	lv = list_item(lvh, struct lv_list)->lv;
-	list_del(lvh);
-	list_add(&vg_to->lvs, lvh);
+	list_move(lvh, &vg_to->lvs);
 	
 	if (lv->status & SNAPSHOT) {
 		vg_from->snapshot_count--;


