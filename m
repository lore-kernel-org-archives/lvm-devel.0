From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 17:19:33 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090730171933.19164.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 17:19:31

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix _mda_setup() to not check first mda's size before pe_align rounding.
	
	Without this fix rounding the end of the first mda to a pe_align
	boundary could silently exceed the disk_size.
	
	Final 'if (start1 + mda_size1 > disk_size)' block serves as a safety
	net.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1213&r2=1.1214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2009/07/30 17:18:03	1.1213
+++ LVM2/WHATS_NEW	2009/07/30 17:19:31	1.1214
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Formalize pe_start policy as split between .pv_setup and .pv_write.
   Document -I option of clvmd in the man page.
   Fix configure script to handle multiple clvmd selections.
--- LVM2/lib/format_text/format-text.c	2009/07/30 17:18:08	1.107
+++ LVM2/lib/format_text/format-text.c	2009/07/30 17:19:31	1.108
@@ -1214,6 +1214,15 @@
 			start1 += (pagesize - mda_adjustment);
 	}
 
+	/* Round up to pe_align boundary */
+	mda_adjustment = (mda_size1 + start1) % alignment;
+	if (mda_adjustment) {
+		mda_size1 += (alignment - mda_adjustment);
+		/* Revert if it's now too large */
+		if (start1 + mda_size1 > disk_size)
+			mda_size1 -= (alignment - mda_adjustment);
+	}
+
 	/* Ensure it's not going to be bigger than the disk! */
 	if (start1 + mda_size1 > disk_size) {
 		log_warn("WARNING: metadata area fills disk leaving no "
@@ -1221,15 +1230,19 @@
 		/* Leave some free space for rounding */
 		/* Avoid empty data area as could cause tools problems */
 		mda_size1 = disk_size - start1 - alignment * 2;
+		if (start1 + mda_size1 > disk_size) {
+			log_error("Insufficient space for first mda on %s",
+				  pv_dev_name(pv));
+			return 0;
+		}
+		/* Round up to pe_align boundary */
+		mda_adjustment = (mda_size1 + start1) % alignment;
+		if (mda_adjustment)
+			mda_size1 += (alignment - mda_adjustment);
 		/* Only have 1 mda in this case */
 		pvmetadatacopies = 1;
 	}
 
-	/* Round up to pe_align() boundary */
-	mda_adjustment = (mda_size1 + start1) % alignment;
-	if (mda_adjustment)
-		mda_size1 += (alignment - mda_adjustment);
-
 	/* If we already have PEs, avoid overlap */
 	if (pe_start || pe_end) {
 		if (pe_start <= start1)


