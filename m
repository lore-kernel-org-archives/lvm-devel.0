From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:54 -0500
Subject: [PATCH 04/12] Add text format specific code to read and write 'rlocn' flags.
In-Reply-To: <1264801082-28132-4-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we read the mda header, we read the rlocn and must save it in
the mda_context structure to make sure we save the flags.  Similarly,
when writing out, make sure we copy the flags to be written to the
new 'rlocn' flags area.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   12 +++++++++++-
 lib/format_text/format-text.h |    1 +
 lib/format_text/text_label.c  |    3 ++-
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9b24693..344769f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -687,6 +687,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
+		rlocn->flags = mdac->rlocn.flags;
 		log_debug("%sCommitting %s metadata (%u) to %s header at %"
 			  PRIu64, precommit ? "Pre-" : "", vg->name, vg->seqno,
 			  dev_name(mdac->area.dev), mdac->area.start);
@@ -777,6 +778,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn->offset = 0;
 	rlocn->size = 0;
 	rlocn->checksum = 0;
+	rlocn->flags = 0;
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
@@ -1049,6 +1051,7 @@ static int _scan_file(const struct format_type *fmt)
 }
 
 const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_context *mdac,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors)
@@ -1074,6 +1077,11 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	/* FIXME Cope with returning a list */
 	rlocn = mdah->raw_locns;
 
+	/* Copy on-disk rlocn - needed to capture 'flags' field */
+	if (mdac)
+		mdac->rlocn = *rlocn;
+	/* FIXME: Check for mda disable flag, and return here if set */
+
 	/*
 	 * If no valid offset, do not try to search for vgname
 	 */
@@ -1168,7 +1176,8 @@ static int _scan_raw(const struct format_type *fmt)
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
-		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
+		if ((vgname = vgname_from_mda(fmt, NULL,
+					      &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
 			if ((vg = _vg_read_raw_area(&fid, vgname,
 						    &rl->dev_area, 0)))
@@ -1470,6 +1479,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		mdac = mda->metadata_locn;
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
+		mdah->raw_locns[0].flags = mdac->rlocn.flags;
 		if (!_raw_write_mda_header(fmt, mdac->area.dev,
 					   mdac->area.start, mdah)) {
 			if (!dev_close(pv->dev))
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 17997cc..adcebc5 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -61,6 +61,7 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 void del_mdas(struct dm_list *mdas);
 
 const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_context *mdac,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7f02fc6..c56934d 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -298,7 +298,8 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
-		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
+		if ((vgname = vgname_from_mda(info->fmt, mdac,
+					      &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
 		    !lvmcache_update_vgname_and_id(info, vgname,
-- 
1.6.0.6


