From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:48:57 -0400
Subject: master - scan: do scanning at the start of a command
Message-ID: <201804231348.w3NDmvZv031544@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=748f29b42a61e05fb696a86e04b4b589d70d6d79
Commit:        748f29b42a61e05fb696a86e04b4b589d70d6d79
Parent:        4507ba3596a549697733e1b839f25af454ccf878
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 7 13:26:37 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:21:38 2018 -0500

scan: do scanning at the start of a command

Move the location of scans to make it clearer and avoid
unnecessary repeated scanning.  There should be one scan
at the start of a command which is then used through the
rest of command processing.

Previously, the initial label scan was called as a side effect
from various utility functions.  This would lead to it being called
unnecessarily.  It is an expensive operation, and should only be
called when necessary.  Also, this is a primary step in the
function of the command, and as such it should be called prominently
at the top level of command processing, not as a hidden side effect
of a utility function.  lvm knows exactly where and when the
label scan needs to be done.  Because of this, move the label scan
calls from the internal functions to the top level of processing.

Other specific instances of lvmcache_label_scan() are still called
unnecessarily or unclearly by specific commands that do not use
the common process_each functions.  These will be improved in
future commits.

During the processing phase, rescanning labels for devices in a VG
needs to be done after the VG lock is acquired in case things have
changed since the initial label scan.  This was being done by way
of rescanning devices that had the INVALID flag set in lvmcache.
This usually approximated the right set of devices, but it was not
exact, and obfuscated the real requirement.  Correct this by using
a new function that rescans the devices in the VG:
lvmcache_label_rescan_vg().

Apart from being inexact, the rescanning was extremely well hidden.
_vg_read() would call ->create_instance(), _text_create_text_instance(),
_create_vg_text_instance() which would call lvmcache_label_scan()
which would call _scan_invalid() which repeats the label scan on
devices flagged INVALID.  lvmcache_label_rescan_vg() is now called
prominently by _vg_read() directly.
---
 lib/cache/lvmcache.c          |    2 -
 lib/format_text/format-text.c |   16 ----------
 lib/metadata/metadata.c       |   62 +++++++++++++++++++++++++++++++++--------
 tools/toollib.c               |   27 ++++++++++++-----
 tools/vgcfgrestore.c          |    2 +
 5 files changed, 71 insertions(+), 38 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c0b2202..47058cc 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1436,8 +1436,6 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 	struct vgnameid_list *vgnl;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd);
-
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!include_internal && is_orphan_vg(vginfo->vgname))
 			continue;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c438b2d..6c13346 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2049,22 +2049,6 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		}
 
 		if (type & FMT_INSTANCE_MDAS) {
-			/*
-			 * TODO in theory, this function should be never reached
-			 * while in critical_section(), because lvmcache's
-			 * cached_vg should be valid. However, this assumption
-			 * sometimes fails (possibly due to inconsistent
-			 * (precommit) metadata and/or missing devices), and
-			 * calling lvmcache_label_scan inside the critical
-			 * section may be fatal (i.e. deadlock).
-			 */
-			if (!critical_section())
-				/* Scan PVs in VG for any further MDAs */
-				/*
-				 * FIXME Only scan PVs believed to be in the VG.
- 				 */
-				lvmcache_label_scan(fid->fmt->cmd);
-
 			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
 				goto_out;
 			if (!lvmcache_fid_add_mdas_vg(vginfo, fid))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 00b7737..b4ee204 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3859,20 +3859,28 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		correct_vg = NULL;
 	}
 
+	/*
+	 * Rescan the devices that are associated with this vg in lvmcache.
+	 * This repeats what was done by the command's initial label scan,
+	 * but only the devices associated with this VG.
+	 *
+	 * The lvmcache info about these devs is from the initial label scan
+	 * performed by the command before the vg lock was held.  Now the VG
+	 * lock is held, so we rescan all the info from the devs in case
+	 * something changed between the initial scan and now that the lock
+	 * is held.
+	 */
+	log_debug_metadata("Reading VG rereading labels for %s", vgname);
 
