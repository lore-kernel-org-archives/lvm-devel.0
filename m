From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2012 22:03:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c man/lvs.8.in
Message-ID: <20120120220305.27433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2012-01-20 22:03:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 
	man            : lvs.8.in 

Log message:
	Use m and M lv_attr to indicate that a snapshot merge failed in lvs.
	
	snapshot (m)erge failed, suspended snapshot (M)erge failed

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2230&r2=1.2231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2012/01/20 22:02:04	1.2230
+++ LVM2/WHATS_NEW	2012/01/20 22:03:03	1.2231
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use m and M lv_attr to indicate that a snapshot merge failed in lvs.
   Differentiate between snapshot status of "Invalid" and "Merge failed".
   Lookup snapshot usage percent of origin volume when a snapshot is merging.
   Update lvdisplay with backward compat. config opt. lvm1_compatible_display.
--- LVM2/lib/metadata/lv.c	2012/01/20 10:56:30	1.34
+++ LVM2/lib/metadata/lv.c	2012/01/20 22:03:04	1.35
@@ -441,14 +441,21 @@
 			repstr[4] = 'd';	/* Inactive without table */
 
 		/* Snapshot dropped? */
-		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent) ||
-		     snap_percent == PERCENT_INVALID)) {
-			repstr[0] = toupper(repstr[0]);
-			if (info.suspended)
-				repstr[4] = 'S'; /* Susp Inv snapshot */
-			else
-				repstr[4] = 'I'; /* Invalid snapshot */
+		if (info.live_table && lv_is_cow(lv)) {
+			if (!lv_snapshot_percent(lv, &snap_percent) ||
+			    snap_percent == PERCENT_INVALID) {
+				repstr[0] = toupper(repstr[0]);
+				if (info.suspended)
+					repstr[4] = 'S'; /* Susp Inv snapshot */
+				else
+					repstr[4] = 'I'; /* Invalid snapshot */
+			}
+			else if (snap_percent == PERCENT_MERGE_FAILED) {
+				if (info.suspended)
+					repstr[4] = 'M'; /* Susp snapshot merge failed */
+				else
+					repstr[4] = 'm'; /* snapshot merge failed */
+			}
 		}
 
 		/*
--- LVM2/man/lvs.8.in	2012/01/12 16:58:44	1.19
+++ LVM2/man/lvs.8.in	2012/01/20 22:03:04	1.20
@@ -105,6 +105,7 @@
 fixed (m)inor
 .IP 5 3
 State: (a)ctive, (s)uspended, (I)nvalid snapshot, invalid (S)uspended snapshot,
+snapshot (m)erge failed, suspended snapshot (M)erge failed,
 mapped (d)evice present without tables, mapped device present with (i)nactive table
 .IP 6 3
 device (o)pen


