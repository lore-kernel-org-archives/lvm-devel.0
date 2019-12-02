From: David Teigland <teigland@sourceware.org>
Date: Mon, 2 Dec 2019 12:17:30 -0500
Subject: master - pvck: deal with coverity warnings
Message-ID: <05414.119120212172700369@us-mta-76.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec71df6fec481b688a7c4db3171a451c18dbdc52
Commit:        ec71df6fec481b688a7c4db3171a451c18dbdc52
Parent:        91f91b80f1c0879b48b683cc762512c0c980cb7c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 2 11:16:02 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 2 11:16:02 2019 -0600

pvck: deal with coverity warnings

---
 tools/pvck.c |   98 +++++++++++++++++++++++++++++++++------------------------
 1 files changed, 57 insertions(+), 41 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 4eaf8b4..0266218 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -304,7 +304,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	char vgname[NAME_LEN+1];
 	char id_str[ID_STR_SIZE];
 	char id_first[ID_STR_SIZE];
-	char *text_buf;
+	char *text_buf = NULL;
 	char *p;
 	uint32_t buf_off; /* offset with buf which begins with mda_header, bytes */
 	uint32_t buf_off_first = 0;
@@ -1488,7 +1488,8 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 
 		mda_offset = dev_bytes - extra_bytes - ONE_MB_IN_BYTES;
 		mda_size = dev_bytes - mda_offset;
