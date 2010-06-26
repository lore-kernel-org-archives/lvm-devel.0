From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:35 -0400
Subject: [PATCH 04/38] Move dev_open / dev_close outside _vg_read_raw_area().
In-Reply-To: <1277520789-6808-4-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This refactoring moves the device open/close up one level to the caller of
_vg_read_raw_area().  Should be no functional change and facilitate future
changes related to metadata balancing.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   40 ++++++++++++++++++++++++++++++----------
 1 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3a032ea..fdddae5 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -483,9 +483,6 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!dev_open(area->dev))
-		return_NULL;
-
 	if (!(mdah = _raw_read_mda_header(fid->fmt, area)))
 		goto_out;
 
@@ -520,9 +517,6 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		vg->status |= PRECOMMITTED;
 
       out:
-	if (!dev_close(area->dev))
-		stack;
-
 	return vg;
 }
 
@@ -531,8 +525,17 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct volume_group *vg;
 
-	return _vg_read_raw_area(fid, vgname, &mdac->area, 0);
+	if (!dev_open(mdac->area.dev))
+		return_NULL;
+
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0);
+
+	if (!dev_close(mdac->area.dev))
+		stack;
+
+	return vg;
 }
 
 static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
@@ -540,8 +543,17 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 						   struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct volume_group *vg;
+
+	if (!dev_open(mdac->area.dev))
+		return_NULL;
+
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1);
+
+	if (!dev_close(mdac->area.dev))
+		stack;
 
-	return _vg_read_raw_area(fid, vgname, &mdac->area, 1);
+	return vg;
 }
 
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
@@ -1192,9 +1204,17 @@ static int _scan_raw(const struct format_type *fmt)
 		/* FIXME We're reading mdah twice here... */
 		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			if ((vg = _vg_read_raw_area(&fid, vgname,
-						    &rl->dev_area, 0)))
+			if (!dev_open(rl->dev_area.dev)) {
+				stack;
+				continue;
+			}
+
+			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
+			if (vg)
 				lvmcache_update_vg(vg, 0);
+
+			if (!dev_close(rl->dev_area.dev))
+				stack;
 		}
 	}
 
-- 
1.6.0.6


