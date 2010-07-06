From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2010 17:27:33 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100706172733.23389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-06 17:27:32

Modified files:
	lib/metadata   : metadata.c 

Log message:
	shorten mesg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.380&r2=1.381

--- LVM2/lib/metadata/metadata.c	2010/07/06 17:26:08	1.380
+++ LVM2/lib/metadata/metadata.c	2010/07/06 17:27:32	1.381
@@ -1073,7 +1073,7 @@
 	dm_bitset_t mda_to_ignore_bs;
 	int r = 1;
 
-	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " of %" PRIu32 " mdas in use "
+	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
 		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
 		  vg->name, mda_used_count, vg_mda_count(vg), vg_mda_copies(vg), num_to_ignore);
 
@@ -1114,7 +1114,7 @@
 	if (!num_to_unignore)
 		return 1;
 
-	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " of %" PRIu32 " mdas in use "
+	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
 		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
 		  vg->name, mda_used_count, mda_count, vg_mda_copies(vg), num_to_unignore);
 


