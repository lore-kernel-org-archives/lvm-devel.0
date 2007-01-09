From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jan 2007 21:12:42 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20070109211242.18959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-09 21:12:41

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	man            : lvextend.8 
	tools          : vgsplit.c 

Log message:
	Free memory in _raw_read_mda_header() error paths.
	Fix ambiguous vgsplit error message for split LV.
	Fix lvextend man page typo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.528&r2=1.529
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2007/01/09 20:31:08	1.528
+++ LVM2/WHATS_NEW	2007/01/09 21:12:40	1.529
@@ -1,5 +1,8 @@
 Version 2.02.18 -
 ====================================
+  Free memory in _raw_read_mda_header() error paths.
+  Fix ambiguous vgsplit error message for split LV.
+  Fix lvextend man page typo.
   Add configure --with-dmdir to compile against a device-mapper source tree.
   Use no flush suspending for mirrors.
   Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
--- LVM2/lib/format_text/format-text.c	2006/11/30 23:11:41	1.70
+++ LVM2/lib/format_text/format-text.c	2007/01/09 21:12:41	1.71
@@ -132,37 +132,40 @@
 
 	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		stack;
-		dm_pool_free(fmt->cmd->mem, mdah);
-		return NULL;
+		goto error;
 	}
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
 		log_error("Incorrect metadata area header checksum");
-		return NULL;
+		goto error;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
 		log_error("Wrong magic number in metadata area header");
-		return NULL;
+		goto error;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d",
 			  mdah->version);
-		return NULL;
+		goto error;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: %"
 			  PRIu64, mdah->start);
-		return NULL;
+		goto error;
 	}
 
 	return mdah;
+
+error:
+	dm_pool_free(fmt->cmd->mem, mdah);
+	return NULL;
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,
--- LVM2/man/lvextend.8	2006/11/10 18:24:11	1.8
+++ LVM2/man/lvextend.8	2007/01/09 21:12:41	1.9
@@ -31,7 +31,7 @@
 free space in the Volume Group with the suffix %FREE.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
-Extend or set the logical volume size in units in units of megabytes.
+Extend or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
 or E for exabytes is optional.
--- LVM2/tools/vgsplit.c	2006/10/13 13:22:44	1.20
+++ LVM2/tools/vgsplit.c	2007/01/09 21:12:41	1.21
@@ -84,9 +84,9 @@
 				pv = seg_pv(seg, s);
 				if (vg_with) {
 					if (!pv_is_in_vg(vg_with, pv)) {
-						log_error("Logical Volume %s "
-							  "split between "
-							  "Volume Groups",
+						log_error("Can't split Logical "
+							  "Volume %s between "
+							  "two Volume Groups",
 							  lv->name);
 						return 0;
 					}


