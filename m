From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:39 -0500
Subject: master - pvck: improve mda_offset mda_size choices
Message-ID: <202003041458.024EwdOZ015623@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c6746181a3c2c40447f5a33e15359b57567f8217
Commit:        c6746181a3c2c40447f5a33e15359b57567f8217
Parent:        1b79673845496402d9614784e8b08dbd284328ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 28 12:00:23 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

pvck: improve mda_offset mda_size choices

Attempt to calculate an offset or size if one only
value was specified in the settings.

Use header values when available.
---
 tools/pvck.c | 199 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 182 insertions(+), 17 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 745f0f9..ab85537 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -20,6 +20,8 @@
 #include "lib/mm/xlate.h"
 #include "lib/misc/crc.h"
 
+#define ONE_MB_IN_BYTES 1048576
+
 #define PRINT_CURRENT 1
 #define PRINT_ALL 2
 
@@ -297,6 +299,49 @@ static void _copy_line(char *in, char *out, int *len, int linesize)
 	*len = i+1;
 }
 
+static uint64_t mda2_offset_from_size(struct device *dev, uint64_t mda2_size)
+{
+	uint64_t dev_sectors = 0;
+	uint64_t dev_bytes;
+	uint64_t extra_bytes;
+	uint64_t mda2_offset;
+
+	if (dev_get_size(dev, &dev_sectors))
+		stack;
+
+	dev_bytes = dev_sectors * 512;
+	extra_bytes = dev_bytes % ONE_MB_IN_BYTES;
+
+	if (dev_bytes < (2 * ONE_MB_IN_BYTES))
+		return_0;
+
+	mda2_offset = dev_bytes - extra_bytes - mda2_size;
+
+	return mda2_offset;
+}
+
+static uint64_t mda2_size_from_offset(struct device *dev, uint64_t mda2_offset)
+{
+	uint64_t dev_sectors = 0;
+	uint64_t dev_bytes;
+	uint64_t extra_bytes;
+	uint64_t mda2_size;
+
+	if (dev_get_size(dev, &dev_sectors))
+		stack;
+
+	dev_bytes = dev_sectors * 512;
+	extra_bytes = dev_bytes % ONE_MB_IN_BYTES;
+
+	if (dev_bytes < (2 * ONE_MB_IN_BYTES))
+		return_0;
+
+	mda2_size = dev_bytes - extra_bytes - mda2_offset;
+
+	return mda2_size;
+}
+
+
 /* all sizes and offsets in bytes */
 
 static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const char *tofile, struct device *dev,
@@ -1419,8 +1464,6 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
 	return 1;
 }
 
-#define ONE_MB_IN_BYTES 1048576
-
 /*
  * all sizes and offsets in bytes (except dev_sectors from dev_get_size)
  *
@@ -1435,21 +1478,18 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	const char *tofile = NULL;
 	char *buf;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
-	uint64_t mda_offset, mda_size; /* bytes */
+	uint64_t mda_offset = 0, mda_size = 0; /* bytes */
+	int mda_num = 0;
+	int found_label = 0;
 	int mda_count = 0;
-	int mda_num = 1;
+	int set_vals = 0;
 
 	if (arg_is_set(cmd, file_ARG)) {
 		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
 			return_0;
 	}
 
-	if (set->mda_num)
-		mda_num = set->mda_num;
-	else if (arg_is_set(cmd, pvmetadatacopies_ARG))
-		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
-
-	_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
+	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	/*
@@ -1470,13 +1510,131 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	 * at the end of device (mod 1MB extra) can make mda2 even
 	 * larger.
 	 */
