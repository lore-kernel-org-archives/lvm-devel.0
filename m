From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Jun 2019 13:26:06 -0400
Subject: master - pvck: dump metadata_all
Message-ID: <201906051726.x55HQ6Zp004244@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bada89a224b0135ac4415d43e6b128989bbf3b2b
Commit:        bada89a224b0135ac4415d43e6b128989bbf3b2b
Parent:        4d9f41b11945df83b37b55439a44372b894a78f5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 5 11:10:37 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 5 12:25:34 2019 -0500

pvck: dump metadata_all

This searches the entire metadata area for any
copy of the metadata and dumps it to file.
---
 tools/args.h |    7 +-
 tools/pvck.c |  355 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 348 insertions(+), 14 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 83c1cfe..69f7e07 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -215,9 +215,10 @@ arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0,
 
 arg(dump_ARG, '\0', "dump", string_VAL, 0, 0,
     "Dump metadata from a PV. Option values include \\fBmetadata\\fP\n"
-    "to extract the current text metadata, \\fBmetadata_area\\fP\n"
-    "to extract the entire text metadata area, and \\fBheaders\\fP\n"
-    "to print and check LVM headers.\n")
+    "to print or save the current text metadata, \\fBmetadata_area\\fP\n"
+    "to save the entire text metadata area to a file, \\fBmetadata_all\\fP\n"
+    "to save the current and any previous complete versions of metadata\n"
+    "to a file, and \\fBheaders\\fP to print and check LVM headers.\n")
 
 arg(errorwhenfull_ARG, '\0', "errorwhenfull", bool_VAL, 0, 0,
     "Specifies thin pool behavior when data space is exhausted.\n"
diff --git a/tools/pvck.c b/tools/pvck.c
index 9e690a8..c9b833a 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -291,17 +291,326 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	return 1;
 }
 
