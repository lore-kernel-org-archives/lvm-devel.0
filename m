From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:15:50 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100224181550.14759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:15:49

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : lvchange.c 

Log message:
	Refactor lvchange_tag() to call lv_change_tag() library function.
	
	Similar refactoring to vgchange - pull out common parts and put into
	library function for reuse.  Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.315&r2=1.316
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/lib/metadata/metadata-exported.h	2010/02/24 18:15:05	1.132
+++ LVM2/lib/metadata/metadata-exported.h	2010/02/24 18:15:49	1.133
@@ -493,6 +493,8 @@
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
            uint64_t sectors, int value);
 
+int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
+
 /* Reduce the size of an LV by extents */
 int lv_reduce(struct logical_volume *lv, uint32_t extents);
 
--- LVM2/lib/metadata/metadata.c	2010/02/24 18:15:05	1.315
+++ LVM2/lib/metadata/metadata.c	2010/02/24 18:15:49	1.316
@@ -665,6 +665,30 @@
 	return 0;
 }
 
+int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
+{
+	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
+		log_error("Logical volume %s/%s does not support tags",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (add_tag) {
+		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
+			log_error("Failed to add tag %s to %s/%s",
+				  tag, lv->vg->name, lv->name);
+			return 0;
+		}
+	} else {
+		if (!str_list_del(&lv->tags, tag)) {
+			log_error("Failed to remove tag %s from %s/%s",
+				  tag, lv->vg->name, lv->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag)
 {
 	if (!(vg->fid->fmt->features & FMT_TAGS)) {
--- LVM2/tools/lvchange.c	2010/01/06 19:08:58	1.116
+++ LVM2/tools/lvchange.c	2010/02/24 18:15:49	1.117
@@ -500,25 +500,8 @@
 		return 0;
 	}
 
-	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Logical volume %s/%s does not support tags",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if ((arg == addtag_ARG)) {
-		if (!str_list_add(cmd->mem, &lv->tags, tag)) {
-			log_error("Failed to add tag %s to %s/%s",
-				  tag, lv->vg->name, lv->name);
-			return 0;
-		}
-	} else {
-		if (!str_list_del(&lv->tags, tag)) {
-			log_error("Failed to remove tag %s from %s/%s",
-				  tag, lv->vg->name, lv->name);
-			return 0;
-		}
-	}
+	if (!lv_change_tag(lv, tag, arg == addtag_ARG))
+		return_0;
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 


