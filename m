From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Nov 2007 02:10:40 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20071105021040.21291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-05 02:10:39

Modified files:
	lib/display    : display.c 

Log message:
	adjust sizes for metadata

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/lib/display/display.c	2007/11/05 01:47:48	1.80
+++ LVM2/lib/display/display.c	2007/11/05 02:10:39	1.81
@@ -295,7 +295,7 @@
 	const char *size;
 
 	uint32_t pe_free;
-	uint64_t used_size, pvsize, unusable;
+	uint64_t data_size, pvsize, unusable;
 
 	if (!pv)
 		return;
@@ -310,17 +310,17 @@
 	log_print("VG Name               %s%s", pv->vg_name,
 		  pv->status & EXPORTED_VG ? " (exported)" : "");
 
-	used_size = (uint64_t) pv->pe_count * pv->pe_size;
-	if (pv->size > used_size) {
+	data_size = (uint64_t) pv->pe_count * pv->pe_size;
+	if (pv->size > data_size + pv->pe_start) {
 		pvsize = pv->size;
-		unusable = pvsize - used_size;
+		unusable = pvsize - data_size;
 	} else {
-		pvsize = used_size;
-		unusable = used_size - pv->size;
+		pvsize = data_size + pv->pe_start;
+		unusable = pvsize - pv->size;
 	}
 
 	size = display_size(cmd, pvsize);
-	if (used_size)
+	if (data_size)
 		log_print("PV Size               %s / not usable %s",	/*  [LVM: %s]", */
 			  size, display_size(cmd, unusable));
 	else


