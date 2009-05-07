From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 May 2009 12:11:52 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20090507121152.30578.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-07 12:11:51

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	test           : t-pvcreate-usage.sh 

Log message:
	Fix PV datalign when for values starting prior to MDA area.
	
	The dataalign value must always be aligned according
	to MDA area.
	The currect code checks if calculated value collides with
	MDA area but not if the value is so small that it is
	located before MDA starts.
	
	Unfortunatelly there can be also MDA in the end of the device.
	
	The patch adds simple check to avoid this miscalculation.
	Patch expects that first MDA always starts on <= pagesize boundary
	(this is true for all allowed label sector parameters).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1096&r2=1.1097
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2009/04/25 01:17:59	1.1096
+++ LVM2/WHATS_NEW	2009/05/07 12:11:50	1.1097
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
   Add lvs origin_size field.
   Fix linux configure --enable-debug to exclude -O2.
--- LVM2/lib/format_text/format-text.c	2009/03/23 21:13:37	1.104
+++ LVM2/lib/format_text/format-text.c	2009/05/07 12:11:51	1.105
@@ -1372,7 +1372,9 @@
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
-		    (mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) &&
+		    ((mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) ||
+		    (mdac->area.start <= lvm_getpagesize() &&
+		     pv->pe_start < (lvm_getpagesize() >> SECTOR_SHIFT))) &&
 		    (mdac->area.start + mdac->area.size >
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
--- LVM2/test/t-pvcreate-usage.sh	2009/02/25 23:31:06	1.8
+++ LVM2/test/t-pvcreate-usage.sh	2009/05/07 12:11:51	1.9
@@ -94,6 +94,12 @@
 pvcreate --metadatasize 100k --dataalignment 100k $dev1
 check_pv_field_ $dev1 pe_start 200.00K
 
+pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
+check_pv_field_ $dev1 pe_start 133.00K
+
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
+check_pv_field_ $dev1 pe_start 133.00K
+
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
 pvcreate --dataalignment 256k $dev1


