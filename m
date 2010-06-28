From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:37:37 -0000
Subject: LVM2/tools args.h commands.h vgchange.c
Message-ID: <20100628203737.18559.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:37:37

Modified files:
	tools          : args.h commands.h vgchange.c 

Log message:
	Update vgchange tool to accept --vgmetadatacopies.
	
	Update logic in vgchange to handle --vgmetadatacopies, allow
	--metadatacopies as a synonym to --vgmetadatacopies,
	and add these parameters to args.h and commands.h
	Forbit both --vgmetadatacopies and --metadatacopies as only
	one allowed.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/tools/args.h	2010/06/28 20:33:58	1.75
+++ LVM2/tools/args.h	2010/06/28 20:37:37	1.76
@@ -23,6 +23,7 @@
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/06/28 20:33:58	1.147
+++ LVM2/tools/commands.h	2010/06/28 20:37:37	1.148
@@ -710,6 +710,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
@@ -731,7 +732,8 @@
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
+   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
+   physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
--- LVM2/tools/vgchange.c	2010/06/23 10:22:59	1.105
+++ LVM2/tools/vgchange.c	2010/06/28 20:37:37	1.106
@@ -525,6 +525,45 @@
 	return ECMD_PROCESSED;
 }
 
+static int _vgchange_metadata_copies(struct cmd_context *cmd,
+				     struct volume_group *vg)
+{
+	uint32_t mda_copies;
+
+	if (arg_count(cmd, vgmetadatacopies_ARG))
+		mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG,
+			DEFAULT_VGMETADATACOPIES);
+	else if (arg_count(cmd, metadatacopies_ARG))
+		mda_copies = arg_uint_value(cmd, metadatacopies_ARG,
+			DEFAULT_VGMETADATACOPIES);
+	if (mda_copies == vg_mda_copies(vg)) {
+		log_error("Metadata copies of VG %s is already %u",
+			  vg->name, mda_copies);
+		return ECMD_PROCESSED;
+	}
+
+	if (!archive(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (!vg_set_mda_copies(vg, mda_copies)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	backup(vg);
+
+	log_print("Volume group \"%s\" successfully changed", vg->name);
+
+	return ECMD_PROCESSED;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
@@ -593,6 +632,10 @@
 	else if (arg_count(cmd, refresh_ARG))
 		r = _vgchange_refresh(cmd, vg);
 
+	else if (arg_count(cmd, vgmetadatacopies_ARG) ||
+		 arg_count(cmd, metadatacopies_ARG))
+		r = _vgchange_metadata_copies(cmd, vg);
+
 	return r;
 }
 
@@ -606,10 +649,12 @@
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
 	     arg_count(cmd, monitor_ARG) + arg_count(cmd, poll_ARG) +
-	     arg_count(cmd, refresh_ARG))) {
+	     arg_count(cmd, refresh_ARG) + arg_count(cmd, metadatacopies_ARG) +
+	     arg_count(cmd, vgmetadatacopies_ARG))) {
 		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
 			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
-			  "--monitor or --poll");
+			  "--monitor, --poll, --vgmetadatacopies or "
+			  "--metadatacopies");
 		return EINVALID_CMD_LINE;
 	}
 


