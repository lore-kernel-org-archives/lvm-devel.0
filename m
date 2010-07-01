From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 01 Jul 2010 16:47:52 -0500
Subject: [Patch]: Handle both devices of a mirrored log failing (bug 607347)
Message-ID: <1278020872.7956.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

Fix for bug 607347: failing both redundant mirror log legs...

Rather than attempting to remove all the images of a mirrored
log volume via remove_mirror_images, simply remove the log
if all its devices have failed.

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -705,9 +705,12 @@ static int _lv_update_mirrored_log(struc
 		return 1;
 
 	/* Reducing redundancy of the log */
-	return remove_mirror_images(log_lv, log_count,
-				    is_mirror_image_removable,
-				    operable_pvs, 0U);
+	if (log_count)
+		return remove_mirror_images(log_lv, log_count,
+					    is_mirror_image_removable,
+					    operable_pvs, 0U);
+
+	return remove_mirror_log(lv->vg->cmd, lv, operable_pvs);
 }
 
 static int _lv_update_log_type(struct cmd_context *cmd,



