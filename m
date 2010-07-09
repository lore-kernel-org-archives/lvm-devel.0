From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2010 16:57:44 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100709165744.19714.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-09 16:57:44

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add log_error when strdup fails in {vg|lv}_change_tag().
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.388&r2=1.389

--- LVM2/lib/metadata/metadata.c	2010/07/09 15:34:45	1.388
+++ LVM2/lib/metadata/metadata.c	2010/07/09 16:57:44	1.389
@@ -723,7 +723,9 @@
 
 	if (add_tag) {
 		if (!(tag_new = dm_pool_strdup(lv->vg->vgmem, tag))) {
-			return_0;
+			log_error("Failed to duplicate tag %s from %s/%s",
+				  tag, lv->vg->name, lv->name);
+			return 0;
 		}
 		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag_new)) {
 			log_error("Failed to add tag %s to %s/%s",
@@ -751,7 +753,9 @@
 
 	if (add_tag) {
 		if (!(tag_new = dm_pool_strdup(vg->vgmem, tag))) {
-			return_0;
+			log_error("Failed to duplicate tag %s from %s",
+				  tag, vg->name);
+			return 0;
 		}
 		if (!str_list_add(vg->vgmem, &vg->tags, tag_new)) {
 			log_error("Failed to add tag %s to volume group %s",


