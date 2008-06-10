From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jun 2008 20:07:05 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/vgdisplay.c
Message-ID: <20080610200705.2569.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-10 20:07:04

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c vgdisplay.c 

Log message:
	Fix return values for reporting commands when run with no PVs, LVs, or VGs.
	The new error checking code caught some commands that were returning '0' as
	an exit status for success.  This is incorrect and resulted in a benign error
	message displayed (see below).  As of today, all commands should return a
	value defined in lib/commands/errors.h (1-5).  This results in an exit code of
	0 on success, or > 0 on failure (as stated in the lvm.8 man page).
	
	Before change:
	1. Make sure no PVs are on the system
	2. Run 'pvs'
	Command failed with status code 0.
	
	After change:
	<no output>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.895&r2=1.896
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2008/06/10 15:25:37	1.895
+++ LVM2/WHATS_NEW	2008/06/10 20:07:04	1.896
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Fix return values for reporting commands when run with no PVs, LVs, or VGs.
   Add omitted unlock_vg() call when sigint_caught() during vg processing.
   Fix wrong free_count on imported vg from pool device
   Fix segfault when calling pvcreate on the pool device
--- LVM2/tools/toollib.c	2008/06/10 15:25:38	1.134
+++ LVM2/tools/toollib.c	2008/06/10 20:07:04	1.135
@@ -145,7 +145,7 @@
 			  void *handle,
 			  process_single_lv_fn_t process_single)
 {
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	unsigned process_all = 0;
 	unsigned process_lv = 0;
@@ -223,7 +223,7 @@
 					   void *handle))
 {
 	int opt = 0;
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int consistent;
 
@@ -421,7 +421,7 @@
 {
 	struct pv_segment *pvseg;
 	const char *vg_name = NULL;
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	if (!vg && !is_orphan(pv)) {
@@ -456,7 +456,7 @@
 						      void *handle))
 {
 	struct lv_segment *seg;
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	list_iterate_items(seg, &lv->segments) {
@@ -464,7 +464,7 @@
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			return ret_max;
+			break;
 	}
 
 	return ret_max;
@@ -527,7 +527,7 @@
 					   int consistent, void *handle))
 {
 	int opt = 0;
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 
 	struct str_list *sl;
 	struct list *vgnames, *vgids;
@@ -613,7 +613,7 @@
 			  const struct list *tags, void *handle,
 			  process_single_pv_fn_t process_single)
 {
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	struct pv_list *pvl;
 
@@ -642,7 +642,7 @@
 	struct dev_iter *iter;
 	struct device *dev;
 
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
 	if (!scan_vgs_for_pvs(cmd)) {
@@ -684,7 +684,7 @@
 					   void *handle))
 {
 	int opt = 0;
-	int ret_max = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
 	struct pv_list *pvl;
--- LVM2/tools/vgdisplay.c	2008/01/30 14:00:02	1.20
+++ LVM2/tools/vgdisplay.c	2008/06/10 20:07:04	1.21
@@ -113,5 +113,5 @@
 	}
 ************/
 
-	return 0;
+	return ECMD_PROCESSED;
 }


