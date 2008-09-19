From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 15:44:08 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW daemons/clvmd/lvm-f ...
Message-ID: <20080919154408.28915.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 15:44:03

Modified files:
	.              : VERSION WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	tools          : vgreduce.c 

Log message:
	fix last release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.962&r2=1.963
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/VERSION	2008/09/19 06:48:48	1.181
+++ LVM2/VERSION	2008/09/19 15:44:03	1.182
@@ -1 +1 @@
-2.02.40-cvs (2008-09-18)
+2.02.41-cvs (2008-09-19)
--- LVM2/WHATS_NEW	2008/09/19 06:48:48	1.962
+++ LVM2/WHATS_NEW	2008/09/19 15:44:03	1.963
@@ -1,3 +1,6 @@
+Version 2.02.41 -
+=====================================
+
 Version 2.02.40 - 19th September 2008
 =====================================
   Allow lvremove to remove LVs from VGs with missing PVs.
--- LVM2/daemons/clvmd/lvm-functions.c	2008/09/19 06:41:57	1.45
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/09/19 15:44:03	1.46
@@ -141,8 +141,7 @@
 {
 	static char buf[128];
 
-	sprintf(buf, "0x%x (%s%s%s)", flags,
-		flags & LCK_PARTIAL_MODE	  ? "PARTIAL " : "",
+	sprintf(buf, "0x%x (%s%s)", flags,
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "");
 
--- LVM2/tools/vgreduce.c	2008/09/19 06:42:00	1.83
+++ LVM2/tools/vgreduce.c	2008/09/19 15:44:03	1.84
@@ -163,7 +163,9 @@
 
 static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 {
+	struct list *pvh, *pvht;
 	struct list *lvh, *lvht;
+	struct pv_list *pvl;
 	struct lv_list *lvl, *lvl2, *lvlt;
 	struct logical_volume *lv;
 	struct physical_volume *pv;
@@ -190,7 +192,8 @@
 				/* FIXME Also check for segs on deleted LVs (incl pvmove) */
 
 				pv = seg_pv(seg, s);
-				if (!pv || !pv_dev(pv)) {
+				if (!pv || !pv_dev(pv) ||
+				    (pv->status & MISSING_PV)) {
 					if (arg_count(cmd, mirrorsonly_ARG) &&
 					    !(lv->status & MIRROR_IMAGE)) {
 						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
@@ -211,8 +214,21 @@
 		return 0;
 	}
 
-	if (!_consolidate_vg(cmd, vg))
-		return_0;
+	/*
+	 * Remove missing PVs. FIXME: This duplicates _consolidate_vg above,
+	 * but we cannot use that right now, since the LV removal code in this
+	 * function leaves the VG in a "somewhat inconsistent" state and
+	 * _consolidate_vg doesn't like that -- specifically, mirrors are fixed
+	 * up *after* the PVs are removed. All this should be gradually
+	 * superseded by lvconvert --repair.
+	 */
+	list_iterate_safe(pvh, pvht, &vg->pvs) {
+		pvl = list_item(pvh, struct pv_list);
+		if (pvl->pv->dev)
+			continue;
+		if (!_remove_pv(vg, pvl, 0))
+			return_0;
+	}
 
 	/* FIXME Recovery.  For now people must clean up by hand. */
 


