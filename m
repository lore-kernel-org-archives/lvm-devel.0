From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Feb 2011 19:27:06 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20110214192706.27432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-02-14 19:27:05

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix an lv_postorder bug where it failed to clear temporary flags, making it
	impossible to use twice with the same LV(s). Discovered by Milan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.420&r2=1.421

--- LVM2/lib/metadata/metadata.c	2011/01/12 20:42:51	1.420
+++ LVM2/lib/metadata/metadata.c	2011/02/14 19:27:05	1.421
@@ -1969,18 +1969,6 @@
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data);
 
-static int _lv_postorder_level(struct logical_volume *lv, void *data)
-{
-	struct _lv_postorder_baton *baton = data;
-	if (lv->status & POSTORDER_OPEN_FLAG)
-		return 1; // a data structure loop has closed...
-	lv->status |= POSTORDER_OPEN_FLAG;
-	int r =_lv_postorder_visit(lv, baton->fn, baton->data);
-	lv->status &= ~POSTORDER_OPEN_FLAG;
-	lv->status |= POSTORDER_FLAG;
-	return r;
-};
-
 static int _lv_each_dependency(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data)
@@ -2022,6 +2010,12 @@
 	return 1;
 }
 
+static int _lv_postorder_level(struct logical_volume *lv, void *data)
+{
+	struct _lv_postorder_baton *baton = data;
+	return _lv_postorder_visit(lv, baton->fn, baton->data);
+};
+
 static int _lv_postorder_visit(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data)
@@ -2031,13 +2025,20 @@
 
 	if (lv->status & POSTORDER_FLAG)
 		return 1;
+	if (lv->status & POSTORDER_OPEN_FLAG)
+		return 1; // a data structure loop has closed...
+	lv->status |= POSTORDER_OPEN_FLAG;
 
 	baton.fn = fn;
 	baton.data = data;
 	r = _lv_each_dependency(lv, _lv_postorder_level, &baton);
+
 	if (r)
 		r = fn(lv, data);
 
+	lv->status &= ~POSTORDER_OPEN_FLAG;
+	lv->status |= POSTORDER_FLAG;
+
 	return r;
 }
 