+/*
+ * Search for any instance of id_str[] in the metadata area,
+ * where the id_str indicates the start of a metadata copy
+ * (which could be complete or a fragment.)
+ * id_str is an open brace followed by id = <uuid>.
+ *
+ * {\n
+ *    id = "lL7Mnk-oCGn-Bde2-9B6S-44Z7-VrHa-wvfC3v"
+ *
+ * 1\23456789012345678901234567890123456789012345678
+ *          10        20        30        40
+ */
+#define ID_STR_SIZE 48
+
+#define SEARCH_VGNAME_LEN 512
+
+static int _dump_meta_all(struct device *dev, const char *tofile,
+			  uint64_t mda_offset, uint64_t mda_size,
+			  uint64_t meta_offset, uint64_t meta_size,
+			  char *meta_buf)
+{
+	FILE *fp = NULL;
+	struct dm_config_tree *cft;
+	char vgname[SEARCH_VGNAME_LEN];
+	char id_str[ID_STR_SIZE];
+	char *text_buf, *new_buf;
+	char *p, *brace, *start, *buf_begin, *buf_end;
+	uint64_t search_offset, start_offset;
+	uint32_t brace_dist, new_len, len_a, len_b;
+	uint32_t left_count, right_count;
+	uint32_t seqno;
+	int search_wrapped = 0;
+	int p_wrapped;
+	int save_bad;
+	int i;
+
+	/*
+	 * metadata begins:
+	 *
+	 * <vgname> {
+	 * id = "<uuid>"
+	 *
+	 * Search the metadata buffer for each instance
+	 * of the string:
+	 *
+	 * {
+	 * id = "<uuid>"
+	 *
+	 * Then reverse by the length of the <vgname> +1
+	 * to get to the start of the metadata.  The
+	 * vgname must come from the original/current copy
+	 * of metadata found through the mda_header pointer.
+	 *
+	 * From the start of the metadata, find the end of
+	 * the metadata by searching foward until \0 is found.
+	 * Metadata ends with the three bytes:
+	 * \n\n\0 (0x0a0a00)
+	 */
+
+	memset(vgname, 0, sizeof(vgname));
+	memset(id_str, 0, sizeof(id_str));
+
+	for (i = 0; i < SEARCH_VGNAME_LEN; i++) {
+		if (meta_buf[i] == ' ')
+			break;
+		vgname[i] = meta_buf[i];
+	}
+
+	if (!(p = strchr(meta_buf, '{')))
+		return_0;
+
+	for (i = 0; i < ID_STR_SIZE; i++) {
+		id_str[i] = *p;
+		p++;
+	}
+
+	if (!(text_buf = malloc(mda_size)))
+		return_0;
+	memset(text_buf, 0, mda_size);
+
+	if (!dev_read_bytes(dev, mda_offset, mda_size, text_buf)) {
+		log_print("CHECK: failed to read metadata area@offset %llu size %llu",
+			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		free(text_buf);
+		return 0;
+	}
+
+	search_offset = meta_offset + meta_size;
+
+ search_next:
+	if (search_offset > mda_size) {
+		if (search_wrapped)
+			goto done;
+		search_offset = 512;
+		search_wrapped = 1;
+	}
+
+	/*
+	 * Search between buf_begin and buf_end for next open brace.
+	 */
+	buf_begin = text_buf + search_offset;
+	buf_end = text_buf + mda_size;
+	brace = NULL;
+
+	for (p = buf_begin; p < buf_end; p++) {
+		if (*p != '{')
+			continue;
+		brace = p;
+		break;
+	}
+
+	if (!brace && search_wrapped)
+		goto done;
+	if (!brace) {
+		search_offset = 512;
+		search_wrapped = 1;
+		goto search_next;
+	}
+
+	/*
+	 * brace_dist is the distance from the last place we
+	 * began searching to the brace we are testing for
+	 * metadata.  If this brace is not the start of valid 
+	 * metadata, then advance brace_dist and search for
+	 * the next brace to check.
+	 */
+	brace_dist = (uint32_t)(brace - buf_begin);
+
+	/*
+	 * Found an open brace, check if it's the start of new metadata
+	 * by checking if brace is followed by id = "<uuid>".
+	 */
+
+	if (memcmp(brace, id_str, ID_STR_SIZE)) {
+		/* It's not, look for next open brace. */
+		search_offset += (brace_dist + 1);
+		goto search_next;
+	}
+
+	/*
+	 * This looks like a new instance of metadata, check if it's complete.
+	 * The start of the metadata is the vgname preceding the open brace,
+	 * so step backward through the text_buf to find the start of vgname.
+	 * There is no delimiter preceding the vgname, there can be any
+	 * text or data in the byte immediately before vgname (this means
+	 * we cannot handle extracting metadata prior to a vgrename.)
+	 *
+	 * <vgname> {
+	 * id = "..."
+	 */
+	start = brace - (strlen(vgname) + 1);
+
+	/* Offset from the begininng of device to the start of this metadata. */
+	start_offset = (uint64_t)(start - text_buf) + mda_offset;
+
+	/*
+	 * The end of the metadata is found by searching forward in text_buf
+	 * until \0, at which point open and close braces should match.
+	 * This forward search may wrap around to the start of text_buf.
+	 *
+	 * Metadata ends with the three bytes \n\n\0: 0a 0a 00
+	 */
+	p = start;
+	p_wrapped = 0;
+	len_a = 0;
+	len_b = 0;
+	new_len = 0;
+	new_buf = NULL;
+	left_count = 0;
+	right_count = 0;
+	save_bad = 0;
+	seqno = 0;
+
+	while (1) {
+		p++;
+
+		if (p == (buf_end)) {
+			p = text_buf + 512;
+			p_wrapped = 1;
+		}
+
+		if (*p == '{')
+			left_count++;
+		else if (*p == '}')
+			right_count++;
+		else if (*p == '\0')
+			break;
+	}
+
+	/* \0 should be preceded by \n\n (0x0a0a) */
+	if ((*(p - 2) != 0x0a) || (*(p - 1) != 0x0a))
+		log_print("Unexpected metadata end bytes.");
+
+	if (p_wrapped) {
+		len_a = (uint32_t)(buf_end - start);
+		len_b = (uint32_t)(p - (text_buf + 512));
+		new_len = len_a + len_b;
+		search_wrapped = 1;
+	} else {
+		new_len = (uint32_t)(p - start);
+	}
+
+	/*
+	 * A couple simple tests indicate if this could be valid metadata
+	 * before attempting to parse it. (min length is probably greater
+	 * than 256, so this could be increased.)
+	 *
+	 * If this is complete but corrupt, we should save it.
+	 * TODO: If this is a fragment we should skip it.
+	 */
+	if ((left_count != right_count) || (new_len < 256)) {
+		/*
+		 * To skip this:
+		 * search_offset += (brace_dist + 1);
+		 * goto search_next;
+		 */
+		log_print("Found incorrect metadata at %llu length %u with braces %u %u",
+			  (unsigned long long)start_offset, new_len, left_count, right_count);
+		save_bad = 1;
+	}
+
+	/*
+	 * Copy the potential metadata into a new buffer to parse.
+	 */
+	if (!(new_buf = malloc(new_len + 1))) {
+		search_offset += (brace_dist + 1);
+		log_print("No memory for metadata at %llu length %u with %u sections",
+			  (unsigned long long)start_offset, new_len, right_count);
+		goto search_next;
+	}
+	memset(new_buf, 0, new_len + 1);
+
+	if (p_wrapped) {
+		memcpy(new_buf, start, len_a);
+		memcpy(new_buf + len_a, text_buf + 512, len_b);
+	} else {
+		memcpy(new_buf, start, new_len);
+	}
+
+	if (save_bad)
+		goto save;
+
+	/*
+	 * Check the metadata is parsable.
+	 * If this is complete but corrupt, we should save it.
+	 * TODO: If this is a fragment we should skip it.
+	 */
+	if ((cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0))) {
+		if (!dm_config_parse(cft, new_buf, new_buf + new_len)) {
+			/*
+			 * To skip this:
+			 * search_offset += (brace_dist + 1);
+			 * goto search_next;
+			 */
+			log_print("Found unparsable metadata@%llu length %u with %u sections",
+				  (unsigned long long)start_offset, new_len, right_count);
+			config_destroy(cft);
+			goto save;
+		}
+
+		if (cft->root && cft->root->child)
+			dm_config_get_uint32(cft->root->child, "seqno", &seqno);
+		config_destroy(cft);
+	}
+
+	log_print("Found metadata at %llu length %u seqno %u with %u sections",
+		  (unsigned long long)start_offset, new_len, seqno, right_count);
+
+ save:
+	if (!fp && tofile) {
+		if (!(fp = fopen(tofile, "a"))) {
+			log_error("Failed to open file %s", tofile);
+			goto out;
+		}
+	}
+
+	if (fp) {
+		fprintf(fp, "%s", new_buf);
+		fprintf(fp, "\n--\n");
+	}
+
+ out:
+	free(new_buf);
+
+	/*
+	 * Look for another id_str instance after the metadata
+	 * that was just finished.
+	 */
+
+	if (p_wrapped)
+		search_offset = len_b;
+	else
+		search_offset += new_len;
+	goto search_next;
+
+ done:
+	if (fp) {
+		if (fflush(fp))
+			stack;
+		if (fclose(fp))
+			stack;
+	}
+
+	free(text_buf);
+	return 1;
+}
+
 static int _dump_meta_text(struct device *dev,
 			   int print_fields, int print_metadata, const char *tofile,
 			   int mda_num, int rlocn_index,
 			   uint64_t mda_offset, uint64_t mda_size,
 			   uint64_t meta_offset, uint64_t meta_size,
-			   uint32_t meta_checksum)
+			   uint32_t meta_checksum,
+			   char **meta_buf_out)
 {
 	char *meta_buf;
 	struct dm_config_tree *cft;
 	const char *vgname = NULL;
 	uint32_t crc;
+	uint32_t seqno = 0;
 	int mn = mda_num; /* 1 or 2 */
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
@@ -367,14 +676,17 @@ static int _dump_meta_text(struct device *dev,
 				   (unsigned long long)meta_size);
 			bad++;
 		} else {
-			vgname = strdup(cft->root->key);
+			if (cft->root && cft->root->key)
+				vgname = strdup(cft->root->key);
+			if (cft->root && cft->root->child)
+				dm_config_get_uint32(cft->root->child, "seqno", &seqno);
 		}
 		config_destroy(cft);
 	}
 
