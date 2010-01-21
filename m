From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jan 2010 21:09:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100121210923.32089.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-01-21 21:09:23

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Call _alloc_pv() inside _pv_read() and clean up error paths.
	
	We should be consistent with pv constructors so call _alloc_pv()
	here as we do from pv_create().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1397&r2=1.1398
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.311&r2=1.312

--- LVM2/WHATS_NEW	2010/01/21 17:14:18	1.1397
+++ LVM2/WHATS_NEW	2010/01/21 21:09:23	1.1398
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Cleanup memory initialization and freeing in pv_read() and pv_create().
   Clear pointer and counters after their release in _fin_commands().
   Add t-topology-support.sh and t-snapshot-merge.sh tests.
   Fix clvmd to never scan suspended devices.
--- LVM2/lib/metadata/metadata.c	2010/01/21 21:04:44	1.311
+++ LVM2/lib/metadata/metadata.c	2010/01/21 21:09:23	1.312
@@ -3020,29 +3020,30 @@
 	if (label_sector && *label_sector)
 		*label_sector = label->sector;
 
-	if (!(pv = dm_pool_zalloc(pvmem, sizeof(*pv)))) {
+	pv = _alloc_pv(pvmem, dev);
+	if (!pv) {
 		log_error("pv allocation for '%s' failed", pv_name);
 		return NULL;
 	}
 
-	dm_list_init(&pv->tags);
-	dm_list_init(&pv->segments);
-
 	/* FIXME Move more common code up here */
 	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas,
 	      scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
 			  pv_name);
-		return NULL;
+		goto bad;
 	}
 
 	if (!pv->size)
-		return NULL;
+		goto bad;
 
 	if (!alloc_pv_segment_whole_pv(pvmem, pv))
-		return_NULL;
+		goto_bad;
 
 	return pv;
+bad:
+	_free_pv(pvmem, pv);
+	return NULL;
 }
 
 /* May return empty list */


