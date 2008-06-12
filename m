From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jun 2008 13:24:03 -0000
Subject: LVM2 ./WHATS_NEW tools/commands.h
Message-ID: <20080612132403.29874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-12 13:24:03

Modified files:
	.              : WHATS_NEW 
	tools          : commands.h 

Log message:
	Add --force to lvextend and lvresize.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.900&r2=1.901
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2008/06/12 11:49:45	1.900
+++ LVM2/WHATS_NEW	2008/06/12 13:24:02	1.901
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Add --force to lvextend and lvresize.
   Fix vgchange to not activate mirror leg and log volumes directly.
   Fix test directory clean up in make distclean.
  
--- LVM2/tools/commands.h	2008/06/06 19:28:35	1.115
+++ LVM2/tools/commands.h	2008/06/12 13:24:02	1.116
@@ -217,6 +217,7 @@
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
@@ -230,9 +231,9 @@
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
-   alloc_ARG, autobackup_ARG, extents_ARG, mirrors_ARG, nofsck_ARG,
-   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG, test_ARG,
-   type_ARG)
+   alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
+   nofsck_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
@@ -339,6 +340,7 @@
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
@@ -351,8 +353,9 @@
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
-   alloc_ARG, autobackup_ARG, extents_ARG, nofsck_ARG, resizefs_ARG,
-   size_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG)
+   alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
+   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG, test_ARG,
+   type_ARG)
 
 xx(lvs,
    "Display information about logical volumes",


