From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 May 2007 20:26:12 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20070531202612.3502.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-31 20:26:12

Modified files:
	lib/display    : display.c 

Log message:
	Fix pvdisplay --maps to not display segment header for orphan PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/display/display.c	2007/05/31 20:10:25	1.74
+++ LVM2/lib/display/display.c	2007/05/31 20:26:11	1.75
@@ -262,7 +262,8 @@
 {
 	struct pv_segment *pvseg;
 
-	log_print("--- Physical Segments ---");
+	if (pv->pe_size)
+		log_print("--- Physical Segments ---");
 
 	list_iterate_items(pvseg, &pv->segments) {
 		log_print("Physical extent %u to %u:",


