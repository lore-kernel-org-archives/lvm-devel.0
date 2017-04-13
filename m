From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 13 Apr 2017 16:19:45 -0400
Subject: master - lvconvert: typo in message
Message-ID: <201704132019.v3DKJjHB032163@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15c3ad9641deaee64f4c645a87d191adb098035e
Commit:        15c3ad9641deaee64f4c645a87d191adb098035e
Parent:        0ea9a15612e5a5527ca9747b402884a4e864b236
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 13 22:19:29 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 13 22:19:29 2017 +0200

lvconvert: typo in message

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 34ac2a6..173b5bf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2985,7 +2985,7 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, int yes, uint3
 	uint32_t old_count = lv_raid_image_count(lv);
 
 	if (old_count == new_count) {
-		log_warn("WARGNING: %s already has image count of %d.",
+		log_warn("WARNING: %s already has image count of %d.",
 			 display_lvname(lv), new_count);
 		return 1;
 	}


