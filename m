From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:52:54 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20120125215254.32720.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:52:53

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Limit alignment to 32bit values
	
	to get the same behavior on 32/64 machines.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2241&r2=1.2242
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238

--- LVM2/WHATS_NEW	2012/01/25 21:43:51	1.2241
+++ LVM2/WHATS_NEW	2012/01/25 21:52:53	1.2242
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Limit alignment to 32bit values.
   Check for correctness of uint64 dev_size value.
   Rename origin_only parameter to more generic flag use_layer for lv_info().
   Thin pools have segment fields thin_count, zero, transaction_id.
--- LVM2/tools/toollib.c	2012/01/05 15:38:19	1.237
+++ LVM2/tools/toollib.c	2012/01/25 21:52:53	1.238
@@ -1438,7 +1438,7 @@
 	}
 	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
 
-	if (pp->data_alignment > ULONG_MAX) {
+	if (pp->data_alignment > UINT32_MAX) {
 		log_error("Physical volume data alignment is too big.");
 		return 0;
 	}
@@ -1457,7 +1457,7 @@
 	}
 	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
 
-	if (pp->data_alignment_offset > ULONG_MAX) {
+	if (pp->data_alignment_offset > UINT32_MAX) {
 		log_error("Physical volume data alignment offset is too big.");
 		return 0;
 	}


