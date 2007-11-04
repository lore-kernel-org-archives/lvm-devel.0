From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2007 16:28:57 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20071104162857.3845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-04 16:28:57

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	fix new lvremove checks - mustn't fail when activation is disabled

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/lib/metadata/lv_manip.c	2007/10/12 14:29:32	1.131
+++ LVM2/lib/metadata/lv_manip.c	2007/11/04 16:28:57	1.132
@@ -1839,45 +1839,37 @@
 
 	/* FIXME Ensure not referred to by another existing LVs */
 
-	/*
-	 * If we can't get information about the LV from the kernel, or
-	 * someone has the LV device open, fail.
-	 */
-	if (!lv_info(cmd, lv, &info, 1)) {
-		log_error("Unable to obtain status for logical volume \"%s\"",
-			  lv->name);
-		return 0;
-	}
-	if (info.open_count) {
-		log_error("Can't remove open logical volume \"%s\"",
-			  lv->name);
-		return 0;
-	}
-
-	/*
-	 * Check for confirmation prompts in the following cases:
-	 * 1) Clustered VG, and some remote nodes have the LV active
-	 * 2) Non-clustered VG, but LV active locally
-	 */
-	if ((vg_status(vg) & CLUSTERED) && !activate_lv_excl(cmd, lv) &&
-	    (force == PROMPT)) {
-		if (yes_no_prompt("Logical volume \"%s\" is active on other "
-				  "cluster nodes.  Really remove? [y/n]: ",
-				  lv->name) == 'n') {
-			log_print("Logical volume \"%s\" not removed",
+	if (lv_info(cmd, lv, &info, 1)) {
+		if (info.open_count) {
+			log_error("Can't remove open logical volume \"%s\"",
 				  lv->name);
 			return 0;
 		}
-	} else if (info.exists && (force == PROMPT)) {
-		 if (yes_no_prompt("Do you really want to remove active "
-				   "logical volume \"%s\"? [y/n]: ",
-				   lv->name) == 'n') {
-			 log_print("Logical volume \"%s\" not removed",
-				  lv->name);
-			 return 0;
-		 }
-	}
 
+		/*
+		 * Check for confirmation prompts in the following cases:
+		 * 1) Clustered VG, and some remote nodes have the LV active
+		 * 2) Non-clustered VG, but LV active locally
+		 */
+		if ((vg_status(vg) & CLUSTERED) && !activate_lv_excl(cmd, lv) &&
+		    (force == PROMPT)) {
+			if (yes_no_prompt("Logical volume \"%s\" is active on other "
+					  "cluster nodes.  Really remove? [y/n]: ",
+					  lv->name) == 'n') {
+				log_print("Logical volume \"%s\" not removed",
+					  lv->name);
+				return 0;
+			}
+		} else if (info.exists && (force == PROMPT)) {
+			 if (yes_no_prompt("Do you really want to remove active "
+					   "logical volume \"%s\"? [y/n]: ",
+					   lv->name) == 'n') {
+				 log_print("Logical volume \"%s\" not removed",
+					  lv->name);
+				 return 0;
+			 }
+		}
+	}
 
 	if (!archive(vg))
 		return 0;


