From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Oct 2009 15:43:07 -0400
Subject: [PATCH] Add --pvmetadatacopies as a synonym for --metadatacopies in various commands.
In-Reply-To: <1254697907-16448-11-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1254771787-22813-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Going forward, we would like to allow users to specify the total
number of metadatacopies in a VG rather than on a per-PV basis.  In
order to facilitate that, introduce --pvmetadatacopes to replace
--metadatacopies everywhere.  We still allow --metadatacopies everywhere,
but eventually we will introduce --vgmetadatacopies.  Once we do that,
we should either deprecate --metadatacopies or make it a synonym based
on the command (pvmetadatacopies for pv commands, and vgmetadatacopies
for vg commands).  The latter option would likely just require a simple
'strncpy' check against cmd->command->name to qualify the merge_synonym
call.

Update nightly tests to cover the pvmetadatacopies synonym.

Note that this patch is the result of an eariler review comment for
the implicit pvcreate patches.  Should apply cleanly on top of the
implicit pvcreate patches (I applied after patch 10/10 in that series).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/pvcreate.8.in        |    4 ++--
 man/vgchange.8.in        |    2 +-
 man/vgconvert.8.in       |    2 +-
 man/vgcreate.8.in        |    4 ++--
 man/vgextend.8.in        |    2 +-
 test/t-pvcreate-usage.sh |   15 +++++++++------
 test/t-vgcreate-usage.sh |    7 +++++--
 test/t-vgextend-usage.sh |    5 ++++-
 tools/args.h             |    1 +
 tools/commands.h         |   18 ++++++++++--------
 tools/lvmcmdline.c       |    3 ++-
 tools/toollib.c          |    8 ++++----
 12 files changed, 42 insertions(+), 29 deletions(-)

diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 2f214e3..cef9b3d 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -11,7 +11,7 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
 .RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-pvmetadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
 .RB [ \-\-dataalignmentoffset alignment_offset ]
@@ -105,7 +105,7 @@ use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
 .BR \-\-dataalignmentoffset " alignment_offset"
 Shift the start of the data area by this additional \fBalignment_offset\fP.
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-pvmetadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
 this can be 0, 1 or 2.  
 If set to 2, two copies of the volume group metadata 
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index c2b09ba..bacb3b4 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -113,7 +113,7 @@ removes this restriction: there is then no limit.
 If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format,
 for tool performance reasons, you should consider
-some use of \fB--metadatacopies 0\fP
+some use of \fB--pvmetadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
index f5353a0..14e95f4 100644
--- a/man/vgconvert.8.in
+++ b/man/vgconvert.8.in
@@ -9,7 +9,7 @@ vgconvert \- convert volume group metadata format
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
 .RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-pvmetadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-version ]
 .IR VolumeGroupName " [" VolumeGroupName ...]
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index f00afcf..1a4e772 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -71,7 +71,7 @@ which removes this restriction: there is then no limit.
 If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format, 
 for tool performance reasons, you should consider 
-some use of \fB--metadatacopies 0\fP
+some use of \fB--pvmetadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
@@ -108,7 +108,7 @@ volume group.  These options are further described in the pvcreate man page.
 .TP
 .BR \-\-metadatasize " size"
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-pvmetadatacopies " copies"
 .TP
 .BR \-\-dataalignment " alignment"
 .TP
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 9cfc631..7f34b96 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -42,7 +42,7 @@ volume group.  These options are further described in the pvcreate man page.
 .TP
 .BR \-\-metadatasize " size"
 .TP
-.BR \-\-metadatacopies " copies"
+.BR \-\-pvmetadatacopies " copies"
 .TP
 .BR \-\-dataalignment " alignment"
 .TP
diff --git a/test/t-pvcreate-usage.sh b/test/t-pvcreate-usage.sh
index a61d5cd..01f13db 100755
--- a/test/t-pvcreate-usage.sh
+++ b/test/t-pvcreate-usage.sh
@@ -46,15 +46,18 @@ vgremove -ff $vg
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
diff --git a/test/t-vgcreate-usage.sh b/test/t-vgcreate-usage.sh
index fb9904d..d6ae531 100755
--- a/test/t-vgcreate-usage.sh
+++ b/test/t-vgcreate-usage.sh
@@ -105,14 +105,17 @@ do
     pvremove -f $dev1
 done
 