-	}
+	} else
+		return_0;
 
 	if ((mda_num == 1) && (mda1_offset != mda_offset)) {
 		log_print("Ignoring mda1_offset %llu mda1_size %llu from pv_header.",
@@ -1999,7 +2000,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	uint64_t pe_start_sectors;        /* in sectors, as stored in metadata */
 	uint64_t data_offset;             /* in bytes, as stored in pv_header */
 	uint32_t head_crc;
-	int mda_count;
+	int mda_count = 0;
 	int found_label = 0;
 	int di;
 
@@ -2460,7 +2461,7 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 	char line[MAX_META_LINE];
 	char line2[MAX_META_LINE];
 	char *p, *text_buf;
-	uint32_t text_pos, pre_len, back_pos, text_max;
+	uint32_t text_pos, pre_len = 0, back_pos, text_max;
 	int len, len2, vgnamelen;
 
 	text_max = back_size * 2;
@@ -2514,8 +2515,10 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 		back_pos += len;
 
 		/* shouldn't happen */
-		if (text_pos + len > text_max)
+		if (text_pos + len > text_max) {
+			free(text_buf);
 			return_0;
+		}
 
 		if (len == 1) {
 			text_buf[text_pos++] = '\n';
@@ -2529,12 +2532,16 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 	}
 
 	/* shouldn't happen */
-	if (text_pos + pre_len + 3 > text_max)
+	if (text_pos + pre_len + 3 > text_max) {
+		free(text_buf);
 		return_0;
+	}
 
-	/* copy first pre_len bytes of back_buf into text_buf */
-	memcpy(text_buf + text_pos, back_buf, pre_len);
-	text_pos += pre_len;
+	if (pre_len) {
+		/* copy first pre_len bytes of back_buf into text_buf */
+		memcpy(text_buf + text_pos, back_buf, pre_len);
+		text_pos += pre_len;
+	}
 
 	text_pos++; /* null termination */
 
@@ -2560,7 +2567,7 @@ static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
 	struct stat sb;
 	char *back_buf, *text_buf;
 	uint64_t back_size, text_size;
-	int fd, rv;
+	int fd, rv, ret;
 
 	if (arg_is_set(cmd, file_ARG)) {
 		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
@@ -2572,37 +2579,33 @@ static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
 		return 0;
 	}
 
-	if (!(fd = open(input, O_RDONLY))) {
+	if ((fd = open(input, O_RDONLY)) < 0) {
 		log_error("Cannot open file: %s", input);
 		return 0;
 	}
 
 	if (fstat(fd, &sb)) {
 		log_error("Cannot access file: %s", input);
-		close(fd);
-		return 0;
+		goto fail_close;
 	}
 
 	if (!(back_size = (uint64_t)sb.st_size)) {
 		log_error("Empty file: %s", input);
-		close(fd);
-		return 0;
+		goto fail_close;
 	}
 
-	if (!(back_buf = zalloc(back_size))) {
-		close(fd);
-		return 0;
-	}
+	if (!(back_buf = zalloc(back_size)))
+		goto fail_close;
 
 	rv = read(fd, back_buf, back_size);
 	if (rv != back_size) {
 		log_error("Cannot read file: %s", input);
-		close(fd);
 		free(back_buf);
-		return 0;
+		goto fail_close;
 	}
 
-	close(fd);
+	if (close(fd))
+		stack;
 
 	if (!_is_backup_file(cmd, back_buf, back_size)) {
 		log_error("File does not appear to contain a metadata backup.");
@@ -2615,8 +2618,6 @@ static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
 		return_0;
 	}
 
-	free(back_buf);
-
 	if (!tofile) {
 		log_print("---");
 		printf("%s\n", text_buf);
@@ -2625,7 +2626,8 @@ static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
 		FILE *fp;
 		if (!(fp = fopen(tofile, "wx"))) {
 			log_error("Failed to create file %s", tofile);
-			return 0;
+			ret = 0;
+			goto out;
 		}
 
 		fprintf(fp, "%s", text_buf);
@@ -2635,8 +2637,16 @@ static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
 		if (fclose(fp))
 			stack;
 	}
+	ret = 1;
+out:
+	free(back_buf);
+	free(text_buf);
+	return ret;
 
-	return 1;
+fail_close:
+	if (close(fd))
+		stack;
+	return 0;
 }
 
 /* all sizes and offsets in bytes */
@@ -2706,51 +2716,52 @@ static int _read_metadata_file(struct cmd_context *cmd, struct metadata_file *mf
 	uint32_t text_crc;
 	int fd, rv;
 
-	if (!(fd = open(mf->filename, O_RDONLY))) {
+	if ((fd = open(mf->filename, O_RDONLY)) < 0) {
 		log_error("Cannot open file: %s", mf->filename);
 		return 0;
 	}
 
 	if (fstat(fd, &sb)) {
 		log_error("Cannot access file: %s", mf->filename);
-		close(fd);
-		return 0;
+		goto out;
 	}
 
 	if (!(text_size = (uint64_t)sb.st_size)) {
 		log_error("Empty file: %s", mf->filename);
-		close(fd);
-		return 0;
+		goto out;
 	}
 
-	if (!(text_buf = zalloc(text_size + 1))) {
-		close(fd);
-		return 0;
-	}
+	if (!(text_buf = zalloc(text_size + 1)))
+		goto_out;
 
 	rv = read(fd, text_buf, text_size);
 	if (rv != text_size) {
 		log_error("Cannot read file: %s", mf->filename);
-		close(fd);
 		free(text_buf);
-		return 0;
+		goto out;
 	}
 
 	text_size += 1; /* null terminating byte */
 
-	close(fd);
+	if (close(fd))
+		stack;
 
 	if (_is_backup_file(cmd, text_buf, text_size)) {
 		char *back_buf = text_buf;
 		uint64_t back_size = text_size;
 		text_buf = NULL;
 		text_size = 0;
-		if (!_backup_file_to_raw_metadata(back_buf, back_size, &text_buf, &text_size))
+		if (!_backup_file_to_raw_metadata(back_buf, back_size, &text_buf, &text_size)) {
+			free(back_buf);
 			return_0;
+		}
+		free(back_buf);
 	}
 
-	if (!_check_metadata_file(cmd, mf, text_buf, text_size))
+	if (!_check_metadata_file(cmd, mf, text_buf, text_size)) {
+		free(text_buf);
 		return_0;
+	}
 
 	text_crc = calc_crc(INITIAL_CRC, (uint8_t *)text_buf, text_size);
 
@@ -2758,13 +2769,18 @@ static int _read_metadata_file(struct cmd_context *cmd, struct metadata_file *mf
 	mf->text_buf = text_buf;
 	mf->text_crc = text_crc;
 	return 1;
+
+out:
+	if (close(fd))
+		stack;
+	return 0;
 }
 
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct settings set;
 	struct metadata_file mf;
-	struct device *dev;
+	struct device *dev = NULL;
 	const char *dump, *repair;
 	const char *pv_name;
 	uint64_t labelsector = 1;



