From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Sep 2009 20:22:36 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c tools/toolli ...
Message-ID: <20090929202236.10724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-29 20:22:35

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c toollib.c toollib.h vgchange.c 

Log message:
	Don't attempt to restart pvmoves when deactivating LVs in vgchange.
	Restart lvconverts in vgchange by sharing lv_spawn_background_polling.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1280&r2=1.1281
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2009/09/29 19:35:26	1.1280
+++ LVM2/WHATS_NEW	2009/09/29 20:22:35	1.1281
@@ -1,5 +1,7 @@
 Version 2.02.54 -
 =====================================
+  Don't attempt to restart pvmoves when deactivating LVs in vgchange.
+  Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
   Generalise polldaemon code by changing mirror-specific variable names.
   Don't attempt to deactivate an LV if any of its snapshots are in use.
   Return fail if lv_deactivate fails to remove device from kernel.
--- LVM2/tools/lvchange.c	2009/09/14 22:47:49	1.110
+++ LVM2/tools/lvchange.c	2009/09/29 20:22:35	1.111
@@ -105,7 +105,6 @@
 				 struct logical_volume *lv)
 {
 	int activate;
-	const char *pvname;
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
@@ -136,18 +135,7 @@
 				return_0;
 		}
 
-		if ((lv->status & LOCKED) &&
-		    (pvname = get_pvmove_pvname_from_lv(lv))) {
-			log_verbose("Spawning background pvmove process for %s",
-				    pvname);
-			pvmove_poll(cmd, pvname, 1);
-		}
-
-		if (lv->status & CONVERTING) {
-			log_verbose("Spawning background lvconvert process for %s",
-				    lv->name);
-			lvconvert_poll(cmd, lv, 1);
-		}
+		lv_spawn_background_polling(cmd, lv);
 	}
 
 	return 1;
--- LVM2/tools/toollib.c	2009/09/15 13:49:11	1.170
+++ LVM2/tools/toollib.c	2009/09/29 20:22:35	1.171
@@ -1247,3 +1247,22 @@
 	
 	return r;
 }
+
+void lv_spawn_background_polling(struct cmd_context *cmd,
+				 struct logical_volume *lv)
+{
+	const char *pvname;
+
+	if ((lv->status & LOCKED) &&
+	    (pvname = get_pvmove_pvname_from_lv(lv))) {
+		log_verbose("Spawning background pvmove process for %s",
+			    pvname);
+		pvmove_poll(cmd, pvname, 1);
+	}
+
+	if (lv->status & CONVERTING) {
+		log_verbose("Spawning background lvconvert process for %s",
+			lv->name);
+		lvconvert_poll(cmd, lv, 1);
+	}
+}
--- LVM2/tools/toollib.h	2009/07/01 17:00:52	1.63
+++ LVM2/tools/toollib.h	2009/09/29 20:22:35	1.64
@@ -105,4 +105,7 @@
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
+void lv_spawn_background_polling(struct cmd_context *cmd,
+				 struct logical_volume *lv);
+
 #endif
--- LVM2/tools/vgchange.c	2009/09/15 18:35:14	1.86
+++ LVM2/tools/vgchange.c	2009/09/29 20:22:35	1.87
@@ -91,13 +91,9 @@
 		} else if (!activate_lv(cmd, lv))
 			continue;
 
-		if ((lv->status & PVMOVE) &&
-		    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
-			log_verbose("Spawning background process for %s %s",
-				    lv->name, pvname);
-			pvmove_poll(cmd, pvname, 1);
-			continue;
-		}
+		if (activate != CHANGE_AN && activate != CHANGE_ALN &&
+		    (lv->status & (PVMOVE|CONVERTING)))
+			lv_spawn_background_polling(cmd, lv);
 
 		count++;
 	}


