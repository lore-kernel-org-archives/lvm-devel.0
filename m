From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Aug 2017 13:04:52 -0400
Subject: master - lvmlockd: zero extended lvmlock LV
Message-ID: <201708151704.v7FH4qGt023101@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df5c2964269895b6f5ce16dbdb70edd57c5aa67d
Commit:        df5c2964269895b6f5ce16dbdb70edd57c5aa67d
Parent:        43305ae8da20ac8ab4390a2aa81618f2973753af
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 15 11:53:21 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 15 11:56:31 2017 -0500

lvmlockd: zero extended lvmlock LV

After the internal lvmlock LV (holding sanlock leases) is
extended to hold more leases, it needs to be zeroed.
sanlock expects to see either zeroed blocks or blocks
initialized with leases.
---
 lib/locking/lvmlockd.c |   42 +++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 54e3cf6..d85021c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -365,6 +365,9 @@ static int _remove_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
 
 static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg, int extend_mb)
 {
+	struct device *dev;
+	char path[PATH_MAX];
+	uint64_t old_size_bytes, new_size_bytes;
 	struct logical_volume *lv = vg->sanlock_lv;
 	struct lvresize_params lp = {
 		.sign = SIGN_NONE,
@@ -374,12 +377,49 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.force = 1,
 	};
 
+	old_size_bytes = lv->size * SECTOR_SIZE;
+
 	if (!lv_resize(lv, &lp, &vg->pvs)) {
-		log_error("Extend LV %s to size %s failed.",
+		log_error("Extend sanlock LV %s to size %s failed.",
 			  display_lvname(lv), display_size(cmd, lp.size));
 		return 0;
 	}
 
+	new_size_bytes = lv->size * SECTOR_SIZE;
+
+	if (dm_snprintf(path, sizeof(path), "%s/mapper/%s-%s", lv->vg->cmd->dev_dir,
+			lv->vg->name, lv->name) < 0) {
+		log_error("Extend sanlock LV %s name too long - extended size not zeroed.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	log_debug("Extend sanlock LV zeroing blocks from offset " FMTu64 " bytes len %u bytes",
+		  old_size_bytes, (uint32_t)(new_size_bytes - old_size_bytes));
+
+	log_print("Zeroing %u MiB on extended internal lvmlock LV...", extend_mb);
+
+	if (!(dev = dev_cache_get(path, NULL))) {
+		log_error("Extend sanlock LV %s cannot find device.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!dev_open_quiet(dev)) {
+		log_error("Extend sanlock LV %s cannot open device.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!dev_set(dev, old_size_bytes, new_size_bytes - old_size_bytes, 0)) {
+		log_error("Extend sanlock LV %s cannot zero device.", display_lvname(lv));
+		dev_close_immediate(dev);
+		return 0;
+	}
+
+	dev_flush(dev);
+
+	if (!dev_close_immediate(dev))
+		stack;
+
 	return 1;
 }
 


