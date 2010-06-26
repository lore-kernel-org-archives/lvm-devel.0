From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:36 -0400
Subject: [PATCH 05/38] Move dev_open/dev_close outside vgname_from_mda().
In-Reply-To: <1277520789-6808-5-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refactor vgname_from_mda() so caller must open/close the device.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   20 +++++++-------------
 lib/format_text/text_label.c  |    6 ++++++
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index fdddae5..dc730fb 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1099,9 +1099,6 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-	if (!dev_open(dev_area->dev))
-		return_NULL;
-
 	if (!(mdah = _raw_read_mda_header(fmt, dev_area)))
 		goto_out;
 
@@ -1179,9 +1176,6 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	}
 
       out:
-	if (!dev_close(dev_area->dev))
-		stack;
-
 	return vgname;
 }
 
@@ -1202,20 +1196,20 @@ static int _scan_raw(const struct format_type *fmt)
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
+		if (!dev_open(rl->dev_area.dev)) {
+			stack;
+			continue;
+		}
+
 		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			if (!dev_open(rl->dev_area.dev)) {
-				stack;
-				continue;
-			}
-
 			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 
-			if (!dev_close(rl->dev_area.dev))
-				stack;
 		}
+		if (!dev_close(rl->dev_area.dev))
+			stack;
 	}
 
 	return 1;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 15758d6..6f897e1 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -299,6 +299,10 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
+		if (!dev_open(mdac->area.dev)) {
+			stack;
+			continue;
+		}
 		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
@@ -306,6 +310,8 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 						   (char *) &vgid, vgstatus,
 						   creation_host))
 			return_0;
+		if (!dev_close(mdac->area.dev))
+			stack;
 	}
 
 	info->status &= ~CACHE_INVALID;
-- 
1.6.0.6


