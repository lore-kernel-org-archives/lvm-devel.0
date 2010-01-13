From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:50:35 -0000
Subject: LVM2/tools toollib.c vgchange.c
Message-ID: <20100113015035.2807.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:50:34

Modified files:
	tools          : toollib.c vgchange.c 

Log message:
	Start background polling of merging stores on:
	- lvchange -ay or vgchange -ay.
	- lvchange --refresh or vgchange --refresh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/tools/toollib.c	2010/01/05 21:07:31	1.181
+++ LVM2/tools/toollib.c	2010/01/13 01:50:34	1.182
@@ -1261,6 +1261,18 @@
 	if (!r)
 		goto_out;
 
+	/*
+	 * check if snapshot merge should be polled
+	 * - unfortunately: even though the dev_manager will clear
+	 *   the lv's merge attributes if a merge is not possible;
+	 *   it is clearing a different instance of the lv (as
+	 *   retrieved with lv_from_lvid)
+	 * - fortunately: polldaemon will immediately shutdown if the
+	 *   origin doesn't have a status with a snapshot percentage
+	 */
+	if (background_polling() && lv_is_origin(lv) && lv->merging_snapshot)
+		lv_spawn_background_polling(cmd, lv);
+
 out:
 	return r;
 }
@@ -1295,7 +1307,7 @@
 		pvmove_poll(cmd, pvname, 1);
 	}
 
-	if (lv->status & CONVERTING) {
+	if (lv->status & CONVERTING || lv->merging_snapshot) {
 		log_verbose("Spawning background lvconvert process for %s",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
--- LVM2/tools/vgchange.c	2010/01/06 19:08:58	1.95
+++ LVM2/tools/vgchange.c	2010/01/13 01:50:34	1.96
@@ -68,12 +68,12 @@
 		else
 			lv_active = info.exists;
 
-		if (!lv_active ||
-		    !(lv->status & (PVMOVE|CONVERTING)))
-			continue;
-
-		lv_spawn_background_polling(cmd, lv);
-		count++;
+		if (lv_active &&
+		    (lv->status & (PVMOVE|CONVERTING) ||
+		     lv->merging_snapshot)) {
+			lv_spawn_background_polling(cmd, lv);
+			count++;
+		}
 	}
 
 	/*
@@ -140,7 +140,8 @@
 
 		if (background_polling() &&
 		    activate != CHANGE_AN && activate != CHANGE_ALN &&
-		    (lv->status & (PVMOVE|CONVERTING)))
+		    (lv->status & (PVMOVE|CONVERTING) ||
+		     lv->merging_snapshot))
 			lv_spawn_background_polling(cmd, lv);
 
 		count++;


