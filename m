From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Dec 2009 13:54:46 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20091217135446.11173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-17 13:54:46

Modified files:
	tools          : vgreduce.c 

Log message:
	Also clean up MISSING devices in --removemissing --force in vgreduce.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/tools/vgreduce.c	2009/09/14 22:47:50	1.98
+++ LVM2/tools/vgreduce.c	2009/12/17 13:54:46	1.99
@@ -224,7 +224,7 @@
 	 */
 	dm_list_iterate_safe(pvh, pvht, &vg->pvs) {
 		pvl = dm_list_item(pvh, struct pv_list);
-		if (pvl->pv->dev)
+		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
 			continue;
 		if (!_remove_pv(vg, pvl, 0))
 			return_0;


