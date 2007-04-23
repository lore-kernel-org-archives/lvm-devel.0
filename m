From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 23 Apr 2007 14:57:53 -0400
Subject: [PATCH REPOST2] convert _count_hyphens to generalised count_chars_null and export
In-Reply-To: <1177089463.11574.0.camel@linux-cxyg>
References: <1177079834.4206.5.camel@linux-cxyg>
	<1177081612.4206.11.camel@linux-cxyg>
	<1177089463.11574.0.camel@linux-cxyg>
Message-ID: <1177354673.4165.39.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add count_chars_null and count_chars_len functions, two
generic string utility functions.

Index: LVM2-working2/lib/misc/lvm-string.c
===================================================================
--- LVM2-working2.orig/lib/misc/lvm-string.c	2006-08-21 08:54:53.000000000 -0400
+++ LVM2-working2/lib/misc/lvm-string.c	2007-04-23 14:48:56.000000000 -0400
@@ -36,18 +36,38 @@ int emit_to_buffer(char **buffer, size_t
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
+void count_chars_null(const char *str, size_t *len, int *count,
+		      char c)
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
+unsigned count_chars_len(const char *str, size_t size, char c)
+{
+	int i;
+	unsigned count=0;
+
+	for (i=0; i<size; i++)
+		if (str[i] == c)
+			count++;
+	return count;
+
 }
 
 /*
@@ -73,11 +93,11 @@ char *build_dm_name(struct dm_pool *mem,
 	int hyphens = 1;
 	char *r, *out;
 
-	_count_hyphens(vgname, &len, &hyphens);
-	_count_hyphens(lvname, &len, &hyphens);
+	count_chars_null(vgname, &len, &hyphens, '-');
+	count_chars_null(lvname, &len, &hyphens, '-');
 
 	if (layer && *layer) {
-		_count_hyphens(layer, &len, &hyphens);
+		count_chars_null(layer, &len, &hyphens, '-');
 		hyphens++;
 	}
 
@@ -105,6 +125,12 @@ char *build_dm_name(struct dm_pool *mem,
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
Index: LVM2-working2/lib/misc/lvm-string.h
===================================================================
--- LVM2-working2.orig/lib/misc/lvm-string.h	2006-08-21 08:54:53.000000000 -0400
+++ LVM2-working2/lib/misc/lvm-string.h	2007-04-23 14:38:45.000000000 -0400
@@ -30,4 +30,8 @@ char *build_dm_name(struct dm_pool *mem,
 
 int validate_name(const char *n);
 
+void count_chars_null(const char *str, size_t *len, int *count,
+		      char c);
+unsigned count_chars_len(const char *str, size_t size, char c);
+
 #endif
Index: LVM2-working2/WHATS_NEW
===================================================================
--- LVM2-working2.orig/WHATS_NEW	2007-04-23 14:21:01.000000000 -0400
+++ LVM2-working2/WHATS_NEW	2007-04-23 14:41:22.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add count_chars_null and count_chars_len functions.
   Add scan_sector param to label_read and _find_labeller.
   Make clvmd cope with quorum devices on RHEL5
   Add dev_read_circular.



