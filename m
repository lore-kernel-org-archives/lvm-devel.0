From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:15:58 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100224181558.15504.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:15:58

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add dm_pool_strdup to allocate memory and copy a tag in {lv|vg}_change_tag()
	
	We need to allocate memory for the tag and copy the tag value before we
	add it to the list of tags.  We could put this inside lvm2app since the
	tools keep their memory around until vg_write/vg_commit is called, but
	we put it inside the internal library to minimize code in lvm2app.
	We need to copy the tag passed in by the caller to ensure the lifetime of
	the memory until the {vg|lv} handle is released.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.316&r2=1.317

--- LVM2/lib/metadata/metadata.c	2010/02/24 18:15:49	1.316
+++ LVM2/lib/metadata/metadata.c	2010/02/24 18:15:57	1.317
@@ -667,6 +667,8 @@
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 {
+	char *tag_new;
+
 	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
 		log_error("Logical volume %s/%s does not support tags",
 			  lv->vg->name, lv->name);
@@ -674,7 +676,10 @@
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
@@ -691,13 +696,18 @@
 
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


