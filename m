From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 08:04:17 -0400
Subject: master - raid: update path for repair
Message-ID: <201706211204.v5LC4HCI005856@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48f06005ab53420241e0c1da3a56a8f5c1a28974
Commit:        48f06005ab53420241e0c1da3a56a8f5c1a28974
Parent:        5f4cfa7c4a6da707354f8c1c059531dac5287192
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 13:57:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 14:00:50 2017 +0200

raid: update path for repair

Updating path from commit 61980bcf0624790bfdc07d371fd510d1c4079fb5.

When repair is running, no removing PVS are given so it shall return
success in such case.
---
 lib/metadata/raid_manip.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 34545b4..9e4f3a3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6661,9 +6661,14 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	}
 
 	if (!match_count) {
-		log_error("Logical volume %s does not contain devices specified to %s.",
-			  display_lvname(lv), action_str);
-		return 0;
+		if (remove_pvs && !dm_list_empty(remove_pvs)) {
+			log_error("Logical volume %s does not contain devices specified to %s.",
+				  display_lvname(lv), action_str);
+			return 0;
+		}
+		log_print_unless_silent("%s does not contain devices specified to %s.",
+					display_lvname(lv), action_str);
+		return 1;
 	} else if (match_count == raid_seg->area_count) {
 		log_error("Unable to %s all PVs from %s at once.",
 			  action_str, display_lvname(lv));


