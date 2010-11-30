From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2010 11:15:56 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20101130111556.24421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-30 11:15:55

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Avoid the automatic MISSING_PV recovery path in commands with special
	MISSING_PV handling (cmd->handles_missing_pvs is set).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.412&r2=1.413

--- LVM2/lib/metadata/metadata.c	2010/11/29 18:35:37	1.412
+++ LVM2/lib/metadata/metadata.c	2010/11/30 11:15:54	1.413
@@ -2614,6 +2614,14 @@
 {
 	struct pv_list *pvl;
 
+        /*
+         * Skip these checks in case the tool is going to deal with missing
+         * PVs, especially since the resulting messages can be pretty
+         * confusing.
+         */
+        if (correct_vg->cmd->handles_missing_pvs)
+            return;
+
 	dm_list_iterate_items(pvl, &correct_vg->pvs)
 		if (pv->dev == pvl->pv->dev && is_missing_pv(pvl->pv)) {
 			log_warn("Missing device %s reappeared, updating "


