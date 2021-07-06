From: David Teigland <teigland@sourceware.org>
Date: Tue,  6 Jul 2021 15:10:59 +0000 (GMT)
Subject: main - scan: move metadata vgname check
Message-ID: <20210706151059.43C4F388CC01@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b876dbfc245b8fe0a4c433b39d214652455c3f9e
Commit:        b876dbfc245b8fe0a4c433b39d214652455c3f9e
Parent:        e035e323508383fdcd9df0ef036d276a9c9909ab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 29 12:40:03 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 6 10:10:23 2021 -0500

scan: move metadata vgname check

There have been two separate checks for metadata
validity: first that the metadata text begins with
a valid VG name, and second the checksum of the
metadata text.  These happen in different places,
which means there have been two separate error paths
for invalid metadata.  This also causes large metadata
to be read in multiple parts, the first part is read
just to check the vgname, and then remaining parts are
read later when the full metadata is needed.

This patch moves the vg name verification so it's
done just before the checksum verification, which
results in a single error path for invalid metadata,
and causes the entire metadata to be read together
rather that in parts from different parts of the code.
---
 lib/config/config.c           | 25 +++++++++++-
 lib/format_text/format-text.c | 94 +++++--------------------------------------
 2 files changed, 33 insertions(+), 86 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 485063a3d..25a87c983 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -501,6 +501,9 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			checksum_fn_t checksum_fn, uint32_t checksum,
 			int checksum_only, int no_dup_node_check)
 {
+	char namebuf[NAME_LEN + 1] __attribute__((aligned(8)));
+	int namelen = 0;
+	int bad_name = 0;
 	char *fb, *fe;
 	int r = 0;
 	int sz, use_plain_read = 1;
@@ -548,6 +551,23 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 
 	fb = buf;
 
+	if (!(dev->flags & DEV_REGULAR)) {
+		memcpy(namebuf, buf, NAME_LEN);
+
+		while (namebuf[namelen] && !isspace(namebuf[namelen]) && namebuf[namelen] != '{' && namelen < (NAME_LEN - 1))
+			namelen++;
+		namebuf[namelen] = '\0';
+
+		/*
+		 * Check that the text metadata begins with a valid name.
+		 */
+		if (!validate_name(namebuf)) {
+			log_warn("WARNING: Metadata location on %s at offset %llu begins with invalid name.",
+				 dev_name(dev), (unsigned long long)offset);
+			bad_name = 1;
+		}
+	}
+
 	/*
 	 * The checksum passed in is the checksum from the mda_header
 	 * preceding this metadata.  They should always match.
@@ -557,10 +577,13 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	if (checksum_fn && checksum !=
 	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
 			 (const uint8_t *)(fb + size), size2))) {
-		log_error("%s: Checksum error at offset %" PRIu64, dev_name(dev), (uint64_t) offset);
+		log_warn("WARNING: Checksum error on %s@offset %llu.", dev_name(dev), (unsigned long long)offset);
 		goto out;
 	}
 
+	if (bad_name)
+		goto out;
+
 	if (!checksum_only) {
 		fe = fb + size + size2;
 		if (no_dup_node_check) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index dd550a6eb..26e55cec4 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -296,24 +296,11 @@ static struct raw_locn *_read_metadata_location_vg(struct cmd_context *cmd,
 				       const char *vgname,
 				       int *precommitted)
 {
-	size_t len;
-	char vgnamebuf[NAME_LEN + 2] __attribute__((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
-	struct lvmcache_info *info;
-	struct lvmcache_vgsummary vgsummary_orphan = {
-		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
-	};
-	int rlocn_was_ignored;
-
-	dm_list_init(&vgsummary_orphan.pvsummaries);
-
-	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
 	rlocn = mdah->raw_locns;	/* Slot 0 */
 	rlocn_precommitted = rlocn + 1;	/* Slot 1 */
 
-	rlocn_was_ignored = rlocn_is_ignored(rlocn);
-
 	/* Should we use precommitted metadata? */
 	if (*precommitted && rlocn_precommitted->size &&
 	    (rlocn_precommitted->offset != rlocn->offset)) {
@@ -338,42 +325,7 @@ static struct raw_locn *_read_metadata_location_vg(struct cmd_context *cmd,
 	if (!rlocn->offset && !rlocn->size)
 		return NULL;
 
-	/*
-	 * Don't try to check existing metadata
-	 * if given vgname is an empty string.
-	 */
-	if (!vgname || !*vgname)
-		return rlocn;
-
-	/*
-	 * If live rlocn has ignored flag, data will be out-of-date so skip further checks.
-	 */
-	if (rlocn_was_ignored)
-		return rlocn;
-
-	/*
-	 * Verify that the VG metadata pointed to by the rlocn
-	 * begins with a valid vgname.
-	 */
-	memset(vgnamebuf, 0, sizeof(vgnamebuf));
-
-	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf))
-		goto fail;
-
-	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
-	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
-		return rlocn;
- fail:
-	log_error("Metadata on %s at %llu has wrong VG name \"%s\" expected %s.",
-		  dev_name(dev_area->dev),
-		  (unsigned long long)(dev_area->start + rlocn->offset),
-		  vgnamebuf, vgname);
-
-	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
-	    !lvmcache_update_vgname_and_id(cmd, info, &vgsummary_orphan))
-		stack;
-
-	return NULL;
+	return rlocn;
 }
 
 /*
@@ -487,9 +439,13 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
 				rlocn->checksum,
 				&when, &desc);
 
-	if (!vg) {
-		/* FIXME: detect and handle errors, and distinguish from the optimization
-		   that skips parsing the metadata which also returns NULL. */
+	if (!vg && !*use_previous_vg) {
+		log_warn("WARNING: failed to read metadata text on %s at %llu size %llu for VG %s.",
+			 dev_name(area->dev),
+			 (unsigned long long)(area->start + rlocn->offset),
+			 (unsigned long long)rlocn->size,
+			 vgname);
+		return NULL;
 	}
 
 	log_debug_metadata("Found metadata on %s at %llu size %llu for VG %s",
@@ -498,7 +454,7 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
 			   (unsigned long long)rlocn->size,
 			   vgname);
 
