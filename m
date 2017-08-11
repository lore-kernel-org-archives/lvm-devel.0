From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 11 Aug 2017 15:44:21 -0400
Subject: master - pvcreate: Wipe cached bootloaderarea when wiping label.
Message-ID: <201708111944.v7BJiLNL031283@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fa5add6b1bd4d7f7313f2950021a09e4130ad08
Commit:        4fa5add6b1bd4d7f7313f2950021a09e4130ad08
Parent:        7d09d7288b3aaecdfba9a3a05e7697f7dcdfed79
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 11 20:32:04 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 11 20:32:04 2017 +0100

pvcreate: Wipe cached bootloaderarea when wiping label.

Previously the cache remembered an existing bootloaderarea and
reinstated it (without even checking for overlap) when asked to
write out the PV.  pvcreate could write out an incorrect layout.
---
 WHATS_NEW         |    1 +
 lib/label/label.c |    8 +++++++-
 tools/toollib.c   |    5 -----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b21702c..e05fae2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Always clear cached bootloaderarea when wiping label e.g. in pvcreate.
   Disallow --bootloaderareasize with pvcreate --restorefile.
   Fix lvmlockd check for running lock managers during lock adoption.
   Add --withgeneralpreamble and --withlocalpreamble to lvmconfig.
diff --git a/lib/label/label.c b/lib/label/label.c
index c5f4884..0e99517 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -202,6 +202,7 @@ int label_remove(struct device *dev)
 	int wipe;
 	struct labeller_i *li;
 	struct label_header *lh;
+	struct lvmcache_info *info;
 
 	memset(buf, 0, LABEL_SIZE);
 
@@ -245,8 +246,13 @@ int label_remove(struct device *dev)
 		if (wipe) {
 			log_very_verbose("%s: Wiping label at sector %" PRIu64,
 					 dev_name(dev), sector);
-			if (!dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE,
+			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE,
 				       buf)) {
+				/* Also remove the PV record from cache. */
+				info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
+				if (info)
+					lvmcache_del(info);
+			} else {
 				log_error("Failed to remove label from %s at "
 					  "sector %" PRIu64, dev_name(dev),
 					  sector);
diff --git a/tools/toollib.c b/tools/toollib.c
index c2807b8..1799bc9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5398,7 +5398,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct pvcreate_prompt *prompt, *prompt2;
 	struct physical_volume *pv;
 	struct volume_group *orphan_vg;
-	struct lvmcache_info *info;
 	struct dm_list remove_duplicates;
 	struct dm_list arg_sort;
 	struct pv_list *pvl;
@@ -5811,10 +5810,6 @@ do_command:
 			continue;
 		}
 
-		info = lvmcache_info_from_pvid(pd->pvid, pd->dev, 0);
-		if (info)
-			lvmcache_del(info);
-
 		if (!lvmetad_pv_gone_by_dev(pd->dev)) {
 			log_error("Failed to remove PV %s from lvmetad.", pd->name);
 			dm_list_move(&pp->arg_fail, &pd->list);


