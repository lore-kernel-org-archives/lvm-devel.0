From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  1 Oct 2013 20:26:13 +0000 (UTC)
Subject: master - cmdline: Add --ignoreskippedcluster.
Message-ID: <20131001202613.EC8B360EF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baf95bbff70bdd1474b678f37b840025295903ae
Commit:        baf95bbff70bdd1474b678f37b840025295903ae
Parent:        23ce3352d7e6ad122b3b173ffb739848bec6a7bd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 1 21:20:10 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 1 21:20:10 2013 +0100

cmdline: Add --ignoreskippedcluster.

Accept --ignoreskippedcluster with pvs, vgs, lvs, pvdisplay, vgdisplay,
lvdisplay, vgchange and lvchange to avoid the 'Skipping clustered
VG' errors when requesting information about a clustered VG
without using clustered locking and still exit with success.

The messages can still be seen with -v.
---
 WHATS_NEW                  |    3 +-
 lib/commands/toolcontext.c |    1 +
 lib/commands/toolcontext.h |    1 +
 lib/metadata/metadata.c    |   10 ++++++-
 man/lvchange.8.in          |    1 +
 man/lvdisplay.8.in         |    2 +
 man/lvm.8.in               |    5 ++++
 man/lvs.8.in               |    1 +
 man/pvdisplay.8.in         |    1 +
 man/pvs.8.in               |    1 +
 man/vgchange.8.in          |    1 +
 man/vgdisplay.8.in         |    2 +
 man/vgs.8.in               |    1 +
 tools/args.h               |    1 +
 tools/commands.h           |   40 +++++++++++++++++++++++----------
 tools/lvmcmdline.c         |    2 +
 tools/pvdisplay.c          |    7 ++---
 tools/reporter.c           |   22 ++++++++++++-----
 tools/toollib.c            |   53 +++++++++++++++++++++++++++++--------------
 tools/toollib.h            |    2 +
 20 files changed, 114 insertions(+), 43 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b813eb6..cfcd8c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,12 +1,13 @@
 Version 2.02.103 - 
 ======================================
+  Add --ignoreskippedcluster for exit status success when clustered VGs skipped.
   Fix 3min udev timeout so that it is applied for all LVM volumes.
   Fix RAID calculation for sufficient allocatable space.
   Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
-  Set use_lvmetad=0 on lvmconf --enable-cluster, reset to default on --disable-cluster.
+  Have lvmconf --enable/disable-cluster reset/set use_lvmetad.
   Don't install separate command symlink in binary directory for 'lvm devtypes'.
   Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4f53f0e..2732094 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1396,6 +1396,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
 	cmd->independent_metadata_areas = 0;
