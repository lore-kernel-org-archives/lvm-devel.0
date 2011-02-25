From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Feb 2011 13:50:04 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20110225135004.26736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-25 13:50:03

Modified files:
	lib/format_text: format-text.c 

Log message:
	Fix a bug in metadata location calculation, cleanup pv_add_metadata_area fn.
	
	This bug (a missing line) caused the 2nd MDA area location to be calculated
	incorrectly and it didn't fit the disk size properly.
	
	(https://www.redhat.com/archives/lvm-devel/2011-February/msg00127.html)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/lib/format_text/format-text.c	2011/02/21 12:31:28	1.166
+++ LVM2/lib/format_text/format-text.c	2011/02/25 13:50:02	1.167
@@ -1884,11 +1884,13 @@
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
 	uint64_t mda_start;
-	uint64_t adjustment, limit;
+	uint64_t adjustment, limit, tmp_mda_size;
 	uint64_t wipe_size = 8 << SECTOR_SHIFT;
 	size_t page_size = lvm_getpagesize();
 	struct metadata_area *mda;
 	struct mda_context *mdac;
+	const char *limit_name;
+	int limit_applied = 0;
 
 	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
 		log_error(INTERNAL_ERROR "invalid index of value %u used "
@@ -1917,13 +1919,19 @@
 		 * is locked. If it's not locked, count with any existing MDA1.
 		 * If there's no MDA1, just use disk size as the limit.
 		 */
-		if (pe_start_locked)
+		if (pe_start_locked) {
 			limit = pe_start;
+			limit_name = "pe_start";
+		}
 		else if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 1)) &&
-			 (mdac = mda->metadata_locn))
+			 (mdac = mda->metadata_locn)) {
 			limit = mdac->area.start;
-		else
+			limit_name = "MDA1 start";
+		}
+		else {
 			limit = disk_size;
+			limit_name = "disk size";
+		}
 
 		if (limit > disk_size)
 			goto bad;
@@ -1937,29 +1945,22 @@
 		}
 
 		/* Align MDA0 end position with given alignment if possible. */
-		if (alignment) {
-			if ((adjustment = (mda_start + mda_size) % alignment)) {
-				mda_size += (alignment - adjustment);
-				if (mda_start + mda_size > limit)
-					mda_size -= (alignment - adjustment);
-			}
+		if (alignment &&
+		    (adjustment = (mda_start + mda_size) % alignment)) {
+			tmp_mda_size = mda_size + alignment - adjustment;
+			if (mda_start + tmp_mda_size <= limit)
+				mda_size = tmp_mda_size;
 		}
 
 		/* Align MDA0 end position with given alignment offset if possible. */
 		if (alignment_offset &&
 		    (((mda_start + mda_size) % alignment) == 0)) {
-			mda_size += alignment_offset;
-			if (mda_start + mda_size > limit)
-				mda_size -= alignment_offset;
+			tmp_mda_size = mda_size + alignment_offset;
+			if (mda_start + tmp_mda_size <= limit)
+				mda_size = tmp_mda_size;
 		}
 
 		if (mda_start + mda_size > limit) {
-			log_warn("WARNING: metadata area size outreaches "
-				 "a limit on PV %s specified by its %s. "
-				 "Trying to adjust metadata area size.",
-				  pv_dev_name(pv),
-				  pe_start_locked ? "PE start" : "disk size");
-
 			/*
 			 * Try to decrease the MDA0 size with twice the
 			 * alignment and then align with given alignment.
@@ -1982,6 +1983,8 @@
 			/* FIXME: We should probably check for some minimum MDA size here. */
 			else
 				mda_size = limit - mda_start;
+
+			limit_applied = 1;
 		}
 
 		/*
@@ -1997,41 +2000,54 @@
 	else {
 		/*
 		 * Try to fit MDA1 start within given pe_end or pe_start limit
-		 * if it's locked. If pe_start and pe_end are not defined yet,
-		 * count with any existing MDA0 and pe_start. If MDA0 does not
-		 * exist, just use LABEL_SCAN_SIZE.
+		 * if defined or locked. If pe_start is not defined yet, count
+		 * with any existing MDA0. If MDA0 does not exist, just use
+		 * LABEL_SCAN_SIZE.
 		 */
 		pe_end = pv->pe_count ? (pv->pe_start +
 					 pv->pe_count * pv->pe_size - 1) << SECTOR_SHIFT
 				      : 0;
-		if (pe_start_locked)
+
+		if (pe_start || pe_start_locked) {
 			limit = pe_end ? pe_end : pe_start;
-		else if (pe_start)
-			limit = pe_start;
-		/*
-		 * Normally MDA0's start + size should be pe_start.
-		 * The statemet here is probably useless since the
-		 * situation is covered by previous statement.
-		 */
+			limit_name = pe_end ? "pe_end" : "pe_start";
+		}
 		else if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 0)) &&
-			 (mdac = mda->metadata_locn))
+			 (mdac = mda->metadata_locn)) {
 			limit = mdac->area.start + mdac->area.size;
-		else
+			limit_name = "MDA0 end";
+		}
+		else {
 			limit = LABEL_SCAN_SIZE;
+			limit_name = "label scan size";
+		}
 
-		if (limit > disk_size || mda_size > disk_size)
+		if (limit > disk_size)
 			goto bad;
 
-		mda_start = disk_size - mda_size;
-
-		if (alignment) {
-			adjustment = mda_start % alignment;
-			if (adjustment)
-				mda_size += adjustment;
+		if (mda_size > disk_size) {
+			mda_size = disk_size - limit;
+			limit_applied = 1;
 		}
 
-		if (disk_size - mda_size < limit)
+		mda_start = disk_size - mda_size;
+
+		/* If MDA1 size is too big, just take any usable space. */
+		if (disk_size - mda_size < limit) {
 			mda_size = disk_size - limit;
+			mda_start = disk_size - mda_size;
+			limit_applied = 1;
+		}
+		/* Otherwise, try to align MDA1 start if possible. */
+		else if (alignment &&
+		    (adjustment = mda_start % alignment)) {
+			tmp_mda_size = mda_size + adjustment;
+			if (tmp_mda_size < disk_size &&
+			    disk_size - tmp_mda_size >= limit) {
+				mda_size = tmp_mda_size;
+				mda_start = disk_size - mda_size;
+			}
+		}
 
 		/*
 		 * If PV's pe_end not set yet, set it to the end of the
@@ -2044,6 +2060,12 @@
 		}*/
 	}
 
+	if (limit_applied)
+		log_very_verbose("Using limited metadata area size on %s "
+				 "with value %" PRIu64 " (limited by %s of "
+				 "%" PRIu64 ").", pv_dev_name(pv),
+				  mda_size, limit_name, limit);
+
 	if (mda_size) {
 		/* Wipe metadata area with zeroes. */
 		if (!dev_set((struct device *) pv->dev, mda_start,


