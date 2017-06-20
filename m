From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 20 Jun 2017 11:59:51 -0400
Subject: master - lvconvert: check open count to disable reshaping of open RAID LV
Message-ID: <201706201559.v5KFxpOt029306@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e611c700ba1032ffb71bf0cdd33e062e5e16439
Commit:        5e611c700ba1032ffb71bf0cdd33e062e5e16439
Parent:        601ad1c73faa5fe3d74ff5b06cc47073b40a1850
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 20 17:59:10 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 20 17:59:10 2017 +0200

lvconvert: check open count to disable reshaping of open RAID LV

Also check LV open count in addition to opening the RaidLV
exclusively as of commit 601ad1c73faa5fe3d74ff5b06cc47073b40a1850.

Related: rhbz1447812
---
 lib/metadata/raid_manip.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f787ad0..93895fe 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -75,6 +75,23 @@ static int _rebuild_with_emptymeta_is_supported(struct cmd_context *cmd,
 	return 1;
 }
 
+/* BZ1447812: check open count of @lv vs. @open_count */
+static int _check_lv_open_count(struct logical_volume *lv, int open_count) {
+	struct lvinfo info = { 0 };
+
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
+		log_error("lv_info failed: aborting.");
+		return 0;
+	}
+	if (info.open_count != open_count) {
+		log_error("Reshape of open %s not supported.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+
 /*
  * Ensure region size exceeds the minimum for @lv because
  * MD's bitmap is limited to tracking 2^21 regions.
@@ -2371,6 +2388,10 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	seg->region_size = new_region_size;
 
+	/* BZ1447812: also check open count */
+	if (!_check_lv_open_count(lv, 1))
+		return 0;
+
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
 							       _post_raid_reshape, NULL,
@@ -6351,8 +6372,14 @@ int lv_raid_convert(struct logical_volume *lv,
 		}
 
 		/* BZ1447812: reject reshape on open LV */
+		if (!_check_lv_open_count(lv, 0))
+			return 0;
 		if (!_lv_open_excl(lv, &dev))
 			return 0;
+		if (!_check_lv_open_count(lv, 1)) {
+			dev_close(dev);
+			return 0;
+		}
 
 		if (!_raid_reshape(lv, new_segtype, yes, force,
 				   data_copies, region_size,


