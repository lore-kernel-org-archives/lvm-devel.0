From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jul 2008 15:19:43 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20080717151943.2052.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-17 15:19:42

Modified files:
	tools          : lvcreate.c 

Log message:
	Refactor _lvcreate() - no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/tools/lvcreate.c	2008/06/05 13:38:30	1.175
+++ LVM2/tools/lvcreate.c	2008/07/17 15:19:42	1.176
@@ -523,8 +523,6 @@
 	struct lvinfo info;
 	uint32_t pv_extent_count;
 
-	status |= lp->permission | VISIBLE_LV;
-
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
@@ -544,16 +542,6 @@
 		return 0;
 	}
 
-	/*
-	 * Create the pv list.
-	 */
-	if (lp->pv_count) {
-		if (!(pvh = create_pv_list(cmd->mem, vg,
-					   lp->pv_count, lp->pvs, 1)))
-			return_0;
-	} else
-		pvh = &vg->pvs;
-
 	if (lp->stripe_size > vg->extent_size) {
 		log_error("Reducing requested stripe size %s to maximum, "
 			  "physical extent size %s",
@@ -594,6 +582,16 @@
 		lp->extents = (uint64_t) tmp_size / vg->extent_size;
 	}
 
+	/*
+	 * Create the pv list.
+	 */
+	if (lp->pv_count) {
+		if (!(pvh = create_pv_list(cmd->mem, vg,
+					   lp->pv_count, lp->pvs, 1)))
+			return_0;
+	} else
+		pvh = &vg->pvs;
+
 	switch(lp->percent) {
 		case PERCENT_VG:
 			lp->extents = lp->extents * vg->extent_count / 100;
@@ -631,6 +629,8 @@
 		return 0;
 	}
 
+	status |= lp->permission | VISIBLE_LV;
+
 	if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "


