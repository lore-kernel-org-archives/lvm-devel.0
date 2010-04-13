From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 13 Apr 2010 17:05:36 +0200
Subject: [PATCH] Fix vg_write/vg_commit to not reset position in metadata ring buffer on vgrename (updated)
Message-ID: <4BC48840.3060808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should write metadata into next position in the ring buffer while calling vgrename.
At this code level (_vg_write_raw), we're not able to determine if this is a rename
or not. If yes, then accompanying VG structure passed here has a new name set,
not the old one.

When looking for a location where to put metadata next, we're given a NULL value because
of failed VG name comparison (in _find_vg_rlocn) between the name in existing metadata
and metadata we're just about to write.

This resets the position in the ring buffer, overwriting any existing metadata
(and also incorrectly updates the cache to "orphan" afterwards).

This patch just adds old_name item in struct volume_group that we can check and use
if necessary and detect renames at lower layers as well.


(update)
We can find the same problem while using vgcfgrestore. We don't want to compare with
any existing metadata content here so we use a special value of old_name, an empty string,
to instruct the code further not to do any checks.

Peter
---

 lib/format_text/archiver.c       |    6 ++++++
 lib/format_text/format-text.c    |   24 ++++++++++++++++++++----
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   14 ++++++++++----
 4 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 78aea95..41381dd 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -306,6 +306,12 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 	}
 
+	/*
+	 * Setting vg->old_name to a blank value will explicitly
+	 * disable any attempt to check VG name in existing metadata.
+	*/
+	vg->old_name = dm_pool_strdup(vg->vgmem, "");
+
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ad4db34..829b13f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -380,6 +380,17 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	} else
 		*precommitted = 0;
 
+	/* Do not check non-existent metadata. */
+	if (!rlocn->offset && !rlocn->size)
+		return NULL;
+
+	/*
+	 * Don't try to check existing metadata
+	 * if given vgname is an empty string.
+	 */
+	if (!*vgname)
+		return rlocn;
+
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
@@ -387,9 +398,11 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 		goto_bad;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
-	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{')) {
+	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
-	}
+	else
+		log_debug("Volume group name found in metadata does "
+			  "not match expected name %s.", vgname);
 
       bad:
 	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
@@ -542,7 +555,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
+	rlocn = _find_vg_rlocn(&mdac->area, mdah,
+			vg->old_name ? vg->old_name : vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
 
 	if (!fidtc->raw_metadata_buf &&
@@ -647,7 +661,9 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah,
+				     vg->old_name ? vg->old_name : vg->name,
+				     &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b4967e6..8be729b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -216,6 +216,7 @@ struct volume_group {
 
 	struct id id;
 	char *name;
+	char *old_name;		/* Set during vgrename and vgcfgrestore */
 	char *system_id;
 
 	uint32_t extent_size;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a4f1948..10202c5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -451,6 +451,8 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	struct dm_pool *mem = vg->vgmem;
 	struct pv_list *pvl;
 
+	vg->old_name = vg->name;
+
 	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
 		log_error("vg->name allocation failed for '%s'", new_name);
 		return 0;
@@ -2417,11 +2419,15 @@ int vg_commit(struct volume_group *vg)
 		}
 	}
 
-	/*
-	 * Instruct remote nodes to upgrade cached metadata.
-	 */
-	if (cache_updated)
+	if (cache_updated) {
+		/* Instruct remote nodes to upgrade cached metadata. */
 		remote_commit_cached_metadata(vg);
+		/*
+		 * We need to clear old_name after a successful commit.
+		 * The volume_group structure could be reused later.
+		 */
+		vg->old_name = NULL;
+	}
 
 	/* If update failed, remove any cached precommitted metadata. */
 	if (!cache_updated && !drop_cached_metadata(vg))


