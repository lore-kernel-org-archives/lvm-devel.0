From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 May 2009 09:55:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c tools ...
Message-ID: <20090520095535.13608.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-20 09:55:34

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	tools          : lvchange.c 

Log message:
	Use lock query instead of activate_lv_excl
	
	- switch lvremove to not force activate volume when removing
	- ditto for force resync
	
	- fix some wrong return codes in lvchange_resync()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1117&r2=1.1118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2009/05/20 09:52:37	1.1117
+++ LVM2/WHATS_NEW	2009/05/20 09:55:33	1.1118
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Use lock query instead of activate_lv_excl.
   Enable online resizing of mirrors.
   Use suspend with flush when device size was changed during table preload.
   Introduce CLVMD_CMD_LOCK_QUERY command for clvmd.
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:29:10	1.172
+++ LVM2/lib/metadata/lv_manip.c	2009/05/20 09:55:34	1.173
@@ -2036,28 +2036,13 @@
 			return 0;
 		}
 
-		/*
-		 * Check for confirmation prompts in the following cases:
-		 * 1) Clustered VG, and some remote nodes have the LV active
-		 * 2) Non-clustered VG, but LV active locally
-		 */
-		if (vg_is_clustered(vg) && !activate_lv_excl(cmd, lv) &&
-		    (force == PROMPT)) {
-			if (yes_no_prompt("Logical volume \"%s\" is active on other "
-					  "cluster nodes.  Really remove? [y/n]: ",
-					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			}
-		} else if (info.exists && (force == PROMPT)) {
-			 if (yes_no_prompt("Do you really want to remove active "
-					   "logical volume \"%s\"? [y/n]: ",
-					   lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			 }
+		if (lv_is_active(lv) && (force == PROMPT) &&
+		    yes_no_prompt("Do you really want to remove active "
+				  "%slogical volume %s? [y/n]: ",
+				  vg_is_clustered(vg) ? "clustered " : "",
+				  lv->name) == 'n') {
+			log_print("Logical volume %s not removed", lv->name);
+			return 0;
 		}
 	}
 
--- LVM2/tools/lvchange.c	2009/05/13 21:27:44	1.100
+++ LVM2/tools/lvchange.c	2009/05/20 09:55:34	1.101
@@ -201,7 +201,7 @@
 		if (info.open_count) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (info.exists) {
@@ -211,11 +211,11 @@
 					  lv->name) == 'n') {
 				log_print("Logical volume \"%s\" not resynced",
 					  lv->name);
-				return ECMD_FAILED;
+				return 0;
 			}
 
 			if (sigint_caught())
-				return ECMD_FAILED;
+				return 0;
 
 			active = 1;
 		}
@@ -225,17 +225,17 @@
 	monitored = dmeventd_monitor_mode();
 	init_dmeventd_monitor(0);
 
-	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
-		log_error("Can't get exclusive access to clustered volume %s",
-			  lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate %s for resync", lv->name);
 		return 0;
 	}
 
+	if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
+		log_error("Can't get exclusive access to clustered volume %s",
+			  lv->name);
+		return 0;
+	}
+
 	init_dmeventd_monitor(monitored);
 
 	log_lv = first_seg(lv)->log_lv;


