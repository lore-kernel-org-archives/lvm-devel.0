From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 6 Apr 2017 13:24:37 -0400
Subject: master - lvconvert: raid1 -> linear prompt
Message-ID: <201704061724.v36HObAH011051@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=653bca6811d6e0928afb9de01d7baa7baaf23010
Commit:        653bca6811d6e0928afb9de01d7baa7baaf23010
Parent:        3b1a96b9b3650f8776e9d09573bc7754f283e234
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 19:24:11 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 19:24:11 2017 +0200

lvconvert: raid1 -> linear prompt

Avoid 2 prompts when downconverting raid1 to linear
(related commit 0f65d7ec3a7325165af1a9f722cb760fd363e932).
---
 lib/metadata/raid_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f360254..f522fe2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3000,9 +3000,10 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 {
 	struct lv_segment *seg = first_seg(lv);
 	const char *level = seg->area_count == 1 ? "raid1 with " : "";
-	const char *resil = new_count == 1 ? " loosing all" : (new_count < seg->area_count ? "s reducing" : "s enhancing");
+	const char *resil = new_count < seg->area_count ? "reducing" : "enhancing";
 
-	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s%u image%s resilience? [y/n]: ",
+	if (new_count != 1 && /* Already prompted for in _raid_remove_images() */
+	    !yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s%u images %s resilience? [y/n]: ",
 				  lvseg_name(first_seg(lv)), display_lvname(lv), level, new_count, resil) == 'n') {
 		log_error("Logical volume %s NOT converted.", display_lvname(lv));
 		return 0;


