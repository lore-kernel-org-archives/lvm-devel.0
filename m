From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:12 +0000 (UTC)
Subject: master - lvremove: detect cluster wide active state
Message-ID: <20141006133312.CB8316016C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=189d0f8e1deb2ad8b985696d9925f5259ab30baa
Commit:        189d0f8e1deb2ad8b985696d9925f5259ab30baa
Parent:        b37203c8193ea47d2de1033b5e57ae5bd1360df4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 23:49:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

lvremove: detect cluster wide active state

If the LV is active remotely do not skip question for deactivation.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 275d666..8a4fa13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Check cluster-wide (not local) active status before removing LV.
   Properly check if activation of removed cached LV really activated.
   Lvremoving cached LV removes cachepool (keep with lvconvert --splitcache).
   Always remove spare LV with last removed pool volume.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 168ce05..1edb0a0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5429,7 +5429,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (!lv_is_cache_pool(lv) && lv_is_active_locally(lv)) {
+	if (!lv_is_cache_pool(lv) && /* cache pool cannot be active */
+	    lv_is_active(lv)) {
 		if (!lv_check_not_in_use(lv))
 			return_0;
 


