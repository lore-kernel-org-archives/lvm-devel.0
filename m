From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Jan 2023 12:53:10 +0000 (GMT)
Subject: main - fix typo
Message-ID: <20230111125310.648803858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb34ebd4e4facb3a12b799bc0541af798e091459
Commit:        bb34ebd4e4facb3a12b799bc0541af798e091459
Parent:        2ab81a3513f200d16d35b07cc8d510ba5d95c001
Author:        lilinjie <lilinjie@uniontech.com>
AuthorDate:    Wed Jan 4 13:21:13 2023 +0800
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jan 11 13:52:12 2023 +0100

fix typo

Signed-off-by: lilinjie <lilinjie@uniontech.com>
(cherry picked from commit 81b1f5bc3bac0e2e9099b67162da7d1a4995c5f4)
---
 WHATS_NEW                   | 2 +-
 lib/metadata/vdo_manip.c    | 6 +++---
 test/lib/lvm_vdo_wrapper.sh | 2 +-
 tools/lvconvert.c           | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 172a6a42b..357203a4d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -196,7 +196,7 @@ Version 2.03.10 - 09th August 2020
 
 Version 2.03.09 - 26th March 2020
 =================================
-  Fix formating of vdopool (vdo_slab_size_mb was smaller by 2 bits).
+  Fix formatting of vdopool (vdo_slab_size_mb was smaller by 2 bits).
   Fix showing of a dm kernel error when uncaching a volume with cachevol.
 
 Version 2.03.08 - 11th February 2020
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 0181dc6d5..b73d40d2c 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -258,7 +258,7 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 	};
 
 	if (!(dpath = lv_path_dup(data_lv->vg->cmd->mem, data_lv))) {
-		log_error("Failed to build device path for VDO formating of data volume %s.",
+		log_error("Failed to build device path for VDO formatting of data volume %s.",
 			  display_lvname(data_lv));
 		return 0;
 	}
@@ -425,13 +425,13 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 	/* Format data LV as VDO volume */
 	if (format) {
 		if (test_mode()) {
-			log_verbose("Test mode: Skipping formating of VDO pool volume.");
+			log_verbose("Test mode: Skipping formatting of VDO pool volume.");
 		} else if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
 			log_error("Cannot format VDO pool volume %s.", display_lvname(data_lv));
 			return NULL;
 		}
 	} else {
-		log_verbose("Skiping VDO formating %s.", display_lvname(data_lv));
+		log_verbose("Skiping VDO formatting %s.", display_lvname(data_lv));
 		/* TODO: parse existing VDO data and retrieve vdo_logical_size */
 		if (!*virtual_extents)
 			vdo_logical_size = data_lv->size;
diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index b1da2e35b..25a6ce0fe 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -6,7 +6,7 @@
 
 set -euE -o pipefail
 
-# tool for formating 'old' VDO metadata format
+# tool for formatting 'old' VDO metadata format
 LVM_VDO_FORMAT=${LVM_VDO_FORMAT-"oldvdoformat"}
 # tool for shifting VDO metadata header by 2MiB
 LVM_VDO_PREPARE=${LVM_VDO_PREPARE-"oldvdoprepareforlvm"}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8888cac28..c41d9aaf1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5464,7 +5464,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 
 	vdo_pool_zero = arg_int_value(cmd, zero_ARG, 1);
 
-	log_warn("WARNING: Converting logical volume %s to VDO pool volume %s formating.",
+	log_warn("WARNING: Converting logical volume %s to VDO pool volume %s formatting.",
 		 display_lvname(lv), vdo_pool_zero ? "with" : "WITHOUT");
 
 	if (vdo_pool_zero)

