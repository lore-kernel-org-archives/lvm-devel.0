From: Dave Wysochanski <dave.wysochanski@redhat.com>
Date: Mon, 08 Jan 2007 16:44:48 -0500
Subject: [LVM2 PATCH] Fix lvextend man pg minor error
Message-ID: <1168292688.4239.28.camel@linux-cxyg.rtp.netapp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix typo in lvextend man page.

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-01-08 16:25:47.000000000 -0500
+++ LVM2/WHATS_NEW	2007-01-08 16:30:40.000000000 -0500
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix typeo in lvextend man pg.
   Fix misleading vgsplit error message when LV is part of PV not on cmdline.
   Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
   Fix create mirror with name longer than 22 chars.
Index: LVM2/man/lvextend.8
===================================================================
--- LVM2.orig/man/lvextend.8	2006-11-10 13:24:11.000000000 -0500
+++ LVM2/man/lvextend.8	2007-01-08 16:30:20.000000000 -0500
@@ -31,7 +31,7 @@ size of the Logical Volume with the suff
 free space in the Volume Group with the suffix %FREE.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
-Extend or set the logical volume size in units in units of megabytes.
+Extend or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
 or E for exabytes is optional.



