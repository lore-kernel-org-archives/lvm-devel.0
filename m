From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 Oct 2019 13:27:02 -0400
Subject: master - pvck: dump metadata search
Message-ID: <201910181727.x9IHR2er009517@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5714c8c9cc12d9442ad9ee85fb73a8ae49d6b548
Commit:        5714c8c9cc12d9442ad9ee85fb73a8ae49d6b548
Parent:        4f860f79ff7c5bb35520776f5906ae51442d5920
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 17 17:24:22 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 18 12:26:29 2019 -0500

pvck: dump metadata search

Improve the implementation of extracting all text metadata
copies from the metadata area.  Use this for the existing
metadata_all dump option.

Add a new metadata_search dump option which does not use
lvm headers to find metadata, but looks in standard
locations.  This is useful if headers are damaged and
can't be used to locate metadata.

Adding '-v' to metadata_all or metadata_search will add
the description and creation_time to the printed list of
metadata instances that are found.
---
 test/shell/pvck-dump.sh |    8 +-
 tools/pvck.c            |  845 +++++++++++++++++++++++++++++------------------
 2 files changed, 534 insertions(+), 319 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 542fb49..17faa17 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -105,10 +105,10 @@ pvck --dump metadata_all --pvmetadatacopies 2 -f all3b "$dev3" > out3b
 diff out1 out2
 diff out1 out3
 
-grep "seqno 1 with" out1
-grep "seqno 1 with" out3b
-grep "seqno 2 with" out1
-grep "seqno 2 with" out3b
+grep "seqno 1" out1
+grep "seqno 1" out3b
+grep "seqno 2" out1
+grep "seqno 2" out3b
 
 diff all1 all2
 diff all1 all3
diff --git a/tools/pvck.c b/tools/pvck.c
index 2b5e63b..231faf9 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -20,6 +20,9 @@
 #include "lib/mm/xlate.h"
 #include "lib/misc/crc.h"
 