-	if (vg && precommitted)
+	if (precommitted)
 		vg->status |= PRECOMMITTED;
 
       out:
@@ -1533,8 +1489,6 @@ int read_metadata_location_summary(const struct format_type *fmt,
 {
 	struct raw_locn *rlocn;
 	uint32_t wrap = 0;
-	unsigned int len = 0;
-	char namebuf[NAME_LEN + 1] __attribute__((aligned(8)));
 	uint64_t max_size;
 
 	if (!mdah) {
@@ -1563,36 +1517,6 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	/*
-	 * This code reading the start of the metadata area and verifying that
-	 * it looks like a vgname can be removed.  The checksum verifies it.
-	 */
-	log_debug_metadata("Reading metadata_vgname summary from %s at %llu",
-			   dev_name(dev_area->dev),
-			   (unsigned long long)(dev_area->start + rlocn->offset));
-
-	memset(namebuf, 0, sizeof(namebuf));
-
-	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, namebuf))
-		stack;
-
-	while (namebuf[len] && !isspace(namebuf[len]) && namebuf[len] != '{' &&
-	       len < (NAME_LEN - 1))
-		len++;
-
-	namebuf[len] = '\0';
-
-	/*
-	 * Check that the text metadata in the circular buffer begins with a
-	 * valid vg name.
-	 */
-	if (!validate_name(namebuf)) {
-		log_warn("WARNING: Metadata location on %s@%llu begins with invalid VG name.",
-			  dev_name(dev_area->dev),
-			  (unsigned long long)(dev_area->start + rlocn->offset));
-		return 0;
-	}
-
 	/*
 	 * This function is used to read the vg summary during label scan.
 	 * Save the text start location and checksum during scan.  After the VG


