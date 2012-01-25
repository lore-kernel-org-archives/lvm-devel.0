From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:43:51 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20120125214351.28803.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:43:51

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Check for correctness of uint64 value if exists

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2240&r2=1.2241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2012/01/25 13:10:26	1.2240
+++ LVM2/WHATS_NEW	2012/01/25 21:43:51	1.2241
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Check for correctness of uint64 dev_size value.
   Rename origin_only parameter to more generic flag use_layer for lv_info().
   Thin pools have segment fields thin_count, zero, transaction_id.
   Each new created LV volume has creation lv_time and lv_host.
--- LVM2/lib/format_text/import_vsn1.c	2012/01/19 15:31:45	1.98
+++ LVM2/lib/format_text/import_vsn1.c	2012/01/25 21:43:51	1.99
@@ -216,7 +216,11 @@
 		pv->status |= MISSING_PV;
 
 	/* Late addition */
-	_read_uint64(pvn, "dev_size", &pv->size);
+	if (dm_config_has_node(pvn, "dev_size") &&
+	    !_read_uint64(pvn, "dev_size", &pv->size)) {
+		log_error("Couldn't read dev size for physical volume.");
+		return 0;
+	}
 
 	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent size for physical volume.");


