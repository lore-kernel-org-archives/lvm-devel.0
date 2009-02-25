From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 25 Feb 2009 23:31:06 -0000
Subject: LVM2 lib/report/columns.h test/t-pvcreate-usage.sh
Message-ID: <20090225233106.17661.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-25 23:31:06

Modified files:
	lib/report     : columns.h 
	test           : t-pvcreate-usage.sh 

Log message:
	pe_start can be overwritten in VG metadata, so it is not PV label-only field.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/report/columns.h	2009/02/09 09:45:49	1.30
+++ LVM2/lib/report/columns.h	2009/02/25 23:31:06	1.31
@@ -41,11 +41,11 @@
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
 FIELD(LABEL, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
-FIELD(LABEL, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.")
 FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
 
+FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.")
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size", "Size of PV in current units.")
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free", "Total amount of unallocated space in current units.")
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used", "Total amount of allocated space in current units.")
--- LVM2/test/t-pvcreate-usage.sh	2009/02/25 23:29:07	1.7
+++ LVM2/test/t-pvcreate-usage.sh	2009/02/25 23:31:06	1.8
@@ -118,9 +118,6 @@
 vgcfgbackup -f "$(pwd)/backup.$$" $vg
 sed 's/pe_start = [0-9]*/pe_start = 0/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
-
-# BUG! this one fails, because now we read only label and vgcfgrestore does
-# not fix pe_start in label and there is no text metadta on this PV
-#check_pv_field_ $dev1 pe_start 0
-#check_pv_field_ $dev2 pe_start 0
+check_pv_field_ $dev1 pe_start 0
+check_pv_field_ $dev2 pe_start 0
 vgremove $vg


