From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Sep 2010 12:02:37 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20100923120237.4064.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-23 12:02:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/misc       : lvm-string.c lvm-string.h 
	tools          : pvchange.c pvck.c pvcreate.c pvmove.c 
	                 pvremove.c toollib.c vgsplit.c 

Log message:
	Add escape sequence for ':' and '@' found in device names used as PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1734&r2=1.1735
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.396&r2=1.397
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2010/09/22 22:31:45	1.1734
+++ LVM2/WHATS_NEW	2010/09/23 12:02:33	1.1735
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 =====================================
+  Add escape sequence for ':' and '@' found in device names used as PVs.
   Replace alloca with dm_malloc in _aligned_io.
   Fix partial mode operations for lvm1 metadata format.
   Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
--- LVM2/lib/metadata/metadata.c	2010/08/20 20:59:07	1.396
+++ LVM2/lib/metadata/metadata.c	2010/09/23 12:02:34	1.397
@@ -677,6 +677,7 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
+		unescape_colons_and_at_signs(pv_names[i], NULL, NULL);
 		if (!vg_extend_single_pv(vg, pv_names[i], pp))
 			goto bad;
 	}
--- LVM2/lib/misc/lvm-string.c	2010/09/20 14:25:27	1.21
+++ LVM2/lib/misc/lvm-string.c	2010/09/23 12:02:34	1.22
@@ -109,19 +109,31 @@
 }
 
 /*
- * Unquote orig_char in string.
- * Also unquote quote_char.
- */
-static void _unquote_characters(char *src, const int orig_char,
-				const int quote_char)
+ * Unquote each character given in orig_char array and unquote quote_char
+ * as well. The array ends up with '\0' character. Also save the first
+ * occurence of each character from orig_char that was found unquoted in
+ * arr_substr_first_unquoted array. This way we can process several
+ * characters in one go.
+ */
+static void _unquote_characters(char *src, const int orig_chars[],
+				const int quote_char,
+				char *arr_substr_first_unquoted[])
 {
 	char *out = src;
+	int c;
+	int i;
 
 	while (*src) {
-		if (*src == quote_char &&
-		    (*(src + 1) == orig_char || *(src + 1) == quote_char))
-			src++;
-
+		for (i = 0; (c = orig_chars[i]); i++) {
+			if (*src == quote_char &&
+			    (*(src + 1) == c || *(src + 1) == quote_char)) {
+				src++;
+				break;
+			}
+			else if (arr_substr_first_unquoted && (*src == c) &&
+				 !arr_substr_first_unquoted[i])
+				arr_substr_first_unquoted[i] = out;
+		}
 		*out++ = *src++;
 	}
 
@@ -217,7 +229,31 @@
  */
 void unescape_double_quotes(char *src)
 {
-	_unquote_characters(src, '\"', '\\');
+	const int orig_chars[] = {'\"', '\0'};
+
+	_unquote_characters(src, orig_chars, '\\', NULL);
+}
+
+/*
+ * Unescape colons and "at" signs in situ and save the substrings
+ * starting at the position of the first unescaped colon and the
+ * first unescaped "at" sign. This is normally used to unescape
+ * device names used as PVs.
+ */
+void unescape_colons_and_at_signs(char *src,
+				  char **substr_first_unquoted_colon,
+				  char **substr_first_unquoted_at_sign)
+{
+	const int orig_chars[] = {':', '@', '\0'};
+	char *arr_substr_first_unquoted[] = {NULL, NULL, NULL};
+
+	_unquote_characters(src, orig_chars, '\\', arr_substr_first_unquoted);
+
+	if (substr_first_unquoted_colon)
+		*substr_first_unquoted_colon = arr_substr_first_unquoted[0];
+
+	if (substr_first_unquoted_at_sign)
+		*substr_first_unquoted_at_sign = arr_substr_first_unquoted[1];
 }
 
 /*
--- LVM2/lib/misc/lvm-string.h	2010/04/23 14:16:33	1.20
+++ LVM2/lib/misc/lvm-string.h	2010/09/23 12:02:34	1.21
@@ -60,4 +60,13 @@
  */
 void unescape_double_quotes(char *src);
 
+/*
+ * Unescape colons and at signs in situ and save the substring starting
+ *@the position of the first unescaped colon and the first unescaped
+ * "at" sign.
+ */
+void unescape_colons_and_at_signs(char *src,
+				  char **substr_first_unquoted_colon,
+				  char **substr_first_unquoted_at_sign);
+
 #endif
--- LVM2/tools/pvchange.c	2010/07/09 15:34:48	1.83
+++ LVM2/tools/pvchange.c	2010/09/23 12:02:34	1.84
@@ -195,7 +195,8 @@
 	int total = 0;
 
 	struct volume_group *vg;
-	const char *pv_name, *vg_name;
+	const char *vg_name;
+	char *pv_name;
 
 	struct pv_list *pvl;
 	struct dm_list *vgnames;
@@ -223,6 +224,7 @@
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
+			unescape_colons_and_at_signs(pv_name, NULL, NULL);
 			vg_name = find_vgname_from_pvname(cmd, pv_name);
 			if (!vg_name) {
 				log_error("Failed to read physical volume %s",
--- LVM2/tools/pvck.c	2007/08/22 14:38:18	1.4
+++ LVM2/tools/pvck.c	2010/09/23 12:02:34	1.5
@@ -31,6 +31,7 @@
 		/* FIXME: warning and/or check if in use? */
 		log_verbose("Scanning %s", argv[i]);
 
+		unescape_colons_and_at_signs(argv[i], NULL, NULL);
 		pv_analyze(cmd, argv[i],
 			   arg_uint64_value(cmd, labelsector_ARG,
 					   UINT64_C(0)));
--- LVM2/tools/pvcreate.c	2010/08/12 04:09:00	1.91
+++ LVM2/tools/pvcreate.c	2010/09/23 12:02:34	1.92
@@ -109,6 +109,8 @@
 			return ECMD_FAILED;
 		}
 
+		unescape_colons_and_at_signs(argv[i], NULL, NULL);
+
 		if (!pvcreate_single(cmd, argv[i], &pp)) {
 			stack;
 			ret = ECMD_FAILED;
--- LVM2/tools/pvmove.c	2010/08/23 11:34:10	1.79
+++ LVM2/tools/pvmove.c	2010/09/23 12:02:34	1.80
@@ -644,17 +644,16 @@
 	}
 
 	if (argc) {
-		pv_name = argv[0];
+		if (!(pv_name = dm_pool_strdup(cmd->mem, argv[0]))) {
+			log_error("Failed to clone PV name");
+			return ECMD_FAILED;
+		}
+
+		unescape_colons_and_at_signs(pv_name, &colon, NULL);
 
 		/* Drop any PE lists from PV name */
-		if ((colon = strchr(pv_name, ':'))) {
-			if (!(pv_name = dm_pool_strndup(cmd->mem, pv_name,
-						     (unsigned) (colon -
-								 pv_name)))) {
-				log_error("Failed to clone PV name");
-				return ECMD_FAILED;
-			}
-		}
+		if (colon)
+			*colon = '\0';
 
 		if (!arg_count(cmd, abort_ARG) &&
 		    (ret = _set_up_pvmove(cmd, pv_name, argc, argv)) !=
--- LVM2/tools/pvremove.c	2010/08/19 23:04:37	1.29
+++ LVM2/tools/pvremove.c	2010/09/23 12:02:34	1.30
@@ -144,6 +144,7 @@
 	}
 
 	for (i = 0; i < argc; i++) {
+		unescape_colons_and_at_signs(argv[i], NULL, NULL);
 		r = pvremove_single(cmd, argv[i], NULL);
 		if (r > ret)
 			ret = r;
--- LVM2/tools/toollib.c	2010/08/19 23:04:37	1.208
+++ LVM2/tools/toollib.c	2010/09/23 12:02:34	1.209
@@ -680,7 +680,7 @@
 	struct dm_list *pvslist, *vgnames;
 	struct dm_list tags;
 	struct str_list *sll;
-	char *tagname;
+	char *at_sign, *tagname;
 	int scanned = 0;
 	struct dm_list mdas;
 
@@ -694,8 +694,9 @@
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
-			if (*argv[opt] == '@') {
-				tagname = argv[opt] + 1;
+			unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
+			if (at_sign && (at_sign == argv[opt])) {
+				tagname = at_sign + 1;
 
 				if (!validate_name(tagname)) {
 					log_error("Skipping invalid tag %s",
@@ -1093,8 +1094,8 @@
 	struct dm_list *r;
 	struct pv_list *pvl;
 	struct dm_list tags, arg_pvnames;
-	const char *pvname = NULL;
-	char *colon, *tagname;
+	char *pvname = NULL;
+	char *colon, *at_sign, *tagname;
 	int i;
 
 	/* Build up list of PVs */
@@ -1108,8 +1109,10 @@
 	dm_list_init(&arg_pvnames);
 
 	for (i = 0; i < argc; i++) {
-		if (*argv[i] == '@') {
-			tagname = argv[i] + 1;
+		unescape_colons_and_at_signs(argv[i], &colon, &at_sign);
+
+		if (at_sign && (at_sign == argv[i])) {
+			tagname = at_sign + 1;
 			if (!validate_name(tagname)) {
 				log_error("Skipping invalid tag %s", tagname);
 				continue;
@@ -1128,13 +1131,10 @@
 
 		pvname = argv[i];
 
-		if ((colon = strchr(pvname, ':'))) {
-			if (!(pvname = dm_pool_strndup(mem, pvname,
-						    (unsigned) (colon -
-								pvname)))) {
-				log_error("Failed to clone PV name");
-				return NULL;
-			}
+		if (colon && !(pvname = dm_pool_strndup(mem, pvname,
+					(unsigned) (colon - pvname)))) {
+			log_error("Failed to clone PV name");
+			return NULL;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pvname))) {
--- LVM2/tools/vgsplit.c	2010/06/30 20:03:53	1.101
+++ LVM2/tools/vgsplit.c	2010/09/23 12:02:34	1.102
@@ -394,6 +394,7 @@
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
+		unescape_colons_and_at_signs(argv[opt], NULL, NULL);
 		if (!move_pv(vg_from, vg_to, argv[opt]))
 			goto_bad;
 	}


