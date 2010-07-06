From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2010 20:09:39 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100706200939.7274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-06 20:09:38

Modified files:
	lib/metadata   : metadata.c 

Log message:
	fix code in 2nd mda unignore loop to match 1st loop

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.382&r2=1.383

--- LVM2/lib/metadata/metadata.c	2010/07/06 17:29:50	1.382
+++ LVM2/lib/metadata/metadata.c	2010/07/06 20:09:38	1.383
@@ -1133,8 +1133,8 @@
 		}
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
-		if (mda_is_ignored(mda) &&
-		    dm_bit(mda_to_unignore_bs, num_to_unignore - 1)) {
+		if (mda_is_ignored(mda) && (--mda_free_count,
+		    dm_bit(mda_to_unignore_bs, mda_free_count))) {
 			mda_set_ignored(mda, 0);
 			if (!--num_to_unignore)
 				goto out;


