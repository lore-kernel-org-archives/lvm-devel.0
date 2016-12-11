From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:53 +0000 (UTC)
Subject: master - cleanup: use NAME_LEN stack buffer
Message-ID: <20161211223453.C22E96038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc7d3dd5eda43186829ac4237ab049fe50cbc12a
Commit:        dc7d3dd5eda43186829ac4237ab049fe50cbc12a
Parent:        6cd68c55ddc280bcba72961944d24c6a66da1c18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 12:19:38 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

cleanup: use NAME_LEN stack buffer

Using NAME_LEN we get at least easy max LV name size validation.
Also code gets more simple.
---
 lib/metadata/mirror.c |   42 +++++++++++++++---------------------------
 1 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 73b1110..c668ea0 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -661,6 +661,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 	struct dm_list split_images;
 	struct lv_list *lvl;
 	struct cmd_context *cmd = lv->vg->cmd;
+	char layer_name[NAME_LEN], format[NAME_LEN];
 
 	if (!lv_is_mirrored(lv)) {
 		log_error("Unable to split non-mirrored LV %s.",
@@ -728,9 +729,6 @@ static int _split_mirror_images(struct logical_volume *lv,
 	}
 
 	if (!dm_list_empty(&split_images)) {
-		size_t len = strlen(new_lv->name) + 32;
-		char *layer_name, format[len];
-
 		/*
 		 * A number of images have been split and
 		 * a new mirror layer must be formed
@@ -747,23 +745,21 @@ static int _split_mirror_images(struct logical_volume *lv,
 		dm_list_iterate_items(lvl, &split_images) {
 			sub_lv = lvl->lv;
 
-			if (dm_snprintf(format, len, "%s_mimage_%%d",
+			if (dm_snprintf(format, sizeof(format), "%s_mimage_%%d",
 					new_lv->name) < 0) {
 				log_error("Failed to build new image name for %s.",
 					  display_lvname(new_lv));
 				return 0;
 			}
-			if (!(layer_name = dm_pool_alloc(lv->vg->vgmem, len))) {
-				log_error("Unable to allocate memory.");
-				return 0;
-			}
-			if (!generate_lv_name(lv->vg, format, layer_name, len)||
-			    sscanf(layer_name, format, &i) != 1) {
+			if (!generate_lv_name(lv->vg, format, layer_name, sizeof(layer_name))) {
 				log_error("Failed to generate new image names for %s.",
 					  display_lvname(new_lv));
 				return 0;
 			}
-			sub_lv->name = layer_name;
+			if (!(sub_lv->name = dm_pool_strdup(lv->vg->vgmem, layer_name))) {
+				log_error("Unable to allocate memory.");
+				return 0;
+			}
 		}
 
 		if (!_merge_mirror_images(new_lv, &split_images)) {
@@ -1403,15 +1399,11 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 			      int log)
 {
 	uint32_t m, first_area;
-	char *img_name;
-	size_t len;
-	
-	len = strlen(lv->name) + 32;
-	img_name = alloca(len);
+	char img_name[NAME_LEN];
 
-	if (dm_snprintf(img_name, len, "%s_mimage_%%d", lv->name) < 0) {
-		log_error("img_name allocation failed. "
-			  "Remove new LV and retry.");
+	if (dm_snprintf(img_name, sizeof(img_name), "%s_mimage_%%d", lv->name) < 0) {
+		log_error("Failed to build new mirror image name for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1784,14 +1776,10 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 						 const char *suffix)
 {
 	struct logical_volume *log_lv;
-	char *log_name;
-	size_t len;
-
-	len = strlen(lv_name) + 32;
-	log_name = alloca(len); /* alloca never fails */
+	char log_name[NAME_LEN];
 
-	if (dm_snprintf(log_name, len, "%s%s", lv_name, suffix) < 0) {
-		log_error("log_name allocation failed.");
+	if (dm_snprintf(log_name, sizeof(log_name), "%s%s", lv_name, suffix) < 0) {
+		log_error("Failed to build new mirror log name for %s.", lv_name);
 		return NULL;
 	}
 


