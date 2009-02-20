From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Feb 2009 23:19:29 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/text_label.c ...
Message-ID: <20090220231929.10604.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-20 23:19:28

Modified files:
	.              : WHATS_NEW 
	lib/format_text: text_label.c 
	lib/label      : label.c 

Log message:
	Provide da and mda locations in debug message when writing text format label.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1045&r2=1.1046
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2009/02/20 01:47:02	1.1045
+++ LVM2/WHATS_NEW	2009/02/20 23:19:28	1.1046
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Provide da and mda locations in debug message when writing text format label.
   Mention the restriction on file descriptors at invocation on the lvm man page.
   Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.
   No longer require kernel and metadata major numbers to match.
--- LVM2/lib/format_text/text_label.c	2008/11/03 22:14:28	1.22
+++ LVM2/lib/format_text/text_label.c	2009/02/20 23:19:28	1.23
@@ -44,6 +44,8 @@
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct data_area_list *da;
+	char buffer[64] __attribute((aligned(8)));
+	int da1, mda1, mda2;
 
 	/* FIXME Move to where label is created */
 	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
@@ -54,6 +56,11 @@
 	info = (struct lvmcache_info *) label->info;
 	pvhdr->device_size_xl = xlate64(info->device_size);
 	memcpy(pvhdr->pv_uuid, &info->dev->pvid, sizeof(struct id));
+	if (!id_write_format((const struct id *)pvhdr->pv_uuid, buffer,
+			     sizeof(buffer))) {
+		stack;
+		buffer[0] = '\0';
+	}
 
 	pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
 
@@ -85,6 +92,50 @@
 	pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
 	pvh_dlocn_xl->size = xlate64(UINT64_C(0));
 
+	/* Create debug message with da and mda locations */
+	if (xlate64(pvhdr->disk_areas_xl[0].offset) ||
+	    xlate64(pvhdr->disk_areas_xl[0].size))
+		da1 = 0;
+	else
+		da1 = -1;
+
+	mda1 = da1 + 2;
+	mda2 = mda1 + 1;
+	
+	if (!xlate64(pvhdr->disk_areas_xl[mda1].offset) &&
+	    !xlate64(pvhdr->disk_areas_xl[mda1].size))
+		mda1 = mda2 = 0;
+	else if (!xlate64(pvhdr->disk_areas_xl[mda2].offset) &&
+		 !xlate64(pvhdr->disk_areas_xl[mda2].size))
+		mda2 = 0;
+
+	log_debug("%s: Preparing PV label header %s size %" PRIu64 " with"
+		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
+		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
+		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
+		  dev_name(info->dev), buffer, info->device_size, 
+		  (da1 > -1) ? " da1 (" : "",
+		  (da1 > -1) ? 1 : 0,
+		  (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
+		  (da1 > -1) ? "s, " : "",
+		  (da1 > -1) ? 1 : 0,
+		  (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].size) >> SECTOR_SHIFT : 0,
+		  (da1 > -1) ? "s)" : "",
+		  mda1 ? " mda1 (" : "",
+		  mda1 ? 1 : 0,
+		  mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].offset) >> SECTOR_SHIFT : 0,
+		  mda1 ? "s, " : "",
+		  mda1 ? 1 : 0,
+		  mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].size) >> SECTOR_SHIFT : 0,
+		  mda1 ? "s)" : "",
+		  mda2 ? " mda2 (" : "",
+		  mda2 ? 1 : 0,
+		  mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].offset) >> SECTOR_SHIFT : 0,
+		  mda2 ? "s, " : "",
+		  mda2 ? 1 : 0,
+		  mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].size) >> SECTOR_SHIFT : 0,
+		  mda2 ? "s)" : "");
+
 	return 1;
 }
 
--- LVM2/lib/label/label.c	2008/11/03 22:14:28	1.45
+++ LVM2/lib/label/label.c	2009/02/20 23:19:28	1.46
@@ -329,8 +329,9 @@
 	if (!dev_open(dev))
 		return_0;
 
-	log_info("%s: Writing label to sector %" PRIu64, dev_name(dev),
-		 label->sector);
+	log_info("%s: Writing label to sector %" PRIu64 " with stored offset %"
+		 PRIu32 ".", dev_name(dev), label->sector,
+		 xlate32(lh->offset_xl));
 	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
 		log_debug("Failed to write label to %s", dev_name(dev));
 		r = 0;


