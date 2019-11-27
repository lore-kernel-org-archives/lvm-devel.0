From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:10 -0500
Subject: master - pvck: allow disk locations to be specified
Message-ID: <90733.119112712210701563@us-mta-269.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cf08836ef42c32de6874e77e1d3003b7b476039
Commit:        9cf08836ef42c32de6874e77e1d3003b7b476039
Parent:        53126ceada394f7c12ce95c4cd8d824132d418eb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 22 13:28:45 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

pvck: allow disk locations to be specified

using --settings:

mda_offset=<offset> mda_size=<size> can be used
in place of the offset/size that normally come
from headers.

metadata_offset=<offset> prints/saves one instance
of metadata text at the given offset, in
metadata_all or metadata_search.
---
 tools/args.h           |    4 +
 tools/command-lines.in |    2 +-
 tools/pvck.c           |  214 +++++++++++++++++++++++++++++-------------------
 3 files changed, 134 insertions(+), 86 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index bd07aa3..2f84d2c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -459,6 +459,10 @@ arg(setphysicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
     "Overrides the automatically detected size of the PV.\n"
     "Use with care, or prior to reducing the physical size of the device.\n")
 
+arg(settings_ARG, '\0', "settings", string_VAL, ARG_GROUPABLE, 0,
+    "Specifies command specific settings in \"Key = Value\" form.\n"
+    "Repeat this option to specify multiple values.\n")
+
 arg(poll_ARG, '\0', "poll", bool_VAL, 0, 0,
     "When yes, start the background transformation of an LV.\n"
     "An incomplete transformation, e.g. pvmove or lvconvert interrupted\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 7be4715..cbd64a8 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1437,7 +1437,7 @@ ID: pvck_general
 DESC: Check for metadata on a device
 
 pvck --dump String PV
-OO: --file String, --pvmetadatacopies MetadataCopiesPV, --labelsector Number
+OO: --settings String, --file String, --pvmetadatacopies MetadataCopiesPV, --labelsector Number
 ID: pvck_dump
 DESC: Print metadata from a device
 
diff --git a/tools/pvck.c b/tools/pvck.c
index d2c2f9d..483c49f 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -23,6 +23,16 @@
 #define PRINT_CURRENT 1
 #define PRINT_ALL 2
 
+struct settings {
+	uint64_t metadata_offset;  /* start of text metadata, from start of disk */
+	uint64_t mda_offset;       /* start of mda_header, from start of disk */
+	uint64_t mda_size;         /* size of metadata area (mda_header + text area) */
+
+	unsigned metadata_offset_set:1;
+	unsigned mda_offset_set:1;
+	unsigned mda_size_set:1;
+};
+
 static char *_chars_to_str(void *in, void *out, int num, int max, const char *field)
 {
 	char *i = in;
@@ -237,7 +247,7 @@ static void _copy_line(char *in, char *out, int *len)
 	*len = i+1;
 }
 
-static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct device *dev,
+static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const char *tofile, struct device *dev,
 			  int mda_num, uint64_t mda_offset, uint64_t mda_size, char *buf)
 {
 	FILE *fp = NULL;
@@ -253,6 +263,7 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 	uint32_t crc;
 	uint64_t text_size;
 	uint64_t meta_size;
+	int metadata_offset_found = 0;
 	int multiple_vgs = 0;
 	int bad_end;
 	int vgnamelen;
@@ -320,6 +331,19 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 		p = buf + buf_off;
 
 		/*
+		 * user specified metadata in one location
+		 */
+		if (set->metadata_offset_set && (set->metadata_offset != (mda_offset + buf_off))) {
+			count++;
+			continue;
+		}
+		if (set->metadata_offset_set) {
+			if (metadata_offset_found)
+				break;
+			metadata_offset_found = 1;
+		}
+
+		/*
 		 * copy line of possible metadata to check for vgname
 		 */
 		memset(line, 0, sizeof(line));
@@ -427,7 +451,8 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 
 		if (fp) {
 			fprintf(fp, "%s", text_buf);
-			fprintf(fp, "\n--\n");
+			if (!set->metadata_offset_set)
+				fprintf(fp, "\n--\n");
 		}
 
 		free(text_buf);
@@ -676,19 +701,6 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	return 1;
 }
 
