From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:14:05 -0000
Subject: LVM2 ./WHATS_NEW lib/snapshot/snapshot.c
Message-ID: <20100105211405.31122.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:14:05

Modified files:
	.              : WHATS_NEW 
	lib/snapshot   : snapshot.c 

Log message:
	Use snapshot metadata usage to determine if snapshot is empty
	
	Version >= 1.8.0 of the DM snapshot target appends metadata sectors used
	to a snapshot's status.  This patch allows LVM2 to accurately determine
	if the snapshot store is empty.  Knowing when a snapshot store is empty
	is important in the context of snapshot-merge (means merge is complete).
	
	Also update LVM2 to be aware of the possibility for "Merge failed" in
	the snapshot-merge target's status.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1362&r2=1.1363
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2010/01/05 20:56:51	1.1362
+++ LVM2/WHATS_NEW	2010/01/05 21:14:04	1.1363
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Use snapshot metadata usage to determine if a snapshot is empty.
   Add --poll flag to vgchange and lvchange.
   Propagate commit and revert metadata notification to other nodes in cluster.
   Use proper mask for VG lock mode in clvmd.
--- LVM2/lib/snapshot/snapshot.c	2009/10/01 00:35:30	1.38
+++ LVM2/lib/snapshot/snapshot.c	2010/01/05 21:14:05	1.39
@@ -95,19 +95,27 @@
 				char *params, uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
-	uint64_t numerator, denominator;
+	uint64_t total_sectors, sectors_allocated, metadata_sectors;
+	int r;
 
-	if (sscanf(params, "%" PRIu64 "/%" PRIu64,
-		   &numerator, &denominator) == 2) {
-		*total_numerator += numerator;
-		*total_denominator += denominator;
-		if (!numerator)
+	/*
+	 * snapshot target's percent format:
+	 * <= 1.7.0: <sectors_allocated>/<total_sectors>
+	 * >= 1.8.0: <sectors_allocated>/<total_sectors> <metadata_sectors>
+	 */
+	r = sscanf(params, "%" PRIu64 "/%" PRIu64 " %" PRIu64,
+		   &sectors_allocated, &total_sectors, &metadata_sectors);
+	if (r == 2 || r == 3) {
+		*total_numerator += sectors_allocated;
+		*total_denominator += total_sectors;
+		if (r == 3 && sectors_allocated == metadata_sectors)
 			*percent_range = PERCENT_0;
-		else if (numerator == denominator)
+		else if (sectors_allocated == total_sectors)
 			*percent_range = PERCENT_100;
 		else
 			*percent_range = PERCENT_0_TO_100;
-	} else if (!strcmp(params, "Invalid"))
+	} else if (!strcmp(params, "Invalid") ||
+		   !strcmp(params, "Merge failed"))
 		*percent_range = PERCENT_INVALID;
 	else
 		return 0;


