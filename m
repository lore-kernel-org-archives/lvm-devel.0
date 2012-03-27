From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Mar 2012 12:01:24 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20120327120124.16576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-27 12:01:23

Modified files:
	tools          : pvmove.c 

Log message:
	Fail early if cmirror is not detected and pvmove requires it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/tools/pvmove.c	2012/03/27 11:43:32	1.98
+++ LVM2/tools/pvmove.c	2012/03/27 12:01:22	1.99
@@ -274,7 +274,15 @@
 		return NULL;
 	}
 
-	if (lv_exclusive_count) {
+	if (vg_is_clustered(vg) && lv_active_count && *exclusive) {
+		log_error("Cannot move in clustered VG %s, "
+			  "clustered mirror (cmirror) not detected "
+			  "and LVs are activated non-exclusively.",
+			  vg->name);
+		return NULL;
+	}
+
+	if (vg_is_clustered(vg) && lv_exclusive_count) {
 		if (lv_active_count) {
 			log_error("Cannot move in clustered VG %s "
 				  "if some LVs are activated "