+	cmd->ignore_clustered_vgs = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index cd91605..74b1177 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -90,6 +90,7 @@ struct cmd_context {
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned metadata_read_only:1;
+	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
 
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1e34f83..4ffd502 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4005,7 +4005,10 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 
 	if ((status & CLUSTERED) &&
 	    (vg_is_clustered(vg)) && !locking_is_clustered()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		if (!vg->cmd->ignore_clustered_vgs)
+			log_error("Skipping clustered volume group %s", vg->name);
+		else
+			log_verbose("Skipping clustered volume group %s", vg->name);
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
 	}
@@ -4123,7 +4126,10 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	}
 
 	if (vg_is_clustered(vg) && !locking_is_clustered()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		if (!cmd->ignore_clustered_vgs)
+			log_error("Skipping clustered volume group %s", vg->name);
+		else
+			log_verbose("Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto bad;
 	}
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index ea8a6ef..49337e4 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -27,6 +27,7 @@ lvchange \- change attributes of a logical volume
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoremonitoring ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-monitor
 .RI { y | n }]
 .RB [ \-\-poll
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 84f21d3..49654bc 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -8,6 +8,7 @@ lvdisplay \- display attributes of a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
@@ -26,6 +27,7 @@ lvdisplay \- display attributes of a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
diff --git a/man/lvm.8.in b/man/lvm.8.in
index da471ab..13e66d0 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -216,6 +216,11 @@ This lets you proceed with read-only metadata operations such as
 One use for this is in a system init script if the lock directory
 is mounted read-only when the script runs.
 .TP
+.B \-\-ignoreskippedcluster
+Use to avoid exiting with an non-zero status code if the command is run
+without clustered locking and some clustered Volume Groups have to be
+skipped over.
+.TP
 .B \-\-addtag \fITag
 Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 85f7d33..8427aca 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -8,6 +8,7 @@ lvs \- report information about logical volumes
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 6a8a0d0..03c12c4 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -7,6 +7,7 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
 .RB [ \-s | \-\-short ]
diff --git a/man/pvs.8.in b/man/pvs.8.in
index d1f6e8b..67e395b 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -8,6 +8,7 @@ pvs \- report information about physical volumes
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 97042b1..e687587 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -29,6 +29,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoremonitoring ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-l | \-\-logicalvolume
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 70c1fa7..9016a45 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -10,6 +10,7 @@ vgdisplay \- display attributes of volume groups
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-units
@@ -26,6 +27,7 @@ vgdisplay \- display attributes of volume groups
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o|\-\-options
diff --git a/man/vgs.8.in b/man/vgs.8.in
index 381e3a9..eae60fa 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -8,6 +8,7 @@ vgs \- report information about volume groups
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
diff --git a/tools/args.h b/tools/args.h
index c5e4d14..27b97eb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -100,6 +100,7 @@ arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
+arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index a0cd5d7..c299276 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -107,6 +107,7 @@ xx(lvchange,
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[-k|--setactivationskip {y|n}]\n"
    "\t[-K|--ignoreactivationskip] \n"
    "\t[--monitor {y|n}]\n"
@@ -135,6 +136,7 @@ xx(lvchange,
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
+   ignoreskippedcluster_ARG,
    major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
    noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
    profile_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
@@ -303,6 +305,7 @@ xx(lvdisplay,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
@@ -317,6 +320,7 @@ xx(lvdisplay,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
@@ -330,8 +334,8 @@ xx(lvdisplay,
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, colon_ARG, columns_ARG,
-    ignorelockingfailure_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
+    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG, 
+    ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
     options_ARG, sort_ARG, partial_ARG, segments_ARG, separator_ARG,
     unbuffered_ARG, units_ARG)
 
@@ -502,6 +506,7 @@ xx(lvs,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -519,7 +524,8 @@ xx(lvs,
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+   nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
    unbuffered_ARG, units_ARG, unquoted_ARG)
@@ -646,6 +652,7 @@ xx(pvdisplay,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-s|--short]\n"
@@ -660,6 +667,7 @@ xx(pvdisplay,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
@@ -672,8 +680,8 @@ xx(pvdisplay,
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
-   maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, separator_ARG,
-   short_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
+   options_ARG, separator_ARG, short_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(pvmove,
    "Move extents from one physical volume to another",
@@ -722,6 +730,7 @@ xx(pvs,
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -739,10 +748,10 @@ xx(pvs,
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
+   partial_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -813,6 +822,7 @@ xx(vgchange,
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[-K|--ignoreactivationskip] \n"
    "\t[--monitor {y|n}]\n"
    "\t[--[vg]metadatacopies #copies] " "\n"
@@ -838,6 +848,7 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
    available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
+   ignoreskippedcluster_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
    metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG, profile_ARG,
    physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
@@ -910,6 +921,7 @@ xx(vgdisplay,
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]" "\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
@@ -921,6 +933,7 @@ xx(vgdisplay,
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]" "\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
@@ -934,8 +947,9 @@ xx(vgdisplay,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
-   ignorelockingfailure_ARG, noheadings_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, noheadings_ARG,
+   nosuffix_ARG, options_ARG, partial_ARG, short_ARG, separator_ARG,
+   sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1075,6 +1089,7 @@ xx(vgs,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -1091,7 +1106,8 @@ xx(vgs,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+   nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
    unquoted_ARG)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e004f61..6fe4670 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -906,6 +906,8 @@ static int _get_settings(struct cmd_context *cmd)
 	else
 		init_ignorelockingfailure(0);
 
+	cmd->ignore_clustered_vgs = arg_count(cmd, ignoreskippedcluster_ARG) ? 1 : 0;
+
 	if (!arg_count(cmd, sysinit_ARG))
 		lvmetad_connect_or_warn();
 
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index c6cd412..35fb75b 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -30,11 +30,10 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (vg_read_error(vg)) {
-			log_error("Skipping volume group %s", vg_name);
+		if (ignore_vg(vg, vg_name, 0, &ret)) {
 			release_vg(vg);
-			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
-			return ECMD_FAILED;
+			stack;
+			return ret;
 		}
 
 	 	/*
diff --git a/tools/reporter.c b/tools/reporter.c
index 44a9aa8..a967f60 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -145,10 +145,10 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		vg_name = pv_vg_name(pv);
 
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (vg_read_error(vg)) {
-			log_error("Skipping volume group %s", vg_name);
+		if (ignore_vg(vg, vg_name, 0, &ret)) {
 			release_vg(vg);
-			return ECMD_FAILED;
+			stack;
+			return ret;
 		}
 
 		/*
@@ -205,8 +205,12 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
 		      void *handle)
 {
-	if (vg_read_error(vg))
-		return_ECMD_FAILED;
+	int ret = ECMD_PROCESSED;
+
+	if (ignore_vg(vg, vg_name, 0, &ret)) {
+		stack;
+		return ret;
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
@@ -215,8 +219,12 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle)
 {
-	if (vg_read_error(vg))
-		return_ECMD_FAILED;
+	int ret = ECMD_PROCESSED;
+
+	if (ignore_vg(vg, vg_name, 0, &ret)) {
+		stack;
+		return ret;
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 9b3e842..bc8b33c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -156,6 +156,29 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 }
 
 /*
+ * Returns 1 if VG should be ignored.
+ */
+int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *ret)
+{
+	uint32_t read_error = vg_read_error(vg);
+
+	if (!read_error)
+		return 0;
+
+	if ((read_error == FAILED_INCONSISTENT) && allow_inconsistent)
+		return 0;
+
+	if (read_error == FAILED_CLUSTERED && vg->cmd->ignore_clustered_vgs)
+		log_verbose("Skipping volume group %s", vg_name);
+	else {
+		log_error("Skipping volume group %s", vg_name);
+		*ret = ECMD_FAILED;
+	}
+
+	return 1;
+}
+
+/*
  * Metadata iteration functions
  */
 int process_each_lv_in_vg(struct cmd_context *cmd,
@@ -404,12 +427,10 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			return_ECMD_FAILED;
 
 		if (!cmd_vg_read(cmd, &cmd_vgs)) {
-			free_cmd_vgs(&cmd_vgs);
-			if (ret_max < ECMD_FAILED) {
-				log_error("Skipping volume group %s", vgname);
-				ret_max = ECMD_FAILED;
-			} else
+			if (ignore_vg(cvl_vg->vg, vgname, 0, &ret_max))
 				stack;
+
+			free_cmd_vgs(&cmd_vgs);
 			continue;
 		}
 
@@ -489,10 +510,10 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		vg_name = pv_vg_name(pv);
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
-		if (vg_read_error(vg)) {
+		if (ignore_vg(vg, vg_name, 0, &ret)) {
 			release_vg(vg);
-			log_error("Skipping volume group %s", vg_name);
-			return ECMD_FAILED;
+			stack;
+			return ret;
 		}
 
 		/*
@@ -561,13 +582,13 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 {
 	struct dm_list cmd_vgs;
 	struct cmd_vg *cvl_vg;
-	int ret = 0;
+	int ret = ECMD_PROCESSED;
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
 	dm_list_init(&cmd_vgs);
 	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, vgid, flags)))
-		return_0;
+		return_ECMD_FAILED;
 
 	for (;;) {
 		if (sigint_caught()) {
@@ -575,15 +596,14 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			stack;
 			break;
 		}
-		if (!cmd_vg_read(cmd, &cmd_vgs))
+
+		if (!cmd_vg_read(cmd, &cmd_vgs)) {
 			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-			if (vg_read_error(cvl_vg->vg) &&
-			    (!((flags & READ_ALLOW_INCONSISTENT) &&
-			       (vg_read_error(cvl_vg->vg) == FAILED_INCONSISTENT)))) {
-				ret = ECMD_FAILED;
+			if (ignore_vg(cvl_vg->vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
 				stack;
 				break;
 			}
+		}
 
 		if (!dm_list_empty(tags) &&
 		    /* Only process if a tag matches or it's on arg_vgnames */
@@ -889,8 +909,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 					goto_out;
 				}
 				vg = vg_read(cmd, sll->str, NULL, flags);
-				if (vg_read_error(vg)) {
-					ret_max = ECMD_FAILED;
+				if (ignore_vg(vg, sll->str, 0, &ret_max)) {
 					release_vg(vg);
 					stack;
 					continue;
diff --git a/tools/toollib.h b/tools/toollib.h
index d831b95..aa6f699 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -25,6 +25,8 @@ int autobackup_init(const char *backup_dir, int keep_days, int keep_number,
 		    int autobackup);
 int autobackup(struct volume_group *vg);
 
+int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *ret);
+
 struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
 				uint32_t lock_type);
 


