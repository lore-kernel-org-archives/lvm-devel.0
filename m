From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:10 +0000 (GMT)
Subject: main - cov: remove unused but set variables
Message-ID: <20230506204610.DC8BE3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f038fc3b177c43b9bb0929f5dcc834e24574df03
Commit:        f038fc3b177c43b9bb0929f5dcc834e24574df03
Parent:        c451d7925d91c6fec56b1537e341a5bbc94fb545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 16:32:23 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 20:38:57 2023 +0200

cov: remove unused but set variables

---
 device_mapper/vdo/vdo_reader.c | 9 ++++-----
 lib/device/dev-cache.c         | 3 +--
 lib/device/dev-mpath.c         | 4 ++--
 lib/metadata/integrity_manip.c | 4 ++--
 lib/metadata/lv_manip.c        | 3 +--
 tools/pvck.c                   | 7 +++----
 6 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/device_mapper/vdo/vdo_reader.c b/device_mapper/vdo/vdo_reader.c
index 3596afbd3..9f1344f4b 100644
--- a/device_mapper/vdo/vdo_reader.c
+++ b/device_mapper/vdo/vdo_reader.c
@@ -174,9 +174,8 @@ static void _vdo_decode_pvc(struct vdo_component_41_0 *pvc)
 bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 {
 	char buffer[4096];
-	int fh, n;
+	int fh;
 	bool r = false;
-	off_t l;
 	struct stat st;
 	uint64_t size;
 	uint64_t regpos;
@@ -207,7 +206,7 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 		size = st.st_size;
 	}
 
-	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
+	if (read(fh, buffer, sizeof(buffer)) < 0) {
 		log_sys_debug("read", vdo_path);
 		goto err;
 	}
@@ -235,12 +234,12 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 		goto err;
 	}
 
-	if ((l = lseek(fh, regpos, SEEK_SET)) < 0) {
+	if (lseek(fh, regpos, SEEK_SET) < 0) {
 		log_sys_debug("lseek", vdo_path);
 		goto err;
 	}
 
-	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
+	if (read(fh, buffer, sizeof(buffer)) < 0) {
 		log_sys_debug("read", vdo_path);
 		goto err;
 	}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 85f9b499a..3d13e16bc 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2231,7 +2231,6 @@ try_partition:
 int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname)
 {
 	struct stat buf;
-	struct device *dev;
 
 	if (stat(devname, &buf) < 0) {
 		log_error("Cannot access device %s.", devname);
@@ -2246,7 +2245,7 @@ int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname)
 	if (!_insert_dev(devname, buf.st_rdev))
 		return_0;
 
-	if (!(dev = (struct device *) dm_hash_lookup(_cache.names, devname)))
+	if (!dm_hash_lookup(_cache.names, devname))
 		return_0;
 
 	return 1;
diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index fb45d1858..5433b64e1 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -50,7 +50,7 @@ static void _read_blacklist_file(const char *path)
 	FILE *fp;
 	char line[MAX_WWID_LINE];
 	char wwid[MAX_WWID_LINE];
-	char *word, *p;
+	char *word;
 	int section_black = 0;
 	int section_exceptions = 0;
 	int found_quote;
@@ -100,7 +100,7 @@ static void _read_blacklist_file(const char *path)
 		 * section, and skips those (should the entire mp
 		 * config filtering be disabled if non-wwids are seen?
 		 */
-		if (!(p = strstr(word, "wwid")))
+		if (!strstr(word, "wwid"))
 			continue;
 
 		i += 4; /* skip "wwid" */
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 0c1c29436..d71fbaeb6 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -484,7 +484,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 	struct logical_volume *imeta_lvs[DEFAULT_RAID_MAX_IMAGES];
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct volume_group *vg = lv->vg;
-	struct logical_volume *lv_image, *lv_imeta, *lv_iorig;
+	struct logical_volume *lv_image, *lv_imeta;
 	struct lv_segment *seg_top, *seg_image;
 	struct pv_list *pvl;
 	const struct segment_type *segtype;
@@ -682,7 +682,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 		 * but gets a new integrity segment, in place of the segments
 		 * that were moved to lv_iorig.
 		 */
-		if (!(lv_iorig = insert_layer_for_lv(cmd, lv_image, INTEGRITY, "_iorig")))
+		if (!insert_layer_for_lv(cmd, lv_image, INTEGRITY, "_iorig"))
 			goto_bad;
 
 		lv_image->status |= INTEGRITY;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b8e6ce053..298d307f3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4370,13 +4370,12 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		for (s = 0; s < seg->area_count; s++) {
 			struct logical_volume *lv_image;
 			struct logical_volume *lv_iorig;
-			struct logical_volume *lv_imeta;
 			struct lv_segment *seg_image;
 
 			lv_image = seg_lv(seg, s);
 			seg_image = first_seg(lv_image);
 
-			if (!(lv_imeta = seg_image->integrity_meta_dev)) {
+			if (!seg_image->integrity_meta_dev) {
 				log_error("1");
 				return 0;
 			}
diff --git a/tools/pvck.c b/tools/pvck.c
index 0998caaf5..d10751706 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1028,7 +1028,6 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 	uint64_t pvh_offset;    /* bytes */
 	uint64_t pvhe_offset;   /* bytes */
 	uint64_t dlocn_offset;  /* bytes */
-	uint64_t tmp;
 	int mda_count = 0;
 	int bad = 0;
 	int di;
@@ -1095,7 +1094,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 	if ((void *)dlocn != (void *)(buf + dlocn_offset - lh_offset))
 		log_print("CHECK: problem with pv_header.disk_locn[%d] offset calculation", di);
 
-	while ((tmp = xlate64(dlocn->offset))) {
+	while (xlate64(dlocn->offset)) {
 		if (print_fields) {
 			log_print("pv_header.disk_locn[%d] at %llu # location of data area", di,
 				  (unsigned long long)dlocn_offset);
@@ -1128,7 +1127,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 	if ((void *)dlocn != (void *)(buf + dlocn_offset - lh_offset))
 		log_print("CHECK: problem with pv_header.disk_locn[%d] offset calculation", di);
 
-	while ((tmp = xlate64(dlocn->offset))) {
+	while (xlate64(dlocn->offset)) {
 		if (print_fields) {
 			log_print("pv_header.disk_locn[%d] at %llu # location of metadata area", di,
 				  (unsigned long long)dlocn_offset);
@@ -1214,7 +1213,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 	dlocn = pvhe->bootloader_areas_xl;
 	dlocn_offset = pvhe_offset + 8;
 
-	while ((tmp = xlate64(dlocn->offset))) {
+	while (xlate64(dlocn->offset)) {
 		if (print_fields) {
 			log_print("pv_header_extension.disk_locn[%d] at %llu # bootloader area", di,
 				  (unsigned long long)dlocn_offset);

