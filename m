From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Mar 2008 16:03:23 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/filte ...
Message-ID: <20080312160323.19897.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-12 16:03:22

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/filters    : filter-persistent.c 
	lib/format_text: export.c 
	lib/misc       : lvm-string.c lvm-string.h 

Log message:
	Escape double quotes and backslashes in external metadata and config data.
	Add functions for escaping double quotes in strings.
	Rename count_chars_len to count_chars.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.801&r2=1.802
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2008/03/10 18:51:27	1.801
+++ LVM2/WHATS_NEW	2008/03/12 16:03:21	1.802
@@ -1,5 +1,8 @@
 Version 2.02.34 -
 ===================================
+  Escape double quotes and backslashes in external metadata and config data.
+  Add functions for escaping double quotes in strings.
+  Rename count_chars_len to count_chars.
   Use return_0 in a couple more places.
   Correct a function name typo in _line_append error message.
   Include limits.h in clvmd so it compiles with newer headers.
--- LVM2/lib/config/config.c	2008/03/10 18:51:27	1.67
+++ LVM2/lib/config/config.c	2008/03/12 16:03:21	1.68
@@ -34,7 +34,8 @@
 enum {
 	TOK_INT,
 	TOK_FLOAT,
-	TOK_STRING,
+	TOK_STRING,		/* Single quotes */
+	TOK_STRING_ESCAPED,	/* Double quotes */
 	TOK_EQ,
 	TOK_SECTION_B,
 	TOK_SECTION_E,
@@ -401,9 +402,16 @@
 
 static int _write_value(struct output_line *outline, struct config_value *v)
 {
+	char *buf;
+
 	switch (v->type) {
 	case CFG_STRING:
-		line_append("\"%s\"", v->v.str);
+		if (!(buf = alloca(escaped_len(v->v.str)))) {
+			log_error("temporary stack allocation for a config "
+				  "string failed");
+			return 0;
+		}
+		line_append("\"%s\"", escape_double_quotes(buf, v->v.str));
 		break;
 
 	case CFG_FLOAT:
@@ -644,6 +652,17 @@
 		match(TOK_STRING);
 		break;
 
+	case TOK_STRING_ESCAPED:
+		v->type = CFG_STRING;
+
+		p->tb++, p->te--;	/* strip "'s */
+		if (!(v->v.str = _dup_tok(p)))
+			return_0;
+		unescape_double_quotes(v->v.str);
+		p->te++;
+		match(TOK_STRING_ESCAPED);
+		break;
+
 	default:
 		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
 			  p->tb - p->fb + 1, p->line);
@@ -714,7 +733,7 @@
 		break;
 
 	case '"':
-		p->t = TOK_STRING;
+		p->t = TOK_STRING_ESCAPED;
 		p->te++;
 		while ((p->te != p->fe) && (*p->te) && (*p->te != '"')) {
 			if ((*p->te == '\\') && (p->te + 1 != p->fe) &&
@@ -1232,7 +1251,7 @@
 
 	c = _token_type_to_char(type);
 
-	return count_chars_len(str, len, c);
+	return count_chars(str, len, c);
 }
 
 /*
--- LVM2/lib/filters/filter-persistent.c	2008/01/30 13:59:58	1.35
+++ LVM2/lib/filters/filter-persistent.c	2008/03/12 16:03:21	1.36
@@ -18,6 +18,7 @@
 #include "dev-cache.h"
 #include "filter-persistent.h"
 #include "lvm-file.h"
+#include "lvm-string.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -142,6 +143,7 @@
 {
 	void *d;
 	int first = 1;
+	char *buf, *str;
 	struct dm_hash_node *n;
 
 	for (n = dm_hash_get_first(pf->devices); n;
@@ -158,7 +160,13 @@
 			first = 0;
 		}
 
-		fprintf(fp, "\t\t\"%s\"", dm_hash_get_key(pf->devices, n));
+		str = dm_hash_get_key(pf->devices, n);
+		if (!(buf = alloca(escaped_len(str)))) {
+			log_error("persistent filter device path stack "
+				  "allocation failed");
+			return;
+		}
+		fprintf(fp, "\t\t\"%s\"", escape_double_quotes(buf, str));
 	}
 
 	if (!first)
--- LVM2/lib/format_text/export.c	2008/01/30 13:59:59	1.61
+++ LVM2/lib/format_text/export.c	2008/03/12 16:03:22	1.62
@@ -296,6 +296,7 @@
 static int _print_header(struct formatter *f,
 			 const char *desc)
 {
+	char *buf;
 	time_t t;
 
 	t = time(NULL);
@@ -305,7 +306,12 @@
 	outf(f, FORMAT_VERSION_FIELD " = %d", FORMAT_VERSION_VALUE);
 	outnl(f);
 
-	outf(f, "description = \"%s\"", desc);
+	if (!(buf = alloca(escaped_len(desc)))) {
+		log_error("temporary stack allocation for description"
+			  "string failed");
+		return 0;
+	}
+	outf(f, "description = \"%s\"", escape_double_quotes(buf, desc));
 	outnl(f);
 	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
 	     _utsname.sysname, _utsname.nodename, _utsname.release,
@@ -370,6 +376,7 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	char buffer[4096];
+	char *buf;
 	const char *name;
 
 	outf(f, "physical_volumes {");
@@ -389,7 +396,15 @@
 			return_0;
 
 		outf(f, "id = \"%s\"", buffer);
-		if (!out_hint(f, "device = \"%s\"", pv_dev_name(pv)))
+
+		if (!(buf = alloca(escaped_len(pv_dev_name(pv))))) {
+			log_error("temporary stack allocation for device name"
+				  "string failed");
+			return 0;
+		}
+
+		if (!out_hint(f, "device = \"%s\"",
+			      escape_double_quotes(buf, pv_dev_name(pv))))
 			return_0;
 		outnl(f);
 
--- LVM2/lib/misc/lvm-string.c	2008/01/30 14:00:00	1.16
+++ LVM2/lib/misc/lvm-string.c	2008/03/12 16:03:22	1.17
@@ -39,16 +39,16 @@
  * Count occurences of 'c' in 'str' until we reach a null char.
  *
  * Returns:
- *  len - incremented for each char we encounter, whether 'c' or not.
- *  count - number of occurrences of 'c'
+ *  len - incremented for each char we encounter.
+ *  count - number of occurrences of 'c' and 'c2'.
  */
-void count_chars(const char *str, size_t *len, int *count,
-		 const int c)
+static void _count_chars(const char *str, size_t *len, int *count,
+			 const int c1, const int c2)
 {
 	const char *ptr;
 
 	for (ptr = str; *ptr; ptr++, (*len)++)
-		if (*ptr == c)
+		if (*ptr == c1 || *ptr == c2)
 			(*count)++;
 }
 
@@ -58,7 +58,7 @@
  * Returns:
  *   Number of occurrences of 'c'
  */
-unsigned count_chars_len(const char *str, size_t len, const int c)
+unsigned count_chars(const char *str, size_t len, const int c)
 {
 	size_t i;
 	unsigned count = 0;
@@ -71,19 +71,64 @@
 }
 
 /*
- * Copies a string, quoting hyphens with hyphens.
+ * Length of string after escaping double quotes and backslashes.
  */
-static void _quote_hyphens(char **out, const char *src)
+size_t escaped_len(const char *str)
+{
+	size_t len = 1;
+	int count = 0;
+
+	_count_chars(str, &len, &count, '\"', '\\');
+
+	return count + len;
+}
+
+/*
+ * Copies a string, quoting orig_char with quote_char.
+ * Optionally also quote quote_char.
+ */
+static void _quote_characters(char **out, const char *src,
+			      const int orig_char, const int quote_char,
+			      int quote_quote_char)
 {
 	while (*src) {
-		if (*src == '-')
-			*(*out)++ = '-';
+		if (*src == orig_char ||
+		    (*src == quote_char && quote_quote_char))
+			*(*out)++ = quote_char;
 
 		*(*out)++ = *src++;
 	}
 }
 
 /*
+ * Unquote orig_char in string.
+ * Also unquote quote_char.
+ */
+static void _unquote_characters(char *src, const int orig_char,
+				const int quote_char)
+{
+	char *out = src;
+
+	while (*src) {
+		if (*src == quote_char &&
+		    (*(src + 1) == orig_char || *(src + 1) == quote_char))
+			src++;
+
+		*out++ = *src++;
+	}
+
+	*out = '\0';
+}
+
+/*
+ * Copies a string, quoting hyphens with hyphens.
+ */
+static void _quote_hyphens(char **out, const char *src)
+{
+	return _quote_characters(out, src, '-', '-', 0);
+}
+
+/*
  * <vg>-<lv>-<layer> or if !layer just <vg>-<lv>.
  */
 char *build_dm_name(struct dm_pool *mem, const char *vgname,
@@ -93,11 +138,11 @@
 	int hyphens = 1;
 	char *r, *out;
 
-	count_chars(vgname, &len, &hyphens, '-');
-	count_chars(lvname, &len, &hyphens, '-');
+	_count_chars(vgname, &len, &hyphens, '-', 0);
+	_count_chars(lvname, &len, &hyphens, '-', 0);
 
 	if (layer && *layer) {
-		count_chars(layer, &len, &hyphens, '-');
+		_count_chars(layer, &len, &hyphens, '-', 0);
 		hyphens++;
 	}
 
@@ -126,6 +171,27 @@
 }
 
 /*
+ * Copies a string, quoting double quotes with backslashes.
+ */
+char *escape_double_quotes(char *out, const char *src)
+{
+	char *buf = out;
+
+	_quote_characters(&buf, src, '\"', '\\', 1);
+	*buf = '\0';
+
+	return out;
+}
+
+/*
+ * Undo quoting in situ.
+ */
+void unescape_double_quotes(char *src)
+{
+	_unquote_characters(src, '\"', '\\');
+}
+
+/*
  * Device layer names are all of the form <vg>-<lv>-<layer>, any
  * other hyphens that appear in these names are quoted with yet
  * another hyphen.  The top layer of any device has no layer
--- LVM2/lib/misc/lvm-string.h	2007/08/22 14:38:17	1.17
+++ LVM2/lib/misc/lvm-string.h	2008/03/12 16:03:22	1.18
@@ -31,8 +31,27 @@
 
 int validate_name(const char *n);
 
-void count_chars(const char *str, size_t *len, int *count,
-		 const int c);
-unsigned count_chars_len(const char *str, size_t len, const int c);
+/*
+ * Returns number of occurrences of c in first len characters of str.
+ */
+unsigned count_chars(const char *str, size_t len, const int c);
+
+/*
+ * Returns what length of escaped string would be including terminating NUL.
+ */
+size_t escaped_len(const char *str);
+
+/*
+ * Copies a string from src to out. 
+ * Double quotation marks and backslashes are quoted with a backslash.
+ * Caller must ensure *out has enough space - see escaped_len().
+ * Returns *out.
+ */
+char *escape_double_quotes(char *out, const char *src);
+
+/*
+ * Removes quoting of double quotation marks and backslashes in situ.
+ */
+void unescape_double_quotes(char *src);
 
 #endif


