From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2009 10:22:15 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090407102215.23368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-07 10:22:15

Modified files:
	tools          : toollib.c 

Log message:
	Use pv from newly read_vg to avoid possible use of not initialized memory.
	
	If the vg in process_each_segment_in_pv is NULL, the pv struct
	can be incomplete (for example lv_segs are not copied in get_pvs()
	call).
	
	We need use the new pv from just read-in volume group.
	
	(The same code is in pvdisplay already.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/tools/toollib.c	2009/02/25 23:29:07	1.144
+++ LVM2/tools/toollib.c	2009/04/07 10:22:14	1.145
@@ -364,6 +364,7 @@
 						      void *handle))
 {
 	struct pv_segment *pvseg;
+	struct pv_list *pvl;
 	const char *vg_name = NULL;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -376,6 +377,18 @@
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
+
+		/*
+		 * Replace possibly incomplete PV structure with new one
+		 * allocated in vg_read_internal() path.
+		 */
+		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
+			 log_error("Unable to find %s in volume group %s",
+				   pv_dev_name(pv), vg_name);
+			return ECMD_FAILED;
+		}
+
+		pv = pvl->pv;
 	}
 
 	dm_list_iterate_items(pvseg, &pv->segments) {


