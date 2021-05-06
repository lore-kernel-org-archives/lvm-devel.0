From: David Teigland <teigland@sourceware.org>
Date: Thu,  6 May 2021 21:32:41 +0000 (GMT)
Subject: main - writecache: allow attaching to thin pool data
Message-ID: <20210506213241.F0105384C003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b00c8c9109b0b6111d4adb9918cccc407ac448f
Commit:        6b00c8c9109b0b6111d4adb9918cccc407ac448f
Parent:        92fcfc59b2b0a81121771cab3b21ec5dde797510
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 6 16:18:50 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 6 16:23:03 2021 -0500

writecache: allow attaching to thin pool data

---
 tools/command-lines.in |  4 ++--
 tools/lvconvert.c      | 14 ++++++++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 164516a2e..1107c1e02 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -493,7 +493,7 @@ AUTOTYPE: cache
 
 ---
 
-lvconvert --type writecache --cachevol LV LV_linear_striped_raid
+lvconvert --type writecache --cachevol LV LV_linear_striped_raid_thinpool
 OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_to_writecache
 DESC: Attach a writecache to an LV, converts the LV to type writecache.
@@ -520,7 +520,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvconvert --type writecache --cachedevice PV LV_linear_striped_raid
+lvconvert --type writecache --cachedevice PV LV_linear_striped_raid_thinpool
 OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
 ID: lvconvert_to_writecache_with_device
 DESC: Add a writecache to an LV, using a specified cache device.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 990a723b6..8dd8a15c4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6106,6 +6106,7 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 					struct processing_handle *handle)
 {
 	struct volume_group *vg = lv->vg;
+	struct logical_volume *lv_update;
 	struct logical_volume *lv_wcorig;
 	struct logical_volume *lv_fast;
 	struct writecache_settings settings = { 0 };
@@ -6228,6 +6229,15 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	lv_fast->status |= LV_CACHE_VOL;
 
+	/* When the lv arg is a thinpool, redirect update to data sub lv. */
+
+	if (lv_is_thin_pool(lv)) {
+		lv_update = seg_lv(first_seg(lv), 0);
+		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv_update));
+	} else {
+		lv_update = lv;
+	}
+
 	/*
 	 * Changes the vg struct to match the desired state.
 	 *
@@ -6240,7 +6250,7 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 *   gets new id, becomes hidden, gets segments from lv.
 	 */
 
-	if (!(lv_wcorig = _lv_writecache_create(cmd, lv, lv_fast, block_size_sectors, &settings)))
+	if (!(lv_wcorig = _lv_writecache_create(cmd, lv_update, lv_fast, block_size_sectors, &settings)))
 		goto_bad;
 
 	/*
@@ -6248,7 +6258,7 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 * where the old LV is suspended and the new LV is resumed.
 	 */
 
-	if (!lv_update_and_reload(lv))
+	if (!lv_update_and_reload(lv_update))
 		goto_bad;
 
 	lockd_lv(cmd, lv, "un", 0);


