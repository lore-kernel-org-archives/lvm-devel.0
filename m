From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:29:00 -0500
Subject: [PATCH 4/8] Add dm_pool_strdup to allocate memory and copy a tag in {lv|vg}_change_tag()
In-Reply-To: <1266427744-30327-4-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1266427744-30327-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need to allocate memory for the tag and copy the tag value before we
add it to the list of tags.  We could put this inside lvm2app since the
tools keep their memory around until vg_write/vg_commit is called, but
we put it inside the internal library to minimize code in lvm2app.
We need to copy the tag passed in by the caller to ensure the lifetime of
the memory until the {vg|lv} handle is released.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2b8a1be..2667e90 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -667,6 +667,8 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 {
+	char *tag_new;
+
 	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
 		log_error("Logical volume %s/%s does not support tags",
 			  lv->vg->name, lv->name);
@@ -674,7 +676,10 @@ int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 	}
 
 	if (add_tag) {
-		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
+		if (!(tag_new = dm_pool_strdup(lv->vg->vgmem, tag))) {
+			return_0;
+		}
+		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag_new)) {
 			log_error("Failed to add tag %s to %s/%s",
 				  tag, lv->vg->name, lv->name);
 			return 0;
@@ -691,13 +696,18 @@ int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 
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
+		if (!(tag_new = dm_pool_strdup(vg->vgmem, tag))) {
+			return_0;
+		}
+		if (!str_list_add(vg->vgmem, &vg->tags, tag_new)) {
 			log_error("Failed to add tag %s to volume group %s",
 				  tag, vg->name);
 			return 0;
-- 
1.6.0.6


