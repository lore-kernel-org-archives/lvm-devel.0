From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 16:58:51 -0400
Subject: master - scan: ignore duplicates that are md component devs
Message-ID: <201805112058.w4BKwpbX020960@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09fcc8eaa8eb7fa4fcd7c6611bfbfb83f726ae38
Commit:        09fcc8eaa8eb7fa4fcd7c6611bfbfb83f726ae38
Parent:        73578e36faa78c616716617a83083cc3a31ba03f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 15:52:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 15:52:22 2018 -0500

scan: ignore duplicates that are md component devs

md devices using an older superblock version have
superblocks at the end of the md device.  For commands
that skip reading the end of devices during filtering,
the md component devs will be scanned, and will appear
as duplicate PVs to the original md device.  Remove
these md components from the list of unused duplicate
devices, so they are treated as if they had been
ignored during filtering.  This avoids the restrictions
that are placed on using PVs with duplicates.
---
 lib/cache/lvmcache.c |   36 ++++++++++++++++++++++++++++++++++++
 lib/device/dev-md.c  |   10 ++++++++--
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d45385b..382edcd 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -977,6 +977,35 @@ int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
 }
 
 /*
+ * Treat some duplicate devs as if they were filtered out by filters.
+ * The actual filters are evaluated too early, before a complete
+ * picture of all PVs is available, to eliminate these duplicates.
+ *
+ * By removing the filtered duplicates from unused_duplicate_devs, we remove
+ * the restrictions that are placed on using duplicate devs or VGs with
+ * duplicate devs.
+ *
+ * There may other kinds of duplicates that we want to ignore.
+ */
+
+static void _filter_duplicate_devs(struct cmd_context *cmd)
+{
+	struct dev_types *dt = cmd->dev_types;
+	struct lvmcache_info *info;
+	struct device_list *devl, *devl2;
+
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+
+		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+
+		if (MAJOR(info->dev->dev) == dt->md_major) {
+			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
+			dm_list_del(&devl->list);
+		}
+	}
+}
+
+/*
  * Compare _found_duplicate_devs entries with the corresponding duplicate dev
  * in lvmcache.  There may be multiple duplicates in _found_duplicate_devs for
  * a given pvid.  If a dev from _found_duplicate_devs is preferred over the dev
@@ -1442,6 +1471,13 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		}
 
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
+
+		/*
+		 * We might want to move the duplicate device warnings until
+		 * after this filtering so that we can skip warning about
+		 * duplicates that we are filtering out.
+		 */
+		_filter_duplicate_devs(cmd);
 	}
 
 	/* Perform any format-specific scanning e.g. text files */
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index f32c1c3..f5a736f 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -134,8 +134,7 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
 	 * Those checks can't be satisfied with the initial bcache data, and
 	 * would require an extra read i/o at the end of every device.  Issuing
 	 * an extra read to every device in every command, just to check for
-	 * the old md format is a bad tradeoff.  It's also not a big issue if
-	 * one happens to exist and we don't filter it out.
+	 * the old md format is a bad tradeoff.
 	 *
 	 * When "full" is set, we check a the start and end of the device for
 	 * md magic numbers.  When "full" is not set, we only check at the
@@ -143,6 +142,13 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
 	 * command if it should do a full check (cmd->use_full_md_check),
 	 * and set it for commands that could possibly write to an md dev
 	 * (pvcreate/vgcreate/vgextend).
+	 *
+	 * For old md versions with magic numbers at the end of devices,
+	 * the md dev components won't be filtered out here when full is 0,
+	 * so they will be scanned, and appear as duplicate PVs in lvmcache.
+	 * The md device itself will be chosen as the primary duplicate,
+	 * and the components are dropped from the list of duplicates in,
+	 * i.e. a kind of post-scan filtering.
 	 */
 	if (!full) {
 		sb_offset = 0;


