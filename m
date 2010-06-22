From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jun 2010 19:18:28 -0000
Subject: LVM2 lib/format_text/format-text.c ./WHATS_NEW
Message-ID: <20100622191828.26827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-22 19:18:28

Modified files:
	lib/format_text: format-text.c 
	.              : WHATS_NEW 

Log message:
	Add device name to output of error messages in raw_read_mda_header().
	
	It would be helpful if we had the device name when something like
	a mda_header checksum error occurs.
	
	Before:
	./tools/lvm pvs -opv_name,vg_name,uuid,mda_count,pv_mda_count_ignored,vg_mda_count,vg_mda_count_ignored,vg_mda_copies
	Incorrect metadata area header checksum
	PV         VG      PV UUID                                #PMda #PMdaIgn #VMda #VMdaIgn #VMdaCps
	/dev/loop0 vgtest2 sVv26t-gjpb-Rcau-uBDO-Cx04-GbRR-6Ssq7e     2        0     4        0        4
	/dev/loop1 vgtest2 zXWStT-qE8F-mbkc-RfgH-aytv-mptF-Y5Ce09     2        0     4        0        4
	/dev/loop2         riCpK9-9G8r-LlIp-i2oh-mb3N-CUzk-u5YpuR     1        0     0        0        0
	/dev/loop3 vgtest  tQCUjm-rmyd-i92d-4eeE-UYBW-v1vQ-kRaA17     2        0     4        2        0
	/dev/loop4 vgtest  ZRvpeI-p8F1-ccVW-BBac-xhl1-aGXU-CbP0oo     2        2     4        2        0
	
	After:
	./tools/lvm pvs -opv_name,vg_name,uuid,mda_count,pv_mda_count_ignored,vg_mda_count,vg_mda_count_ignored,vg_mda_copies
	Incorrect metadata area header checksum on /dev/loop2 at offset 4096
	PV         VG      PV UUID                                #PMda #PMdaIgn #VMda #VMdaIgn #VMdaCps
	/dev/loop0 vgtest2 sVv26t-gjpb-Rcau-uBDO-Cx04-GbRR-6Ssq7e     2        0     4        0        4
	/dev/loop1 vgtest2 zXWStT-qE8F-mbkc-RfgH-aytv-mptF-Y5Ce09     2        0     4        0        4
	/dev/loop2         riCpK9-9G8r-LlIp-i2oh-mb3N-CUzk-u5YpuR     1        0     0        0        0
	/dev/loop3 vgtest  tQCUjm-rmyd-i92d-4eeE-UYBW-v1vQ-kRaA17     2        0     4        2        0
	/dev/loop4 vgtest  ZRvpeI-p8F1-ccVW-BBac-xhl1-aGXU-CbP0oo     2        2     4        2        0

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1624&r2=1.1625

--- LVM2/lib/format_text/format-text.c	2010/06/01 12:08:50	1.122
+++ LVM2/lib/format_text/format-text.c	2010/06/22 19:18:27	1.123
@@ -311,26 +311,32 @@
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
-		log_error("Incorrect metadata area header checksum");
+		log_error("Incorrect metadata area header checksum on %s"
+			  " at offset %"PRIu64, dev_name(dev_area->dev),
+			  dev_area->start);
 		goto bad;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
-		log_error("Wrong magic number in metadata area header");
+		log_error("Wrong magic number in metadata area header on %s"
+			  " at offset %"PRIu64, dev_name(dev_area->dev),
+			  dev_area->start);
 		goto bad;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
-		log_error("Incompatible metadata area header version: %d",
-			  mdah->version);
+		log_error("Incompatible metadata area header version: %d on %s"
+			  " at offset %"PRIu64, mdah->version,
+			  dev_name(dev_area->dev), dev_area->start);
 		goto bad;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: %"
-			  PRIu64, mdah->start);
+			  PRIu64" on %s at offset %"PRIu64, mdah->start,
+			  dev_name(dev_area->dev), dev_area->start);
 		goto bad;
 	}
 
--- LVM2/WHATS_NEW	2010/06/22 13:11:29	1.1624
+++ LVM2/WHATS_NEW	2010/06/22 19:18:27	1.1625
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Add device name and offset to output of error messages in raw_read_mda_header().
   Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
   Honor log argument when down-converting stacked mirror.
   Sleep to workaround clvmd -S race: socket closed early and server drops cmd.


