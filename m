From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:04:07 +0100
Subject: [PATCH 16/17] Fix pvchange -u to work with recent changes in metadata handling interface.
In-Reply-To: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1295867048-21558-17-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I use PV id as a key for format instance's metadata_areas_index.
But since we change this one, I still need to work with the original
one to access the metadata areas (e.g. in pv_write). So, I defined
the pv->old_id to store that.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/format-text.c |   10 +++++-----
 lib/metadata/pv.h             |    1 +
 tools/pvchange.c              |    1 +
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 04abf58..c0d35f0 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1261,6 +1261,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 {
 	struct text_fid_pv_context *fid_pv_tc;
 	struct format_instance *fid = pv->fid;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct label *label;
 	int64_t label_sector;
 	struct lvmcache_info *info;
@@ -1303,8 +1304,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	 * just pass the right format_instance in.
 	 */
 	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
-		if (!(mda = fid_get_mda_indexed(fid, (const char *) &pv->id,
-							ID_LEN, mda_index)))
+		if (!(mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
 			continue;
 
 		mdac = (struct mda_context *) mda->metadata_locn;
@@ -1627,7 +1627,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 			  struct volume_group *vg)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	unsigned mda_index;
 	struct metadata_area *pv_mda;
 	struct mda_context *pv_mdac;
@@ -1871,7 +1871,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				      unsigned mda_ignored)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	uint64_t pe_start, pe_end;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
@@ -2090,7 +2090,7 @@ static int _text_pv_resize(const struct format_type *fmt,
 			   uint64_t size)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	uint64_t size_reduction;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index a9efcfe..af63610 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -22,6 +22,7 @@ struct volume_group;
 
 struct physical_volume {
 	struct id id;
+	struct id old_id;		/* Set during pvchange -u. */
 	struct device *dev;
 	const struct format_type *fmt;
 	struct format_instance *fid;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 3f60f54..1e11982 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -141,6 +141,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			goto out;
 	} else {
 		/* --uuid: Change PV ID randomly */
+		memcpy(&pv->old_id, &pv->id, sizeof(pv->id));
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
-- 
1.7.3.4


