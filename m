From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:55:59 -0000
Subject: LVM2 ./WHATS_NEW man/pvcreate.8.in man/vgchang ...
Message-ID: <20091005205559.12017.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:55:57

Modified files:
	.              : WHATS_NEW 
	man            : pvcreate.8.in vgchange.8.in vgconvert.8.in 
	                 vgcreate.8.in vgextend.8.in 
	test           : t-pvcreate-usage.sh t-vgcreate-usage.sh 
	                 t-vgextend-usage.sh 
	tools          : args.h commands.h lvmcmdline.c toollib.c 
	                 vgconvert.c vgcreate.c vgextend.c 

Log message:
	Add --pvmetadatacopies as a synonym for --metadatacopies in various commands.
	
	Going forward, we would like to allow users to specify the total
	number of metadatacopies in a VG rather than on a per-PV basis.  In
	order to facilitate that, introduce --pvmetadatacopes to replace
	--metadatacopies everywhere.  We still allow --metadatacopies for
	pv commands, but require --pvmetadatacopies for vg commands.
	Eventually we will introduce --vgmetadatacopies.  Once we do that,
	we should either deprecate --metadatacopies or make it a synonym based
	on the command (pvmetadatacopies for pv commands, and vgmetadatacopies
	for vg commands).  The latter option would likely just require a simple
	'strncpy' check against cmd->command->name to qualify the merge_synonym
	call.
	
	Update nightly tests to cover the pvmetadatacopies synonym.
	
	Note that this patch is the result of an eariler review comment for
	the implicit pvcreate patches.  Should apply cleanly on top of the
	implicit pvcreate patches (I applied after patch 10/10 in that series).
	
	NOTE: This patch will require --pvmetadatacopies for vgconvert as
	--metadatacopies is no longer accepted.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1291&r2=1.1292
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgconvert.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2009/10/05 20:04:40	1.1291
+++ LVM2/WHATS_NEW	2009/10/05 20:55:56	1.1292
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Add --pvmetadatacopies for pvcreate, vgcreate, vgextend, vgconvert.
   Add implict pvcreate support to vgcreate and vgextend.
   Correct example.conf to indicate that lvm2 not lvm1 is the default format.
   Remove an unused stray LVM1_SUPPORT ifdef.
--- LVM2/man/pvcreate.8.in	2009/07/30 17:45:29	1.4
+++ LVM2/man/pvcreate.8.in	2009/10/05 20:55:57	1.5
@@ -11,7 +11,7 @@
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
 .RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-[pv]metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
 .RB [ \-\-dataalignmentoffset alignment_offset ]
@@ -105,7 +105,7 @@
 .BR \-\-dataalignmentoffset " alignment_offset"
 Shift the start of the data area by this additional \fBalignment_offset\fP.
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-[pv]metadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
 this can be 0, 1 or 2.  
 If set to 2, two copies of the volume group metadata 
--- LVM2/man/vgchange.8.in	2009/08/04 08:09:52	1.4
+++ LVM2/man/vgchange.8.in	2009/10/05 20:55:57	1.5
@@ -113,7 +113,7 @@
 If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format,
 for tool performance reasons, you should consider
-some use of \fB--metadatacopies 0\fP
+some use of \fB--pvmetadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
--- LVM2/man/vgconvert.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgconvert.8.in	2009/10/05 20:55:57	1.2
@@ -9,7 +9,7 @@
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
 .RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-pvmetadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-version ]
 .IR VolumeGroupName " [" VolumeGroupName ...]
--- LVM2/man/vgcreate.8.in	2009/10/05 20:04:21	1.4
+++ LVM2/man/vgcreate.8.in	2009/10/05 20:55:57	1.5
@@ -71,7 +71,7 @@
 If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format, 
 for tool performance reasons, you should consider 
-some use of \fB--metadatacopies 0\fP
+some use of \fB--pvmetadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
@@ -108,7 +108,7 @@
 .TP
 .BR \-\-metadatasize " size"
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-pvmetadatacopies " copies"
 .TP
 .BR \-\-dataalignment " alignment"
 .TP
