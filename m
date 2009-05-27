From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 27 May 2009 14:45:12 +0200
Subject: [PATCH] Udev integration: Provide --noudevwait option for LVM commands
Message-ID: <4A1D35D8.50508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds --noudevwait option for LVM commands (only the
ones where it has a meaning -- where there are uevents generated,
so the udev rules will apply). This way we can disable the wait
for the notification.

(The "else" part with dm_udev_notif_enable() call is needed
because of the LVM shell -- we keep the enable/disable flag
as global var)

The option is added for these commands:
lvchange, lvconvert, lvcreate, lvextend/lvreduce/lvresize, lvremove,
lvrename, pvmove, vgchange and vgremove

Peter

diff --git a/tools/args.h b/tools/args.h
index c3f2332..11b1175 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -59,6 +59,7 @@ arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
+arg(noudevwait_ARG, '\0', "noudevwait", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 1849528..bf0cd89 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -72,6 +72,7 @@ xx(lvchange,
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--noudevwait]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
@@ -86,8 +87,9 @@ xx(lvchange,
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   monitor_ARG, partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
+   monitor_ARG, noudevwait_ARG, partial_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
+   yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -101,6 +103,7 @@ xx(lvconvert,
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--noudevwait]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
@@ -110,14 +113,15 @@ xx(lvconvert,
    "\t[-c|--chunksize]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--noudevwait]\n"
    "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, snapshot_ARG,
-   test_ARG, zero_ARG)
+   mirrorlog_ARG, mirrors_ARG, noudevwait_ARG, regionsize_ARG, repair_ARG,
+   snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -135,6 +139,7 @@ xx(lvcreate,
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
+   "\t[--noudevwait]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
@@ -158,6 +163,7 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
+   "\t[--noudevwait]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
@@ -169,9 +175,9 @@ xx(lvcreate,
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, virtualoriginsize_ARG, zero_ARG)
+   name_ARG, nosync_ARG, noudevwait_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -228,6 +234,7 @@ xx(lvextend,
    "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevwait]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -236,8 +243,8 @@ xx(lvextend,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG)
+   nofsck_ARG, noudevwait_ARG, resizefs_ARG, size_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, type_ARG)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
@@ -297,6 +304,7 @@ xx(lvreduce,
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
    "\t -L|--size [-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevwait]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -304,8 +312,8 @@ xx(lvreduce,
    "\t[--version]" "\n"
    "\tLogicalVolume[Path]\n",
 
-   autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, resizefs_ARG,
-   size_ARG, test_ARG, yes_ARG)
+   autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, noudevwait_ARG,
+   resizefs_ARG, size_ARG, test_ARG, yes_ARG)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
@@ -315,12 +323,13 @@ xx(lvremove,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--noudevwait]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, test_ARG)
+   autobackup_ARG, force_ARG, noudevwait_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
@@ -329,13 +338,14 @@ xx(lvrename,
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"
+   "\t[--noudevwait]\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\t{ OldLogicalVolumePath NewLogicalVolumePath |" "\n"
    "\t  VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName }\n",
 
-   autobackup_ARG, test_ARG)
+   autobackup_ARG, noudevwait_ARG, test_ARG)
 
 xx(lvresize,
    "Resize a logical volume",
@@ -350,6 +360,7 @@ xx(lvresize,
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevwait]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -358,8 +369,8 @@ xx(lvresize,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
-   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG, test_ARG,
-   type_ARG)
+   noudevwait_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG)
 
 xx(lvs,
    "Display information about logical volumes",
@@ -547,6 +558,7 @@ xx(pvmove,
    "\t[-d|--debug]\n "
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--noudevwait]\n"
    "\t[-t|--test]\n "
    "\t[-v|--verbose]\n "
    "\t[--version]\n"
@@ -556,7 +568,7 @@ xx(pvmove,
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
    abort_ARG, alloc_ARG, autobackup_ARG, background_ARG,
-   interval_ARG, name_ARG, test_ARG)
+   interval_ARG, name_ARG, noudevwait_ARG, test_ARG)
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
@@ -670,6 +682,7 @@ xx(vgchange,
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--noudevwait]\n"
    "\t[--refresh]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
@@ -687,9 +700,9 @@ xx(vgchange,
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
-   physicalextentsize_ARG, refresh_ARG, resizeable_ARG, resizable_ARG,
-   test_ARG, uuid_ARG)
+   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevwait_ARG,
+   partial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -875,12 +888,13 @@ xx(vgremove,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--noudevwait]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, test_ARG)
+   force_ARG, noudevwait_ARG, test_ARG)
 
 xx(vgrename,
    "Rename a volume group",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4a314a3..6795cf6 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -725,6 +725,11 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
 			       &lvchange_single);
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f1186cf..42bb751 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -228,6 +228,11 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (!_lvconvert_name_params(lp, cmd, &argc, &argv))
 		return_0;
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	lp->pv_count = argc;
 	lp->pvs = argv;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 67d065c..37012e0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -607,6 +607,11 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	struct lvinfo info;
 	uint32_t pv_extent_count;
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 712f175..33e2fa1 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -41,6 +41,11 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->handles_missing_pvs = 1;
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
 			       &lvremove_single);
 }
diff --git a/tools/lvrename.c b/tools/lvrename.c
index fae82c3..73a232f 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -113,6 +113,11 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		goto error;
 	}
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	if (!lv_rename(cmd, lvl->lv, lv_name_new))
 		goto error;
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 420e570..ee78bcc 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -200,6 +200,11 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!strcmp(cmd_name, "lvextend"))
 		lp->resize = LV_EXTEND;
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	/*
 	 * Allow omission of extents and size if the user has given us
 	 * one or more PVs.  Most likely, the intent was "resize this
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9ece646..30cdc4c 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -370,6 +370,11 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	argc--;
 	argv++;
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	/* Find PV (in VG) */
 	if (!(pv = find_pv_by_name(cmd, pv_name))) {
 		stack;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 84cbf1a..dc2b9b5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -631,6 +631,11 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
 			       LCK_VG_READ : LCK_VG_WRITE, 0, NULL,
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 38f9ee3..7f0c69e 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -40,6 +40,11 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, noudevwait_ARG))
+		dm_udev_notif_disable();
+	else
+		dm_udev_notif_enable();
+
 	ret = process_each_vg(cmd, argc, argv,
 			      LCK_VG_WRITE, 1,
 			      NULL, &vgremove_single);


