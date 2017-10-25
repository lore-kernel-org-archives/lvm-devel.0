From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:04:25 -0400
Subject: master - typo: fix invalid
Message-ID: <201710252004.v9PK4PHd029336@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a0cc696cafd36ee5cd69e15bb4502eb1be22b86
Commit:        0a0cc696cafd36ee5cd69e15bb4502eb1be22b86
Parent:        0e7edd1d2438bab5d08a8d3db47c082d9c4e0b12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 19:39:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:24 2017 +0200

typo: fix invalid

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 390a784..aa61f73 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1949,7 +1949,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	    (lv_is_mirror_type(org) && !lv_is_mirror(org)) ||
 	    (lv_is_raid_type(org) && !lv_is_raid(org)) ||
 	    lv_is_cow(org)) {
-		log_error("Unable to use LV %s as snapshot origin: invald LV type.",
+		log_error("Unable to use LV %s as snapshot origin: invalid LV type.",
 			  display_lvname(lv));
 		return 0;
 	}


