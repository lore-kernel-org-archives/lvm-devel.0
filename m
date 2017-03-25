From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 24 Mar 2017 22:43:21 -0400
Subject: master - man: a few more missed '-' to escape
Message-ID: <201703250243.v2P2hLej004774@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c199d99f4dc9911d62673baba7643ea649ffe64
Commit:        5c199d99f4dc9911d62673baba7643ea649ffe64
Parent:        66b2084b96271350b840e492e9ea54b1e7eb2f01
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Mar 25 03:40:02 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Mar 25 03:40:02 2017 +0100

man: a few more missed '-' to escape

---
 tools/args.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 24d3037..77f3bf5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -92,7 +92,7 @@ arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0,
     "and \\-\\-dataalignmentoffset. The bootloader area size may eventually\n"
     "end up increased due to the alignment, but it's never less than the\n"
     "size that is requested. To see the bootloader area start and size of\n"
-    "an existing PV use pvs -o +pv_ba_start,pv_ba_size.\n")
+    "an existing PV use pvs \\-o +pv_ba_start,pv_ba_size.\n")
 
 arg(cache_long_ARG, '\0', "cache", 0, 0, 0,
     "#pvscan\n"
@@ -141,7 +141,7 @@ arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Align the start of the data to a multiple of this number.\n"
     "Also specify an appropriate Physical Extent size when creating a VG.\n"
     "To see the location of the first Physical Extent of an existing PV,\n"
-    "use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.\n"
+    "use pvs \\-o +pe_start. In addition, it may be shifted by an alignment offset.\n"
     "See lvm.conf/data_alignment_offset_detection and \\-\\-dataalignmentoffset.\n")
 
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
@@ -222,7 +222,7 @@ arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0,
 arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
     "By default the PV is labelled with an LVM2 identifier in its second\n"
     "sector (sector 1). This lets you use a different sector near the\n"
-    "start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS\n"
+    "start of the disk (between 0 and 3 inclusive \\- see LABEL_SCAN_SECTORS\n"
     "in the source). Use with care.\n")
 
 arg(lockopt_ARG, '\0', "lockopt", string_VAL, 0, 0,
@@ -387,8 +387,8 @@ arg(nosync_ARG, '\0', "nosync", 0, 0, 0,
     "and thus do not support initial synchronization.\n")
 
 arg(notifydbus_ARG, '\0', "notifydbus", 0, 0, 0,
-    "Send a notification to D-Bus. The command will exit with an error\n"
-    "if LVM is not built with support for D-Bus notification, or if the\n"
+    "Send a notification to D\\-Bus. The command will exit with an error\n"
+    "if LVM is not built with support for D\\offsetus notification, or if the\n"
     "notify_dbus config setting is disabled.\n")
 
 arg(noudevsync_ARG, '\0', "noudevsync", 0, 0, 0,
@@ -1063,7 +1063,7 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
     "List metadata backup and archive files pertaining to the VG.\n"
     "May be used with \\-\\-file. Does not restore the VG.\n"
     "#vgmerge\n"
-    "Display merged destination VG like vgdisplay -v.\n")
+    "Display merged destination VG like vgdisplay \\-v.\n")
 
 arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
@@ -1116,7 +1116,7 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
     "#lvdisplay\n"
     "Display the mapping of logical extents to PVs and physical extents.\n"
     "To map physical extents to logical extents use:\n"
-    "pvs \\-\\-segments -o+lv_name,seg_start_pe,segtype\n"
+    "pvs \\-\\-segments \\-o+lv_name,seg_start_pe,segtype\n"
     "#pvdisplay\n"
     "Display the mapping of physical extents to LVs and logical extents.\n")
 
@@ -1188,7 +1188,7 @@ arg(oldpath_ARG, 'n', "oldpath", 0, 0, 0, NULL)
 /*
  * FIXME: a free-form discussion section and document the
  * VG/LV/PV attr bits which were previously listed
- * in the description for -o.
+ * in the description for \\-o.
  */
 
 arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
@@ -1198,8 +1198,8 @@ arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "\\fB-\\fP will remove the specified fields from the default fields, and\n"
     "\\fB#\\fP will compact specified fields (removing them when empty for all rows.)\n"
     "Use \\fB-o help\\fP to view the list of all available fields.\n"
-    "Use separate lists of fields to add, remove or compact by repeating the -o option:\n"
-    "-o+field1,field2 -o-field3,field4 -o#field5.\n"
+    "Use separate lists of fields to add, remove or compact by repeating the \\-o option:\n"
+    "-o+field1,field2 \\-o-field3,field4 \\-o#field5.\n"
     "These lists are evaluated from left to right.\n"
     "Use field name \\fBlv_all\\fP to view all LV fields,\n"
     "\\fBvg_all\\fP all VG fields,\n"
@@ -1369,7 +1369,7 @@ arg(volumegroup_ARG, 'V', "volumegroup", 0, 0, 0, NULL)
 arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
     "The virtual size of a new thin LV.\n"
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n"
-    "Using virtual size (-V) and actual size (-L) together creates\n"
+    "Using virtual size (\\-V) and actual size (\\-L) together creates\n"
     "a sparse LV.\n"
     "lvm.conf global/sparse_segtype_default determines the\n"
     "default segment type used to create a sparse LV.\n"
@@ -1389,7 +1389,7 @@ arg(wipesignatures_ARG, 'W', "wipesignatures", bool_VAL, 0, 0,
     "lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.\n"
     "If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)\n"
     "and LVM is compiled with blkid wiping support, then the blkid(8)\n"
-    "library is used to detect the signatures (use blkid -k to list the\n"
+    "library is used to detect the signatures (use blkid \\-k to list the\n"
     "signatures that are recognized).\n"
     "Otherwise, native LVM code is used to detect signatures\n"
     "(only MD RAID, swap and LUKS signatures are detected in this case.)\n"
@@ -1405,7 +1405,7 @@ arg(resizeable_ARG, 'x', "resizeable", bool_VAL, 0, 0,
 arg(yes_ARG, 'y', "yes", 0, 0, 0,
     "Do not prompt for confirmation interactively but always assume the\n"
     "answer yes. Use with extreme caution.\n"
-    "(For automatic no, see -qq.)\n")
+    "(For automatic no, see \\-qq.)\n")
 
 arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#lvchange\n"


