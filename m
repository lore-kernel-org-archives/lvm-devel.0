From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:56:09 +0000 (UTC)
Subject: master - debug: stack tracing corrections
Message-ID: <20161123165609.882CD60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7404b5b830479e9ff7dd634e015c9ebcdb9b20b
Commit:        a7404b5b830479e9ff7dd634e015c9ebcdb9b20b
Parent:        4f39255dcae168621de9eea264dddfe831286a0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:30:52 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

debug: stack tracing corrections

---
 lib/metadata/mirror.c |    2 +-
 tools/lvconvert.c     |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index df99174..e84916e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1822,7 +1822,7 @@ static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 	if (dm_list_size(&lv->segments) != 1 ||
 	    seg_type(first_seg(lv), 0) != AREA_LV)
 		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
-			return 0;
+			return_0;
 
 	/*
 	 * create mirror image LVs
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f50a551..dc32e37 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1806,7 +1806,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
 					     &new_mimage_count, &new_log_count))
-		return 0;
+		return_0;
 
 	if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
 	     (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
@@ -1827,7 +1827,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 				    new_mimage_count, new_log_count))
-		return 0;
+		return_0;
+
+	backup(lv->vg);
 
 	if (!lp->need_polling)
 		log_print_unless_silent("Logical volume %s converted.",
@@ -1836,8 +1838,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		log_print_unless_silent("Logical volume %s being converted.",
 					display_lvname(lv));
 
-	backup(lv->vg);
-
 	return 1;
 }
 
@@ -2028,7 +2028,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		/* Activation is required later which precludes existing supported raid4 segment */
 		if (!_raid4_conversion_supported(lv, lp))
-			return 0;
+			return_0;
 
 		/* Activation is required later which precludes existing supported raid10 segment */
 		if ((seg_is_raid10(seg) || segtype_is_raid10(lp->segtype)) &&


