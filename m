From: Dave Wysochanski <dave.wysochanski@redhat.com>
Date: Mon, 08 Jan 2007 16:44:37 -0500
Subject: [LVM2 PATCH] Fix misleading vgsplit error message
Message-ID: <1168292677.4239.26.camel@linux-cxyg.rtp.netapp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Error message for failed vgsplit seems to imply that it actually worked.
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=202864

Index: LVM2/tools/vgsplit.c
===================================================================
--- LVM2.orig/tools/vgsplit.c	2006-10-13 09:22:44.000000000 -0400
+++ LVM2/tools/vgsplit.c	2007-01-08 13:05:37.000000000 -0500
@@ -84,8 +84,8 @@ static int _move_lvs(struct volume_group
 				pv = seg_pv(seg, s);
 				if (vg_with) {
 					if (!pv_is_in_vg(vg_with, pv)) {
-						log_error("Logical Volume %s "
-							  "split between "
+						log_error("Can't split Logical "
+							  "Volume %s between 2 "
 							  "Volume Groups",
 							  lv->name);
 						return 0;
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-01-08 16:25:40.000000000 -0500
+++ LVM2/WHATS_NEW	2007-01-08 16:25:47.000000000 -0500
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix misleading vgsplit error message when LV is part of PV not on cmdline.
   Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
   Fix create mirror with name longer than 22 chars.
   Fix some activate.c prototypes when compiled without devmapper.



