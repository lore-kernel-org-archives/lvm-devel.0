From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:51:53 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20120213105153.6976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:51:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Log error reporting for failing _alloc_pv
	
	Drop unneeded zeroing of zalloced memory region.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2280&r2=1.2281
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.480&r2=1.481

--- LVM2/WHATS_NEW	2012/02/13 05:24:57	1.2280
+++ LVM2/WHATS_NEW	2012/02/13 10:51:52	1.2281
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Report allocation failure for allocation of PV structure.
   Add clvmd init dependency on dlm service when running with new corosync.
 
 Version 2.02.91 - 12th February 2012
--- LVM2/lib/metadata/metadata.c	2012/02/12 23:01:19	1.480
+++ LVM2/lib/metadata/metadata.c	2012/02/13 10:51:53	1.481
@@ -1557,21 +1557,14 @@
 
 static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev)
 {
-	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
+	struct physical_volume *pv;
 
-	if (!pv)
-		return_NULL;
+	if (!(pv = dm_pool_zalloc(mem, sizeof(*pv)))) {
+		log_error("Failed to allocate pv structure.");
+		return NULL;
+	}
 
-	pv_set_fid(pv, NULL);
-	pv->pe_size = 0;
-	pv->pe_start = 0;
-	pv->pe_count = 0;
-	pv->pe_alloc_count = 0;
-	pv->pe_align = 0;
-	pv->pe_align_offset = 0;
-	pv->fmt = NULL;
 	pv->dev = dev;
-
 	pv->status = ALLOCATABLE_PV;
 
 	dm_list_init(&pv->tags);
@@ -1621,7 +1614,7 @@
 	unsigned mda_index;
 
 	if (!pv)
-		return NULL;
+		return_NULL;
 
 	if (id)
 		memcpy(&pv->id, id, sizeof(*id));


