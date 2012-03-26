From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Mar 2012 20:31:01 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20120326203101.14850.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-26 20:31:01

Modified files:
	tools          : pvmove.c 

Log message:
	Use new flag PVMOVE_EXCLUSIVE in update_metatada call.
	
	There is no real functional change in this patch except it
	avoids checking cluster cmirror module twice.
	
	(Flag used in following patch.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/tools/pvmove.c	2012/03/13 20:21:27	1.94
+++ LVM2/tools/pvmove.c	2012/03/26 20:31:01	1.95
@@ -18,6 +18,7 @@
 #include "display.h"
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
+#define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
 
 static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 {
@@ -358,7 +359,7 @@
 			    struct logical_volume *lv_mirr,
 			    struct dm_list *lvs_changed, unsigned flags)
 {
-	unsigned exclusive = _pvmove_is_exclusive(cmd, vg);
+	unsigned exclusive = (flags & PVMOVE_EXCLUSIVE) ? 1 : 0;
 	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
 	int r = 0;
 
@@ -390,6 +391,9 @@
 	/* Only the first mirror segment gets activated as a mirror */
 	/* FIXME: Add option to use a log */
 	if (first_time) {
+		if (!exclusive && _pvmove_is_exclusive(cmd, vg))
+			exclusive = 1;
+
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			if (test_mode()) {
 				r = 1;
@@ -428,7 +432,7 @@
 	struct dm_list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
-	unsigned first_time = 1;
+	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
 	int r = ECMD_FAILED;
 
@@ -485,7 +489,7 @@
 			goto out;
 		}
 
-		first_time = 0;
+		flags &= ~PVMOVE_FIRST_TIME;
 	} else {
 		/* Determine PE ranges to be moved */
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
@@ -518,9 +522,11 @@
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
-	if (first_time) {
+	if (flags & PVMOVE_FIRST_TIME) {
+		if (exclusive)
+			flags |= PVMOVE_EXCLUSIVE;
 		if (!_update_metadata
-		    (cmd, vg, lv_mirr, lvs_changed, PVMOVE_FIRST_TIME))
+		    (cmd, vg, lv_mirr, lvs_changed, flags))
 			goto_out;
 	}
 


