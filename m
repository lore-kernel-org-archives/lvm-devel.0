From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 06:36:56 -0400
Subject: master - raid: report error when specified devices are not contained
Message-ID: <201706211036.v5LAauHk021062@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61980bcf0624790bfdc07d371fd510d1c4079fb5
Commit:        61980bcf0624790bfdc07d371fd510d1c4079fb5
Parent:        31d153ced07dda004cff3a67a6e9a740b52253fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 11:45:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 12:35:17 2017 +0200

raid: report error when specified devices are not contained

lvm2 always return non-zero error code when action cannot happen.
---
 lib/metadata/raid_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ab89bdf..31fb0f7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6660,9 +6660,9 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	}
 
 	if (!match_count) {
-		log_print_unless_silent("%s does not contain devices specified to %s.",
-					display_lvname(lv), action_str);
-		return 1;
+		log_error("Logical volume %s does not contain devices specified to %s.",
+			  display_lvname(lv), action_str);
+		return 0;
 	} else if (match_count == raid_seg->area_count) {
 		log_error("Unable to %s all PVs from %s at once.",
 			  action_str, display_lvname(lv));