-	/* Find the vgname in the cache */
-	/* If it's not there we must do full scan to be completely sure */
-	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
+	if (!lvmcache_label_rescan_vg(cmd, vgname, vgid)) {
+		/* The VG wasn't found, so force a full label scan. */
+		lvmcache_force_next_label_scan();
 		lvmcache_label_scan(cmd);
-		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
-			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && prioritized_section())
-				return_NULL;
-			lvmcache_force_next_label_scan();
-			lvmcache_label_scan(cmd);
-			if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
-				return_NULL;
-		}
+	}
+
+	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0))) {
+		log_debug_metadata("Cache did not find fmt for vgname %s", vgname);
+		return_NULL;
 	}
 
 	/* Now determine the correct vgname if none was supplied */
@@ -3890,6 +3898,36 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	if (use_precommitted && !(fmt->features & FMT_PRECOMMIT))
 		use_precommitted = 0;
 
+	/*
+	 * A "format instance" is an abstraction for a VG location,
+	 * i.e. where a VG's metadata exists on disk.
+	 *
+	 * An fic (format_instance_ctx) is a temporary struct used
+	 * to create an fid (format_instance).  The fid hangs around
+	 * and is used to create a 'vg' to which it connected (vg->fid).
+	 *
+	 * The 'fic' describes a VG in terms of fmt/name/id.
+	 *
+	 * The 'fid' describes a VG in more detail than the fic,
+	 * holding information about where to find the VG metadata.
+	 *
+	 * The 'vg' describes the VG in the most detail representing
+	 * all the VG metadata.
+	 *
+	 * The fic and fid are set up by create_instance() to describe
+	 * the VG location.  This happens before the VG metadata is
+	 * assembled into the more familiar struct volume_group "vg".
+	 *
+	 * The fid has one main purpose: to keep track of the metadata
+	 * locations for a given VG.  It does this by putting 'mda'
+	 * structs on fid->metadata_areas_in_use, which specify where
+	 * metadata is located on disk.  It gets this information
+	 * (metadata locations for a specific VG) from the command's
+	 * initial label scan.  The info is passed indirectly via
+	 * lvmcache info/vginfo structs, which are created by the
+	 * label scan and then copied into fid by create_instance().
+	 */
+
 	/* create format instance with appropriate metadata area */
 	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vgname;
diff --git a/tools/toollib.c b/tools/toollib.c
index 451f24d..1c216d8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2228,14 +2228,10 @@ int process_each_vg(struct cmd_context *cmd,
 	}
 
 	/*
-	 * First rescan for available devices, then force the next
-	 * label scan to be done.  get_vgnameids() will scan labels
-	 * (when not using lvmetad).
+	 * Scan all devices to populate lvmcache with initial
+	 * list of PVs and VGs.
 	 */
-	if (cmd->cname->flags & REQUIRES_FULL_LABEL_SCAN) {
-		dev_cache_full_scan(cmd->full_filter);
-		lvmcache_force_next_label_scan();
-	}
+	lvmcache_label_scan(cmd);
 
 	/*
 	 * A list of all VGs on the system is needed when:
@@ -3745,6 +3741,12 @@ int process_each_lv(struct cmd_context *cmd,
 	}
 
 	/*
+	 * Scan all devices to populate lvmcache with initial
+	 * list of PVs and VGs.
+	 */
+	lvmcache_label_scan(cmd);
+
+	/*
 	 * A list of all VGs on the system is needed when:
 	 * . processing all VGs on the system
 	 * . A VG name is specified which may refer to one
@@ -4453,7 +4455,12 @@ int process_each_pv(struct cmd_context *cmd,
 	if (!trust_cache() && !orphans_locked) {
 		log_debug("Scanning for available devices");
 		lvmcache_destroy(cmd, 1, 0);
-		dev_cache_full_scan(cmd->full_filter);
+
+		/*
+		 * Scan all devices to populate lvmcache with initial
+		 * list of PVs and VGs.
+		 */
+		lvmcache_label_scan(cmd);
 	}
 
 	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
@@ -5467,6 +5474,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	dev_cache_full_scan(cmd->full_filter);
 
+	lvmcache_label_scan(cmd);
+
 	/*
 	 * Translate arg names into struct device's.
 	 */
@@ -5621,6 +5630,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto out;
 	}
 
+	lvmcache_label_scan(cmd);
+
 	/*
 	 * The device args began on the arg_devices list, then the first check
 	 * loop moved those entries to arg_process as they were found.  Devices
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index b5a2add..e9f1a4c 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -74,6 +74,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	lvmcache_label_scan(cmd);
+
 	cmd->handles_unknown_segments = 1;
 
 	if (!(arg_is_set(cmd, file_ARG) ?


