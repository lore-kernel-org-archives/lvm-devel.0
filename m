From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Apr 2007 18:24:19 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c lib/mis ...
Message-ID: <20070425182419.23092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-25 19:24:19

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c lvm-string.h 

Log message:
	Add count_chars and count_chars_len functions, two
	generic string utility functions.
	
	--

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.601&r2=1.602
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2007/04/25 14:49:27	1.601
+++ LVM2/WHATS_NEW	2007/04/25 18:24:19	1.602
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add count_chars and count_chars_len functions
   Add /sys/block listings to lvm_dump.sh
   Make lvm_dump.sh list /dev recursively
   Fix thread race in clvmd.
--- LVM2/lib/misc/lvm-string.c	2006/08/21 12:54:53	1.12
+++ LVM2/lib/misc/lvm-string.c	2007/04/25 18:24:19	1.13
@@ -36,18 +36,38 @@
 }
 
 /*
- * Device layer names are all of the form <vg>-<lv>-<layer>, any
- * other hyphens that appear in these names are quoted with yet
- * another hyphen.  The top layer of any device has no layer
- * name.  eg, vg0-lvol0.
+ * Count occurences of 'c' in 'str' until we reach a null char.
+ *
+ * Returns:
+ *  len - incremented for each char we encounter, whether 'c' or not.
+ *  count - number of occurences of 'c'
  */
-static void _count_hyphens(const char *str, size_t *len, int *hyphens)
+void count_chars(const char *str, size_t *len, int *count,
+		 const char c)
 {
 	const char *ptr;
 
 	for (ptr = str; *ptr; ptr++, (*len)++)
-		if (*ptr == '-')
-			(*hyphens)++;
+		if (*ptr == c)
+			(*count)++;
+}
+
+/*
+ * Count occurences of 'c' in 'str' of length 'size'.
+ *
+ * Returns:
+ *   # of occurences of 'c'
+ */
+unsigned count_chars_len(const char *str, size_t size, const char c)
+{
+	int i;
+	unsigned count=0;
+
+	for (i=0; i < size; i++)
+		if (str[i] == c)
+			count++;
+	return count;
+
 }
 
 /*
@@ -73,11 +93,11 @@
 	int hyphens = 1;
 	char *r, *out;
 
-	_count_hyphens(vgname, &len, &hyphens);
-	_count_hyphens(lvname, &len, &hyphens);
+	count_chars(vgname, &len, &hyphens, '-');
+	count_chars(lvname, &len, &hyphens, '-');
 
 	if (layer && *layer) {
-		_count_hyphens(layer, &len, &hyphens);
+		count_chars(layer, &len, &hyphens, '-');
 		hyphens++;
 	}
 
@@ -105,6 +125,12 @@
 	return r;
 }
 
+/*
+ * Device layer names are all of the form <vg>-<lv>-<layer>, any
+ * other hyphens that appear in these names are quoted with yet
+ * another hyphen.  The top layer of any device has no layer
+ * name.  eg, vg0-lvol0.
+ */
 int validate_name(const char *n)
 {
 	register char c;
--- LVM2/lib/misc/lvm-string.h	2006/08/21 12:54:53	1.13
+++ LVM2/lib/misc/lvm-string.h	2007/04/25 18:24:19	1.14
@@ -30,4 +30,8 @@
 
 int validate_name(const char *n);
 
+void count_chars(const char *str, size_t *len, int *count,
+		 char c);
+unsigned count_chars_len(const char *str, size_t size, char c);
+
 #endif


