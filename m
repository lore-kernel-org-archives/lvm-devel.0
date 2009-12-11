From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Dec 2009 13:14:45 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20091211131445.21267.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-11 13:14:45

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Destroy allocated mempool in _vg_read_orphans() error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1351&r2=1.1352
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.301&r2=1.302

--- LVM2/WHATS_NEW	2009/12/11 13:11:56	1.1351
+++ LVM2/WHATS_NEW	2009/12/11 13:14:44	1.1352
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Destroy allocated mempool in _vg_read_orphans() error path.
   Fix unlocking vg in some pvresize and toollib error paths.
   Explicitly call suspend for temporary mirror layer.
   Allow use precommited metadata when a PV is missing.
--- LVM2/lib/metadata/metadata.c	2009/12/09 19:29:04	1.301
+++ LVM2/lib/metadata/metadata.c	2009/12/11 13:14:44	1.302
@@ -2380,7 +2380,7 @@
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
 		log_error("vg allocation failed");
-		return NULL;
+		goto bad;
 	}
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);


