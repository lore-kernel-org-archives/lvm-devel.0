From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:58 -0500
Subject: master - pvck: allow dump from file
Message-ID: <202003041458.024EwwEO015687@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b711b955db17617e723abcfcb0b8e21eb0ce7f5
Commit:        1b711b955db17617e723abcfcb0b8e21eb0ce7f5
Parent:        f140620043eb22b192e7d87e17a42fcd0a3656a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 2 16:26:44 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

pvck: allow dump from file

---
 tools/pvck.c | 154 ++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 111 insertions(+), 43 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 79e3af5..566dfc3 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -341,10 +341,62 @@ static uint64_t mda2_size_from_offset(struct device *dev, uint64_t mda2_offset)
 	return mda2_size;
 }
 
+struct devicefile {
+	char path[PATH_MAX];
+	int fd;
+};
+
+static struct devicefile *get_devicefile(const char *path)
+{
+	struct stat sb;
+	struct devicefile *def;
+
+	if (stat(path, &sb))
+		return_NULL;
+
+	if ((sb.st_mode & S_IFMT) != S_IFREG)
+		return_NULL;
+
+	if (!(def = malloc(sizeof(struct devicefile))))
+		return_NULL;
+
+	if (dm_snprintf(def->path, PATH_MAX, "%s", path) < 0) {
+		free(def);
+		return_NULL;
+	}
+
+	if ((def->fd = open(path, O_RDONLY)) < 0) {
+		free(def);
+		return_NULL;
+	}
+
+	return def;
+}
+
+static bool _read_bytes(struct device *dev, struct devicefile *def, uint64_t start, size_t len, void *data)
+{
+	off_t off;
+	ssize_t rv;
+
+	if (dev)
+		return dev_read_bytes(dev, start, len, data);
+
+	off = lseek(def->fd, start, SEEK_SET);
+	if (off != start)
+		return false;
+
+	rv = read(def->fd, data, len);
+	if (rv < 0)
+		return false;
+	if (rv != len)
+		return false;
+	return true;
+}
 
 /* all sizes and offsets in bytes */
 
