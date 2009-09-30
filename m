From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Sep 2009 14:19:02 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20090930141902.27590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-30 14:19:01

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Distinguish between powers of 1000 and powers of 1024 in unit suffixes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1282&r2=1.1283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2009/09/29 20:33:49	1.1282
+++ LVM2/WHATS_NEW	2009/09/30 14:19:00	1.1283
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Distinguish between powers of 1000 and powers of 1024 in unit suffixes.
   Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
   Generalise polldaemon code by changing mirror-specific variable names.
   Don't attempt to deactivate an LV if any of its snapshots are in use.
--- LVM2/lib/display/display.c	2009/09/28 16:36:03	1.103
+++ LVM2/lib/display/display.c	2009/09/30 14:19:01	1.104
@@ -147,27 +147,56 @@
 	return ALLOC_INVALID;
 }
 
+#define BASE_UNKNOWN 0
+#define BASE_SHARED 1
+#define BASE_1024 7
+#define BASE_1000 13
+#define BASE_SPECIAL 19
+#define NUM_UNIT_PREFIXES 6
+#define NUM_SPECIAL 3
+
 /* Size supplied in sectors */
 static const char *_display_size(const struct cmd_context *cmd,
 				 uint64_t size, size_len_t sl)
 {
-	int s;
+	unsigned base = BASE_UNKNOWN;
+	unsigned s;
 	int suffix = 1, precision;
 	uint64_t byte = UINT64_C(0);
 	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
 	const char * const size_str[][3] = {
-		{" Exabyte", " EB", "E"},
-		{" Petabyte", " PB", "P"},
-		{" Terabyte", " TB", "T"},
-		{" Gigabyte", " GB", "G"},
-		{" Megabyte", " MB", "M"},
-		{" Kilobyte", " KB", "K"},
-		{"", "", ""},
-		{" Byte    ", " B ", "B"},
-		{" Units   ", " Un", "U"},
-		{" Sectors ", " Se", "S"},
-		{"         ", "   ", " "},
+		/* BASE_UNKNOWN */
+		{"         ", "   ", " "},	/* [0] */
+
+		/* BASE_SHARED - Used if cmd->si_unit_consistency = 0 */
+		{" Exabyte", " EB", "E"},	/* [1] */
+		{" Petabyte", " PB", "P"},	/* [2] */
+		{" Terabyte", " TB", "T"},	/* [3] */
+		{" Gigabyte", " GB", "G"},	/* [4] */
+		{" Megabyte", " MB", "M"},	/* [5] */
+		{" Kilobyte", " KB", "K"},	/* [6] */
+
+		/* BASE_1024 - Used if cmd->si_unit_consistency = 1 */
+		{" Exbibyte", " EiB", "e"},	/* [7] */
+		{" Pebibyte", " PiB", "p"},	/* [8] */
+		{" Tebibyte", " TiB", "t"},	/* [9] */
+		{" Gibibyte", " GiB", "g"},	/* [10] */
+		{" Mebibyte", " MiB", "m"},	/* [11] */
+		{" Kibibyte", " KiB", "k"},	/* [12] */
+
+		/* BASE_1000 - Used if cmd->si_unit_consistency = 1 */
+		{" Exabyte",  " EB", "E"},	/* [13] */
+		{" Petabyte", " PB", "P"},	/* [14] */
+		{" Terabyte", " TB", "T"},	/* [15] */
+		{" Gigabyte", " GB", "G"},	/* [16] */
+		{" Megabyte", " MB", "M"},	/* [17] */
+		{" Kilobyte", " kB", "K"},	/* [18] */
+
+		/* BASE_SPECIAL */
+		{" Byte    ", " B ", "B"},	/* [19] */
+		{" Units   ", " Un", "U"},	/* [20] */
+		{" Sectors ", " Se", "S"},	/* [21] */
 	};
 
 	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
@@ -177,30 +206,72 @@
 
 	suffix = cmd->current_settings.suffix;
 
-	for (s = 0; s < 10; s++)
-		if (toupper((int) cmd->current_settings.unit_type) ==
-		    *size_str[s][2])
-			break;
+	if (!cmd->si_unit_consistency) {
+		/* Case-independent match */
+		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (toupper((int) cmd->current_settings.unit_type) ==
+			    *size_str[BASE_SHARED + s][2]) {
+				base = BASE_SHARED;
+				break;
+			}
+	} else {
+		/* Case-dependent match for powers of 1000 */
+		for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (cmd->current_settings.unit_type ==
+			    *size_str[BASE_1000 + s][2]) {
+				base = BASE_1000;
+				break;
+			}
+
+		/* Case-dependent match for powers of 1024 */
+		if (base == BASE_UNKNOWN)
+			for (s = 0; s < NUM_UNIT_PREFIXES; s++)
+			if (cmd->current_settings.unit_type ==
+			    *size_str[BASE_1024 + s][2]) {
+				base = BASE_1024;
+				break;
+			}
+	}
+
+	if (base == BASE_UNKNOWN)
+		/* Check for special units - s, b or u */
+		for (s = 0; s < NUM_SPECIAL; s++)
+			if (toupper((int) cmd->current_settings.unit_type) ==
+			    *size_str[BASE_SPECIAL + s][2]) {
+				base = BASE_SPECIAL;
+				break;
+			}
 
 	if (size == UINT64_C(0)) {
-		sprintf(size_buf, "0%s", suffix ? size_str[s][sl] : "");
+		if (base == BASE_UNKNOWN)
+			s = 0;
+		sprintf(size_buf, "0%s", suffix ? size_str[base + s][sl] : "");
 		return size_buf;
 	}
 
 	size *= UINT64_C(512);
 
-	if (s < 10)
+	if (base != BASE_UNKNOWN)
 		byte = cmd->current_settings.unit_factor;
 	else {
-		suffix = 1;
-		if (cmd->current_settings.unit_type == 'H')
+		/* Human-readable style */
+		if (cmd->current_settings.unit_type == 'H') {
 			units = UINT64_C(1000);
-		else
+			base = BASE_1000;
+		} else {
 			units = UINT64_C(1024);
+			base = BASE_1024;
+		}
+
+		if (!cmd->si_unit_consistency)
+			base = BASE_SHARED;
+
 		byte = units * units * units * units * units * units;
-		s = 0;
-		while (size_str[s] && size < byte)
-			s++, byte /= units;
+
+		for (s = 0; s < NUM_UNIT_PREFIXES && size < byte; s++)
+			byte /= units;
+
+		suffix = 1;
 	}
 
 	/* FIXME Make precision configurable */
@@ -214,7 +285,7 @@
 	}
 
 	snprintf(size_buf, SIZE_BUF - 1, "%.*f%s", precision,
-		 (double) size / byte, suffix ? size_str[s][sl] : "");
+		 (double) size / byte, suffix ? size_str[base + s][sl] : "");
 
 	return size_buf;
 }


