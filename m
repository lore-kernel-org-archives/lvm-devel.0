From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2010 17:29:50 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100706172950.24275.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-06 17:29:50

Modified files:
	lib/metadata   : metadata.c 

Log message:
	s/flags/mda/

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.381&r2=1.382

--- LVM2/lib/metadata/metadata.c	2010/07/06 17:27:32	1.381
+++ LVM2/lib/metadata/metadata.c	2010/07/06 17:29:50	1.382
@@ -1074,7 +1074,7 @@
 	int r = 1;
 
 	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
-		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
+		  "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
 		  vg->name, mda_used_count, vg_mda_count(vg), vg_mda_copies(vg), num_to_ignore);
 
 	if (!num_to_ignore)
@@ -1115,7 +1115,7 @@
 		return 1;
 
 	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
-		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
+		  "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
 		  vg->name, mda_used_count, mda_count, vg_mda_copies(vg), num_to_unignore);
 
 	if (!(mda_to_unignore_bs = _bitset_with_random_bits(vg->vgmem, mda_free_count,


