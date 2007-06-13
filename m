From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 21:14:07 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20070613211407.23437.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 21:14:07

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove casts in pv_create and find_pv_in_vg_by_uuid

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/lib/metadata/metadata.c	2007/06/13 20:55:56	1.115
+++ LVM2/lib/metadata/metadata.c	2007/06/13 21:14:07	1.116
@@ -595,11 +595,11 @@
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct list *mdas)
 {
-	return (pv_t *) _pv_create(fmt, dev, id, size, pe_start, 
-					existing_extent_count,
-					existing_extent_size,
-					pvmetadatacopies,
-					pvmetadatasize, mdas);
+	return _pv_create(fmt, dev, id, size, pe_start, 
+			  existing_extent_count,
+			  existing_extent_size,
+			  pvmetadatacopies,
+			  pvmetadatasize, mdas);
 }
 
 /* Sizes in sectors */
@@ -721,7 +721,7 @@
  */
 pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
 {
-	return (pv_t *) _find_pv_in_vg_by_uuid(vg, id);
+	return _find_pv_in_vg_by_uuid(vg, id);
 }
 
 


