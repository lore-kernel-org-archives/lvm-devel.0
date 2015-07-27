From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 27 Jul 2015 20:32:46 +0000 (UTC)
Subject: master - libdm: Add dm_size_to_string to libdevmapper.
Message-ID: <20150727203246.7C4EE61131@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af1c7bf0c71f9cc132e9cf211eb1512078af0081
Commit:        af1c7bf0c71f9cc132e9cf211eb1512078af0081
Parent:        fa11ddd7df9cd29956cb2610d4a730980734b8c2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 27 21:30:20 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 27 21:30:20 2015 +0100

libdm: Add dm_size_to_string to libdevmapper.

Moved out from lib/display and a little documentation added.
It's tuned to LVM's requirements historically and its behaviour
might not always be what you would expect.
---
 configure.in                        |    2 +-
 lib/display/display.c               |  156 ++--------------------------------
 libdm/.exported_symbols.DM_1_02_104 |    1 +
 libdm/libdevmapper.h                |   26 ++++++
 libdm/libdm-string.c                |  157 ++++++++++++++++++++++++++++++++++-
 5 files changed, 193 insertions(+), 149 deletions(-)

diff --git a/configure.in b/configure.in
index c2cd69a..e273e1d 100644
--- a/configure.in
+++ b/configure.in
@@ -1726,7 +1726,7 @@ if test "$BUILD_CMIRRORD" = yes; then
 fi
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	AC_CHECK_FUNCS(clock_gettime strtoull,,hard_bailout) 
+	AC_CHECK_FUNCS(clock_gettime strtoull,,hard_bailout)
 fi
 
 if test "$BUILD_LVMPOLLD" = yes; then
diff --git a/lib/display/display.c b/lib/display/display.c
index 62ad1fe..308ce31 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -24,10 +24,6 @@
 
 #include <stdarg.h>
 
-#define SIZE_BUF 128
-
-typedef enum { SIZE_LONG = 0, SIZE_SHORT = 1, SIZE_UNIT = 2 } size_len_t;
-
 static const struct {
 	alloc_policy_t alloc;
 	const char str[14]; /* must be changed when size extends 13 chars */
@@ -146,164 +142,30 @@ const char *display_lvname(const struct logical_volume *lv)
 	return name;
 }
 
