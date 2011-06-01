From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2011 19:21:06 -0000
Subject: LVM2 tools/commands.h tools/tools.h tools/lvcr ...
Message-ID: <20110601192106.21049.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-01 19:21:04

Modified files:
	tools          : commands.h tools.h lvcreate.c 
	man            : lvcreate.8.in 
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h lv_manip.c 
	liblvm         : lvm_lv.c 

Log message:
	Permit --available with lvcreate so non-snapshot LVs need not be activated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2002&r2=1.2003
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/tools/commands.h	2010/10/25 11:20:56	1.157
+++ LVM2/tools/commands.h	2011/06/01 19:21:03	1.158
@@ -148,6 +148,7 @@
    0,
    "lvcreate " "\n"
    "\t[-A|--autobackup {y|n}]\n"
+   "\t[-a|--available [e|l]y|n]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
@@ -198,12 +199,12 @@
 
    "\t[PhysicalVolumePath...]\n\n",
 
-   addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, extents_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
-   permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
-   snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
-   virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
+   addtag_ARG, alloc_ARG, autobackup_ARG, available_ARG, chunksize_ARG,
+   contiguous_ARG, corelog_ARG, extents_ARG, ignoremonitoring_ARG, major_ARG,
+   minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG,
+   noudevsync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
+   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/tools.h	2010/11/30 11:53:33	1.74
+++ LVM2/tools/tools.h	2011/06/01 19:21:03	1.75
@@ -87,14 +87,6 @@
 	PERCENT_ORIGIN
 } percent_type_t;
 
-enum {
-	CHANGE_AY = 0,
-	CHANGE_AN = 1,
-	CHANGE_AE = 2,
-	CHANGE_ALY = 3,
-	CHANGE_ALN = 4
-};
-
 #define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
 #define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
 
--- LVM2/tools/lvcreate.c	2011/03/25 21:56:28	1.230
+++ LVM2/tools/lvcreate.c	2011/06/01 19:21:03	1.231
@@ -429,12 +429,21 @@
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
+	lp->activate = arg_uint_value(cmd, available_ARG, CHANGE_AY);
+
 	/*
 	 * Should we zero the lv.
 	 */
 	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
 		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
 
+	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
+		if (lp->zero) {
+			log_error("--available n requires --zero n");
+			return 0;
+		}
+	}
+
 	/*
 	 * Alloc policy
 	 */
--- LVM2/man/lvcreate.8.in	2010/05/28 03:50:18	1.18
+++ LVM2/man/lvcreate.8.in	2011/06/01 19:21:04	1.19
@@ -5,6 +5,7 @@
 .B lvcreate
 [\-\-addtag Tag]
 [\-\-alloc AllocationPolicy]
+[\-a|\-\-available y|n|ey|en|ly|ln]
 [\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
 [\-h|\-?|\-\-help] [\-\-noudevsync]
 [\-\-ignoremonitoring]
@@ -55,6 +56,18 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-a, \-\-available y|n|ey|en|ly|ln
+Controls the availability of the Logical Volumes for immediate use after 
+the command finishes running.
+By default, new Logical Volumes are activated automatically (-ay).
+If it is possible technically, -an will leave the new Logical Volume inactive.
+But for example, snapshots can only be created
+in the active state so -an cannot be used with --snapshot.
+Normally the --zero n argument has to be supplied too because zeroing (the
+default behaviour) also requires activation.
+If clustered locking is enabled, -aey will activate exclusively
+on one node and -aly will activate only on the local node.
+.TP
 .I \-c, \-\-chunksize ChunkSize
 Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
 .TP
--- LVM2/WHATS_NEW	2011/06/01 15:30:36	1.2002
+++ LVM2/WHATS_NEW	2011/06/01 19:21:04	1.2003
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Permit --available with lvcreate so non-snapshot LVs need not be activated.
   Report sector containing label in verbose message.
   Clarify error message when unable to convert an LV into a snapshot of an LV.
   Add and use dev_open_readonly and variations.
--- LVM2/lib/metadata/metadata-exported.h	2011/05/07 13:32:05	1.191
+++ LVM2/lib/metadata/metadata-exported.h	2011/06/01 19:21:04	1.192
@@ -78,6 +78,7 @@
 
 #define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
 #define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
+#define UNLABELLED_PV           0x80000000U     /* PV -this PV had no label written yet */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -360,7 +361,8 @@
 
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
 					const char *pv_name,
-					struct pvcreate_params *pp);
+					struct pvcreate_params *pp,
+					int write_now);
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 
 /*
@@ -372,7 +374,7 @@
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, int warnings, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				uint64_t *label_sector, int warnings,
+				int warnings,
 				int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
@@ -519,6 +521,17 @@
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
+/*
+ * Activation options
+ */
+typedef enum {
+	CHANGE_AY = 0,
+	CHANGE_AN = 1,
+	CHANGE_AE = 2,
+	CHANGE_ALY = 3,
+	CHANGE_ALN = 4
+} activation_change_t;
+
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
@@ -529,6 +542,7 @@
 	int log_count; /* mirror */
 	int nosync; /* mirror */
 	int activation_monitoring; /* all */
+	activation_change_t activate; /* non-snapshot, non-mirror */
 
 	char *origin; /* snap */
 	const char *vg_name; /* all */
--- LVM2/lib/metadata/lv_manip.c	2011/04/09 19:05:24	1.258
+++ LVM2/lib/metadata/lv_manip.c	2011/06/01 19:21:04	1.259
@@ -3711,7 +3711,9 @@
 				  "exception store.");
 			goto revert_new_lv;
 		}
-	} else if (!activate_lv(cmd, lv)) {
+	} else if ((lp->activate == CHANGE_AY && !activate_lv(cmd, lv)) ||
+		   (lp->activate == CHANGE_AE && !activate_lv_excl(cmd, lv)) ||
+		   (lp->activate == CHANGE_ALY && !activate_lv_local(cmd, lv))) {
 		log_error("Failed to activate new LV.");
 		if (lp->zero)
 			goto deactivate_and_revert_new_lv;
--- LVM2/liblvm/lvm_lv.c	2011/02/03 01:24:46	1.35
+++ LVM2/liblvm/lvm_lv.c	2011/06/01 19:21:04	1.36
@@ -111,6 +111,7 @@
 	lp->major = -1;
 	lp->minor = -1;
 	lp->activation_monitoring = DEFAULT_DMEVENTD_MONITOR;
+	lp->activate = CHANGE_AY;
 	lp->vg_name = vg->name;
 	lp->lv_name = lvname; /* FIXME: check this for safety */
 	lp->pvh = &vg->pvs;


