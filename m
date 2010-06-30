From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 14:48:08 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100630144808.25747.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 14:48:08

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Only attempt to guarantee 1 mda ignored if there's at least one mda in the vg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.370&r2=1.371

--- LVM2/lib/metadata/metadata.c	2010/06/30 14:27:40	1.370
+++ LVM2/lib/metadata/metadata.c	2010/06/30 14:48:07	1.371
@@ -1110,8 +1110,8 @@
 	 * and another not ignored; function needs refactoring to simplify the
 	 * below check and retain correctness.
 	 */
-	if (!dm_list_size(&vg->fid->metadata_areas_in_use) ||
-	    !vg_mda_used_count(vg) && vg_mda_count(vg))
+	if ((!dm_list_size(&vg->fid->metadata_areas_in_use) ||
+	    !vg_mda_used_count(vg)) && vg_mda_count(vg))
 		ret = _vg_unignore_mdas(vg, 1);
 
 	if (!ret)


