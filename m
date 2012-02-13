From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:58:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20120213105821.8979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:58:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Add missing test for failure of lvmcache_foreach_pv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2283&r2=1.2284
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.481&r2=1.482

--- LVM2/WHATS_NEW	2012/02/13 10:56:31	1.2283
+++ LVM2/WHATS_NEW	2012/02/13 10:58:20	1.2284
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Check for foreach loop errors in _vg_read_orphans() (2.02.91).
   Clean error paths for format instance creation (2.02.91).
   Release vg in error path of _format1_vg_read() instead of just free().
   Report allocation failure for allocation of PV structure.
--- LVM2/lib/metadata/metadata.c	2012/02/13 10:51:53	1.481
+++ LVM2/lib/metadata/metadata.c	2012/02/13 10:58:21	1.482
@@ -2754,7 +2754,9 @@
 
 	baton.warnings = warnings;
 	baton.vg = vg;
-	lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton);
+
+	if (!lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton))
+                return_NULL;
 
 	return vg;
 }


