From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Apr 2007 10:37:13 -0400
Subject: [PATCH] convert _count_hyphens to generalised _count_chars and export
Message-ID: <1177079834.4206.5.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should not change functional behavior and be simple to review.
Adds newly created function to lvm-string.h exports.

Index: LVM2/lib/misc/lvm-string.c
===================================================================
--- LVM2.orig/lib/misc/lvm-string.c	2006-08-21 08:54:53.000000000 -0400
+++ LVM2/lib/misc/lvm-string.c	2007-04-20 10:28:03.000000000 -0400
@@ -36,21 +36,6 @@ int emit_to_buffer(char **buffer, size_t
 }
 
 /*
- * Device layer names are all of the form <vg>-<lv>-<layer>, any
- * other hyphens that appear in these names are quoted with yet
- * another hyphen.  The top layer of any device has no layer
- * name.  eg, vg0-lvol0.
- */
-static void _count_hyphens(const char *str, size_t *len, int *hyphens)
-{
-	const char *ptr;
-
-	for (ptr = str; *ptr; ptr++, (*len)++)
-		if (*ptr == '-')
-			(*hyphens)++;
-}
-
-/*
  * Copies a string, quoting hyphens with hyphens.
  */
 static void _quote_hyphens(char **out, const char *src)
@@ -63,6 +48,17 @@ static void _quote_hyphens(char **out, c
 	}
 }
 
+
+void _count_chars(const char *str, size_t *len, int *count,
+		  char c)
+{
+	const char *ptr;
+
+	for (ptr = str; *ptr; ptr++, (*len)++)
+		if (*ptr == c)
+			(*count)++;
+}
+
 /*
  * <vg>-<lv>-<layer> or if !layer just <vg>-<lv>.
  */
@@ -73,11 +69,11 @@ char *build_dm_name(struct dm_pool *mem,
 	int hyphens = 1;
 	char *r, *out;
 
-	_count_hyphens(vgname, &len, &hyphens);
-	_count_hyphens(lvname, &len, &hyphens);
+	_count_chars(vgname, &len, &hyphens, '-');
+	_count_chars(lvname, &len, &hyphens, '-');
 
 	if (layer && *layer) {
-		_count_hyphens(layer, &len, &hyphens);
+		_count_chars(layer, &len, &hyphens, '-');
 		hyphens++;
 	}
 
@@ -105,6 +101,12 @@ char *build_dm_name(struct dm_pool *mem,
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
Index: LVM2/lib/misc/lvm-string.h
===================================================================
--- LVM2.orig/lib/misc/lvm-string.h	2006-08-21 08:54:53.000000000 -0400
+++ LVM2/lib/misc/lvm-string.h	2007-04-20 10:22:23.000000000 -0400
@@ -30,4 +30,7 @@ char *build_dm_name(struct dm_pool *mem,
 
 int validate_name(const char *n);
 
+void _count_chars(const char *str, size_t *len, int *count,
+		  char c);
+
 #endif
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-04-20 10:16:21.000000000 -0400
+++ LVM2/WHATS_NEW	2007-04-20 10:23:37.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Convert _count_hyphens to generalized _count_chars.
   Add dev_read_circular.
   Add pvck command stub.
   Update lists of attribute characters in man pages.



