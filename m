From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Apr 2009 17:46:47 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090428174647.28649.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-28 17:46:47

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix error path in vg_make_handle().
	
	Enter the error condition if either of the allocations fail, and
	don't use dm_pool_zalloc if dm_pool_create fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213

--- LVM2/lib/metadata/metadata.c	2009/04/22 09:31:31	1.212
+++ LVM2/lib/metadata/metadata.c	2009/04/28 17:46:47	1.213
@@ -2595,7 +2595,7 @@
 	struct dm_pool *vgmem;
 
 	if (!vg) {
-		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) &&
+		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
 		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
 			log_error("Error allocating vg handle.");
 			if (vgmem)


