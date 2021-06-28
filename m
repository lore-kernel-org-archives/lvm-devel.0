From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:27 +0000 (GMT)
Subject: master - vdo: rename variable vdo_pool_zero
Message-ID: <20210628184227.B53B9398B403@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fcbc3bd7d3473f14e556508fff1b381431c59f0
Commit:        5fcbc3bd7d3473f14e556508fff1b381431c59f0
Parent:        6e773bb196d7e45fbecf0619f8993e6cf4534fa2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 17:54:55 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 20:41:07 2021 +0200

vdo: rename variable vdo_pool_zero

Match rest of code.
---
 tools/lvconvert.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ab8b42b7e..19b3c587e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5404,7 +5404,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 					struct processing_handle *handle)
 {
 	const char *vg_name = NULL;
-	unsigned int zero_vdopool;
+	unsigned int vdo_pool_zero;
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *vdo_lv;
 	struct dm_vdo_target_params vdo_params; /* vdo */
@@ -5463,12 +5463,12 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	zero_vdopool = arg_int_value(cmd, zero_ARG, 1);
+	vdo_pool_zero = arg_int_value(cmd, zero_ARG, 1);
 
 	log_warn("WARNING: Converting logical volume %s to VDO pool volume %s formating.",
-		 display_lvname(lv), zero_vdopool ? "with" : "WITHOUT");
+		 display_lvname(lv), vdo_pool_zero ? "with" : "WITHOUT");
 
-	if (zero_vdopool)
+	if (vdo_pool_zero)
 		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 	else
 		log_warn("WARNING: Using invalid VDO pool data MAY DESTROY YOUR DATA!");
@@ -5480,7 +5480,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (zero_vdopool) {
+	if (vdo_pool_zero) {
 		if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
 			     .yes = arg_count(cmd, yes_ARG),
 			     .force = arg_count(cmd, force_ARG)})) {
@@ -5489,7 +5489,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		}
 	}
 
-	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents, zero_vdopool))
+	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents, vdo_pool_zero))
 		goto_out;
 
 	dm_list_init(&lvc.tags);