-# metadatacopies
+# metadatacopies, pvmetadatacopies
 for i in 1 2
 do
-    vgcreate --metadatacopies $i $vg $dev1
+for j in metadatacopies pvmetadatacopies
+do
+    vgcreate --$j $i $vg $dev1
     check_pv_field_ $dev1 pv_mda_count $i
     vgremove -f $vg
     pvremove -f $dev1
 done
+done
 not vgcreate --metadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
 vgcreate --metadatacopies 0 $vg $dev1 $dev2
diff --git a/test/t-vgextend-usage.sh b/test/t-vgextend-usage.sh
index b47cedd..7a148cf 100644
--- a/test/t-vgextend-usage.sh
+++ b/test/t-vgextend-usage.sh
@@ -54,11 +54,14 @@ done
 # metadatacopies
 for i in 0 1 2
 do
-    vgextend --metadatacopies $i $vg $dev1
+for j in metadatacopies pvmetadatacopies
+do
+    vgextend --$j $i $vg $dev1
     check_pv_field_ $dev1 pv_mda_count $i
     vgreduce $vg $dev1
     pvremove -f $dev1
 done
+done
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
diff --git a/tools/args.h b/tools/args.h
index 1204683..3f8cda5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -23,6 +23,7 @@ arg(quiet_ARG, '\0', "quiet", NULL, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
+arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 728ebd5..b54809b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -479,7 +479,7 @@ xx(pvcreate,
    "\t[-h|-?|--help] " "\n"
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--metadatacopies #copies]" "\n"
+   "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
@@ -493,8 +493,9 @@ xx(pvcreate,
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
-   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, metadatasize_ARG,
-   physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
+   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
+   metadatasize_ARG, physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG,
+   yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
@@ -727,7 +728,7 @@ xx(vgconvert,
    "\t[-h|--help] " "\n"
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--metadatacopies #copies]" "\n"
+   "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -735,7 +736,7 @@ xx(vgconvert,
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   metadatasize_ARG )
+   pvmetadatacopies_ARG, metadatasize_ARG )
 
 xx(vgcreate,
    "Create a volume group",
@@ -760,7 +761,8 @@ xx(vgcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   metadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
+   pvmetadatacopies_ARG, metadatacopies_ARG, dataalignment_ARG,
+   dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -826,8 +828,8 @@ xx(vgextend,
 
    autobackup_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
-   metadatasize_ARG, metadatacopies_ARG, dataalignment_ARG,
-   dataalignmentoffset_ARG)
+   metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 80c1a46..31ebd12 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -837,7 +837,8 @@ static int _get_settings(struct cmd_context *cmd)
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
-	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
+	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG))
 		return EINVALID_CMD_LINE;
 
 	/* Zero indicates success */
diff --git a/tools/toollib.c b/tools/toollib.c
index 9211576..c48314f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1305,7 +1305,7 @@ int pvcreate_validate_params(struct cmd_context *cmd,
 	}
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, metadatacopies_ARG) ||
+	    (arg_count(cmd, pvmetadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG)   ||
 	     arg_count(cmd, dataalignment_ARG)  ||
 	     arg_count(cmd, dataalignmentoffset_ARG))) {
@@ -1314,8 +1314,8 @@ int pvcreate_validate_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG) &&
-	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
+	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return 0;
 	}
@@ -1371,7 +1371,7 @@ int pvcreate_validate_params(struct cmd_context *cmd,
 						 "metadata/pvmetadatasize",
 						 DEFAULT_PVMETADATASIZE);
 
-	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
+	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 	if (pp->pvmetadatacopies < 0)
 		pp->pvmetadatacopies = find_config_tree_int(cmd,
 						   "metadata/pvmetadatacopies",
-- 
1.6.0.6


