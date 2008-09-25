From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 25 Sep 2008 15:57:03 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata ...
Message-ID: <20080925155703.5415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-25 15:57:03

Modified files:
	lib/metadata   : metadata-exported.h metadata.c metadata.h 

Log message:
	Try to fix possible infinite loop in dependency tree walking (by mornfall).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.182&r2=1.183

--- LVM2/lib/metadata/metadata-exported.h	2008/09/19 06:41:59	1.53
+++ LVM2/lib/metadata/metadata-exported.h	2008/09/25 15:57:02	1.54
@@ -75,8 +75,8 @@
 #define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
 						   written out in metadata*/
 
-//#define POSTORDER_FLAG	0x02000000U /* Not a real flag, reserved for
-//					       temporary use inside vg_read. */
+//#define POSTORDER_FLAG	0x02000000U /* Not real flags, reserved for
+//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read. */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
--- LVM2/lib/metadata/metadata.c	2008/09/19 06:41:59	1.191
+++ LVM2/lib/metadata/metadata.c	2008/09/25 15:57:02	1.192
@@ -1199,7 +1199,11 @@
 static int _lv_postorder_level(struct logical_volume *lv, void *data)
 {
 	struct _lv_postorder_baton *baton = data;
+	if (lv->status & POSTORDER_OPEN_FLAG)
+		return 1; // a data structure loop has closed...
+	lv->status |= POSTORDER_OPEN_FLAG;
 	int r =_lv_postorder_visit(lv, baton->fn, baton->data);
+	lv->status &= ~POSTORDER_OPEN_FLAG;
 	lv->status |= POSTORDER_FLAG;
 	return r;
 };
--- LVM2/lib/metadata/metadata.h	2008/09/19 06:41:59	1.182
+++ LVM2/lib/metadata/metadata.h	2008/09/25 15:57:02	1.183
@@ -67,8 +67,8 @@
 //#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
 //						   written out in metadata*/
 
-#define POSTORDER_FLAG		0x02000000U /* Not a real flag, reserved for
-					       temporary use inside vg_read. */
+#define POSTORDER_FLAG		0x02000000U /* Not real flags, reserved for  */
+#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read. */
 
 //#define LVM_READ              	0x00000100U	/* LV VG */
 //#define LVM_WRITE             	0x00000200U	/* LV VG */