-/*
- * Search for any instance of id_str[] in the metadata area,
- * where the id_str indicates the start of a metadata copy
- * (which could be complete or a fragment.)
- * id_str is an open brace followed by id = <uuid>.
- *
- * {\n
- *    id = "lL7Mnk-oCGn-Bde2-9B6S-44Z7-VrHa-wvfC3v"
- *
- * 1\23456789012345678901234567890123456789012345678
- *          10        20        30        40
- */
-
 static int _dump_current_text(struct device *dev,
 			      int print_fields, int print_metadata, const char *tofile,
 			      int mda_num, int rlocn_index,
@@ -1049,7 +1061,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
  * pv_header is.
  */
 
-static int _dump_mda_header(struct cmd_context *cmd,
+static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 			    int print_fields, int print_metadata, int print_area,
 			    const char *tofile,
 			    struct device *dev,
@@ -1171,7 +1183,7 @@ static int _dump_mda_header(struct cmd_context *cmd,
 			goto out;
 		}
 
-		_dump_all_text(cmd, tofile, dev, mda_num, mda_offset, mda_size, buf);
+		_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, buf);
 	}
 
 	/* Should we also check text metadata if it exists in rlocn1? */
@@ -1183,7 +1195,8 @@ static int _dump_mda_header(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _dump_headers(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
+static int _dump_headers(struct cmd_context *cmd, const char *dump, struct settings *set,
+			 uint64_t labelsector, struct device *dev,
 			 int argc, char **argv)
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
@@ -1200,31 +1213,14 @@ static int _dump_headers(struct cmd_context *cmd, uint64_t labelsector, struct d
 		return ECMD_PROCESSED;
 	}
 
-	/* N.B. mda1_size and mda2_size may be different */
-
 	/*
 	 * The first mda is always 4096 bytes from the start of the device.
-	 *
-	 * TODO: A second mda may not exist.  If the pv_header says there
-	 * is no second mda, we may still want to check for a second mda
-	 * in case it's the pv_header that is wrong.  Try looking for
-	 * an mda_header at 1MB prior to the end of the device, if
-	 * mda2_offset is 0 or if we don't find an mda_header at mda2_offset
-	 * which may have been corrupted.
 	 */
-
-	if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, NULL))
+	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, NULL))
 		bad++;
 
-	/*
-	 * mda2_offset may be incorrect.  Probe for a valid mda_header at
-	 * mda2_offset and at other possible/expected locations, e.g.
-	 * 1MB before end of device.  Call dump_mda_header with a different
-	 * offset than mda2_offset if there's no valid header at mda2_offset 
-	 * but there is a valid header elsewhere.
-	 */
 	if (mda2_offset) {
-		if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
 			bad++;
 
 		/* This probably indicates that one was committed and the other not. */
@@ -1239,7 +1235,8 @@ static int _dump_headers(struct cmd_context *cmd, uint64_t labelsector, struct d
 	return ECMD_PROCESSED;
 }
 
-static int _dump_metadata(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
+static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct settings *set,
+			 uint64_t labelsector, struct device *dev,
 			 int argc, char **argv,
 			 int print_metadata, int print_area)
 {
@@ -1270,30 +1267,16 @@ static int _dump_metadata(struct cmd_context *cmd, uint64_t labelsector, struct
 
 	/*
 	 * The first mda is always 4096 bytes from the start of the device.
-	 *
-	 * TODO: A second mda may not exist.  If the pv_header says there
-	 * is no second mda, we may still want to check for a second mda
-	 * in case it's the pv_header that is wrong.  Try looking for
-	 * an mda_header at 1MB prior to the end of the device, if
-	 * mda2_offset is 0 or if we don't find an mda_header at mda2_offset
-	 * which may have been corrupted.
-	 *
-	 * mda2_offset may be incorrect.  Probe for a valid mda_header at
-	 * mda2_offset and at other possible/expected locations, e.g.
-	 * 1MB before end of device.  Call dump_mda_header with a different
-	 * offset than mda2_offset if there's no valid header at mda2_offset 
-	 * but there is a valid header elsewhere.
 	 */
-
 	if (mda_num == 1) {
-		if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, 4096, mda1_size, &mda1_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, 4096, mda1_size, &mda1_checksum, NULL))
 			bad++;
 	} else if (mda_num == 2) {
 		if (!mda2_offset) {
 			log_print("CHECK: second mda not found");
 			bad++;
 		} else {
-			if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
+			if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
 				bad++;
 		}
 	}
@@ -1305,7 +1288,7 @@ static int _dump_metadata(struct cmd_context *cmd, uint64_t labelsector, struct
 	return ECMD_PROCESSED;
 }
 
-static int _dump_found(struct cmd_context *cmd, uint64_t labelsector, struct device *dev)
+static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t labelsector, struct device *dev)
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum = 0, mda2_checksum = 0;
@@ -1318,12 +1301,12 @@ static int _dump_found(struct cmd_context *cmd, uint64_t labelsector, struct dev
 		bad++;
 
 	if (found_label && mda1_offset) {
-		if (!_dump_mda_header(cmd, 0, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, &found_header1))
+		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, &found_header1))
 			bad++;
 	}
 
 	if (found_label && mda2_offset) {
-		if (!_dump_mda_header(cmd, 0, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, &found_header2))
+		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, &found_header2))
 			bad++;
 	}
 
