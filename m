From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2012 14:12:58 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120305141258.10583.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-05 14:12:58

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Use 64bit math
	
	Prevent 32bit overflow and resulting weird error reports when working
	with TB sizes..

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2341&r2=1.2342
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.370&r2=1.371

--- LVM2/WHATS_NEW	2012/03/04 17:40:59	1.2341
+++ LVM2/WHATS_NEW	2012/03/05 14:12:57	1.2342
@@ -1,5 +1,6 @@
 Version 2.02.95 -
 ================================
+  Use 64bit math for verification of thin pool and snapshot chunk size.
   Validate udev structures in _insert_udev_dir().
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
   Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
--- LVM2/lib/metadata/lv_manip.c	2012/03/04 15:57:27	1.370
+++ LVM2/lib/metadata/lv_manip.c	2012/03/05 14:12:57	1.371
@@ -4239,12 +4239,12 @@
 	}
 
 	if (seg_is_thin_pool(lp) &&
-	    (lp->extents * vg->extent_size < lp->chunk_size)) {
+	    ((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
 		log_error("Unable to create thin pool smaller than 1 chunk.");
 		return NULL;
 	}
 
-	if (lp->snapshot && !lp->thin && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
+	if (lp->snapshot && !lp->thin && ((uint64_t)lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
 		log_error("Unable to create a snapshot smaller than 2 chunks.");
 		return NULL;
 	}


