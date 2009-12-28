From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Dec 2009 18:34:46 -0000
Subject: LVM2/tools vgcreate.c
Message-ID: <20091228183446.17181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-28 18:34:46

Modified files:
	tools          : vgcreate.c 

Log message:
	Fix previous vgcreate commit to not call unpaired unlock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/tools/vgcreate.c	2009/12/03 19:20:49	1.76
+++ LVM2/tools/vgcreate.c	2009/12/28 18:34:45	1.77
@@ -60,7 +60,8 @@
 			log_error("A volume group called %s already exists.", vp_new.vg_name);
 		else
 			log_error("Can't get lock for %s.", vp_new.vg_name);
-		goto bad;
+		vg_release(vg);
+		return ECMD_FAILED;
 	}
 
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
@@ -68,7 +69,7 @@
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
 	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
 	    !vg_set_clustered(vg, vp_new.clustered))
-		goto_bad;
+		goto bad_orphan;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");