-static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const char *tofile, struct device *dev,
+static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const char *tofile,
+			  struct device *dev, struct devicefile *def,
 			  int mda_num, uint64_t mda_offset, uint64_t mda_size, char *buf)
 {
 	FILE *fp = NULL;
@@ -719,7 +771,7 @@ static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_of
  * (the location of the metadata text in the metadata area.)
  */
 
-static int _dump_raw_locn(struct device *dev, int print_fields,
+static int _dump_raw_locn(struct device *dev, struct devicefile *def, int print_fields,
 			  struct raw_locn *rlocn, int rlocn_index, uint64_t rlocn_offset,
 			  int mda_num, uint64_t mda_offset, uint64_t mda_size,
 			  uint64_t *meta_offset_ret,
@@ -789,7 +841,7 @@ static int _dump_raw_locn(struct device *dev, int print_fields,
 	return 1;
 }
 
-static int _dump_meta_area(struct device *dev, const char *tofile,
+static int _dump_meta_area(struct device *dev, struct devicefile *def, const char *tofile,
 			   uint64_t mda_offset, uint64_t mda_size)
 {
 	FILE *fp;
@@ -801,7 +853,7 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!(meta_buf = zalloc(mda_size)))
 		return_0;
 
-	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
+	if (!_read_bytes(dev, def, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 		free(meta_buf);
@@ -827,7 +879,7 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 
 /* all sizes and offsets in bytes */
 
-static int _dump_current_text(struct device *dev,
+static int _dump_current_text(struct device *dev, struct devicefile *def,
 			      int print_fields, int print_metadata, const char *tofile,
 			      int mda_num, int rlocn_index,
 			      uint64_t mda_offset, uint64_t mda_size,
@@ -865,7 +917,7 @@ static int _dump_current_text(struct device *dev,
 		off_t offset_b = mda_offset + 512; /* continues after mda_header sector */
 		uint32_t size_b = wrap;
 
-		if (!dev_read_bytes(dev, offset_a, size_a, meta_buf)) {
+		if (!_read_bytes(dev, def, offset_a, size_a, meta_buf)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_a %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_a, (unsigned long long)size_a);
@@ -873,7 +925,7 @@ static int _dump_current_text(struct device *dev,
 			return 0;
 		}
 
-		if (!dev_read_bytes(dev, offset_b, size_b, meta_buf + size_a)) {
+		if (!_read_bytes(dev, def, offset_b, size_b, meta_buf + size_a)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_b %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_b, (unsigned long long)size_b);
@@ -881,7 +933,7 @@ static int _dump_current_text(struct device *dev,
 			return 0;
 		}
 	} else {
-		if (!dev_read_bytes(dev, mda_offset + meta_offset, meta_size, meta_buf)) {
+		if (!_read_bytes(dev, def, mda_offset + meta_offset, meta_size, meta_buf)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size);
 			free(meta_buf);
@@ -951,7 +1003,8 @@ static int _dump_current_text(struct device *dev,
 
 /* all sizes and offsets in bytes */
 
-static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
+static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsector,
+				     struct device *dev, struct devicefile *def,
 				     int print_fields,
 				     int *found_label,
 				     uint64_t *mda1_offset, uint64_t *mda1_size,
@@ -975,7 +1028,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 
 	lh_offset = labelsector * 512; /* from start of disk */
 
-	if (!dev_read_bytes(dev, lh_offset, 512, buf)) {
+	if (!_read_bytes(dev, def, lh_offset, 512, buf)) {
 		log_print("CHECK: failed to read label_header at %llu",
 			  (unsigned long long)lh_offset);
 		return 0;
@@ -985,7 +1038,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 	 * Not invalidating this range can cause an error reading
 	 * a larger range that overlaps this.
 	 */
-	if (!dev_invalidate_bytes(dev, lh_offset, 512))
+	if (dev && !dev_invalidate_bytes(dev, lh_offset, 512))
 		stack;
 
 	lh = (struct label_header *)buf;
@@ -1202,7 +1255,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 			    int print_fields, int print_metadata, int print_area,
 			    const char *tofile,
-			    struct device *dev,
+			    struct device *dev, struct devicefile *def,
 			    uint64_t mda_offset, uint64_t mda_size,
 			    uint32_t *checksum0_ret,
 			    int *found_header)
@@ -1232,7 +1285,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	 * (Why was mda_header magic made only partially printable?)
 	 */
 
-	if (!dev_read_bytes(dev, mda_offset, 512, buf)) {
+	if (!_read_bytes(dev, def, mda_offset, 512, buf)) {
 		log_print("CHECK: failed to read mda_header at %llu", (unsigned long long)mda_offset);
 		return 0;
 	}
@@ -1252,7 +1305,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 		bad++;
 
 	if (print_area) {
-		if (!_dump_meta_area(dev, tofile, mda_offset, mda_size))
+		if (!_dump_meta_area(dev, def, tofile, mda_offset, mda_size))
 			bad++;
 		goto out;
 	}
@@ -1274,7 +1327,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	meta_size = 0;
 	meta_checksum = 0;
 
-	if (!_dump_raw_locn(dev, print_fields, rlocn0, 0, rlocn0_offset, mda_num, mda_offset, mda_size,
+	if (!_dump_raw_locn(dev, def, print_fields, rlocn0, 0, rlocn0_offset, mda_num, mda_offset, mda_size,
 			    &meta_offset, &meta_size, &meta_checksum))
 		bad++;
 
@@ -1287,7 +1340,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	if ((void *)rlocn1 != (void *)(buf + rlocn1_offset - mda_offset))
 		log_print("CHECK: problem with rlocn1 offset calculation");
 
-	if (!_dump_raw_locn(dev, print_fields, rlocn1, 1, rlocn1_offset, mda_num, mda_offset, mda_size,
+	if (!_dump_raw_locn(dev, def, print_fields, rlocn1, 1, rlocn1_offset, mda_num, mda_offset, mda_size,
 			   NULL, NULL, NULL))
 		bad++;
 
@@ -1298,7 +1351,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	 * looking at the current copy of metadata referenced by raw_locn
 	 */
 	if (print_metadata <= PRINT_CURRENT) {
-		if (!_dump_current_text(dev, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum))
+		if (!_dump_current_text(dev, def, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum))
 			bad++;
 	}
 
@@ -1309,7 +1362,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 		if (!(mda_buf = zalloc(mda_size)))
 			goto_out;
 
-		if (!dev_read_bytes(dev, mda_offset, mda_size, mda_buf)) {
+		if (!_read_bytes(dev, def, mda_offset, mda_size, mda_buf)) {
 			log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 				  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 			bad++;
@@ -1317,7 +1370,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 			goto out;
 		}
 
-		_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, mda_buf);
+		_dump_all_text(cmd, set, tofile, dev, def, mda_num, mda_offset, mda_size, mda_buf);
 		free(mda_buf);
 	}
 
@@ -1331,14 +1384,14 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 /* all sizes and offsets in bytes */
 
 static int _dump_headers(struct cmd_context *cmd, const char *dump, struct settings *set,
-			 uint64_t labelsector, struct device *dev)
+			 uint64_t labelsector, struct device *dev, struct devicefile *def)
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
 	uint32_t mda1_checksum, mda2_checksum;
 	int mda_count = 0;
 	int bad = 0;
 
-	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 1, NULL,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, def, 1, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
@@ -1350,11 +1403,11 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 	/*
 	 * The first mda is always 4096 bytes from the start of the device.
 	 */
-	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, NULL))
+	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
 		bad++;
 
 	if (mda2_offset) {
-		if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, mda2_offset, mda2_size, &mda2_checksum, NULL))
 			bad++;
 
 		/* This probably indicates that one was committed and the other not. */
@@ -1372,7 +1425,7 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 /* all sizes and offsets in bytes */
 
 static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct settings *set,
-			 uint64_t labelsector, struct device *dev,
+			 uint64_t labelsector, struct device *dev, struct devicefile *def,
 			 int print_metadata, int print_area)
 {
 	const char *tofile = NULL;
@@ -1392,7 +1445,7 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 	else if (arg_is_set(cmd, pvmetadatacopies_ARG))
 		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
 
-	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, def, 0, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
@@ -1405,14 +1458,14 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 	 * The first mda is always 4096 bytes from the start of the device.
 	 */
 	if (mda_num == 1) {
-		if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, 4096, mda1_size, &mda1_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
 			bad++;
 	} else if (mda_num == 2) {
 		if (!mda2_offset) {
 			log_print("CHECK: second mda not found");
 			bad++;
 		} else {
-			if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
+			if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, def, mda2_offset, mda2_size, &mda2_checksum, NULL))
 				bad++;
 		}
 	}
@@ -1434,17 +1487,17 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
 	int mda_count = 0;
 	int bad = 0;
 
-	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, NULL, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
 	if (found_label && mda1_offset) {
-		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, &found_header1))
+		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, NULL, 4096, mda1_size, &mda1_checksum, &found_header1))
 			bad++;
 	}
 
 	if (found_label && mda2_offset) {
-		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, &found_header2))
+		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, NULL, mda2_offset, mda2_size, &mda2_checksum, &found_header2))
 			bad++;
 	}
 
@@ -1480,7 +1533,7 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
  */
 
 static int _dump_search(struct cmd_context *cmd, const char *dump, struct settings *set,
-			uint64_t labelsector, struct device *dev)
+			uint64_t labelsector, struct device *dev, struct devicefile *def)
 {
 	const char *tofile = NULL;
 	char *buf;
@@ -1496,7 +1549,7 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 			return_0;
 	}
 
-	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+	_dump_label_and_pv_header(cmd, labelsector, dev, def, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	/*
@@ -1685,14 +1738,14 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	if (!(buf = zalloc(mda_size)))
 		return_0;
 
-	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
+	if (!_read_bytes(dev, def, mda_offset, mda_size, buf)) {
 		log_print("CHECK: failed to read metadata area@offset %llu size %llu",
 			   (unsigned long long)mda_offset, (unsigned long long)mda_size);
 		free(buf);
 		return 0;
 	}
 
-	_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, buf);
+	_dump_all_text(cmd, set, tofile, dev, def, mda_num, mda_offset, mda_size, buf);
 
 	free(buf);
 	return 1;
@@ -1856,7 +1909,7 @@ static int _repair_label_header(struct cmd_context *cmd, const char *repair,
 
 	lh_offset = labelsector * 512; /* from start of disk */
 
-	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+	_dump_label_and_pv_header(cmd, labelsector, dev, NULL, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	if (!found_label) {
@@ -2188,7 +2241,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 		log_warn("WARNING: Cannot get device size.");
 	get_size = get_size_sectors << SECTOR_SHIFT;
 
-	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+	_dump_label_and_pv_header(cmd, labelsector, dev, NULL, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	/*
@@ -2549,7 +2602,7 @@ static int _repair_metadata(struct cmd_context *cmd, const char *repair,
 		return 0;
 	}
 
-	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+	_dump_label_and_pv_header(cmd, labelsector, dev, NULL, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	if (!found_label) {
@@ -2957,6 +3010,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	struct settings set;
 	struct metadata_file mf;
 	struct device *dev = NULL;
+	struct devicefile *def = NULL;
 	const char *dump, *repair;
 	const char *pv_name;
 	uint64_t labelsector = 1;
@@ -2975,7 +3029,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, labelsector_ARG))
 		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
-	if (arg_is_set(cmd, dump_ARG) || arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG)) {
+	if (arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG)) {
 		pv_name = argv[0];
 
 		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
@@ -2984,6 +3038,20 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (arg_is_set(cmd, dump_ARG)) {
+		pv_name = argv[0];
+
+		dev = dev_cache_get(cmd, pv_name, cmd->filter);
+
+		if (!dev)
+			def = get_devicefile(pv_name);
+
+		if (!dev && !def) {
+			log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			return ECMD_FAILED;
+		}
+	}
+
 	if (!_get_settings(cmd, &set))
 		return ECMD_FAILED;
 
@@ -3003,19 +3071,19 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, PRINT_CURRENT, 0);
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, def, PRINT_CURRENT, 0);
 
 		else if (!strcmp(dump, "metadata_all"))
-			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, PRINT_ALL, 0);
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, def, PRINT_ALL, 0);
 
 		else if (!strcmp(dump, "metadata_area"))
-			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, 0, 1);
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, def, 0, 1);
 
 		else if (!strcmp(dump, "metadata_search"))
-			ret = _dump_search(cmd, dump, &set, labelsector, dev);
+			ret = _dump_search(cmd, dump, &set, labelsector, dev, def);
 
 		else if (!strcmp(dump, "headers"))
-			ret = _dump_headers(cmd, dump, &set, labelsector, dev);
+			ret = _dump_headers(cmd, dump, &set, labelsector, dev, def);
 
 		else if (!strcmp(dump, "backup_to_raw")) {
 			ret = _dump_backup_to_raw(cmd, &set);



