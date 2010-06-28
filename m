From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:30:31 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20100628203031.13507.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:30:31

Modified files:
	lib/format_text: format-text.c 

Log message:
	Move dev_open / dev_close outside _vg_read_raw_area().
	
	This refactoring moves the device open/close up one level to the caller of
	_vg_read_raw_area().  Should be no functional change and facilitate future
	changes related to metadata balancing.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:29:57	1.124
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:30:30	1.125
@@ -483,9 +483,6 @@
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!dev_open(area->dev))
-		return_NULL;
-
 	if (!(mdah = _raw_read_mda_header(fid->fmt, area)))
 		goto_out;
 
@@ -520,9 +517,6 @@
 		vg->status |= PRECOMMITTED;
 
       out:
-	if (!dev_close(area->dev))
-		stack;
-
 	return vg;
 }
 
@@ -531,8 +525,17 @@
 					 struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct volume_group *vg;
+
+	if (!dev_open(mdac->area.dev))
+		return_NULL;
+
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0);
 
-	return _vg_read_raw_area(fid, vgname, &mdac->area, 0);
+	if (!dev_close(mdac->area.dev))
+		stack;
+
+	return vg;
 }
 
 static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
@@ -540,8 +543,17 @@
 						   struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct volume_group *vg;
 
-	return _vg_read_raw_area(fid, vgname, &mdac->area, 1);
+	if (!dev_open(mdac->area.dev))
+		return_NULL;
+
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1);
+
+	if (!dev_close(mdac->area.dev))
+		stack;
+
+	return vg;
 }
 
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
@@ -1192,9 +1204,17 @@
 		/* FIXME We're reading mdah twice here... */
 		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			if ((vg = _vg_read_raw_area(&fid, vgname,
-						    &rl->dev_area, 0)))
+			if (!dev_open(rl->dev_area.dev)) {
+				stack;
+				continue;
+			}
+
+			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
+			if (vg)
 				lvmcache_update_vg(vg, 0);
+
+			if (!dev_close(rl->dev_area.dev))
+				stack;
 		}
 	}
 


