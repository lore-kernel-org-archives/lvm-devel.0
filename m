From: Dave Wysochanski <dave.wysochanski@redhat.com>
Date: Mon, 08 Jan 2007 16:45:01 -0500
Subject: [LVM2 PATCH] Fix _raw_read_mda_header does not free struct mda_header *mdah in error paths
Message-ID: <1168292702.4239.30.camel@linux-cxyg.rtp.netapp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix error paths of _raw_read_mda_header 

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=220563

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-01-08 16:35:38.000000000 -0500
+++ LVM2/WHATS_NEW	2007-01-08 16:36:31.000000000 -0500
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix _raw_read_mda_header() error paths to free memory.
   Fix typeo in lvextend man pg.
   Fix misleading vgsplit error message when LV is part of PV not on cmdline.
   Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
Index: LVM2/lib/format_text/format-text.c
===================================================================
--- LVM2.orig/lib/format_text/format-text.c	2006-11-30 18:11:41.000000000 -0500
+++ LVM2/lib/format_text/format-text.c	2006-12-26 18:14:15.000000000 -0500
@@ -127,42 +127,45 @@ static struct mda_header *_raw_read_mda_
 
 	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
-		return NULL;
+		goto error;
 	}
 
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
+ error:
+	if (mdah)
+		dm_pool_free(fmt->cmd->mem, mdah);
+	return NULL;
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,



