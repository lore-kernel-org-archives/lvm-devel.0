From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Sep 2010 01:29:08 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c
Message-ID: <20100928012908.16589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-28 01:29:07

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c 

Log message:
	Speed up unquoting of quoted double quotes and backslashes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1737&r2=1.1738
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/09/27 19:09:34	1.1737
+++ LVM2/WHATS_NEW	2010/09/28 01:29:06	1.1738
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Speed up unquoting of quoted double quotes and backslashes.
   Speed up CRC32 calculations by using a larger lookup table.
 
 Version 2.02.74 - 24th September 2010
--- LVM2/lib/misc/lvm-string.c	2010/09/23 12:02:34	1.22
+++ LVM2/lib/misc/lvm-string.c	2010/09/28 01:29:07	1.23
@@ -108,33 +108,64 @@
 	}
 }
 
+static void _unquote_one_character(char *src, const char orig_char,
+				   const char quote_char)
+{
+	char *out;
+	char s, n;
+
+	/* Optimise for the common case where no changes are needed. */
+	while ((s = *src++)) {
+		if (s == quote_char &&
+		    ((n = *src) == orig_char || n == quote_char)) {
+			out = src++;
+			*(out - 1) = n;
+
+			while ((s = *src++)) {
+				if (s == quote_char &&
+				    ((n = *src) == orig_char || n == quote_char)) {
+					s = n;
+					src++;
+				}
+				*out = s;
+				out++;
+			}
+
+			*out = '\0';
+			return;
+		}
+	}
+}
+
 /*
  * Unquote each character given in orig_char array and unquote quote_char
- * as well. The array ends up with '\0' character. Also save the first
- * occurence of each character from orig_char that was found unquoted in
- * arr_substr_first_unquoted array. This way we can process several
- * characters in one go.
+ * as well. Also save the first occurrence of each character from orig_char
+ * that was found unquoted in arr_substr_first_unquoted array. This way we can
+ * process several characters in one go.
  */
-static void _unquote_characters(char *src, const int orig_chars[],
-				const int quote_char,
+static void _unquote_characters(char *src, const char *orig_chars,
+				const int num_orig_chars, 
+				const char quote_char,
 				char *arr_substr_first_unquoted[])
 {
 	char *out = src;
-	int c;
-	int i;
+	char c, s, n;
+	unsigned i;
 
-	while (*src) {
-		for (i = 0; (c = orig_chars[i]); i++) {
-			if (*src == quote_char &&
-			    (*(src + 1) == c || *(src + 1) == quote_char)) {
+	while ((s = *src++)) {
+		for (i = 0; i < num_orig_chars; i++) {
+			c = orig_chars[i];
+			if (s == quote_char &&
+			    ((n = *src) == c || n == quote_char)) {
+				s = n;
 				src++;
 				break;
 			}
-			else if (arr_substr_first_unquoted && (*src == c) &&
-				 !arr_substr_first_unquoted[i])
+			if (arr_substr_first_unquoted && (s == c) &&
+			    !arr_substr_first_unquoted[i])
 				arr_substr_first_unquoted[i] = out;
-		}
-		*out++ = *src++;
+		};
+		*out++ = s;
 	}
 
 	*out = '\0';
@@ -229,9 +260,7 @@
  */
 void unescape_double_quotes(char *src)
 {
-	const int orig_chars[] = {'\"', '\0'};
-
-	_unquote_characters(src, orig_chars, '\\', NULL);
+	_unquote_one_character(src, '\"', '\\');
 }
 
 /*
@@ -244,10 +273,10 @@
 				  char **substr_first_unquoted_colon,
 				  char **substr_first_unquoted_at_sign)
 {
-	const int orig_chars[] = {':', '@', '\0'};
+	const char *orig_chars = ":@";
 	char *arr_substr_first_unquoted[] = {NULL, NULL, NULL};
 
-	_unquote_characters(src, orig_chars, '\\', arr_substr_first_unquoted);
+	_unquote_characters(src, orig_chars, 2, '\\', arr_substr_first_unquoted);
 
 	if (substr_first_unquoted_colon)
 		*substr_first_unquoted_colon = arr_substr_first_unquoted[0];


