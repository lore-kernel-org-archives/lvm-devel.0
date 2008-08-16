From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Aug 2008 09:46:55 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20080816094655.9912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-16 09:46:55

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix allocation bug in text metadata format write error path.
	
	Function _text_pv_write doesn't use memory pool but static buffer,
	call dm_pool_free in error path in _raw_write_mda_header is wrong.
	
	Move pool free only to path where is the memory pool used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.946&r2=1.947
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2008/08/13 12:44:23	1.946
+++ LVM2/WHATS_NEW	2008/08/16 09:46:55	1.947
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix allocation bug in text metadata format write error path.
   Fix vgcfgbackup to properly check filename if template is used.
   configure aborts if lcov or genhtml are missing with --enable-profiling
   vgremove tries to remove lv snapshot first.
--- LVM2/lib/format_text/format-text.c	2008/07/31 13:07:01	1.93
+++ LVM2/lib/format_text/format-text.c	2008/08/16 09:46:55	1.94
@@ -346,10 +346,8 @@
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
-		dm_pool_free(fmt->cmd->mem, mdah);
+	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, mdah))
 		return_0;
-	}
 
 	return 1;
 }
@@ -670,6 +668,7 @@
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
+		dm_pool_free(fid->fmt->cmd->mem, mdah);
 		log_error("Failed to write metadata area header");
 		goto out;
 	}
@@ -752,6 +751,7 @@
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
+		dm_pool_free(fid->fmt->cmd->mem, mdah);
 		log_error("Failed to write metadata area header");
 		goto out;
 	}


