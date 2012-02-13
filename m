From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:01:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20120213110135.10063.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:01:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	If the same fid is already same avoid ref_counting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2284&r2=1.2285
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.482&r2=1.483

--- LVM2/WHATS_NEW	2012/02/13 10:58:20	1.2284
+++ LVM2/WHATS_NEW	2012/02/13 11:01:34	1.2285
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Skip pv/vg_set_fid processing if the fid is same.
   Check for foreach loop errors in _vg_read_orphans() (2.02.91).
   Clean error paths for format instance creation (2.02.91).
   Release vg in error path of _format1_vg_read() instead of just free().
--- LVM2/lib/metadata/metadata.c	2012/02/13 10:58:21	1.482
+++ LVM2/lib/metadata/metadata.c	2012/02/13 11:01:35	1.483
@@ -4149,6 +4149,9 @@
 void pv_set_fid(struct physical_volume *pv,
 		struct format_instance *fid)
 {
+	if (fid == pv->fid)
+		return;
+
 	if (fid)
 		fid->ref_count++;
 
@@ -4163,6 +4166,9 @@
 {
 	struct pv_list *pvl;
 
+	if (fid == vg->fid)
+		return;
+
 	if (fid)
 		fid->ref_count++;
 


