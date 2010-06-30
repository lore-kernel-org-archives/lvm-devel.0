From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 14:52:30 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100630145230.28485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 14:52:30

Modified files:
	lib/metadata   : metadata.c 

Log message:
	suppress useless compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.371&r2=1.372

--- LVM2/lib/metadata/metadata.c	2010/06/30 14:48:07	1.371
+++ LVM2/lib/metadata/metadata.c	2010/06/30 14:52:29	1.372
@@ -1111,7 +1111,7 @@
 	 * below check and retain correctness.
 	 */
 	if ((!dm_list_size(&vg->fid->metadata_areas_in_use) ||
-	    !vg_mda_used_count(vg)) && vg_mda_count(vg))
+	    (!vg_mda_used_count(vg)) && vg_mda_count(vg)))
 		ret = _vg_unignore_mdas(vg, 1);
 
 	if (!ret)