@@ -1358,16 +1341,14 @@ static int _dump_found(struct cmd_context *cmd, uint64_t labelsector, struct dev
  * zeroed/damaged.
  */
 
-static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
+static int _dump_search(struct cmd_context *cmd, const char *dump, struct settings *set,
+			uint64_t labelsector, struct device *dev,
 			int argc, char **argv)
 {
-	char str[256];
 	const char *tofile = NULL;
 	char *buf;
-	struct mda_header *mh;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint64_t mda_offset, mda_size;
-	int found_header = 0;
 	int mda_count = 0;
 	int mda_num = 1;
 
@@ -1384,9 +1365,6 @@ static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct de
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	/*
-	 * TODO: allow mda_offset and mda_size to be specified on the
-	 * command line.
-	 *
 	 * For mda1, mda_offset is always 4096 bytes from the start of
 	 * device, and mda_size is the space between mda_offset and
 	 * the first PE which is usually at 1MB.
@@ -1404,7 +1382,10 @@ static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct de
 	 * at the end of device (mod 1MB extra) can make mda2 even
 	 * larger.
 	 */
-	if (mda_num == 1) {
+	if (set->mda_offset_set && set->mda_size_set) {
+		mda_offset = set->mda_offset;
+		mda_size = set->mda_size;
+	} else if (mda_num == 1) {
 		mda_offset = 4096;
 		mda_size = ONE_MB_IN_BYTES - 4096;
 	} else if (mda_num == 2) {
@@ -1436,7 +1417,7 @@ static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct de
 			  (unsigned long long)mda2_size);
 	}
 
-	log_print("Searching for metadata in mda%d at offset %llu size %llu", mda_num,
+	log_print("Searching for metadata at offset %llu size %llu",
 		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 
 	if (!(buf = malloc(mda_size)))
@@ -1450,28 +1431,88 @@ static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct de
 		return ECMD_FAILED;
 	}
 
-	mh = (struct mda_header *)buf;
+	_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, buf);
 
-	/* Can be useful to know if there's a valid mda_header at this location. */
-	log_print("mda_header_%d at %llu # metadata area", mda_num, (unsigned long long)mda_offset);
-	log_print("mda_header_%d.checksum 0x%x", mda_num, xlate32(mh->checksum_xl));
-	log_print("mda_header_%d.magic 0x%s", mda_num, _chars_to_hexstr(mh->magic, str, 16, 256, "mda_header.magic"));
-	log_print("mda_header_%d.version %u", mda_num, xlate32(mh->version));
-	log_print("mda_header_%d.start %llu", mda_num, (unsigned long long)xlate64(mh->start));
-	log_print("mda_header_%d.size %llu", mda_num, (unsigned long long)xlate64(mh->size));
+	free(buf);
+	return ECMD_PROCESSED;
+}
 
-	_check_mda_header(mh, mda_num, mda_offset, mda_size, &found_header);
+static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char *key, char *val)
+{
+	if (!strncmp(key, "metadata_offset", strlen("metadata_offset"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->metadata_offset) != 1)
+			goto_bad;
+		set->metadata_offset_set = 1;
+		return 1;
+	}
 
-	log_print("searching for metadata text");
+	if (!strncmp(key, "mda_offset", strlen("mda_offset"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->mda_offset) != 1)
+			goto_bad;
+		set->mda_offset_set = 1;
+		return 1;
+	}
 
-	_dump_all_text(cmd, tofile, dev, mda_num, mda_offset, mda_size, buf);
+	if (!strncmp(key, "mda_size", strlen("mda_size"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->mda_size) != 1)
+			goto_bad;
+		set->mda_size_set = 1;
+		return 1;
+	}
+bad:
+	log_error("Invalid setting: %s", key);
+	return 0;
+}
 