--- LVM2/man/vgextend.8.in	2009/10/05 20:04:21	1.3
+++ LVM2/man/vgextend.8.in	2009/10/05 20:55:57	1.4
@@ -42,7 +42,7 @@
 .TP
 .BR \-\-metadatasize " size"
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-pvmetadatacopies " copies"
 .TP
 .BR \-\-dataalignment " alignment"
 .TP
--- LVM2/test/t-pvcreate-usage.sh	2009/09/30 16:13:53	1.13
+++ LVM2/test/t-pvcreate-usage.sh	2009/10/05 20:55:57	1.14
@@ -46,15 +46,18 @@
 not pvcreate --metadatacopies -1 $dev1
 
 #COMM 'pvcreate accepts metadatacopies = 0, 1, 2'
-pvcreate --metadatacopies 0 $dev1 
-pvcreate --metadatacopies 1 $dev2 
-pvcreate --metadatacopies 2 $dev3 
-check_pv_field_ $dev1 pv_mda_count 0 
-check_pv_field_ $dev2 pv_mda_count 1 
-check_pv_field_ $dev3 pv_mda_count 2 
+for j in metadatacopies pvmetadatacopies
+do
+pvcreate --$j 0 $dev1
+pvcreate --$j 1 $dev2
+pvcreate --$j 2 $dev3
+check_pv_field_ $dev1 pv_mda_count 0
+check_pv_field_ $dev2 pv_mda_count 1
+check_pv_field_ $dev3 pv_mda_count 2
 pvremove $dev1 
 pvremove $dev2 
 pvremove $dev3
+done
 
 #COMM 'pvcreate rejects metadatacopies > 2'
 not pvcreate --metadatacopies 3 $dev1
--- LVM2/test/t-vgcreate-usage.sh	2009/10/05 20:04:40	1.11
+++ LVM2/test/t-vgcreate-usage.sh	2009/10/05 20:55:57	1.12
@@ -105,17 +105,17 @@
     pvremove -f $dev1
 done
 
-# metadatacopies
+# pvmetadatacopies
 for i in 1 2
 do
-    vgcreate --metadatacopies $i $vg $dev1
+    vgcreate --pvmetadatacopies $i $vg $dev1
     check_pv_field_ $dev1 pv_mda_count $i
     vgremove -f $vg
     pvremove -f $dev1
 done
 not vgcreate --metadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
-vgcreate --metadatacopies 0 $vg $dev1 $dev2
+vgcreate --pvmetadatacopies 0 $vg $dev1 $dev2
 check_pv_field_ $dev1 pv_mda_count 0
 check_pv_field_ $dev2 pv_mda_count 1
 vgremove -f $vg
--- LVM2/test/t-vgextend-usage.sh	2009/10/05 20:53:41	1.1
+++ LVM2/test/t-vgextend-usage.sh	2009/10/05 20:55:57	1.2
@@ -51,10 +51,10 @@
     pvremove -f $dev1
 done
 
-# metadatacopies
+# pvmetadatacopies
 for i in 0 1 2
 do
-    vgextend --metadatacopies $i $vg $dev1
+    vgextend --pvmetadatacopies $i $vg $dev1
     check_pv_field_ $dev1 pv_mda_count $i
     vgreduce $vg $dev1
     pvremove -f $dev1
