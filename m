From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 May 2012 12:31:04 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20120509123104.4087.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-09 12:31:00

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	test/shell     : pvcreate-operation.sh 

Log message:
	Fix division by zero if PV with zero PE count is used during vgcfgrestore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2399&r2=1.2400
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2012/05/09 12:17:06	1.2399
+++ LVM2/WHATS_NEW	2012/05/09 12:30:56	1.2400
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix division by zero if PV with zero PE count is used during vgcfgrestore.
   Add initial support for thin pool lvconvert.
   Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
   Fix up-convert when mirror activation is controled by volume_list and tags.
--- LVM2/lib/format_text/format-text.c	2012/04/10 12:26:27	1.200
+++ LVM2/lib/format_text/format-text.c	2012/05/09 12:30:59	1.201
@@ -1713,7 +1713,7 @@
 			   pv->pe_start + size_reduction;
 
 	/* Recalculate number of extents that will fit */
-	if (!pv->pe_count) {
+	if (!pv->pe_count && vg->extent_size) {
 		pe_count = (pv->size - pv->pe_start - size_reduction) /
 			   vg->extent_size;
 		if (pe_count > UINT32_MAX) {
--- LVM2/test/shell/pvcreate-operation.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/pvcreate-operation.sh	2012/05/09 12:30:59	1.3
@@ -111,6 +111,14 @@
 vgcfgbackup -f $backupfile
 not pvcreate --uuid $uuid2 --restorefile $backupfile "$dev2"
 
+# vgcfgrestore of a VG containing a PV with zero PEs (bz #820116)
+# (use case: one PV in a VG used solely to keep metadata)
+size_mb=$(($(blockdev --getsz $dev1) / 2048))
+pvcreate --metadatasize $size_mb $dev1
+vgcreate $vg1 $dev1
+vgcfgbackup -f $backupfile
+vgcfgrestore -f $backupfile $vg1
+
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of="$dev1" bs=1024 count=64
 mkswap "$dev1"


