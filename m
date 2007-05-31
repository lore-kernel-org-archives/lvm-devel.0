From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 May 2007 20:10:26 -0000
Subject: LVM2 lib/display/display.c tools/pvdisplay.c
Message-ID: <20070531201026.25473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-31 20:10:25

Modified files:
	lib/display    : display.c 
	tools          : pvdisplay.c 

Log message:
	Fix redundant segment display when PV is given to 'pvdisplay --maps' cmdline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/lib/display/display.c	2007/05/31 15:18:44	1.73
+++ LVM2/lib/display/display.c	2007/05/31 20:10:25	1.74
@@ -265,8 +265,6 @@
 	log_print("--- Physical Segments ---");
 
 	list_iterate_items(pvseg, &pv->segments) {
-		if (pvseg->len == pv->pe_count)
-			continue;
 		log_print("Physical extent %u to %u:",
 			  pvseg->pe, pvseg->pe + pvseg->len - 1);
 
--- LVM2/tools/pvdisplay.c	2007/05/30 20:43:09	1.26
+++ LVM2/tools/pvdisplay.c	2007/05/31 20:10:25	1.27
@@ -22,6 +22,7 @@
 	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
+	struct physical_volume *pv_temp;
 
 	const char *pv_name = dev_name(pv->dev);
 
@@ -43,7 +44,21 @@
 	                 ret = ECMD_FAILED;
 	                 goto out;
 	         }
-	 }
+
+		 /*
+		  * Replace possibly incomplete PV structure with new one
+		  * allocated in vg_read() path.
+		  */
+		 pv_temp = find_pv(vg, pv->dev);
+		 if (!pv_temp) {
+			 log_error("Unable to find physical volume %s "
+				   "in volume group %s",
+				   pv_name, pv->vg_name);
+	                 ret = ECMD_FAILED;
+			 goto out;
+		 }
+		 pv = pv_temp;
+	}
 
 	if (!*pv->vg_name)
 		size = pv->size;


