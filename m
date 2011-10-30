From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:07:39 -0000
Subject: LVM2 lib/metadata/lv_manip.c tools/lvchange.c ...
Message-ID: <20111030220739.7780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:07:38

Modified files:
	lib/metadata   : lv_manip.c 
	tools          : lvchange.c vgchange.c 

Log message:
	Thin creation without activation
	
	All thins are created with the next activation and VG is updated
	without messages. Only some basic commands works.
	(i.e. lvcreate -an  -V10 -T mvg/pool)
	There can be some combination to confuse this system.
	
	This functionality for snapshots is going to be interesting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.315&r2=1.316
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/lib/metadata/lv_manip.c	2011/10/30 22:02:18	1.315
+++ LVM2/lib/metadata/lv_manip.c	2011/10/30 22:07:38	1.316
@@ -4194,8 +4194,12 @@
 
 	init_dmeventd_monitor(lp->activation_monitoring);
 
-	if (seg_is_thin_pool(lp) || seg_is_thin(lp)) {
-		if (!activate_lv_excl(cmd, lv)) {
+	if (seg_is_thin(lp)) {
+		if ((lp->activate == CHANGE_AY) ||
+		    (lp->activate == CHANGE_ALY))
+                        lp->activate = CHANGE_AE;
+		if ((lp->activate == CHANGE_AE) &&
+		    !activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate thin %s.",
 				  lv->name);
 			goto deactivate_and_revert_new_lv;
@@ -4222,7 +4226,7 @@
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
 		goto deactivate_and_revert_new_lv;
-	} else if (seg_is_thin_volume(lp)) {
+	} else if (seg_is_thin_volume(lp) && (lp->activate == CHANGE_AE)) {
 		/* FIXME: for now we may drop any queued thin messages
 		 * since we are sure everything was activated already */
 		if (!detach_pool_messages(first_seg(lv)->pool_lv)) {
--- LVM2/tools/lvchange.c	2011/10/28 20:29:06	1.132
+++ LVM2/tools/lvchange.c	2011/10/30 22:07:38	1.133
@@ -142,6 +142,10 @@
 				    "exclusively", lv->name);
 			if (!activate_lv_excl(cmd, lv))
 				return_0;
+			/* Drop any left thin messages after activation */
+			if (lv_is_thin_volume(lv) &&
+			    !detach_pool_messages(first_seg(lv)->pool_lv))
+				return_0;
 		} else if (activate == CHANGE_ALY) {
 			log_verbose("Activating logical volume \"%s\" locally",
 				    lv->name);
--- LVM2/tools/vgchange.c	2011/10/28 20:29:06	1.126
+++ LVM2/tools/vgchange.c	2011/10/30 22:07:38	1.127
@@ -157,6 +157,12 @@
 				stack;
 				continue;
 			}
+			/* Drop any left thin messages after activation */
+			if (lv_is_thin_volume(lv) &&
+			    !detach_pool_messages(first_seg(lv)->pool_lv)) {
+				stack;
+				continue;
+			}
 		} else if (activate == CHANGE_ALY) {
 			if (!activate_lv_local(cmd, lv)) {
 				stack;