-	if (set->mda_offset_set && set->mda_size_set) {
-		mda_offset = set->mda_offset;
-		mda_size = set->mda_size;
+
+	/*
+	 * When mda offset or size is set in command line settings,
+	 * use what is set and calculate an unspecified value.
+	 */
+	if (set->mda_offset_set || set->mda_size_set) {
+		if (set->mda_offset_set) {
+			mda_offset = set->mda_offset;
+			set_vals++;
+		}
+		if (set->mda_size_set) {
+			mda_size = set->mda_size;
+			set_vals++;
+		}
+		if ((mda_num = set->mda_num))
+			set_vals++;
+
+		if (mda_offset && mda_size)
+			goto search;
+
+		if (set_vals < 2) {
+			log_error("Specify@least two values from: mda_num, mda_offset, mda_size.");
+			return 0;
+		}
+
+		if (!mda_size) {
+			if ((mda_num == 1) && mda1_size)
+				mda_size = mda1_size; /* from headers */
+			else if ((mda_num == 2) && mda2_size)
+				mda_size = mda2_size; /* from headers */
+			else if (mda_num == 1)
+				mda_size = ONE_MB_IN_BYTES - 4096;
+			else if (mda_num == 2)
+				mda_size = mda2_size_from_offset(dev, mda_offset);
+		}
+		if (!mda_offset) {
+			if (mda_num == 1)
+				mda_offset = 4096;
+			else if (mda_num == 2)
+				mda_offset = mda2_offset_from_size(dev, mda_size);
+		}
+
+		if (set->mda2_offset_set || set->mda2_size_set)
+			log_print("Ignoring mda2 values from settings.");
+
+		goto search;
+	}
+	if (set->mda2_offset_set || set->mda2_size_set) {
+		if (set->mda2_offset_set) {
+			mda_offset = set->mda2_offset;
+			set_vals++;
+		}
+		if (set->mda_size_set) {
+			mda_size = set->mda2_size;
+			set_vals++;
+		}
+		if ((mda_num = set->mda_num))
+			set_vals++;
+
+		if (mda_offset && mda_size)
+			goto search;
+
+		if (set_vals < 2) {
+			log_error("Specify@least two values from: mda_num, mda2_offset, mda2_size.");
+			return 0;
+		}
+
+		if (mda_num == 1) {
+			log_error("Invalid mda_num=1 and mda2 settings.");
+			return 0;
+		}
+
+		if (!mda_size) {
+			if (mda2_size)
+				mda_size = mda2_size; /* from headers */
+			else
+				mda_size = mda2_size_from_offset(dev, mda_offset);
+		}
+		if (!mda_offset) {
+			if (mda2_offset)
+				mda_offset = mda2_offset; /* from headers */
+			else
+				mda_offset = mda2_offset_from_size(dev, mda_size);
+		}
+
+		goto search;
+	}
+
+	/*
+	 * When no mda offset or size is set in command line settings,
+	 * the user can just set mda_num=1|2 to control if we pick defaults
+	 * for mda1 or mda2.  If unspecified, we search in the first mda.
+	 */
+	if (set->mda_num)
+		mda_num = set->mda_num;
+	else if (arg_is_set(cmd, pvmetadatacopies_ARG))
+		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
+	else
+		mda_num = 1;
+
+	/*
+	 * No mda offset or size was set in command line settings,
+	 * so we use what's in the headers or defaults.
+	 */
+	if ((mda_num == 1) && found_label && mda1_offset && mda1_size) {
+		/* use header values when available */
+		mda_offset = 4096;
+		mda_size = mda1_size;
+
 	} else if (mda_num == 1) {
+		/* use default values when header values are not available */
 		mda_offset = 4096;
 		mda_size = ONE_MB_IN_BYTES - 4096;
+
+		log_print("Using common defaults for first mda: offset %llu size %llu.",
+			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		log_print("Override defaults with --settings \"mda_offset=<bytes> mda_size=<bytes>\"");
+
+	} else if ((mda_num == 2) && found_label && mda2_offset && mda2_size) {
+		/* use header values when available */
+		mda_offset = mda2_offset;
+		mda_size = mda2_size;
+
 	} else if (mda_num == 2) {
+		/* use default values when header values are not available */
 		uint64_t dev_sectors = 0;
 		uint64_t dev_bytes;
 		uint64_t extra_bytes;
@@ -1492,17 +1650,24 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 
 		mda_offset = dev_bytes - extra_bytes - ONE_MB_IN_BYTES;
 		mda_size = dev_bytes - mda_offset;
-	} else
+
+		log_print("Using defaults for second mda: offset %llu size %llu.",
+			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		log_print("Override defaults with --settings \"mda_offset=<bytes> mda_size=<bytes>\"");
+	} else {
+		log_error("No mda location.");
 		return_0;
+	}
 
-	if ((mda_num == 1) && (mda1_offset != mda_offset)) {
+ search:
+	if ((mda_num == 1) && ((mda1_offset && mda1_offset != mda_offset) || (mda1_size && mda1_size != mda_size))) {
 		log_print("Ignoring mda1_offset %llu mda1_size %llu from pv_header.",
 			  (unsigned long long)mda1_offset,
 			  (unsigned long long)mda1_size);
 	}
 
-	if ((mda_num == 2) && (mda2_offset != mda_offset)) {
-		log_print("Ignoring mda2_size %llu mda2_offset %llu from pv_header.",
+	if ((mda_num == 2) && ((mda2_offset && mda2_offset != mda_offset) || (mda2_size && mda2_size != mda_size))) {
+		log_print("Ignoring mda2_offset %llu mda2_size %llu from pv_header.",
 			  (unsigned long long)mda2_offset,
 			  (unsigned long long)mda2_size);
 	}