-	log_print("metadata text at %llu crc 0x%x # vgname %s",
+	log_print("metadata text at %llu crc 0x%x # vgname %s seqno %u",
 		  (unsigned long long)(mda_offset + meta_offset), crc,
-		  vgname ? vgname : "?");
+		  vgname ? vgname : "?", seqno);
 
 	if (!print_metadata)
 		goto out;
@@ -399,6 +711,8 @@ static int _dump_meta_text(struct device *dev,
 	}
 
  out:
+	*meta_buf_out = meta_buf;
+
 	if (bad)
 		return 0;
 	return 1;
@@ -662,6 +976,7 @@ static int _dump_mda_header(struct cmd_context *cmd,
 {
 	char str[256];
 	char *buf;
+	char *meta_buf = NULL;
 	struct mda_header *mh;
 	struct raw_locn *rlocn0, *rlocn1;
 	uint64_t rlocn0_offset, rlocn1_offset;
@@ -749,8 +1064,24 @@ static int _dump_mda_header(struct cmd_context *cmd,
 	if (!meta_offset)
 		goto out;
 
-	if (!_dump_meta_text(dev, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum))
-		bad++;
+	/*
+	 * looking at the current copy of metadata referenced by raw_locn
+	 */
+	if (print_metadata < 2) {
+		if (!_dump_meta_text(dev, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum, &meta_buf))
+			bad++;
+	}
+
+	/*
+	 * looking@all copies of the metadata in the area
+	 */
+	if (print_metadata == 2) {
+		if (!_dump_meta_text(dev, 0, 0, NULL, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum, &meta_buf))
+			bad++;
+
+		if (!_dump_meta_all(dev, tofile, mda_offset, mda_size, meta_offset, meta_size, meta_buf))
+			bad++;
+	}
 
 	/* Should we also check text metadata if it exists in rlocn1? */
  out:
@@ -821,15 +1152,14 @@ static int _dump_headers(struct cmd_context *cmd,
 }
 
 static int _dump_metadata(struct cmd_context *cmd,
-			 int argc, char **argv, int full_area)
+			 int argc, char **argv,
+			 int print_metadata, int print_area)
 {
 	struct device *dev;
 	const char *pv_name;
 	const char *tofile = NULL;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
-	int print_metadata = !full_area;
-	int print_area = full_area;
 	int mda_num = 1;
 	int bad = 0;
 
@@ -908,10 +1238,13 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			return _dump_metadata(cmd, argc, argv, 0);
+			return _dump_metadata(cmd, argc, argv, 1, 0);
+
+		if (!strcmp(dump, "metadata_all"))
+			return _dump_metadata(cmd, argc, argv, 2, 0);
 
 		if (!strcmp(dump, "metadata_area"))
-			return _dump_metadata(cmd, argc, argv, 1);
+			return _dump_metadata(cmd, argc, argv, 0, 1);
 
 		if (!strcmp(dump, "headers"))
 			return _dump_headers(cmd, argc, argv);


