From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jun 2020 18:06:39 +0000 (GMT)
Subject: master - integrity: fix block size check when inactive
Message-ID: <20200611180639.E4E013898528@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b528a9ce9060ed8d66466f7df86c0eafa7c94ec8
Commit:        b528a9ce9060ed8d66466f7df86c0eafa7c94ec8
Parent:        9fbad5bb0fdc7d9a9dca8539e4cd217c5ef1fede
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 12:43:52 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 11 12:43:52 2020 -0500

integrity: fix block size check when inactive

Checking fs block size requires the LV to be active.
---
 lib/metadata/integrity_manip.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 7942be0d6..790642dbb 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -587,13 +587,33 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 		}
 	}
 
+	if (!is_active) {
+		/* checking block size of fs on the lv requires the lv to be active */
+		if (!activate_lv(cmd, lv)) {
+			log_error("Failed to activate LV to check block size %s", display_lvname(lv));
+			goto bad;
+		}
+		if (!sync_local_dev_names(cmd))
+			stack;
+	}
+
 	/*
 	 * Set settings->block_size which will be copied to segment settings below.
 	 * integrity block size chosen based on device logical block size and
 	 * file system block size.
 	 */
-	if (!_set_integrity_block_size(cmd, lv, settings, lbs_4k, lbs_512, pbs_4k, pbs_512))
+	if (!_set_integrity_block_size(cmd, lv, settings, lbs_4k, lbs_512, pbs_4k, pbs_512)) {
+		if (!is_active && !deactivate_lv(cmd, lv))
+			stack;
 		goto_bad;
+	}
+
+	if (!is_active) {
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Failed to deactivate LV after checking block size %s", display_lvname(lv));
+			goto bad;
+		}
+	}
 
 	/*
 	 * For each rimage, move its segments to a new rimage_iorig and give


