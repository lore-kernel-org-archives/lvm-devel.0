From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 Nov 2013 12:05:51 +0000 (UTC)
Subject: master - activation: improve activation
Message-ID: <20131101120551.067B161028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f6209b878fb5b33dae5bc52a7ea47a9de9ff900
Commit:        9f6209b878fb5b33dae5bc52a7ea47a9de9ff900
Parent:        c3e674ad3010d21dc2cbde27b7634f7ea4fe67e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 10:31:31 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 13:03:50 2013 +0100

activation: improve activation

This patch fixes mostly cluster behavior but also updates
non-cluster reaction where calls like   'lvchange -aln'
lead to incorrect errors for some segment types.

Fix the implicit activation rules where some segment types could
be activated only in exclusive mode in cluster.
lvm2 command was not preserver 'local' property and incorrectly
converted local activations in to plain exclusive, so the local
activation could have activate volumes exclusively, but remotely.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |   63 ++++++++++++++++++++++++++++++++---------------
 lib/metadata/lv_manip.c |   10 +++----
 3 files changed, 48 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff8da1d..f0a764b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Fix and improve logic for implicitely exclusive activations.
   Return success when LV cannot be activated because of volume_list filter.
   Return proper error state for remote exclusive activation.
   Fix missing lvmetad scan for PVs found on MD partitions.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e59bd8e..c1f6271 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -735,39 +735,62 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, lv->hostname ? : "");
 }
 
+static int _lv_is_exclusive(struct logical_volume *lv)
+{
+	/* Some devices require exlusivness */
+	return seg_is_raid(first_seg(lv)) ||
+		lv_is_origin(lv) ||
+		lv_is_thin_type(lv);
+}
+
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate)
 {
-	if (activate == CHANGE_AN) {
+	switch (activate) {
+	case CHANGE_AN:
+deactivate:
 		log_verbose("Deactivating logical volume \"%s\"", lv->name);
 		if (!deactivate_lv(cmd, lv))
 			return_0;
-	} else if ((activate == CHANGE_AE) ||
-		   seg_is_raid(first_seg(lv)) ||
-		   lv_is_origin(lv) ||
-		   lv_is_thin_type(lv)) {
-		if (activate == CHANGE_ALN) {
-			/* origin, thin or RAID - all others have _AE */
-			/* other types of activation are implicitly exclusive */
-			/* Note: the order of tests is mandatory */
-			log_error("Cannot deactivate \"%s\" locally.", lv->name);
-			return 0;
+		break;
+	case CHANGE_ALN:
+		if (_lv_is_exclusive(lv)) {
+			if (!lv_is_active_locally(lv)) {
+				log_error("Cannot deactivate remotely exclusive device locally.");
+				return 0;
+			}
+			/* Unlock whole exclusive activation */
+			goto deactivate;
 		}
-		log_verbose("Activating logical volume \"%s\" exclusively.",
-			    lv->name);
-		if (!activate_lv_excl(cmd, lv))
-			return_0;
-	} else if (activate == CHANGE_ALN) {
 		log_verbose("Deactivating logical volume \"%s\" locally.",
 			    lv->name);
 		if (!deactivate_lv_local(cmd, lv))
 			return_0;
-	} else if ((activate == CHANGE_ALY) || (activate == CHANGE_AAY)) {
-		log_verbose("Activating logical volume \"%s\" locally.",
+		break;
+	case CHANGE_ALY:
+	case CHANGE_AAY:
+		if (_lv_is_exclusive(lv)) {
+			log_verbose("Activating logical volume \"%s\" exclusively locally.",
+				    lv->name);
+			if (!activate_lv_excl_local(cmd, lv))
+				return_0;
+		} else {
+			log_verbose("Activating logical volume \"%s\" locally.",
+				    lv->name);
+			if (!activate_lv_local(cmd, lv))
+				return_0;
+		}
+		break;
+	case CHANGE_AE:
+exclusive:
+		log_verbose("Activating logical volume \"%s\" exclusively.",
 			    lv->name);
-		if (!activate_lv_local(cmd, lv))
+		if (!activate_lv_excl(cmd, lv))
 			return_0;
-	} else { /* CHANGE_AY */
+		break;
+	default: /* CHANGE_AY */
+		if (_lv_is_exclusive(lv))
+			goto exclusive;
 		log_verbose("Activating logical volume \"%s\".", lv->name);
 		if (!activate_lv(cmd, lv))
 			return_0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 020b365..4a224e4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2892,8 +2892,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				continue;
 			}
 
-			/* For clearing, simply activate exclusive locally */
-			if (!activate_lv_excl_local(meta_lv->vg->cmd, meta_lv)) {
+			/* For clearing, simply activate locally */
+			if (!activate_lv_local(meta_lv->vg->cmd, meta_lv)) {
 				log_error("Failed to activate %s/%s for clearing",
 					  meta_lv->vg->name, meta_lv->name);
 				return 0;
@@ -6046,7 +6046,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
-			if (!activate_lv_excl(cmd, lv)) {
+			if (!lv_active_change(cmd, lv, lp->activate)) {
 				log_error("Failed to activate thin %s.", lv->name);
 				goto deactivate_and_revert_new_lv;
 			}
@@ -6057,9 +6057,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				  "exception store.");
 			goto revert_new_lv;
 		}
-	} else if ((lp->activate == CHANGE_AY && !activate_lv(cmd, lv)) ||
-		   (lp->activate == CHANGE_AE && !activate_lv_excl(cmd, lv)) ||
-		   (lp->activate == CHANGE_ALY && !activate_lv_local(cmd, lv))) {
+	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV.");
 		if (lp->zero)
 			goto deactivate_and_revert_new_lv;


