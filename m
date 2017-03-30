From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 12:09:22 -0400
Subject: master - raid: address coverity issues
Message-ID: <201703301609.v2UG9MqT012667@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d75ef3b057fac5df66dee97b1cf93a582258582
Commit:        2d75ef3b057fac5df66dee97b1cf93a582258582
Parent:        b3854155d9331868a92324b4ac6f03d04dd59baa
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 18:09:06 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 18:09:06 2017 +0200

raid: address coverity issues

---
 lib/metadata/raid_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4d20639..ed0f4c1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -937,11 +937,12 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 static char *_generate_raid_name(struct logical_volume *lv,
 				 const char *suffix, int count)
 {
-	const char *format = (count >= 0) ? "%s_%s_%u" : "%s_%s";
 	char name[NAME_LEN], *lvname;
 	int historical;
 
-	if (dm_snprintf(name, sizeof(name), format, lv->name, suffix, count) < 0) {
+	if (dm_snprintf(name, sizeof(name), 
+			(count >= 0) ? "%s_%s_%u" : "%s_%s",
+			lv->name, suffix, count) < 0) {
 		log_error("Failed to new raid name for %s.",
 			  display_lvname(lv));
 		return NULL;
@@ -1701,7 +1702,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 
 	/* Externally visible LV size w/o reshape space */
 	lv->le_count = seg->len = new_le_count;
-	lv->size = (uint64_t) (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
+	lv->size = (uint64_t) (lv->le_count - new_image_count * (uint32_t) _reshape_len_per_dev(seg)) * lv->vg->extent_size;
 	/* seg->area_len does not change */
 
 	if (old_image_count < new_image_count) {


