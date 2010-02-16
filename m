From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:46 -0500
Subject: [PATCH 4/7] Add _tag_copy() to allocate memory and copy a tag in {lv|vg}_change_tag()
In-Reply-To: <1266349189-23166-4-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need to allocate memory for the tag and copy the tag value before we
add it to the list of tags.  We could put this inside lvm2app since the
tools keep their memory around until vg_write/vg_commit is called.
Call _tag_copy() from {vg|lv}_change_tag().  We need to copy the tag passed
in by the caller to ensure the memory until the {vg|lv} handle is released.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2b8a1be..e0d63c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -665,8 +665,22 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
 	return 0;
 }
 
+static char *_tag_copy(struct dm_pool *p, const char *tag)
+{
+	char *tag_new;
+
+	/* FIXME: verify tag length */
+	if (!(tag_new = dm_pool_alloc(p, strlen(tag)))) {
+		log_error("Failed to alloc memory for tag %s.", tag);
+		return NULL;
+	}
+	strcpy(tag_new, tag);
+	return tag_new;
+}
+
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 {
+	char *tag_new;
 	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
 		log_error("Logical volume %s/%s does not support tags",
 			  lv->vg->name, lv->name);
@@ -674,7 +688,8 @@ int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 	}
 
 	if (add_tag) {
-		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
+		tag_new = _tag_copy(lv->vg->vgmem, tag);
+		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag_new)) {
 			log_error("Failed to add tag %s to %s/%s",
 				  tag, lv->vg->name, lv->name);
 			return 0;
@@ -691,13 +706,16 @@ int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag)
 {
+	char *tag_new;
+
 	if (!(vg->fid->fmt->features & FMT_TAGS)) {
 		log_error("Volume group %s does not support tags", vg->name);
 		return 0;
 	}
 
 	if (add_tag) {
-		if (!str_list_add(vg->vgmem, &vg->tags, tag)) {
+		tag_new = _tag_copy(vg->vgmem, tag);
+		if (!str_list_add(vg->vgmem, &vg->tags, tag_new)) {
 			log_error("Failed to add tag %s to volume group %s",
 				  tag, vg->name);
 			return 0;
-- 
1.6.0.6


