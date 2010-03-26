From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Mar 2010 13:38:46 -0400
Subject: [PATCH] Remove vgname check from _find_vg_rlocn and just return the rlocn slot.
In-Reply-To: <1269620108.2508.3.camel@f10-node1>
References: <1269620108.2508.3.camel@f10-node1>
Message-ID: <1269625126-18152-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Unclear what the purpose of this check was/is.  Removing it allows for easier
refactoring, fixes at least one bug, and at least breaks no tests.  If it
covers and important case, we should add a comment and/or testcase.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ad4db34..7a3c4ef 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -360,15 +360,10 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	return 1;
 }
 
-static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
-				       struct mda_header *mdah,
-				       const char *vgname,
+static struct raw_locn *_find_vg_rlocn(struct mda_header *mdah,
 				       int *precommitted)
 {
-	size_t len;
-	char vgnamebuf[NAME_LEN + 2] __attribute((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
-	struct lvmcache_info *info;
 
 	rlocn = mdah->raw_locns;	/* Slot 0 */
 	rlocn_precommitted = rlocn + 1;	/* Slot 1 */
@@ -380,23 +375,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	} else
 		*precommitted = 0;
 
-	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
-	/* FIXME Ignore if checksum incorrect!!! */
-	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), vgnamebuf))
-		goto_bad;
-
-	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
-	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{')) {
-		return rlocn;
-	}
-
-      bad:
-	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
-		lvmcache_update_vgname_and_id(info, FMT_TEXT_ORPHAN_VG_NAME,
-					      FMT_TEXT_ORPHAN_VG_NAME, 0, NULL);
-
-	return NULL;
+	return rlocn;
 }
 
 /*
@@ -430,7 +409,7 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, dev_area)))
 		return_0;
 
-	if (_find_vg_rlocn(dev_area, mdah, vgname, &noprecommit))
+	if (_find_vg_rlocn(mdah, &noprecommit))
 		r = 1;
 
 	if (!dev_close(dev_area->dev))
@@ -457,7 +436,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(area, mdah, vgname, &precommitted))) {
+	if (!(rlocn = _find_vg_rlocn(mdah, &precommitted))) {
 		log_debug("VG %s not found on %s", vgname, dev_name(area->dev));
 		goto out;
 	}
@@ -542,7 +521,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
+	rlocn = _find_vg_rlocn(mdah, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
 
 	if (!fidtc->raw_metadata_buf &&
@@ -647,7 +626,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(mdah, &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
@@ -756,7 +735,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(mdah, &noprecommit))) {
 		rlocn = &mdah->raw_locns[0];
 		mdah->raw_locns[1].offset = 0;
 	}
-- 
1.6.0.6