-	free(buf);
-	return ECMD_PROCESSED;
+static int _get_settings(struct cmd_context *cmd, struct settings *set)
+{
+	struct arg_value_group_list *group;
+	const char *str;
+	char key[64];
+	char val[64];
+	int num;
+	int pos;
+
+	memset(set, 0, sizeof(struct settings));
+
+	/*
+	 * "grouped" means that multiple --settings options can be used.
+	 * Each option is also allowed to contain multiple key = val pairs.
+	 */
+
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, settings_ARG))
+			continue;
+
+		if (!(str = grouped_arg_str_value(group->arg_values, settings_ARG, NULL)))
+			break;
+
+		pos = 0;
+
+		while (pos < strlen(str)) {
+			/* scan for "key1=val1 key2 = val2  key3= val3" */
+
+			memset(key, 0, sizeof(key));
+			memset(val, 0, sizeof(val));
+
+			if (sscanf(str + pos, " %63[^=]=%63s %n", key, val, &num) != 2) {
+				log_error("Invalid setting at: %s", str+pos);
+				return 0;
+			}
+
+			pos += num;
+
+			if (!_get_one_setting(cmd, set, key, val))
+				return_0;
+		}
+	}
+
+	return 1;
 }
 
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct settings set;
 	struct device *dev;
 	const char *dump;
 	const char *pv_name;
@@ -1496,6 +1537,9 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (!_get_settings(cmd, &set))
+		return ECMD_FAILED;
+
 	label_scan_setup_bcache();
 
 	if (arg_is_set(cmd, dump_ARG)) {
@@ -1504,19 +1548,19 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			return _dump_metadata(cmd, labelsector, dev, argc, argv, PRINT_CURRENT, 0);
+			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, PRINT_CURRENT, 0);
 
 		if (!strcmp(dump, "metadata_all"))
-			return _dump_metadata(cmd, labelsector, dev, argc, argv, PRINT_ALL, 0);
+			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, PRINT_ALL, 0);
 
 		if (!strcmp(dump, "metadata_area"))
-			return _dump_metadata(cmd, labelsector, dev, argc, argv, 0, 1);
+			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, 0, 1);
 
 		if (!strcmp(dump, "metadata_search"))
-			return _dump_search(cmd, labelsector, dev, argc, argv);
+			return _dump_search(cmd, dump, &set, labelsector, dev, argc, argv);
 
 		if (!strcmp(dump, "headers"))
-			return _dump_headers(cmd, labelsector, dev, argc, argv);
+			return _dump_headers(cmd, dump, &set, labelsector, dev, argc, argv);
 
 		log_error("Unknown dump value.");
 		return ECMD_FAILED;
@@ -1535,7 +1579,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!_dump_found(cmd, labelsector, dev))
+		if (!_dump_found(cmd, &set, labelsector, dev))
 			bad++;
 	}
 