--- LVM2/tools/args.h	2009/08/04 15:53:04	1.67
+++ LVM2/tools/args.h	2009/10/05 20:55:57	1.68
@@ -23,6 +23,7 @@
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
+arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
--- LVM2/tools/commands.h	2009/10/05 20:22:58	1.133
+++ LVM2/tools/commands.h	2009/10/05 20:55:57	1.134
@@ -479,7 +479,7 @@
    "\t[-h|-?|--help] " "\n"
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--metadatacopies #copies]" "\n"
+   "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
@@ -493,8 +493,9 @@
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
-   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, metadatasize_ARG,
-   physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
+   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
+   metadatasize_ARG, physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG,
+   yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
@@ -727,7 +728,7 @@
    "\t[-h|--help] " "\n"
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--metadatacopies #copies]" "\n"
+   "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -735,7 +736,7 @@
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   metadatasize_ARG )
+   pvmetadatacopies_ARG, metadatasize_ARG )
 
 xx(vgcreate,
    "Create a volume group",
@@ -760,7 +761,8 @@
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   metadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
+   pvmetadatacopies_ARG, metadatacopies_ARG, dataalignment_ARG,
+   dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -826,8 +828,8 @@
 
    autobackup_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
-   metadatasize_ARG, metadatacopies_ARG, dataalignment_ARG,
-   dataalignmentoffset_ARG)
+   metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
--- LVM2/tools/lvmcmdline.c	2009/09/14 22:47:49	1.106
+++ LVM2/tools/lvmcmdline.c	2009/10/05 20:55:57	1.107
@@ -837,7 +837,8 @@
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
-	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
+	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG))
 		return EINVALID_CMD_LINE;
 
 	/* Zero indicates success */
--- LVM2/tools/toollib.c	2009/10/05 20:03:54	1.173
+++ LVM2/tools/toollib.c	2009/10/05 20:55:57	1.174
@@ -1305,7 +1305,7 @@
 	}
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, metadatacopies_ARG) ||
+	    (arg_count(cmd, pvmetadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG)   ||
 	     arg_count(cmd, dataalignment_ARG)  ||
 	     arg_count(cmd, dataalignmentoffset_ARG))) {
@@ -1314,8 +1314,8 @@
 		return 0;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG) &&
-	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
+	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return 0;
 	}
@@ -1371,7 +1371,7 @@
 						 "metadata/pvmetadatasize",
 						 DEFAULT_PVMETADATASIZE);
 
-	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
+	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 	if (pp->pvmetadatacopies < 0)
 		pp->pvmetadatacopies = find_config_tree_int(cmd,
 						   "metadata/pvmetadatacopies",
--- LVM2/tools/vgconvert.c	2009/09/15 01:38:59	1.40
+++ LVM2/tools/vgconvert.c	2009/10/05 20:55:57	1.41
@@ -57,7 +57,7 @@
 					    "metadata/pvmetadatasize",
 					    DEFAULT_PVMETADATASIZE);
 
-		pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
+		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 		if (pvmetadatacopies < 0)
 			pvmetadatacopies =
 			    find_config_tree_int(cmd,
@@ -211,15 +211,20 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, metadatacopies_ARG)) {
+		log_error("Invalid option --metadatacopies, "
+			  "use --pvmetadatacopies instead.");
+		return EINVALID_CMD_LINE;
+	}
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, metadatacopies_ARG) ||
+	    (arg_count(cmd, pvmetadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG))) {
 		log_error("Metadata parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG) &&
-	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
+	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return EINVALID_CMD_LINE;
 	}
--- LVM2/tools/vgcreate.c	2009/10/05 20:04:08	1.69
+++ LVM2/tools/vgcreate.c	2009/10/05 20:55:57	1.70
@@ -35,6 +35,11 @@
 	argc--;
 	argv++;
 
+	if (arg_count(cmd, metadatacopies_ARG)) {
+		log_error("Invalid option --metadatacopies, "
+			  "use --pvmetadatacopies instead.");
+		return EINVALID_CMD_LINE;
+	}
 	fill_default_pvcreate_params(&pp);
 	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
--- LVM2/tools/vgextend.c	2009/10/05 20:04:08	1.53
+++ LVM2/tools/vgextend.c	2009/10/05 20:55:57	1.54
@@ -32,6 +32,11 @@
 	argc--;
 	argv++;
 
+	if (arg_count(cmd, metadatacopies_ARG)) {
+		log_error("Invalid option --metadatacopies, "
+			  "use --pvmetadatacopies instead.");
+		return EINVALID_CMD_LINE;
+	}
 	fill_default_pvcreate_params(&pp);
 	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;