-#define BASE_UNKNOWN 0
-#define BASE_SHARED 1
-#define BASE_1024 8
-#define BASE_1000 15
-#define BASE_SPECIAL 21
-#define NUM_UNIT_PREFIXES 6
-#define NUM_SPECIAL 3
-
 /* Size supplied in sectors */
 static const char *_display_size(const struct cmd_context *cmd,
-				 uint64_t size, size_len_t sl)
+				 uint64_t size, dm_size_suffix_t suffix_type)
 {
-	unsigned base = BASE_UNKNOWN;
-	unsigned s;
-	int suffix, precision;
-	uint64_t byte = UINT64_C(0);
-	uint64_t units = UINT64_C(1024);
-	char *size_buf = NULL;
-	const char * const size_str[][3] = {
-		/* BASE_UNKNOWN */
-		{"         ", "   ", " "},	/* [0] */
-
-		/* BASE_SHARED - Used if cmd->si_unit_consistency = 0 */
-		{" Exabyte", " EB", "E"},	/* [1] */
-		{" Petabyte", " PB", "P"},	/* [2] */
-		{" Terabyte", " TB", "T"},	/* [3] */
-		{" Gigabyte", " GB", "G"},	/* [4] */
-		{" Megabyte", " MB", "M"},	/* [5] */
-		{" Kilobyte", " KB", "K"},	/* [6] */
-		{" Byte    ", " B", "B"},	/* [7] */
-
-		/* BASE_1024 - Used if cmd->si_unit_consistency = 1 */
-		{" Exbibyte", " EiB", "e"},	/* [8] */
-		{" Pebibyte", " PiB", "p"},	/* [9] */
-		{" Tebibyte", " TiB", "t"},	/* [10] */
-		{" Gibibyte", " GiB", "g"},	/* [11] */
-		{" Mebibyte", " MiB", "m"},	/* [12] */
-		{" Kibibyte", " KiB", "k"},	/* [13] */
-		{" Byte    ", " B", "b"},	/* [14] */
-
-		/* BASE_1000 - Used if cmd->si_unit_consistency = 1 */
-		{" Exabyte",  " EB", "E"},	/* [15] */
-		{" Petabyte", " PB", "P"},	/* [16] */
-		{" Terabyte", " TB", "T"},	/* [17] */
-		{" Gigabyte", " GB", "G"},	/* [18] */
-		{" Megabyte", " MB", "M"},	/* [19] */
-		{" Kilobyte", " kB", "K"},	/* [20] */
-
-		/* BASE_SPECIAL */
-		{" Byte    ", " B ", "B"},	/* [21] (shared with BASE_1000) */
-		{" Units   ", " Un", "U"},	/* [22] */
-		{" Sectors ", " Se", "S"},	/* [23] */
-	};
-
-	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
-		log_error("no memory for size display buffer");
-		return "";
-	}
-
-	suffix = cmd->current_settings.suffix;
-
-	if (!cmd->si_unit_consistency) {
-		/* Case-independent match */
-		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
-			if (toupper((int) cmd->current_settings.unit_type) ==
-			    *size_str[BASE_SHARED + s][2]) {
-				base = BASE_SHARED;
-				break;
-			}
-	} else {
-		/* Case-dependent match for powers of 1000 */
-		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
-			if (cmd->current_settings.unit_type ==
-			    *size_str[BASE_1000 + s][2]) {
-				base = BASE_1000;
-				break;
-			}
-
-		/* Case-dependent match for powers of 1024 */
-		if (base == BASE_UNKNOWN)
-			for (s = 0; s < NUM_UNIT_PREFIXES; s++)
-			if (cmd->current_settings.unit_type ==
-			    *size_str[BASE_1024 + s][2]) {
-				base = BASE_1024;
-				break;
-			}
-	}
-
-	if (base == BASE_UNKNOWN)
-		/* Check for special units - s, b or u */
-		for (s = 0; s < NUM_SPECIAL; s++)
-			if (toupper((int) cmd->current_settings.unit_type) ==
-			    *size_str[BASE_SPECIAL + s][2]) {
-				base = BASE_SPECIAL;
-				break;
-			}
-
-	if (size == UINT64_C(0)) {
-		if (base == BASE_UNKNOWN)
-			s = 0;
-		sprintf(size_buf, "0%s", suffix ? size_str[base + s][sl] : "");
-		return size_buf;
-	}
-
-	size *= UINT64_C(512);
-
-	if (base != BASE_UNKNOWN)
-		byte = cmd->current_settings.unit_factor;
-	else {
-		/* Human-readable style */
-		if (cmd->current_settings.unit_type == 'H') {
-			units = UINT64_C(1000);
-			base = BASE_1000;
-		} else {
-			units = UINT64_C(1024);
-			base = BASE_1024;
-		}
-
-		if (!cmd->si_unit_consistency)
-			base = BASE_SHARED;
-
-		byte = units * units * units * units * units * units;
-
-		for (s = 0; s < NUM_UNIT_PREFIXES && size < byte; s++)
-			byte /= units;
-
-		suffix = 1;
-	}
-
-	/* FIXME Make precision configurable */
-	switch (toupper(*size_str[base + s][SIZE_UNIT])) {
-	case 'B':
-	case 'S':
-		precision = 0;
-		break;
-	default:
-		precision = 2;
-	}
-
-	snprintf(size_buf, SIZE_BUF - 1, "%.*f%s", precision,
-		 (double) size / byte, suffix ? size_str[base + s][sl] : "");
-
-	return size_buf;
+	return dm_size_to_string(cmd->mem, size, cmd->current_settings.unit_type,
+				 cmd->si_unit_consistency, 
+				 cmd->current_settings.unit_factor,
+				 cmd->current_settings.suffix,
+				 suffix_type);
 }
 
 const char *display_size_long(const struct cmd_context *cmd, uint64_t size)
 {
-	return _display_size(cmd, size, SIZE_LONG);
+	return _display_size(cmd, size, DM_SIZE_LONG);
 }
 
 const char *display_size_units(const struct cmd_context *cmd, uint64_t size)
 {
-	return _display_size(cmd, size, SIZE_UNIT);
+	return _display_size(cmd, size, DM_SIZE_UNIT);
 }
 
 const char *display_size(const struct cmd_context *cmd, uint64_t size)
 {
-	return _display_size(cmd, size, SIZE_SHORT);
+	return _display_size(cmd, size, DM_SIZE_SHORT);
 }
 
 void pvdisplay_colons(const struct physical_volume *pv)
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
new file mode 100644
index 0000000..7bd144d
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -0,0 +1 @@
+dm_size_to_string
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 6523c70..3a900be 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1532,6 +1532,32 @@ int dm_strncpy(char *dest, const char *src, size_t n);
 uint64_t dm_units_to_factor(const char *units, char *unit_type,
 			    int strict, const char **endptr);
 
