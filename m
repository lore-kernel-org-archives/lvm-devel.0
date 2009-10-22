From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 22 Oct 2009 13:54:21 -0500
Subject: [PATCH]: Enable snapshots of mirrors
Message-ID: <1256237661.14726.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A few more touch-ups to the previous patch.  I've tested the following
('+'s mean it's working, '-'s mean it could use some attention):

pv*:
- commands ignored

vgcfgbackup/vgcfgrestore:
+ simple test shows it works

vgck:
+ seems to work, but I didn't try corrupting the VG

vgreduce --removemissing (--force):
+ properly down-converts mirror under snapshot if there is a device
failure

vg*:
- other vg commands/options ignored

lvchange:
+ '-an' of mirror properly shuts down snapshots too
+ '-ay' of mirror properly starts up snapshots too
+ '-a[ny]' of snapshot gives proper error message
+ '--resync' of mirror origin properly resync's it
- other options ignored

lvconvert:
+ down convert works (mirror to linear)
+ down convert works (mirror to mirror)
+ up convert works (linear to mirror) - both background and foreground
- up convert doesn't work (mirror to mirror) - disabled in lvconvert and
err msg added
+ convert between log types works (core <-> disk/redundant)

lvdisplay:
- largely ignored because I'm not familiar with normal output... but it
seems fine

lvextend:
- for origin, I get a strange message saying "snapshot origin volumes
can only be resized while inactive"
+ negative argument not permitted, of course.
+ for snapshot (cow device), I can add space
+ negative arg not permitted

lvreduce:
- origin "cannot be reduced in size yet."
+ snapshot (cow device) can be reduced

lvremove:
+ removing the origin asks if I want to remove the snapshot, then the
origin... the wording is a bit strange, but not affected by mirror
+ removing snapshot works

lvrename:
+ can rename both the mirror (properly handles hidden LVs) and snapshot

lvresize:
+ can grow/shrink snapshot
- cannot grow/shrink origins under a snapshot (but this has nothing to
do with mirror)

lvs:
+ properly displays layout and percentages

lvscan:
+ not familiar with the command, but output looks saine

 brassow

This patch
- takes out check that denies snapshots of mirrors
- takes out check denying conversion to/of mirrors under snapshots
- adds code to properly gather mirror sync %'age if it is an origin
- disallows mirror -> mirror upconvert when under a snapshot (need more
  time to debug problems with this).  For now, comment and disallow.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2990,11 +2990,12 @@ int lv_create_single(struct volume_group
 					  "supported yet");
 				return 0;
 			}
-			if (org->status & MIRROR_IMAGE ||
-			    org->status & MIRROR_LOG ||
-			    org->status & MIRRORED) {
-				log_error("Snapshots and mirrors may not yet "
-					  "be mixed.");
+			if ((org->status & MIRROR_IMAGE) ||
+			    (org->status & MIRROR_LOG)) {
+				log_error("Snapshots of mirror %ss "
+					  "are not supported",
+					  (org->status & MIRROR_LOG) ?
+					  "log" : "image");
 				return 0;
 			}
 
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -733,6 +733,20 @@ static int _lvconvert_mirrors(struct cmd
 				  "LV: use lvchange --resync first.");
 			return 0;
 		}
+
+		/*
+		 * We allow snapshots of mirrors, but for now, we
+		 * do not allow up converting mirrors that are under
+		 * snapshots.  The layering logic is somewhat complex,
+		 * and preliminary test show that the conversion can't
+		 * seem to get the correct %'age of completion.
+		 */
+		if (lv_is_origin(lv)) {
+			log_error("Can't add additional mirror images to "
+				  "mirrors that are under snapshots");
+			return 0;
+		}
+
 		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
@@ -900,12 +914,6 @@ static int lvconvert_single(struct cmd_c
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_origin(lv)) {
-		log_error("Can't convert logical volume \"%s\" under snapshot",
-			  lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_cow(lv)) {
 		log_error("Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -551,16 +551,17 @@ int dev_manager_mirror_percent(struct de
 {
 	char *name;
 	const char *dlid;
+	char *suffix = (lv_is_origin(lv)) ? "real" : NULL;
 
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, suffix)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dlid(dm, lv->lvid.s, suffix))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}



