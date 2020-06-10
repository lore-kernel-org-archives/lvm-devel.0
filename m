From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:46 +0000 (GMT)
Subject: master - writecache: allow snapshot of LV with writecache
Message-ID: <20200610173146.2E6FB388F070@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38eaa1035b13ba1633d0002fa53071d5b7098ef9
Commit:        38eaa1035b13ba1633d0002fa53071d5b7098ef9
Parent:        712c9efbf6104a863b610a006e72d7da8336fa7e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 13 15:58:28 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:18:00 2020 -0500

writecache: allow snapshot of LV with writecache

---
 lib/metadata/snapshot_manip.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 3faea0eb8..0f48e62e8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -389,8 +389,6 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 		err = "raid subvolumes";
 	} else if (lv_is_raid(origin_lv) && lv_raid_has_integrity((struct logical_volume *)origin_lv)) {
 		err = "raid with integrity";
-	} else if (lv_is_writecache(origin_lv)) {
-		err = "writecache";
 	}
 
 	if (err) {