+/*
+ * Type of unit specifier used by dm_size_to_string().
+ */
+typedef enum {
+	DM_SIZE_LONG = 0,	/* Megabyte */
+	DM_SIZE_SHORT = 1,	/* MB or MiB */
+	DM_SIZE_UNIT = 2	/* M or m */
+} dm_size_suffix_t;
+
+/*
+ * Convert a size (in 512-byte sectors) into a printable string using units of unit_type.
+ * An upper-case unit_type indicates output units based on powers of 1000 are
+ * required; a lower-case unit_type indicates powers of 1024.
+ * For correct operation, unit_factor must be one of:
+ * 	0 - the correct value will be calculated internally;
+ *   or the output from dm_units_to_factor() corresponding to unit_type;
+ *   or 'u' or 'U', an arbitrary number of bytes to use as the power base.
+ * Set include_suffix to 1 to include a suffix of suffix_type.
+ * Set use_si_units to 0 for suffixes that don't distinguish between 1000 and 1024.
+ * Set use_si_units to 1 for a suffix that does distinguish.
+ */
+const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
+			      char unit_type, int use_si_units, 
+			      uint64_t unit_factor, int include_suffix, 
+			      dm_size_suffix_t suffix_type);
+
 /**************************
  * file/stream manipulation
  **************************/
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index bc41b70..587abfe 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2006-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -443,6 +443,161 @@ static int _close_enough(double d1, double d2)
 	return fabs(d1 - d2) < DBL_EPSILON;
 }
 
