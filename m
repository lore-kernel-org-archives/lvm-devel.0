From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Oct 2008 00:55:47 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20081017005547.31860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-17 00:55:46

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Avoid overwriting in-use on-disk text metadata by forgetting MDA_HEADER_SIZE. (Edward Allcutt)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.974&r2=1.975
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2008/10/13 12:06:30	1.974
+++ LVM2/WHATS_NEW	2008/10/17 00:55:46	1.975
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Avoid overwriting in-use on-disk text metadata by forgetting MDA_HEADER_SIZE.
   Fix snapshot monitoring library to not cancel monitoring invalid snapshot.
   Generate man pages from templates and include version.
   Add usrlibdir and usrsbindir to configure.
--- LVM2/lib/format_text/format-text.c	2008/09/30 20:37:52	1.96
+++ LVM2/lib/format_text/format-text.c	2008/10/17 00:55:46	1.97
@@ -513,7 +513,7 @@
 	struct mda_header *mdah;
 	struct pv_list *pvl;
 	int r = 0;
-	uint32_t new_wrap = 0, old_wrap = 0;
+       uint64_t new_wrap = 0, old_wrap = 0, new_end;
 	int found = 0;
 	int noprecommit = 0;
 
@@ -552,10 +552,11 @@
 	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
 		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
 
+	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
+			    mdac->rlocn.offset + mdac->rlocn.size;
+
 	if ((new_wrap && old_wrap) ||
-	    (rlocn && ((new_wrap > rlocn->offset) ||
-		       (old_wrap && (mdac->rlocn.offset + mdac->rlocn.size >
-				     rlocn->offset)))) ||
+	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
 	    (mdac->rlocn.size >= mdah->size)) {
 		log_error("VG %s metadata too large for circular buffer",
 			  vg->name);
@@ -573,7 +574,7 @@
 		goto_out;
 
 	if (new_wrap) {
-		log_debug("Writing metadata to %s at %" PRIu64 " len %" PRIu32,
+               log_debug("Writing metadata to %s at %" PRIu64 " len %" PRIu64,
 			  dev_name(mdac->area.dev), mdac->area.start +
 			  MDA_HEADER_SIZE, new_wrap);
 
@@ -592,7 +593,7 @@
 		mdac->rlocn.checksum = calc_crc(mdac->rlocn.checksum,
 						fidtc->raw_metadata_buf +
 						mdac->rlocn.size -
-						new_wrap, new_wrap);
+						new_wrap, (uint32_t) new_wrap);
 
 	r = 1;
 
@@ -601,10 +602,10 @@
 		if (!dev_close(mdac->area.dev))
 			stack;
 
-                if (fidtc->raw_metadata_buf) {
-                        dm_free(fidtc->raw_metadata_buf);
-                        fidtc->raw_metadata_buf = NULL;
-                }
+		if (fidtc->raw_metadata_buf) {
+			dm_free(fidtc->raw_metadata_buf);
+			fidtc->raw_metadata_buf = NULL;
+		}
 	}
 
 	return r;


