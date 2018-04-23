From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:53:39 -0400
Subject: master - pvremove: device check doesn't require label_read
Message-ID: <201804231353.w3NDrdYX001231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f17c2cf7c614e8f6e4ffe9b7415d628ecab61d47
Commit:        f17c2cf7c614e8f6e4ffe9b7415d628ecab61d47
Parent:        29c6c171217753daf5603432bcaeaed2e8dc8418
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 9 12:43:12 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:45 2018 -0500

pvremove: device check doesn't require label_read

It just needs to check if the device was found during
the scan, which means checking if it exists in lvmcache.
---
 lib/cache/lvmcache.c |   19 +++++++++++++++++++
 lib/cache/lvmcache.h |    2 ++
 tools/toollib.c      |   13 ++++++++-----
 3 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 28e46bb..87bcc37 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2562,6 +2562,25 @@ int lvmcache_foreach_ba(struct lvmcache_info *info,
 	return 1;
 }
 
+struct label *lvmcache_get_dev_label(struct device *dev)
+{
+	struct lvmcache_info *info;
+
+	if ((info = lvmcache_info_from_pvid(dev->pvid, NULL, 0))) {
+		/* dev would be different for a duplicate */
+		if (info->dev == dev)
+			return info->label;
+	}
+	return NULL;
+}
+
+int lvmcache_has_dev_info(struct device *dev)
+{
+	if (lvmcache_info_from_pvid(dev->pvid, NULL, 0))
+		return 1;
+	return 0;
+}
+
 /*
  * The lifetime of the label returned is tied to the lifetime of the
  * lvmcache_info which is the same as lvmcache itself.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 1856344..3967b29 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -160,6 +160,8 @@ uint32_t lvmcache_ext_flags(struct lvmcache_info *info);
 
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info);
 struct label *lvmcache_get_label(struct lvmcache_info *info);
+struct label *lvmcache_get_dev_label(struct device *dev);
+int lvmcache_has_dev_info(struct device *dev);
 
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 			const struct format_type *fmt);
diff --git a/tools/toollib.c b/tools/toollib.c
index 1c216d8..6593195 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5292,14 +5292,12 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 * Is there a pv here already?
 	 * If not, this is an error unless you used -f.
 	 */
-	if (!label_read(pd->dev, &label, 0)) {
+	if (!lvmcache_has_dev_info(pv->dev)) {
 		if (pp->force) {
 			dm_list_move(&pp->arg_process, &pd->list);
 			return 1;
 		} else {
-			log_error("No PV label found on %s.", pd->name);
-			dm_list_move(&pp->arg_fail, &pd->list);
-			return 1;
+			pd->is_not_pv = 1;
 		}
 	}
 
@@ -5308,7 +5306,11 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 * device, a PV used in a VG.
 	 */
 
-	if (vg && !is_orphan_vg(vg->name)) {
+	if (pd->is_not_pv) {
+		/* Device is not a PV. */
+		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
+
+	} else if (vg && !is_orphan_vg(vg->name)) {
 		/* Device is a PV used in a VG. */
 		log_debug("Found pvremove arg %s: pv is used in %s.", pd->name, vg->name);
 		pd->is_vg_pv = 1;
@@ -5330,6 +5332,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 		else
 			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	} else {
+		/* FIXME: is it possible to reach here? */
 		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
 		/* Device is not a PV. */
 		pd->is_not_pv = 1;


