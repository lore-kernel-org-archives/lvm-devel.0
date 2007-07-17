From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jul 2007 16:13:13 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20070717161313.24537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-07-17 16:13:12

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Fix snapshot cow area deactivation if origin is not active. (2.02.13)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.656&r2=1.657
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/WHATS_NEW	2007/07/13 17:08:00	1.656
+++ LVM2/WHATS_NEW	2007/07/17 16:13:12	1.657
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Fix snapshot cow area deactivation if origin is not active. (2.02.13)
   Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
--- LVM2/tools/lvcreate.c	2007/06/28 17:33:44	1.137
+++ LVM2/tools/lvcreate.c	2007/07/17 16:13:12	1.138
@@ -478,10 +478,11 @@
 	struct logical_volume *lv, *org = NULL, *log_lv = NULL;
 	struct list *pvh, tags;
 	const char *tag = NULL;
-	int consistent = 1;
+	int consistent = 1, origin_active = 0;
 	struct alloc_handle *ah = NULL;
 	char lv_name_buf[128];
 	const char *lv_name;
+	struct lvinfo info;
 
 	status |= lp->permission | VISIBLE_LV;
 
@@ -615,6 +616,13 @@
  
 		/* Must zero cow */
 		status |= LVM_WRITE;
+
+		if (!lv_info(cmd, org, &info, 0)) {
+			log_error("Check for existence of snapshot origin "
+				  "'%s' failed.", org->name);
+			return 0;
+		}
+		origin_active = info.exists;
 	}
 
 	if (!lp->extents) {
@@ -792,6 +800,13 @@
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
 
+		/* COW area must be deactivated if origin is not active */
+		if (!origin_active && !deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Couldn't deactivate snapshot "
+				  "COW area.");
+			return 0;
+		}
+
 		/* cow LV remains active and becomes snapshot LV */
 
 		if (!vg_add_snapshot(vg->fid, NULL, org, lv, NULL,


