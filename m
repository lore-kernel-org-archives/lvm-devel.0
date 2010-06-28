From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:30:46 -0000
Subject: LVM2/lib/format_text format-text.c text_label.c
Message-ID: <20100628203046.13658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:30:46

Modified files:
	lib/format_text: format-text.c text_label.c 

Log message:
	Move dev_open/dev_close outside vgname_from_mda().
	
	Refactor vgname_from_mda() so caller must open/close the device.
	Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:30:30	1.125
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:30:46	1.126
@@ -1099,9 +1099,6 @@
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-	if (!dev_open(dev_area->dev))
-		return_NULL;
-
 	if (!(mdah = _raw_read_mda_header(fmt, dev_area)))
 		goto_out;
 
@@ -1179,9 +1176,6 @@
 	}
 
       out:
-	if (!dev_close(dev_area->dev))
-		stack;
-
 	return vgname;
 }
 
@@ -1202,20 +1196,20 @@
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
+		if (!dev_open(rl->dev_area.dev)) {
+			stack;
+			continue;
+		}
+
 		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			if (!dev_open(rl->dev_area.dev)) {
-				stack;
-				continue;
-			}
-
 			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 
-			if (!dev_close(rl->dev_area.dev))
-				stack;
 		}
+		if (!dev_close(rl->dev_area.dev))
+			stack;
 	}
 
 	return 1;
--- LVM2/lib/format_text/text_label.c	2010/06/28 20:30:14	1.28
+++ LVM2/lib/format_text/text_label.c	2010/06/28 20:30:46	1.29
@@ -299,6 +299,10 @@
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
+		if (!dev_open(mdac->area.dev)) {
+			stack;
+			continue;
+		}
 		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
@@ -306,6 +310,8 @@
 						   (char *) &vgid, vgstatus,
 						   creation_host))
 			return_0;
+		if (!dev_close(mdac->area.dev))
+			stack;
 	}
 
 	info->status &= ~CACHE_INVALID;