+#define PRINT_CURRENT 1
+#define PRINT_ALL 2
+
 static char *_chars_to_str(void *in, void *out, int num, int max, const char *field)
 {
 	char *i = in;
@@ -83,6 +86,374 @@ static char *_chars_to_hexstr(void *in, void *out, int num, int max, const char
 	return out;
 }
 
+static int _check_vgname_start(char *buf, int *len)
+{
+	int chars = 0;
+	int space = 0;
+	int i;
+	char c;
+
+	/*
+	 * Valid metadata begins: 'vgname {'
+	 */
+	for (i = 0; i <= NAME_LEN + 2; i++) {
+		c = buf[i];
+
+		if (isalnum(c) || c == '.' || c == '_' || c == '-' || c == '+') {
+			if (space)
+				return 0;
+			chars++;
+			continue;
+		}
+
+		if (c == ' ') {
+			if (!chars || space)
+				return 0;
+			space++;
+			continue;
+		}
+
+		if (c == '{') {
+			if (chars && space) {
+				*len = chars;
+				return 1;
+			}
+			return 0;
+		}
+
+		return 0;
+	}
+	return 0;
+}
+
+static void _copy_out_metadata(char *buf, uint32_t start, uint32_t first_start, uint64_t mda_size, char **meta_buf, uint64_t *meta_size, int *bad_end)
+{
+	char *new_buf;
+	uint64_t i;
+	uint64_t new_len;
+	uint64_t len_a = 0, len_b = 0;
+	uint32_t stop;
+	int found_end;
+
+	/*
+	 * If we wrap around the buffer searching for the
+	 * end of some metadata, either stop when we reach
+	 * where we began (start), or stop where we found
+	 * the first copy of metadata (first_start).
+	 */
+	if (!first_start)
+		stop = start;
+	else
+		stop = first_start;
+
+	found_end = 0;
+	for (i = start; i < mda_size; i++) {
+		if (buf[i] == '\0') {
+			found_end = 1;
+			break;
+		}
+	}
+
+	if (found_end) {
+		new_len = i - start;
+	} else {
+		len_a = i - start;
+
+		found_end = 0;
+		for (i = 512; i < stop; i++) {
+			if (buf[i] == '\0') {
+				found_end = 1;
+				break;
+			}
+		}
+
+		if (!found_end)
+			return;
+
+		len_b = i - 512;
+		new_len = len_a + len_b;
+	}
+
+	if (new_len < 256) {
+		log_print("skip invalid metadata with len %llu at %llu",
+			  (unsigned long long)new_len, (unsigned long long)start);
+		return;
+	}
+
+	/* terminating 0 byte */
+	new_len++;
+
+	if (!(new_buf = malloc(new_len)))
+		return;
+
+	memset(new_buf, 0, new_len);
+
+	if (len_a) {
+		memcpy(new_buf, buf+start, len_a);
+		memcpy(new_buf+len_a, buf+512, len_b);
+	} else {
+		memcpy(new_buf, buf+start, new_len);
+	}
+
+	/* \0 should be preceded by \n\n (0x0a0a) */
+	if (new_buf[new_len-1] != 0 || new_buf[new_len-2] != 0x0a || new_buf[new_len-3] != 0x0a)
+		*bad_end = 1;
+
+	*meta_buf = new_buf;
+	*meta_size = new_len;
+}
+
+static int _text_buf_parsable(char *text_buf, uint64_t text_size)
+{
+	struct dm_config_tree *cft;
+
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0))) {
+		return 0;
+	}
+
+	if (!dm_config_parse(cft, text_buf, text_buf + text_size)) {
+		config_destroy(cft);
+		return 0;
+	}
+
+	config_destroy(cft);
+	return 1;
+}
+
+#define MAX_LINE_CHECK 128
+#define ID_STR_SIZE 48
+
+static void _copy_line(char *in, char *out, int *len)
+{
+	int i;
+
+	*len = 0;
+
+	for (i = 0; i < MAX_LINE_CHECK; i++) {
+		if ((in[i] == '\n') || (in[i] == '\0'))
+			break;
+		out[i] = in[i];
+	}
+	*len = i+1;
+}
+
+static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct device *dev,
+			  int mda_num, uint64_t mda_offset, uint64_t mda_size, char *buf)
+{
+	FILE *fp = NULL;
+	char line[MAX_LINE_CHECK];
+	char vgname[NAME_LEN+1];
+	char id_str[ID_STR_SIZE];
+	char id_first[ID_STR_SIZE];
+	char *text_buf;
+	char *p;
+	uint32_t buf_off; /* offset with buf which begins with mda_header */
+	uint32_t buf_off_first = 0;
+	uint32_t seqno;
+	uint32_t crc;
+	uint64_t text_size;
+	uint64_t meta_size;
+	int multiple_vgs = 0;
+	int bad_end;
+	int vgnamelen;
+	int count;
+	int len;
+
+	if (tofile) {
+		if (!(fp = fopen(tofile, "wx"))) {
+			log_error("Failed to create file %s", tofile);
+			return 0;
+		}
+	}
+
+	/*
+	 * If metadata has not wrapped, and the metadata area beginning
+	 * has not been damaged, the text area will begin with vgname {.
+	 * Wrapping or damage would mean we find no metadata starting at
+	 * the start of the area.
+	 *
+	 * Try looking at each 512 byte offset within the area for the start
+	 * of another copy of metadata.  Metadata copies have begun at 512
+	 * aligned offsets since very early lvm2 code in 2002.
+	 *
+	 * (We could also search for something definitive like
+	 * "# Generated by LVM2" in the area, and then work backward to find
+	 * a likely beginning.)
+	 *
+	 * N.B. This relies on VG metadata first having the id = "..." field
+	 * followed by the "seqno = N" field.
+	 */
+
+	memset(id_first, 0, sizeof(id_str));
+
+	/*
+	 * A count of 512 byte chunks within the metadata area.
+	 */
+	count = 0;
+
+	meta_size = mda_size - 512;
+
+	/*
+	 * Search 512 byte boundaries for the start of new metadata copies.
+	 */
+	while (count < (meta_size / 512)) {
+		memset(vgname, 0, sizeof(vgname));
+		memset(id_str, 0, sizeof(id_str));
+		seqno = 0;
+		vgnamelen = 0;
+		text_size = 0;
+		bad_end = 0;
+
+		/*
+		 * Check for a new metadata copy at each 512 offset
+		 * (after skipping 512 bytes for mda_header at the
+		 * start of the buf).
+		 *
+		 * If a line looks like it begins with a vgname
+		 * it could be a new copy of metadata, but it could
+		 * also be a random bit of metadata that looks like
+		 * a vgname, so confirm it's the start of metadata
+		 * by looking for id and seqno lines following the
+		 * possible vgname.
+		 */
+		buf_off = 512 + (count * 512);
+		p = buf + buf_off;
+
+		/*
+		 * copy line of possible metadata to check for vgname
+		 */
+		memset(line, 0, sizeof(line));
+		_copy_line(p, line, &len);
+		p += len;
+
+		if (!_check_vgname_start(line, &vgnamelen)) {
+			count++;
+			continue;
+		}
+
+		memcpy(vgname, line, vgnamelen);
+
+		/*
+		 * copy next line of metadata, which should contain id
+		 */
+		memset(line, 0, sizeof(line));
+		_copy_line(p, line, &len);
+		p += len;
+
+		if (strncmp(line, "id = ", 5)) {
+			count++;
+			continue;
+		}
+
+		memcpy(id_str, line + 6, 38);
+
+		/*
+		 * copy next line of metadata, which should contain seqno
+		 */
+		memset(line, 0, sizeof(line));
+		_copy_line(p, line, &len);
+		p += len;
+
+		if (strncmp(line, "seqno = ", 8)) {
+			count++;
+			continue;
+		}
+
+		sscanf(line, "seqno = %u", &seqno);
+
+		/*
+		 * The first three lines look like metadata with
+		 * vgname/id/seqno, so copy out the full metadata.
+		 *
+		 * If this reaches the end of buf without reaching the
+		 * end marker of metadata, it will wrap around to the
+		 * start of buf and continue copying until it reaches
+		 * a NL or until it reaches buf_off_first (which is
+		 * where we've already taken text from.)
+		 */
+		_copy_out_metadata(buf, buf_off, buf_off_first, mda_size, &text_buf, &text_size, &bad_end);
+
+		if (!text_buf) {
+			log_warn("Failed to extract full metadata text at %llu, skipping.",
+				 (unsigned long long)(mda_offset + buf_off));
+			count++;
+			continue;
+		}
+
+		/*
+		 * check if it's finding metadata from different vgs
+		 */
+		if (!id_first[0])
+			memcpy(id_first, id_str, sizeof(id_first));
+		else if (memcmp(id_first, id_str, sizeof(id_first)))
+			multiple_vgs = 1;
+
+		crc = calc_crc(INITIAL_CRC, (uint8_t *)text_buf, text_size);
+
+		log_print("metadata at %llu length %llu crc %08x vg %s seqno %u id %s",
+			  (unsigned long long)(mda_offset + buf_off),
+			  (unsigned long long)text_size,
+			  crc, vgname, seqno, id_str);
+
+		/*
+		 * save the location of the first metadata we've found so
+		 * we know where to stop after wrapping buf.
+		 */
+		if (!buf_off_first)
+			buf_off_first = buf_off;
+
+		/*
+		 * check if the full metadata is parsable
+		 */
+
+		if (!_text_buf_parsable(text_buf, text_size))
+			log_warn("WARNING: parse error for metadata at %llu", (unsigned long long)(mda_offset + buf_off));
+		if (bad_end)
+			log_warn("WARNING: bad terminating bytes for metadata@%llu", (unsigned long long)(mda_offset + buf_off));
+
+		if (arg_is_set(cmd, verbose_ARG)) {
+			char *str1, *str2;
+			if ((str1 = strstr(text_buf, "description = "))) {
+				memset(line, 0, sizeof(line));
+				_copy_line(str1, line, &len);
+				log_print("%s", line);
+			}
+			if ((str2 = strstr(str1, "creation_time = "))) {
+				memset(line, 0, sizeof(line));
+				_copy_line(str2, line, &len);
+				log_print("%s\n", line);
+			}
+		}
+
+		if (fp) {
+			fprintf(fp, "%s", text_buf);
+			fprintf(fp, "\n--\n");
+		}
+
+		free(text_buf);
+		text_buf = NULL;
+
+		if (text_size < 512)
+			count++;
+		else if (!(text_size % 512))
+			count += (text_size / 512);
+		else
+			count += ((text_size / 512) + 1);
+	}
+
+	if (multiple_vgs)
+		log_warn("WARNING: metadata from multiple VGs was found.");
+
+	if (fp) {
+		if (fflush(fp))
+			stack;
+		if (fclose(fp))
+			stack;
+	}
+
+	return 1;
+}
+
 static int _check_label_header(struct label_header *lh, uint64_t labelsector,
 			       int *found_label)
 {
@@ -317,311 +688,13 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
  * 1\23456789012345678901234567890123456789012345678
  *          10        20        30        40
  */
-#define ID_STR_SIZE 48
-
-#define SEARCH_VGNAME_LEN 512
-
-static int _dump_meta_all(struct device *dev, const char *tofile,
-			  uint64_t mda_offset, uint64_t mda_size,
-			  uint64_t meta_offset, uint64_t meta_size,
-			  char *meta_buf)
-{
-	FILE *fp = NULL;
-	struct dm_config_tree *cft;
-	char vgname[SEARCH_VGNAME_LEN];
-	char id_str[ID_STR_SIZE];
-	char *text_buf, *new_buf;
-	char *p, *brace, *start, *buf_begin, *buf_end;
-	uint64_t search_offset, start_offset;
-	uint32_t brace_dist, new_len, len_a, len_b;
-	uint32_t left_count, right_count;
-	uint32_t seqno;
-	int search_wrapped = 0;
-	int p_wrapped;
-	int save_bad;
-	int i;
-
-	/*
-	 * metadata begins:
-	 *
-	 * <vgname> {
-	 * id = "<uuid>"
-	 *
-	 * Search the metadata buffer for each instance
-	 * of the string:
-	 *
-	 * {
-	 * id = "<uuid>"
-	 *
-	 * Then reverse by the length of the <vgname> +1
-	 * to get to the start of the metadata.  The
-	 * vgname must come from the original/current copy
-	 * of metadata found through the mda_header pointer.
-	 *
-	 * From the start of the metadata, find the end of
-	 * the metadata by searching foward until \0 is found.
-	 * Metadata ends with the three bytes:
-	 * \n\n\0 (0x0a0a00)
-	 */
-
-	memset(vgname, 0, sizeof(vgname));
-	memset(id_str, 0, sizeof(id_str));
 
-	for (i = 0; i < SEARCH_VGNAME_LEN; i++) {
-		if (meta_buf[i] == ' ')
-			break;
-		vgname[i] = meta_buf[i];
-	}
-
-	if (!(p = strchr(meta_buf, '{')))
-		return_0;
-
-	for (i = 0; i < ID_STR_SIZE; i++) {
-		id_str[i] = *p;
-		p++;
-	}
-
-	if (!(text_buf = malloc(mda_size)))
-		return_0;
-	memset(text_buf, 0, mda_size);
-
-	if (!dev_read_bytes(dev, mda_offset, mda_size, text_buf)) {
-		log_print("CHECK: failed to read metadata area@offset %llu size %llu",
-			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
-		free(text_buf);
-		return 0;
-	}
-
-	search_offset = meta_offset + meta_size;
-
- search_next:
-	if (search_wrapped && (search_offset >= meta_offset + meta_size))
-		goto done;
-
-	if (search_offset > mda_size) {
-		if (search_wrapped)
-			goto done;
-		search_offset = 512;
-		search_wrapped = 1;
-	}
-
-	/*
-	 * Search between buf_begin and buf_end for next open brace.
-	 */
-	buf_begin = text_buf + search_offset;
-	buf_end = text_buf + mda_size;
-	brace = NULL;
-
-	for (p = buf_begin; p < buf_end; p++) {
-		if (*p != '{')
-			continue;
-		brace = p;
-		break;
-	}
-
-	if (!brace && search_wrapped)
-		goto done;
-	if (!brace) {
-		search_offset = 512;
-		search_wrapped = 1;
-		goto search_next;
-	}
-
-	/*
-	 * brace_dist is the distance from the last place we
-	 * began searching to the brace we are testing for
-	 * metadata.  If this brace is not the start of valid 
-	 * metadata, then advance brace_dist and search for
-	 * the next brace to check.
-	 */
-	brace_dist = (uint32_t)(brace - buf_begin);
-
-	/*
-	 * Found an open brace, check if it's the start of new metadata
-	 * by checking if brace is followed by id = "<uuid>".
-	 */
-
-	if (memcmp(brace, id_str, ID_STR_SIZE)) {
-		/* It's not, look for next open brace. */
-		search_offset += (brace_dist + 1);
-		goto search_next;
-	}
-
-	/*
-	 * This looks like a new instance of metadata, check if it's complete.
-	 * The start of the metadata is the vgname preceding the open brace,
-	 * so step backward through the text_buf to find the start of vgname.
-	 * There is no delimiter preceding the vgname, there can be any
-	 * text or data in the byte immediately before vgname (this means
-	 * we cannot handle extracting metadata prior to a vgrename.)
-	 *
-	 * <vgname> {
-	 * id = "..."
-	 */
-	start = brace - (strlen(vgname) + 1);
-
-	/* Offset from the begininng of device to the start of this metadata. */
-	start_offset = (uint64_t)(start - text_buf) + mda_offset;
-
-	/*
-	 * The end of the metadata is found by searching forward in text_buf
-	 * until \0, at which point open and close braces should match.
-	 * This forward search may wrap around to the start of text_buf.
-	 *
-	 * Metadata ends with the three bytes \n\n\0: 0a 0a 00
-	 */
-	p = start;
-	p_wrapped = 0;
-	len_a = 0;
-	len_b = 0;
-	new_len = 0;
-	new_buf = NULL;
-	left_count = 0;
-	right_count = 0;
-	save_bad = 0;
-	seqno = 0;
-
-	while (1) {
-		p++;
-
-		if (p == (buf_end)) {
-			p = text_buf + 512;
-			p_wrapped = 1;
-		}
-
-		if (*p == '{')
-			left_count++;
-		else if (*p == '}')
-			right_count++;
-		else if (*p == '\0')
-			break;
-	}
-
-	/* \0 should be preceded by \n\n (0x0a0a) */
-	if ((*(p - 2) != 0x0a) || (*(p - 1) != 0x0a))
-		log_print("Unexpected metadata end bytes.");
-
-	if (p_wrapped) {
-		len_a = (uint32_t)(buf_end - start);
-		len_b = (uint32_t)(p - (text_buf + 512));
-		new_len = len_a + len_b;
-		search_wrapped = 1;
-	} else {
-		new_len = (uint32_t)(p - start);
-	}
-
-	/*
-	 * A couple simple tests indicate if this could be valid metadata
-	 * before attempting to parse it. (min length is probably greater
-	 * than 256, so this could be increased.)
-	 *
-	 * If this is complete but corrupt, we should save it.
-	 * TODO: If this is a fragment we should skip it.
-	 */
-	if ((left_count != right_count) || (new_len < 256)) {
-		/*
-		 * To skip this:
-		 * search_offset += (brace_dist + 1);
-		 * goto search_next;
-		 */
-		log_print("Found incorrect metadata at %llu length %u with braces %u %u",
-			  (unsigned long long)start_offset, new_len, left_count, right_count);
-		save_bad = 1;
-	}
-
-	/*
-	 * Copy the potential metadata into a new buffer to parse.
-	 */
-	if (!(new_buf = malloc(new_len + 1))) {
-		search_offset += (brace_dist + 1);
-		log_print("No memory for metadata at %llu length %u with %u sections",
-			  (unsigned long long)start_offset, new_len, right_count);
-		goto search_next;
-	}
-	memset(new_buf, 0, new_len + 1);
-
-	if (p_wrapped) {
-		memcpy(new_buf, start, len_a);
-		memcpy(new_buf + len_a, text_buf + 512, len_b);
-	} else {
-		memcpy(new_buf, start, new_len);
-	}
-
-	if (save_bad)
-		goto save;
-
-	/*
-	 * Check the metadata is parsable.
-	 * If this is complete but corrupt, we should save it.
-	 * TODO: If this is a fragment we should skip it.
-	 */
-	if ((cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0))) {
-		if (!dm_config_parse(cft, new_buf, new_buf + new_len)) {
-			/*
-			 * To skip this:
-			 * search_offset += (brace_dist + 1);
-			 * goto search_next;
-			 */
-			log_print("Found unparsable metadata@%llu length %u with %u sections",
-				  (unsigned long long)start_offset, new_len, right_count);
-			config_destroy(cft);
-			goto save;
-		}
-
-		if (cft->root && cft->root->child)
-			dm_config_get_uint32(cft->root->child, "seqno", &seqno);
-		config_destroy(cft);
-	}
-
-	log_print("Found metadata at %llu length %u seqno %u with %u sections",
-		  (unsigned long long)start_offset, new_len, seqno, right_count);
-
- save:
-	if (!fp && tofile) {
-		if (!(fp = fopen(tofile, "a"))) {
-			log_error("Failed to open file %s", tofile);
-			goto out;
-		}
-	}
-
-	if (fp) {
-		fprintf(fp, "%s", new_buf);
-		fprintf(fp, "\n--\n");
-	}
-
- out:
-	free(new_buf);
-
-	/*
-	 * Look for another id_str instance after the metadata
-	 * that was just finished.
-	 */
-
-	if (p_wrapped)
-		search_offset = len_b;
-	else
-		search_offset += new_len;
-	goto search_next;
-
- done:
-	if (fp) {
-		if (fflush(fp))
-			stack;
-		if (fclose(fp))
-			stack;
-	}
-
-	free(text_buf);
-	return 1;
-}
-
-static int _dump_meta_text(struct device *dev,
-			   int print_fields, int print_metadata, const char *tofile,
-			   int mda_num, int rlocn_index,
-			   uint64_t mda_offset, uint64_t mda_size,
-			   uint64_t meta_offset, uint64_t meta_size,
-			   uint32_t meta_checksum,
-			   char **meta_buf_out)
+static int _dump_current_text(struct device *dev,
+			      int print_fields, int print_metadata, const char *tofile,
+			      int mda_num, int rlocn_index,
+			      uint64_t mda_offset, uint64_t mda_size,
+			      uint64_t meta_offset, uint64_t meta_size,
+			      uint32_t meta_checksum)
 {
 	char *meta_buf;
 	struct dm_config_tree *cft;
@@ -729,8 +802,6 @@ static int _dump_meta_text(struct device *dev,
 	}
 
  out:
-	*meta_buf_out = meta_buf;
-
 	if (bad)
 		return 0;
 	return 1;
@@ -999,7 +1070,6 @@ static int _dump_mda_header(struct cmd_context *cmd,
 {
 	char str[256];
 	char *buf;
-	char *meta_buf = NULL;
 	struct mda_header *mh;
 	struct raw_locn *rlocn0, *rlocn1;
 	uint64_t rlocn0_offset, rlocn1_offset;
@@ -1090,24 +1160,35 @@ static int _dump_mda_header(struct cmd_context *cmd,
 	/*
 	 * looking at the current copy of metadata referenced by raw_locn
 	 */
-	if (print_metadata < 2) {
-		if (!_dump_meta_text(dev, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum, &meta_buf))
+	if (print_metadata <= PRINT_CURRENT) {
+		if (!_dump_current_text(dev, print_fields, print_metadata, tofile, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum))
 			bad++;
 	}
 
 	/*
 	 * looking at all copies of the metadata in the area
 	 */
-	if (print_metadata == 2) {
-		if (!_dump_meta_text(dev, 0, 0, NULL, mda_num, 0, mda_offset, mda_size, meta_offset, meta_size, meta_checksum, &meta_buf))
-			bad++;
+	if (print_metadata == PRINT_ALL) {
+		free(buf);
+
+		if (!(buf = malloc(mda_size)))
+			goto_out;
+		memset(buf, 0, mda_size);
 
-		if (!_dump_meta_all(dev, tofile, mda_offset, mda_size, meta_offset, meta_size, meta_buf))
+		if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
+			log_print("CHECK: failed to read metadata area@offset %llu size %llu",
+				  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 			bad++;
+			goto out;
+		}
+
+		_dump_all_text(cmd, tofile, dev, mda_num, mda_offset, mda_size, buf);
 	}
 
 	/* Should we also check text metadata if it exists in rlocn1? */
  out:
+	if (buf)
+		free(buf);
 	if (bad)
 		return 0;
 	return 1;
@@ -1303,6 +1384,137 @@ static int _dump_found(struct cmd_context *cmd, struct device *dev,
 	return 1;
 }
 
+#define ONE_MB_IN_BYTES 1048576
+
+/*
+ * Look for metadata text in common locations, without using any headers
+ * (pv_header/mda_header) to find the location, since the headers may be
+ * zeroed/damaged.
+ */
+
+static int _dump_search(struct cmd_context *cmd,
+			int argc, char **argv)
+{
+	char str[256];
+	struct device *dev;
+	const char *pv_name;
+	const char *tofile = NULL;
+	char *buf;
+	struct mda_header *mh;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
+	uint64_t mda_offset, mda_size;
+	int found_header = 0;
+	int mda_count = 0;
+	int mda_num = 1;
+
+	if (arg_is_set(cmd, file_ARG)) {
+		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
+			return ECMD_FAILED;
+	}
+
+	/* 1: dump metadata from first mda, 2: dump metadata from second mda */
+	if (arg_is_set(cmd, pvmetadatacopies_ARG))
+		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
+
+	pv_name = argv[0];
+
+	if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
+		log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+		return ECMD_FAILED;
+	}
+
+	label_scan_setup_bcache();
+
+	_dump_label_and_pv_header(cmd, 0, dev, NULL,
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
+
+	/*
+	 * TODO: allow mda_offset and mda_size to be specified on the
+	 * command line.
+	 *
+	 * For mda1, mda_offset is always 4096 bytes from the start of
+	 * device, and mda_size is the space between mda_offset and
+	 * the first PE which is usually at 1MB.
+	 *
+	 * For mda2, take the dev_size, reduce that to be a 1MB
+	 * multiple.  The mda_offset is then 1MB prior to that,
+	 * and mda_size is the amount of space between that offset
+	 * and the end of the device.
+	 *
+	 * The second mda is generally 4K larger (at least) than the
+	 * first mda because the first mda begins at a 4K offset from
+	 * the start of the device and ends on a 1MB boundary.
+	 * The second mda begins on a 1MB boundary (no 4K offset like
+	 * mda1), then goes to the end of the device.  Extra space
+	 * at the end of device (mod 1MB extra) can make mda2 even
+	 * larger.
+	 */
+	if (mda_num == 1) {
+		mda_offset = 4096;
+		mda_size = ONE_MB_IN_BYTES - 4096;
+	} else if (mda_num == 2) {
+		uint64_t dev_sectors = 0;
+		uint64_t dev_bytes;
+		uint64_t extra_bytes;
+
+		dev_get_size(dev, &dev_sectors);
+
+		dev_bytes = dev_sectors * 512;
+		extra_bytes = dev_bytes % ONE_MB_IN_BYTES;
+
+		if (dev_bytes < (2 * ONE_MB_IN_BYTES))
+			return ECMD_FAILED;
+
+		mda_offset = dev_bytes - extra_bytes - ONE_MB_IN_BYTES;
+		mda_size = dev_bytes - mda_offset;
+	}
+
+	if ((mda_num == 1) && (mda1_offset != mda_offset)) {
+		log_print("Ignoring mda1_offset %llu mda1_size %llu from pv_header.",
+			  (unsigned long long)mda1_offset,
+			  (unsigned long long)mda1_size);
+	}
+
+	if ((mda_num == 2) && (mda2_offset != mda_offset)) {
+		log_print("Ignoring mda2_size %llu mda2_offset %llu from pv_header.",
+			  (unsigned long long)mda2_offset,
+			  (unsigned long long)mda2_size);
+	}
+
+	log_print("Searching for metadata in mda%d at offset %llu size %llu", mda_num,
+		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+
+	if (!(buf = malloc(mda_size)))
+		return ECMD_FAILED;
+	memset(buf, 0, mda_size);
+
+	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
+		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
+			   (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		free(buf);
+		return ECMD_FAILED;
+	}
+
+	mh = (struct mda_header *)buf;
+
+	/* Can be useful to know if there's a valid mda_header at this location. */
+	log_print("mda_header_%d@%llu # metadata area", mda_num, (unsigned long long)mda_offset);
+	log_print("mda_header_%d.checksum 0x%x", mda_num, xlate32(mh->checksum_xl));
+	log_print("mda_header_%d.magic 0x%s", mda_num, _chars_to_hexstr(mh->magic, str, 16, 256, "mda_header.magic"));
+	log_print("mda_header_%d.version %u", mda_num, xlate32(mh->version));
+	log_print("mda_header_%d.start %llu", mda_num, (unsigned long long)xlate64(mh->start));
+	log_print("mda_header_%d.size %llu", mda_num, (unsigned long long)xlate64(mh->size));
+
+	_check_mda_header(mh, mda_num, mda_offset, mda_size, &found_header);
+
+	log_print("searching for metadata text");
+
+	_dump_all_text(cmd, tofile, dev, mda_num, mda_offset, mda_size, buf);
+
+	free(buf);
+	return ECMD_PROCESSED;
+}
+
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct device *dev;
@@ -1316,14 +1528,17 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			return _dump_metadata(cmd, argc, argv, 1, 0);
+			return _dump_metadata(cmd, argc, argv, PRINT_CURRENT, 0);
 
 		if (!strcmp(dump, "metadata_all"))
-			return _dump_metadata(cmd, argc, argv, 2, 0);
+			return _dump_metadata(cmd, argc, argv, PRINT_ALL, 0);
 
 		if (!strcmp(dump, "metadata_area"))
 			return _dump_metadata(cmd, argc, argv, 0, 1);
 
+		if (!strcmp(dump, "metadata_search"))
+			return _dump_search(cmd, argc, argv);
+
 		if (!strcmp(dump, "headers"))
 			return _dump_headers(cmd, argc, argv);
 


