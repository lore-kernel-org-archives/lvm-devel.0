From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:19 -0500
Subject: master - pvck: dump functions cleanup args and return vals
Message-ID: <11853.119112712211402127@us-mta-192.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e0f2730081554460328b3ac7e28080bd902535c
Commit:        2e0f2730081554460328b3ac7e28080bd902535c
Parent:        d051e899a5ab856da51b9482e3eaf822a73f274d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 4 13:38:23 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

pvck: dump functions cleanup args and return vals

---
 tools/pvck.c |   68 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 6e9b10d..8588906 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1218,8 +1218,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 }
 
 static int _dump_headers(struct cmd_context *cmd, const char *dump, struct settings *set,
-			 uint64_t labelsector, struct device *dev,
-			 int argc, char **argv)
+			 uint64_t labelsector, struct device *dev)
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
@@ -1232,7 +1231,7 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 
 	if (!mda_count) {
 		log_print("zero metadata copies");
-		return ECMD_PROCESSED;
+		return 1;
 	}
 
 	/*
@@ -1252,14 +1251,13 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 
 	if (bad) {
 		log_error("Found bad header or metadata values.");
-		return ECMD_FAILED;
+		return 0;
 	}
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct settings *set,
 			 uint64_t labelsector, struct device *dev,
-			 int argc, char **argv,
 			 int print_metadata, int print_area)
 {
 	const char *tofile = NULL;
@@ -1271,11 +1269,12 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 
 	if (arg_is_set(cmd, file_ARG)) {
 		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
-			return ECMD_FAILED;
+			return 0;
 	}
 
-	/* 1: dump metadata from first mda, 2: dump metadata from second mda */
-	if (arg_is_set(cmd, pvmetadatacopies_ARG))
+	if (set->mda_num)
+		mda_num = set->mda_num;
+	else if (arg_is_set(cmd, pvmetadatacopies_ARG))
 		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
 
 	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
@@ -1284,7 +1283,7 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 
 	if (!mda_count) {
 		log_print("zero metadata copies");
-		return ECMD_PROCESSED;
+		return 1;
 	}
 
 	/*
@@ -1305,9 +1304,9 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 
 	if (bad) {
 		log_error("Found bad header or metadata values.");
-		return ECMD_FAILED;
+		return 0;
 	}
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t labelsector, struct device *dev)
@@ -1364,8 +1363,7 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
  */
 
 static int _dump_search(struct cmd_context *cmd, const char *dump, struct settings *set,
-			uint64_t labelsector, struct device *dev,
-			int argc, char **argv)
+			uint64_t labelsector, struct device *dev)
 {
 	const char *tofile = NULL;
 	char *buf;
@@ -1376,11 +1374,12 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 
 	if (arg_is_set(cmd, file_ARG)) {
 		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
-			return ECMD_FAILED;
+			return_0;
 	}
 
-	/* 1: dump metadata from first mda, 2: dump metadata from second mda */
-	if (arg_is_set(cmd, pvmetadatacopies_ARG))
+	if (set->mda_num)
+		mda_num = set->mda_num;
+	else if (arg_is_set(cmd, pvmetadatacopies_ARG))
 		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
 
 	_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
@@ -1421,7 +1420,7 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 		extra_bytes = dev_bytes % ONE_MB_IN_BYTES;
 
 		if (dev_bytes < (2 * ONE_MB_IN_BYTES))
-			return ECMD_FAILED;
+			return_0;
 
 		mda_offset = dev_bytes - extra_bytes - ONE_MB_IN_BYTES;
 		mda_size = dev_bytes - mda_offset;
@@ -1443,20 +1442,20 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 
 	if (!(buf = malloc(mda_size)))
-		return ECMD_FAILED;
+		return_0;
 	memset(buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
 		log_print("CHECK: failed to read metadata area@offset %llu size %llu",
 			   (unsigned long long)mda_offset, (unsigned long long)mda_size);
 		free(buf);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, buf);
 
 	free(buf);
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char *key, char *val)
@@ -1570,22 +1569,27 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, PRINT_CURRENT, 0);
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, PRINT_CURRENT, 0);
 
-		if (!strcmp(dump, "metadata_all"))
-			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, PRINT_ALL, 0);
+		else if (!strcmp(dump, "metadata_all"))
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, PRINT_ALL, 0);
 
-		if (!strcmp(dump, "metadata_area"))
-			return _dump_metadata(cmd, dump, &set, labelsector, dev, argc, argv, 0, 1);
+		else if (!strcmp(dump, "metadata_area"))
+			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, 0, 1);
 
-		if (!strcmp(dump, "metadata_search"))
-			return _dump_search(cmd, dump, &set, labelsector, dev, argc, argv);
+		else if (!strcmp(dump, "metadata_search"))
+			ret = _dump_search(cmd, dump, &set, labelsector, dev);
 
-		if (!strcmp(dump, "headers"))
-			return _dump_headers(cmd, dump, &set, labelsector, dev, argc, argv);
+		else if (!strcmp(dump, "headers"))
+			ret = _dump_headers(cmd, dump, &set, labelsector, dev);
+		else {
+			log_error("Unknown dump value.");
+			ret = 0;
+		}
 
-		log_error("Unknown dump value.");
-		return ECMD_FAILED;
+		if (!ret)
+			return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	/*



