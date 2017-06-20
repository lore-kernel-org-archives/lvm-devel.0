From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 20 Jun 2017 12:43:51 -0400
Subject: master - raid: provide clickable URL BZ references
Message-ID: <201706201643.v5KGhp3X014558@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dfe1bc29d0ba4da31e83e25d338bfe46209c96c
Commit:        0dfe1bc29d0ba4da31e83e25d338bfe46209c96c
Parent:        710f51e7f24bfc6c4e4300e4bec3316796bf0c78
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 20 18:42:09 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 20 18:43:26 2017 +0200

raid: provide clickable URL BZ references

---
 lib/metadata/raid_manip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6d3a509..a832f7b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -75,7 +75,7 @@ static int _rebuild_with_emptymeta_is_supported(struct cmd_context *cmd,
 	return 1;
 }
 
-/* BZ1447812: check open count of @lv vs. @open_count */
+/* https://bugzilla.redhat.com/1447812 check open count of @lv vs. @open_count */
 static int _check_lv_open_count(struct logical_volume *lv, int open_count) {
 	struct lvinfo info = { 0 };
 
@@ -2399,7 +2399,7 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	seg->region_size = new_region_size;
 
-	/* BZ1447812: also check open count */
+	/* https://bugzilla.redhat.com/1447812 also check open count */
 	if (!_check_lv_open_count(lv, 1))
 		return 0;
 
@@ -6242,7 +6242,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	return r;
 }
 
-/* BZ1447812: try opening LV exclusively */
+/* https://bugzilla.redhat.com/1447812 try opening LV exclusively */
 static int _lv_open_excl(struct logical_volume *lv, struct device **dev) {
 	char *dev_path;
 	size_t sz = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
@@ -6363,7 +6363,7 @@ int lv_raid_convert(struct logical_volume *lv,
 					 new_stripes, new_stripe_size_supplied))
 		return _log_possible_conversion_types(lv, new_segtype);
 
-	/* BZ1439399 */
+	/* https://bugzilla.redhat.com/1439399 */
 	if (lv_is_origin(lv)) {
 		log_error("Can't convert snapshot origin %s.", display_lvname(lv));
 		return 0;
@@ -6382,7 +6382,7 @@ int lv_raid_convert(struct logical_volume *lv,
 			return 0;
 		}
 
-		/* BZ1447812: reject reshape on open LV */
+		/* https://bugzilla.redhat.com/1447812 reject reshape on open LV */
 		if (!_check_lv_open_count(lv, 0))
 			return 0;
 		if (!_lv_open_excl(lv, &dev))


