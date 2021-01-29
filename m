From: David Teigland <teigland@sourceware.org>
Date: Fri, 29 Jan 2021 18:11:51 +0000 (GMT)
Subject: main - writecache: use cleaner message instead of table reload
Message-ID: <20210129181151.BBE40385EC58@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a690d16d29ff7d5e0cc1adb1fed2621efd5fafa4
Commit:        a690d16d29ff7d5e0cc1adb1fed2621efd5fafa4
Parent:        f08ef238564a547477f18c3668c616d497d7f3f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 27 16:23:00 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 28 15:14:25 2021 -0600

writecache: use cleaner message instead of table reload

When detaching writecache, make the first stage send a message
to dm-writecache to set the cleaner option.  This is instead of
reloading the dm table with the cleaner option set.  Reloading
the table causes udev to process/probe the dm dev, which gets
stalled because of the writeback activity, and the stalled udev
in turn stalls the lvconvert command when it tries to sync with
udev events.

When getting writecache status we do not need to get
open_count or read_head info, which can cause extra steps.
---
 lib/metadata/writecache_manip.c | 10 +++++++---
 tools/lvconvert.c               |  2 ++
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 5004aa989..8150d0781 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -75,7 +75,7 @@ static int _get_writecache_kernel_status(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 1, 1)) {
+	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 0, 0)) {
 		log_error("Failed to get device mapper status for %s", display_lvname(lv));
 		goto fail;
 	}
@@ -434,8 +434,12 @@ int lv_writecache_set_cleaner(struct logical_volume *lv)
 	seg->writecache_settings.cleaner_set = 1;
 
 	if (lv_is_active(lv)) {
-		if (!lv_update_and_reload(lv)) {
-			log_error("Failed to update VG and reload LV.");
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+			log_error("Failed to update VG.");
+			return 0;
+		}
+		if (!lv_writecache_message(lv, "cleaner")) {
+			log_error("Failed to set writecache cleaner for %s.", display_lvname(lv));
 			return 0;
 		}
 	} else {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 432396567..7b74afbe2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5720,6 +5720,8 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 		return 0;
 	}
 
+	log_debug("detach writecache check clean reading vg %s", id->vg_name);
+
 	vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
 
 	if (!vg) {


