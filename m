From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:41 +0000 (UTC)
Subject: master - raid: implement transient status check
Message-ID: <20161123165541.A520360F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23809379babf96459ae7135114b9c6302c9a014e
Commit:        23809379babf96459ae7135114b9c6302c9a014e
Parent:        2315743dd3826e880898bf62bb205931da8c1450
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 21 12:43:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:45:44 2016 +0100

raid: implement transient status check

Take into acount reported state from 'raid' targets.
When raid leg is marked with 'D' - take it as missing leg.
---
 WHATS_NEW       |    1 +
 lib/raid/raid.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7f8801a..9414b03 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Implement transient status check for raid volumes.
   Only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification.
   Missing stripe filler now could be also 'zero'.
   lvconvert --repair accepts --interval and --background option.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 92a96a3..80af61e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -349,6 +349,62 @@ static int _raid_target_percent(void **target_state,
 	return 1;
 }
 
+static int _raid_transient_status(struct dm_pool *mem,
+				  struct lv_segment *seg,
+				  char *params)
+{
+	int failed = 0, r = 0;
+	unsigned i;
+	struct lvinfo info;
+	struct logical_volume *lv;
+	struct dm_status_raid *sr;
+
+	log_debug("Raid transient status %s.", params);
+
+	if (!dm_get_status_raid(mem, params, &sr))
+		return_0;
+
+	if (sr->dev_count != seg->area_count) {
+		log_error("Active raid has a wrong number of raid images!");
+		log_error("Metadata says %u, kernel says %u.",
+			  seg->area_count, sr->dev_count);
+		goto out;
+	}
+
+	if (seg->meta_areas)
+		for (i = 0; i < seg->area_count; ++i) {
+			lv = seg_metalv(seg, i);
+			if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0)) {
+				log_error("Check for existence of raid meta %s failed.",
+					  display_lvname(lv));
+				goto out;
+			}
+		}
+
+	for (i = 0; i < seg->area_count; ++i) {
+		lv = seg_lv(seg, i);
+		if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0)) {
+			log_error("Check for existence of raid image %s failed.",
+				  display_lvname(lv));
+			goto out;
+		}
+		if (sr->dev_health[i] == 'D') {
+			lv->status |= PARTIAL_LV;
+			++failed;
+		}
+	}
+
+	/* Update PARTIAL_LV flags across the VG */
+	if (failed)
+		vg_mark_partial_lvs(lv->vg, 0);
+
+	r = 1;
+out:
+	dm_pool_free(mem, sr);
+
+	return r;
+}
+
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes)
@@ -460,6 +516,7 @@ static struct segtype_handler _raid_ops = {
 #ifdef DEVMAPPER_SUPPORT
 	.target_percent = _raid_target_percent,
 	.target_present = _raid_target_present,
+	.check_transient_status = _raid_transient_status,
 	.modules_needed = _raid_modules_needed,
 #  ifdef DMEVENTD
 	.target_monitored = _raid_target_monitored,


