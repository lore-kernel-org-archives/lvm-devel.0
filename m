From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:26 -0500
Subject: master - lvremove: drop unneded check
Message-ID: <201802282022.w1SKMQ7G009787@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b09ea3b6f764f6a853b816da65aeb3d0d351f77c
Commit:        b09ea3b6f764f6a853b816da65aeb3d0d351f77c
Parent:        749372caf3e977f2e3f69848e8535fea397695e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:37:03 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:08:40 2018 +0100

lvremove: drop unneded check

Checking here for cache_pool is not necessary and in effect
the check is not even right - since there are internal
states that do allow to active such LV.
---
 lib/metadata/lv_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 35c805c..12f444b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6033,8 +6033,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (!lv_is_cache_pool(lv) && /* cache pool cannot be active */
-	    lv_is_active(lv)) {
+	if (lv_is_active(lv)) {
 		if (!lv_check_not_in_use(lv, 1))
 			return_0;
 


