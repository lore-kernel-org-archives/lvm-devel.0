From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Apr 2016 21:37:08 +0000 (UTC)
Subject: master - snapshot: Don't deactivate fictional snapshot LV.
Message-ID: <20160414213708.2026460DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0179fac315b630aa4c475d2441dd3b5b12f0c6d
Commit:        f0179fac315b630aa4c475d2441dd3b5b12f0c6d
Parent:        c68fb55ac104079e4708d9b869ef8edd9d1202c4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 14 20:48:28 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 14 22:32:26 2016 +0100

snapshot: Don't deactivate fictional snapshot LV.

Commit 971ab733b74e0ffecc3f9f60af48628cd3fba1db ("thin: activation of
merging thin snapshot") also added an incorrect deactivation attempt
for non-thin LVs: find_snapshot(lv)->lv is not designed to be
activated and any attempt to deactivate it is incorrect.
---
 WHATS_NEW       |    3 ++-
 tools/toollib.c |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f4eb6ad..69ced16 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.151
+Version 2.02.151 -
 =================================
+  Don't try deactivating fictional internal LV before snapshot merge. (2.02.105)
   When not obtaining devs from udev, check they exist before caching them.
   Detect device mismatch also when compiling without udev support.
 
diff --git a/tools/toollib.c b/tools/toollib.c
index ce49773..b1225cd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1022,6 +1022,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		       activation_change_t activate)
 {
 	int r = 1;
+	struct logical_volume *snapshot_lv;
 
 	if (lv_is_cache_pool(lv)) {
 		if (is_change_activating(activate)) {
@@ -1053,7 +1054,8 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		 * User could retry to deactivate it with another
 		 * deactivation of origin, which is the only visible LV
 		 */
-		if (!deactivate_lv(cmd, find_snapshot(lv)->lv)) {
+		snapshot_lv = find_snapshot(lv)->lv;
+		if (lv_is_thin_type(snapshot_lv) && !deactivate_lv(cmd, snapshot_lv)) {
 			if (is_change_activating(activate)) {
 				log_error("Refusing to activate merging \"%s\" while snapshot \"%s\" is still active.",
 					  lv->name, find_snapshot(lv)->lv->name);


