From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:31:18 -0000
Subject: LVM2/lib/format_text format-text.c text_label.c
Message-ID: <20100628203118.13982.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:31:18

Modified files:
	lib/format_text: format-text.c text_label.c 

Log message:
	Ensure in-memory state matches on-disk state of mda ignore bit.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:31:01	1.127
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:31:18	1.128
@@ -726,6 +726,7 @@
 			  "header at %" PRIu64, vg->name,
 			  dev_name(mdac->area.dev), mdac->area.start);
 
+	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
@@ -808,6 +809,7 @@
 	rlocn->offset = 0;
 	rlocn->size = 0;
 	rlocn->checksum = 0;
+	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
@@ -1513,6 +1515,7 @@
 		mdac = mda->metadata_locn;
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
+		rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 		if (!_raw_write_mda_header(fmt, mdac->area.dev,
 					   mdac->area.start, mdah)) {
 			if (!dev_close(pv->dev))
--- LVM2/lib/format_text/text_label.c	2010/06/28 20:31:01	1.30
+++ LVM2/lib/format_text/text_label.c	2010/06/28 20:31:18	1.31
@@ -301,6 +301,7 @@
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (!dev_open(mdac->area.dev)) {
+			mda_set_ignored(mda, 1);
 			stack;
 			continue;
 		}
@@ -308,6 +309,7 @@
 			stack;
 			goto close_dev;
 		}
+		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if ((vgname = vgname_from_mda(info->fmt, mdah,
 					      &mdac->area,


