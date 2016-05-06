From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:39 +0000 (UTC)
Subject: master - lvmetad: set disabled flag in lvmetad if duplicate PVs are found
Message-ID: <20160506140039.DF04660D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9539ee809827a870c88d02cfb2d0dc1e3eaac0d0
Commit:        9539ee809827a870c88d02cfb2d0dc1e3eaac0d0
Parent:        a1dbd54885844a934e17f69691d2371a15453033
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 29 12:25:20 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 08:59:59 2016 -0500

lvmetad: set disabled flag in lvmetad if duplicate PVs are found

When devices are being scanned, if duplicate PVs are seen,
tell lvmetad to set its disabled flag because of duplicate PVs.
---
 lib/cache/lvmcache.c |    6 ++
 lib/cache/lvmetad.c  |  138 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 144 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e2c86c4..8ac113f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -27,6 +27,7 @@
 #include "config.h"
 
 #include "lvmetad.h"
+#include "lvmetad-client.h"
 
 #define CACHE_INVALID	0x00000001
 #define CACHE_LOCKED	0x00000002
@@ -1840,6 +1841,11 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			 * pv->dev under the VG, and its duplicate outside
 			 * the VG context.)
 			 */
+
+			if (!_found_duplicate_pvs && lvmetad_used()) {
+				log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs."); 
+				lvmetad_set_disabled(fmt->cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
+			}
 			_found_duplicate_pvs = 1;
 
 			/*
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8b63696..6c7bddd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2268,6 +2268,144 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 	return ret;
 }
 
+/*
+ * lvmetad has a disabled state in which it continues running,
+ * and returns the "disabled" flag in a get_global_info query.
+ *
+ * Case 1
+ * ------
+ * When "normal" commands start, (those not specifically
+ * intended to rescan devs) they begin by checking lvmetad's
+ * token and global info:
+ *
+ * - If the token doesn't match (should be uncommon), the
+ * command first rescans devices to repopulate lvmetad with
+ * the global_filter it is using.  After rescanning, the
+ * lvmetad disabled state is set or cleared depending on
+ * what the scan saw.
+ *
+ *     An unmatching token occurs when:
+ *     . lvmetad was just started and has not been populated yet.
+ *     . The global_filter has been changed in lvm.conf since the
+ *       last command was run.
+ *     . The global_filter is overriden on the command line.
+ *       (There's little point in using lvmetad if global_filter
+ *       is often changed/overridden.)
+ *
+ * - If the token does match (common case), the command and
+ * lvmetad are using the same global_filter and the command
+ * does not rescan devs to repopulate lvmetad, or change the
+ * lvmetad disabled state.
+ *
+ * - After the token check/sync, the command checks if the
+ * disabled flag is set in lvmetad.  If it is, the command will
+ * not use the lvmetad cache and will revert to scanning, i.e.
+ * it runs the same as if use_lvmetad=0.
+ *
+ * So, "normal" commands try to use the lvmetad cache to avoid
+ * scanning devices.  In the uncommon case when the token doesn't
+ * match, these commands will first rescan devs to repopulate the
+ * lvmetad cache, and then attempt to use the lvmetad cache.
+ * In the uncommon case where lvmetad is disabled (by a previous
+ * command), the common commands do not rescan devs to repopulate
+ * lvmetad, but revert the equivalent of use_lvmetad=0, reading
+ * from disk instead of the cache.
+ * The combination of those two uncommon cases means that a command
+ * could begin by rescanning devs because of a token mismatch, then
+ * disable lvmetad as a result of that scan, and continue without
+ * using lvmetad.
+ *
+ * Case 2
+ * ------
+ * Commands that are meant to scan devices to repopulate the
+ * lvmetad cache, e.g. pvscan --cache, will always rescan
+ * devices and then set/clear the disabled state according to
+ * what they found when scanning.  The global_filter is always
+ * used when choosing which devices to scan to populate lvmetad.
+ * The command-specific filter is never used when choosing
+ * which devices to scan for repopulating the lvmetad cache.
+ *
+ * During a scan repopulating the lvmetad cache, a command looks
+ * for PVs with lvm1 metadata, or duplicate PVs (two devices with
+ * the same PVID).  If either of those are found during the scan,
+ * the command sets the disabled state in lvmetad.  If none are
+ * found, the command clears the disabled state in lvmetad.
+ * (Other problems scanning may also cause the command to set the
+ * disabled state.)
+ *
+ * Case 3
+ * ------
+ * The special command 'pvscan --cache <dev>' is meant to only
+ * scan the specified device and send info from the dev to
+ * lvmetad.  This single-dev pvscan will not detect duplicate PVs
+ * since it only sees the one device.  If lvmetad already knows
+ * about the same PV on another device, then lvmetad will be the
+ * first to discover that a duplicate PV exists.  In this case,
+ * lvmetad sets the disabled state for itself.
+ *
+ * Duplicates
+ * ----------
+ * The most common reasons for duplicate PVs to exist are:
+ *
+ * 1. Multipath.  When multipath is running, it creates a new
+ * mpath device for the underlying "duplicate" devs.  lvm has
+ * built in, automatic filtering that will hide the duplicate
+ * devs of the underlying mpath dev, so the duplicates will
+ * be skipping during scanning (multipath_component_detection).
+ *
+ * If multipath_component_detection=0, or if multipathd is not
+ * running, or multipath is not set up to handle a particular
+ * set of devs, then lvm will see the multipath paths as
+ * duplicates.  lvm will choose one of them to use, consider
+ * the other a duplicate, and disable lvmetad.  multipathd
+ * should be configured and running to resolve these duplicates,
+ * and multipath_component_detection enabled.
+ *
+ * 2. Cloning by copying.  One device is copied over another, e.g.
+ * with dd.  This is a more concerning case because using the
+ * wrong device could lead to corruption.  LVM will attempt to
+ * choose the best device as the PV, but it may not always
+ * be the right one.  In this case, lvmetad is disabled.
+ * vgimportclone should be used on the new copy to resolve the
+ * duplicates.
+ *
+ * 3. Cloning by hardware.  A LUN is cloned/snapshotted on
+ * a hardware device.  The description here is the same as
+ * cloning by copying.
+ *
+ * 4. Creating LVM snapshots of LVs being used as PVs.
+ * If pvcreate is run on an LV, and lvcreate is used to
+ * create a snapshot of that LV, then the two LVs will
+ * appear to be duplicate PVs.
+ *
+ * Filtering duplicates
+ * --------------------
+ * 
+ * If all but one copy of a PV is added to the global_filter,
+ * then duplicates will not be seen when scanning to populate
+ * the lvmetad cache.  Neither common commands nor scanning
+ * commands will see the duplicates, and lvmetad will not be
+ * disabled.
+ *
+ * If the global_filter is *not* used to hide duplicates,
+ * then lvmetad will be disabled when they are scanned, but
+ * common commands can use the command filter to hide the
+ * duplicates and work with a selected instance of the PV.
+ * The command will not use lvmetad in this case, but will
+ * not see duplicate PVs itself because its command filter
+ * is more restrictive than the global_filter and has hidden
+ * the duplicates.
+ */
+
+/*
+ * FIXME: if we fail to disable lvmetad, then other commands could
+ * potentially use incorrect cache data from lvmetad.  Should we
+ * do something more severe if the disable messages fails, like
+ * sending SIGKILL to the lvmetad pid?
+ *
+ * FIXME: log something in syslog any time we disable lvmetad?
+ * At a minimum if we fail to disable lvmetad.
+ */
 void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 {
 	daemon_reply reply;


