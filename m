From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:30 +0100
Subject: [PATCH 07/24] Remove open_count read from some lv_info calls
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <b5230b4cf9f50756f4ae14ab60f9bd3706224589.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

PLEASE CHECK ME!!!

It's not completely clear what could be the side effect
lv_infoi() in these places does not read 'info.open_count' value -
so it should not need to set this value - unless I'm missing some side-effect??

This change is needed to minimalize the amount of fs_unlock() calls.

As we need to make sure no udev operation is in progress when we
check for open_count.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    2 +-
 liblvm/lvm_lv.c         |    4 ++--
 tools/lvconvert.c       |    2 +-
 tools/lvscan.c          |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ff84f4f..d8f31ba 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1218,7 +1218,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	r = _lv_deactivate(lv);
 	memlock_dec(cmd);
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
 out:
 	if (lv) {
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index b77f78c..664c39d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -62,7 +62,7 @@ struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.live_table)
 		return 1;
 	return 0;
@@ -71,7 +71,7 @@ uint64_t lvm_lv_is_active(const lv_t lv)
 uint64_t lvm_lv_is_suspended(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.suspended)
 		return 1;
 	return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 04c9f41..b35bc81 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1637,7 +1637,7 @@ static int poll_logical_volume(struct cmd_context *cmd, struct logical_volume *l
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
 		log_print("Conversion starts after activation.");
 		return ECMD_PROCESSED;
 	}
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 1f91d39..753b00d 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -28,7 +28,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	inkernel = lv_info(cmd, lv, 0, &info, 1, 0) && info.exists;
+	inkernel = lv_info(cmd, lv, 0, &info, 0, 0) && info.exists;
 	if (lv_is_origin(lv)) {
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
-- 
1.7.3.5


