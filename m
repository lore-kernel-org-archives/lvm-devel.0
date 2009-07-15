From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 05:47:56 -0000
Subject: LVM2 lib/metadata/metadata.c test/t-partial-ac ...
Message-ID: <20090715054756.5199.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 05:47:55

Modified files:
	lib/metadata   : metadata.c 
	test           : t-partial-activate.sh 
	tools          : lvchange.c lvconvert.c vgchange.c vgreduce.c 

Log message:
	Refuse to open VG with MISSING_PVs for update unless handles_missing_pvs is set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.250&r2=1.251
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-partial-activate.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/lib/metadata/metadata.c	2009/07/14 02:19:19	1.250
+++ LVM2/lib/metadata/metadata.c	2009/07/15 05:47:55	1.251
@@ -2940,6 +2940,14 @@
 		}
 	}
 
+	if (!cmd->handles_missing_pvs && vg_missing_pv_count(vg) &&
+	    (lock_flags & LCK_WRITE)) {
+		log_error("Cannot change VG %s while PVs are missing!",
+			  vg->name);
+		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
+		goto_bad;
+	}
+
 	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
 		goto_bad;
--- LVM2/test/t-partial-activate.sh	2009/04/22 17:00:30	1.2
+++ LVM2/test/t-partial-activate.sh	2009/07/15 05:47:55	1.3
@@ -9,3 +9,7 @@
 not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
 lvchange -v --partial -a y $vg/mirror
+
+# also check that vgchange works
+vgchange -a n --partial $vg
+vgchange -a y --partial $vg
--- LVM2/tools/lvchange.c	2009/07/01 17:00:52	1.105
+++ LVM2/tools/lvchange.c	2009/07/15 05:47:55	1.106
@@ -696,15 +696,21 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) &&
-	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
+	int avail_only =
+	    !(arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
-	     arg_count(cmd, refresh_ARG) || arg_count(cmd, alloc_ARG))) {
+	     arg_count(cmd, refresh_ARG) || arg_count(cmd, alloc_ARG) ||
+	     arg_count(cmd, resync_ARG));
+
+	if (arg_count(cmd, ignorelockingfailure_ARG) && !avail_only) {
 		log_error("Only -a permitted with --ignorelockingfailure");
 		return EINVALID_CMD_LINE;
 	}
 
+	if (avail_only)
+		cmd->handles_missing_pvs = 1;
+
 	if (!argc) {
 		log_error("Please give logical volume path(s)");
 		return EINVALID_CMD_LINE;
--- LVM2/tools/lvconvert.c	2009/07/01 16:59:37	1.88
+++ LVM2/tools/lvconvert.c	2009/07/15 05:47:55	1.89
@@ -929,8 +929,10 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, repair_ARG))
+	if (arg_count(cmd, repair_ARG)) {
 		init_ignore_suspended_devices(1);
+		cmd->handles_missing_pvs = 1;
+	}
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
--- LVM2/tools/vgchange.c	2009/07/09 10:08:54	1.80
+++ LVM2/tools/vgchange.c	2009/07/15 05:47:55	1.81
@@ -126,6 +126,12 @@
 	int available;
 	int activate = 1;
 
+	/*
+	 * Safe, since we never write out new metadata here. Required for
+	 * partial activation to work.
+	 */
+	cmd->handles_missing_pvs = 1;
+
 	available = arg_uint_value(cmd, available_ARG, 0);
 
 	if ((available == CHANGE_AN) || (available == CHANGE_ALN))
--- LVM2/tools/vgreduce.c	2009/07/08 14:33:17	1.94
+++ LVM2/tools/vgreduce.c	2009/07/15 05:47:55	1.95
@@ -510,8 +510,10 @@
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	if (repairing)
+	if (repairing) {
 		init_ignore_suspended_devices(1);
+		cmd->handles_missing_pvs = 1;
+	}
 
 	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg) == FAILED_ALLOCATION ||


