From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:28 -0400
Subject: master - lvchange: vdo support compression deduplication change
Message-ID: <201807091335.w69DZS25030833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6206bd0e790b92c8ec53c340902f74932675836f
Commit:        6206bd0e790b92c8ec53c340902f74932675836f
Parent:        c58733ca1538d04a298c4c857492ca544a820064
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 2 10:51:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:15 2018 +0200

lvchange: vdo support compression deduplication change

Add basic support for changing compression and deduplication state
of a VDO pool volume.

Allowing to access it also via top-level VDO volume.
---
 tools/command-lines.in |    3 +-
 tools/lvchange.c       |   71 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index de5c88b..4db1a0a 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -221,6 +221,7 @@ OO_LVCHANGE: --autobackup Bool, --force, --ignoremonitoring,
 
 OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 --alloc Alloc, --contiguous Bool,
+--compression Bool, --deduplication Bool,
 --detachprofile, --metadataprofile String, --profile String,
 --permission Permission, --readahead Readahead, --setactivationskip Bool,
 --errorwhenfull Bool, --discards Discards, --zero Bool,
@@ -308,7 +309,7 @@ OO: --major Number, --activate Active, --poll Bool, --monitor Bool, OO_LVCHANGE
 IO: --ignoreskippedcluster
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
-RULE: all not LV_thinpool LV_cachepool
+RULE: all not LV_thinpool LV_cachepool LV_vdopool
 
 ---
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3ed6b06..6282a6f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -934,6 +934,62 @@ static int _lvchange_activation_skip(struct logical_volume *lv, uint32_t *mr)
 	return 1;
 }
 
+static int _lvchange_compression(struct logical_volume *lv, uint32_t *mr)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	unsigned compression = arg_uint_value(cmd, compression_ARG, 0);
+	struct lv_segment *seg = first_seg(lv);
+
+	if (lv_is_vdo(lv))
+		seg = first_seg(seg_lv(seg, 0));
+	else if (!lv_is_vdo_pool(lv)) {
+		log_error("Unable to change compression for non VDO volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (compression == seg->vdo_params.use_compression) {
+		log_error("Logical volume %s already uses --compression %c.",
+			  display_lvname(lv), compression ? 'y' : 'n');
+		return 0;
+	}
+
+	seg->vdo_params.use_compression = compression;
+
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
+
+	return 1;
+}
+
+static int _lvchange_deduplication(struct logical_volume *lv, uint32_t *mr)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	unsigned deduplication = arg_uint_value(cmd, deduplication_ARG, 0);
+	struct lv_segment *seg = first_seg(lv);
+
+	if (lv_is_vdo(lv))
+		seg = first_seg(seg_lv(seg, 0));
+	else if (!lv_is_vdo_pool(lv)) {
+		log_error("Unable to change deduplication for non VDO volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (deduplication == seg->vdo_params.use_deduplication) {
+		log_error("Logical volume %s already uses --deduplication %c.",
+			  display_lvname(lv), deduplication ? 'y' : 'n');
+		return 0;
+	}
+
+	seg->vdo_params.use_deduplication = deduplication;
+
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
+
+	return 1;
+}
+
 /* Update and reload or commit and/or backup metadata for @lv as requested by @mr */
 static int _commit_reload(struct logical_volume *lv, uint32_t mr)
 {
@@ -966,6 +1022,8 @@ static int _option_allows_group_commit(int opt_enum)
 		permission_ARG,
 		alloc_ARG,
 		contiguous_ARG,
+		compression_ARG,
+		deduplication_ARG,
 		errorwhenfull_ARG,
 		readahead_ARG,
 		persistent_ARG,
@@ -1117,6 +1175,16 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 			doit += _lvchange_activation_skip(lv, &mr);
 			break;
 
+		case compression_ARG:
+			docmds++;
+			doit += _lvchange_compression(lv, &mr);
+			break;
+
+		case deduplication_ARG:
+			docmds++;
+			doit += _lvchange_deduplication(lv, &mr);
+			break;
+
 		default:
 			log_error(INTERNAL_ERROR "Failed to check for option %s",
 				  arg_long_option_name(i));
@@ -1346,6 +1414,9 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_vdo_pool(lv) && !lv_is_named_arg)
+		return 0;	/* Skip VDO pool processing unless explicitely named */
+
 	return 1;
 }
 


