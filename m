From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:53 +0000 (UTC)
Subject: master - cleanup: use NAME_LEN buffer instead of alloca
Message-ID: <20151109092853.B6CFD60EC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c48ef993b372397716dc6f1cf81aec5b5ef2188
Commit:        5c48ef993b372397716dc6f1cf81aec5b5ef2188
Parent:        2e04eee19213b3f498a4e8209cdcc14fcb7a0517
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 5 18:32:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: use NAME_LEN buffer instead of alloca

Drop alloca and use NAME_LEN size to get implicit check
for max len of LV name.
---
 tools/lvconvert.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c6cea0d..9fc064b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -805,36 +805,32 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
 				   struct logical_volume *lv)
 {
-	char *format, *layer_name;
-	size_t len;
+	char format[NAME_LEN], layer_name[NAME_LEN];
 	int i;
 
 	/*
- 	 * We would like to give the same number for this layer
- 	 * and the newly added mimage.
- 	 * However, LV name of newly added mimage is determined *after*
+	 * We would like to give the same number for this layer
+	 * and the newly added mimage.
+	 * However, LV name of newly added mimage is determined *after*
 	 * the LV name of this layer is determined.
 	 *
 	 * So, use generate_lv_name() to generate mimage name first
 	 * and take the number from it.
 	 */
 
-	len = strlen(lv->name) + 32;
-	if (!(format = alloca(len)) ||
-	    !(layer_name = alloca(len)) ||
-	    dm_snprintf(format, len, "%s_mimage_%%d", lv->name) < 0) {
-		log_error("lvconvert: layer name allocation failed.");
+	if (dm_snprintf(format, sizeof(format), "%s_mimage_%%d", lv->name) < 0) {
+		log_error("lvconvert: layer name creation failed.");
 		return 0;
 	}
 
-	if (!generate_lv_name(lv->vg, format, layer_name, len) ||
+	if (!generate_lv_name(lv->vg, format, layer_name, sizeof(layer_name)) ||
 	    sscanf(layer_name, format, &i) != 1) {
 		log_error("lvconvert: layer name generation failed.");
 		return 0;
 	}
 
-	if (dm_snprintf(layer_name, len, MIRROR_SYNC_LAYER "_%d", i) < 0) {
-		log_error("layer name allocation failed.");
+	if (dm_snprintf(layer_name, sizeof(layer_name), MIRROR_SYNC_LAYER "_%d", i) < 0) {
+		log_error("layer name creation failed.");
 		return 0;
 	}
 


