From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:10:44 -0500
Subject: master - suspend: handle start of pvmove
Message-ID: <201711241510.vAOFAiLM000325@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae6beda12ddd203b806c565faabb5715379eaf85
Commit:        ae6beda12ddd203b806c565faabb5715379eaf85
Parent:        175d06a92940dda5de3a7631e3d27cd6828a16be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:51:17 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:05:21 2017 +0100

suspend: handle start of pvmove

Just like suspend handles preload for pvmove finish,
in similar way handle suspend of starting pvmove.

In this case the  precommited metadata are checked for list of PVMOVEed
LVs and those are suspended in with committed metadata.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   52 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03d1e04..5ffe0ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Enhance activation code to automatically suspend pvmove participants.
   Remove unnecessary single read from lvmdiskscan.
   Avoid using precommitted metadata for suspending pvmove tree.
   Ehnance pvmove locking.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index efcecde..fe2fcc6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2095,6 +2095,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	struct lvinfo info;
 	int r = 0, lockfs = 0, flush_required = 0;
 	struct detached_lv_data detached;
+	struct dm_pool *mem = NULL;
+	struct dm_list suspend_lvs;
+	struct lv_list *lvl;
 
 	if (!activation())
 		return 1;
@@ -2226,13 +2229,54 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		lockfs = 1;
 
 	critical_section_inc(cmd, "suspending");
-	if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
-		critical_section_dec(cmd, "failed suspend");
-		goto_out;
-	}
+
+	if (!lv_is_locked(lv) && lv_is_locked(lv_pre) &&
+	    (pvmove_lv = find_pvmove_lv_in_lv(lv_pre))) {
+		/*
+		 * When starting PVMOVE, suspend participating LVs first
+		 * with committed metadata by looking at precommited pvmove list.
+		 * In committed metadata these LVs are not connected in any way.
+		 *
+		 * TODO: prepare list of LVs needed to be suspended and pass them
+		 *       via 'struct laopts' directly to _lv_suspend_lv() and handle this
+		 *       with a single 'dmtree' call.
+		 */
+		if (!(mem = dm_pool_create("suspend_lvs", 128)))
+			goto_out;
+
+		/* Prepare list of all LVs for suspend ahead */
+		dm_list_init(&suspend_lvs);
+		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
+			if (!(lvl = dm_pool_alloc(mem, sizeof(*lvl)))) {
+				log_error("lv_list alloc failed.");
+				goto out;
+			}
+			/* Look for precommitted LV name in commmitted VG */
+			if (!(lvl->lv = find_lv(lv->vg, sl->seg->lv->name))) {
+				log_error(INTERNAL_ERROR "LV %s missing from preload metadata.",
+					  display_lvname(sl->seg->lv));
+				goto out;
+			}
+			/* Never suspend COW, always has to be origin */
+			if (lv_is_cow(lvl->lv))
+				lvl->lv = origin_from_cow(lvl->lv);
+			dm_list_add(&suspend_lvs, &lvl->list);
+		}
+		dm_list_iterate_items(lvl, &suspend_lvs)
+			if (!_lv_suspend_lv(lvl->lv, laopts, lockfs, 1)) {
+				critical_section_dec(cmd, "failed suspend");
+				goto_out; /* FIXME: resume on recovery path? */
+			}
+	} else  /* Standard suspend */
+		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
+			critical_section_dec(cmd, "failed suspend");
+			goto_out;
+		}
 
 	r = 1;
 out:
+	if (mem)
+		dm_pool_destroy(mem);
 	if (lv_pre_to_free)
 		release_vg(lv_pre_to_free->vg);
 	if (lv_to_free)