+#define BASE_UNKNOWN 0
+#define BASE_SHARED 1
+#define BASE_1024 8
+#define BASE_1000 15
+#define BASE_SPECIAL 21
+#define NUM_UNIT_PREFIXES 6
+#define NUM_SPECIAL 3
+
+#define SIZE_BUF 128
+
+const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
+			      char unit_type, int use_si_units, 
+			      uint64_t unit_factor, int include_suffix, 
+			      dm_size_suffix_t suffix_type)
+{
+	unsigned base = BASE_UNKNOWN;
+	unsigned s;
+	int precision;
+	uint64_t byte = UINT64_C(0);
+	uint64_t units = UINT64_C(1024);
+	char *size_buf = NULL;
+	char new_unit_type = '\0', unit_type_buf[2];
+	const char * const size_str[][3] = {
+		/* BASE_UNKNOWN */
+		{"         ", "   ", " "},	/* [0] */
+
+		/* BASE_SHARED - Used if use_si_units = 0 */
+		{" Exabyte", " EB", "E"},	/* [1] */
+		{" Petabyte", " PB", "P"},	/* [2] */
+		{" Terabyte", " TB", "T"},	/* [3] */
+		{" Gigabyte", " GB", "G"},	/* [4] */
+		{" Megabyte", " MB", "M"},	/* [5] */
+		{" Kilobyte", " KB", "K"},	/* [6] */
+		{" Byte    ", " B", "B"},	/* [7] */
+
+		/* BASE_1024 - Used if use_si_units = 1 */
+		{" Exbibyte", " EiB", "e"},	/* [8] */
+		{" Pebibyte", " PiB", "p"},	/* [9] */
+		{" Tebibyte", " TiB", "t"},	/* [10] */
+		{" Gibibyte", " GiB", "g"},	/* [11] */
+		{" Mebibyte", " MiB", "m"},	/* [12] */
+		{" Kibibyte", " KiB", "k"},	/* [13] */
+		{" Byte    ", " B", "b"},	/* [14] */
+
+		/* BASE_1000 - Used if use_si_units = 1 */
+		{" Exabyte",  " EB", "E"},	/* [15] */
+		{" Petabyte", " PB", "P"},	/* [16] */
+		{" Terabyte", " TB", "T"},	/* [17] */
+		{" Gigabyte", " GB", "G"},	/* [18] */
+		{" Megabyte", " MB", "M"},	/* [19] */
+		{" Kilobyte", " kB", "K"},	/* [20] */
+
+		/* BASE_SPECIAL */
+		{" Byte    ", " B ", "B"},	/* [21] (shared with BASE_1000) */
+		{" Units   ", " Un", "U"},	/* [22] */
+		{" Sectors ", " Se", "S"},	/* [23] */
+	};
+
+	if (!(size_buf = dm_pool_alloc(mem, SIZE_BUF))) {
+		log_error("no memory for size display buffer");
+		return "";
+	}
+
+	if (!use_si_units) {
+		/* Case-independent match */
+		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (toupper((int) unit_type) ==
+			    *size_str[BASE_SHARED + s][2]) {
+				base = BASE_SHARED;
+				break;
+			}
+	} else {
+		/* Case-dependent match for powers of 1000 */
+		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (unit_type == *size_str[BASE_1000 + s][2]) {
+				base = BASE_1000;
+				break;
+			}
+
+		/* Case-dependent match for powers of 1024 */
+		if (base == BASE_UNKNOWN)
+			for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (unit_type == *size_str[BASE_1024 + s][2]) {
+				base = BASE_1024;
+				break;
+			}
+	}
+
+	if (base == BASE_UNKNOWN)
+		/* Check for special units - s, b or u */
+		for (s = 0; s < NUM_SPECIAL; s++)
+			if (toupper((int) unit_type) ==
+			    *size_str[BASE_SPECIAL + s][2]) {
+				base = BASE_SPECIAL;
+				break;
+			}
+
+	if (size == UINT64_C(0)) {
+		if (base == BASE_UNKNOWN)
+			s = 0;
+		sprintf(size_buf, "0%s", include_suffix ? size_str[base + s][suffix_type] : "");
+		return size_buf;
+	}
+
+	size *= UINT64_C(512);
+
+	if (base != BASE_UNKNOWN) {
+		if (!unit_factor) {
+			unit_type_buf[0] = unit_type;
+			unit_type_buf[1] = '\0';
+			if (!(unit_factor = dm_units_to_factor(&unit_type_buf[0], &new_unit_type, 1, NULL)) ||
+			    unit_type != new_unit_type) {
+				/* The two functions should match (and unrecognised units get treated like 'h'). */
+				log_error(INTERNAL_ERROR "Inconsistent units: %c and %c.", unit_type, new_unit_type);
+				return "";
+			}
+		}
+		byte = unit_factor;
+	} else {
+		/* Human-readable style */
+		if (unit_type == 'H') {
+			units = UINT64_C(1000);
+			base = BASE_1000;
+		} else {
+			units = UINT64_C(1024);
+			base = BASE_1024;
+		}
+
+		if (!use_si_units)
+			base = BASE_SHARED;
+
+		byte = units * units * units * units * units * units;
+
+		for (s = 0; s < NUM_UNIT_PREFIXES && size < byte; s++)
+			byte /= units;
+
+		include_suffix = 1;
+	}
+
+	/* FIXME Make precision configurable */
+	switch (toupper(*size_str[base + s][DM_SIZE_UNIT])) {
+	case 'B':
+	case 'S':
+		precision = 0;
+		break;
+	default:
+		precision = 2;
+	}
+
+	snprintf(size_buf, SIZE_BUF - 1, "%.*f%s", precision,
+		 (double) size / byte, include_suffix ? size_str[base + s][suffix_type] : "");
+
+	return size_buf;
+}
+
 uint64_t dm_units_to_factor(const char *units, char *unit_type,
 			    int strict, const char **endptr)
 {


