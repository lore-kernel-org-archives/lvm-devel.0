From: Chris Webb <chris@arachsys.com>
Date: Thu, 12 Jun 2008 13:21:21 +0100
Subject: [PATCH] Enable --force option for lvresize
Message-ID: <20080612122121.GG2361@arachsys.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I use lvresize in a script and want to be able to disable the yes/no prompt
when a logical volume is reduced in size. The yes_no prompt is already
guarded by 'if (!arg_count(cmd, force_ARG))' in lvresize.c, but the --force
argument isn't included for lvresize in tools/commands.h so it can't be
specified. This tiny patch fixes that.

Cheers,

Chris.
-------------- next part --------------
diff -uNr LVM2.2.02.38/tools/commands.h LVM2.2.02.38+lvresizeforce/tools/commands.h
--- LVM2.2.02.38/tools/commands.h	2008-06-06 20:28:35.000000000 +0100
+++ LVM2.2.02.38+lvresizeforce/tools/commands.h	2008-06-12 12:01:44.000000000 +0100
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
+   alloc_ARG, autobackup_ARG, force_ARG, extents_ARG, mirrors_ARG,
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
