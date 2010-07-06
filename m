From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2010 17:26:11 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100706172611.21902.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-06 17:26:09

Modified files:
	lib/metadata   : metadata.c 

Log message:
	fix jumbled args in 'Adjusting' message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.379&r2=1.380

--- LVM2/lib/metadata/metadata.c	2010/07/05 22:23:15	1.379
+++ LVM2/lib/metadata/metadata.c	2010/07/06 17:26:08	1.380
@@ -1116,7 +1116,7 @@
 
 	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " of %" PRIu32 " mdas in use "
 		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
-		  vg->name, vg_mda_copies(vg), mda_count, mda_used_count, num_to_unignore);
+		  vg->name, mda_used_count, mda_count, vg_mda_copies(vg), num_to_unignore);
 
 	if (!(mda_to_unignore_bs = _bitset_with_random_bits(vg->vgmem, mda_free_count,
 							    num_to_unignore, &vg->cmd->rand_seed)))


