From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jan 2010 21:04:44 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100121210444.27072.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-01-21 21:04:44

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove useless memory allocation for pv->vg_name in _alloc_pv().
	
	All this seems to do is provide a memory leak so remove it.
	The only caller of _alloc_pv() later explicitly sets
	pv->vg_name = fmt->orphan_vg_name so clearly this allocation
	should be removed.  I also saw no where in the code where
	strncpy was used to assign pv->vg_name - only direct assignments
	and strdup's.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.310&r2=1.311

--- LVM2/lib/metadata/metadata.c	2010/01/21 21:04:20	1.310
+++ LVM2/lib/metadata/metadata.c	2010/01/21 21:04:44	1.311
@@ -1443,11 +1443,6 @@
 	if (!pv)
 		return_NULL;
 
-	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN))) {
-		dm_pool_free(mem, pv);
-		return NULL;
-	}
-
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;


