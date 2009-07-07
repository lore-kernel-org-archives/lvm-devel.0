From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 18:26:58 +0100
Subject: RFC: lvcreate -s --pivotorigin
Message-ID: <20090707172658.GF11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Not fully debugged yet, but putting this out for debate.

(Particularly interested in regressions from the activate.c change,
or cases where the activation rules - such as snapshot can't
be loaded in two devices concurrently - are broken.)

When creating a snapshot of an LV with a mounted filesystem on it,
it swaps the snapshot and origin so the existing mounted
device becomes the snapshot (and the origin is no longer mounted).

Alasdair

Index: lib/activate/activate.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/activate/activate.c,v
retrieving revision 1.153
diff -u -r1.153 activate.c
--- lib/activate/activate.c	1 Jun 2009 12:43:32 -0000	1.153
+++ lib/activate/activate.c	7 Jul 2009 17:14:43 -0000
@@ -899,6 +899,12 @@
 		goto out;
 	}
 
+	if (!_lv_suspend_lv(lv_pre, lockfs, flush_required)) {
+		memlock_dec();
+		fs_unlock();
+		goto out;
+	}
+
 	r = 1;
 out:
 	if (lv_pre)
Index: man/lvcreate.8.in
===================================================================
RCS file: /cvs/lvm2/LVM2/man/lvcreate.8.in,v
retrieving revision 1.8
diff -u -r1.8 lvcreate.8.in
--- man/lvcreate.8.in	6 Jul 2009 19:13:26 -0000	1.8
+++ man/lvcreate.8.in	7 Jul 2009 17:14:44 -0000
@@ -26,7 +26,7 @@
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 \-n|\-\-name SnapshotLogicalVolumeName
-{{\-s|\-\-snapshot}
+{{\-s|\-\-snapshot} [--pivotorigin]
 OriginalLogicalVolumePath | 
 [\-s|\-\-snapshot]
 VolumeGroupName \-\-virtualsize VirtualSize}
@@ -122,6 +122,10 @@
 .br
 Default is read and write.
 .TP
+.I \-\-pivotorigin
+When creating a snapshot with --snapshot, exchange the resulting
+snapshot and origin logical volumes.  
+.TP
 .I \-r, \-\-readahead ReadAheadSectors|auto|none
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
Index: tools/args.h
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/args.h,v
retrieving revision 1.65
diff -u -r1.65 args.h
--- tools/args.h	4 Jun 2009 12:01:16 -0000	1.65
+++ tools/args.h	7 Jul 2009 17:14:45 -0000
@@ -61,6 +61,7 @@
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
+arg(pivotorigin_ARG, '\0', "pivotorigin", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: tools/commands.h
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/commands.h,v
retrieving revision 1.129
diff -u -r1.129 commands.h
--- tools/commands.h	6 Jul 2009 19:13:26 -0000	1.129
+++ tools/commands.h	7 Jul 2009 17:14:45 -0000
@@ -148,7 +148,7 @@
    "\tVolumeGroupName [PhysicalVolumePath...]\n\n"
 
    "lvcreate \n"
-   "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
+   "\t{ {-s|--snapshot} [--pivotorigin] OriginalLogicalVolume[Path] |\n"
    "\t  [-s|--snapshot] VolumeGroupName[Path] --virtualsize VirtualSize}\n"
    "\t[-c|--chunksize]\n"
    "\t[-A|--autobackup {y|n}]\n"
@@ -172,9 +172,10 @@
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
+   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, pivotorigin_ARG,
+   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
+   zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
Index: tools/lvcreate.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/lvcreate.c,v
retrieving revision 1.198
diff -u -r1.198 lvcreate.c
--- tools/lvcreate.c	7 Jul 2009 01:18:35 -0000	1.198
+++ tools/lvcreate.c	7 Jul 2009 17:14:47 -0000
@@ -402,11 +402,23 @@
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
+		if (arg_count(cmd, pivotorigin_ARG) &&
+		    arg_count(cmd, virtualsize_ARG)) {
+			log_error("Only one of --pivotorigin and --virtualsize "
+				  "may be used at once.");
+			return 0;
+		}
 	} else {
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("-c is only available with snapshots");
 			return 0;
 		}
+
+		if (arg_count(cmd, pivotorigin_ARG)) {
+			log_error("--pivotorigin is only available "
+				  "with snapshots");
+			return 0;
+		}
 	}
 
 	if (lp->mirrors > 1) {
@@ -593,6 +605,24 @@
 	return lv;
 }
 
+static void _exchange_origin_and_snapshot(struct logical_volume *origin,
+					  struct logical_volume *snap)
+{
+	union lvid lvid_tmp;
+	char *lvname_tmp;
+
+	log_verbose("Exchanging origin %s with snapshot %s",
+		    origin->name, snap->name);
+
+	lvid_tmp = origin->lvid;
+	origin->lvid = snap->lvid;
+	snap->lvid = lvid_tmp;
+
+	lvname_tmp = origin->name;
+	origin->name = snap->name;
+	snap->name = lvname_tmp;
+}
+
 static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
@@ -934,6 +964,12 @@
 			goto deactivate_and_revert_new_lv;
 		}
 
+		/*
+		 * Move mounted origin to writeable snapshot?
+		 */
+		if (arg_count(cmd, pivotorigin_ARG))
+			_exchange_origin_and_snapshot(org, lv);
+
 		/* store vg on disk(s) */
 		if (!vg_write(vg))
 			return_0;
@@ -955,7 +991,8 @@
 	/* FIXME out of sequence */
 	backup(vg);
 
-	log_print("Logical volume \"%s\" created", lv->name);
+	log_print("Logical volume \"%s\" created",
+		  arg_count(cmd, pivotorigin_ARG) ? org->name : lv->name);
 
 	/*
 	 * FIXME: as a sanity check we could try reading the


