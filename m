From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 24 May 2017 07:48:09 -0400
Subject: master - Fix typo
Message-ID: <201705241148.v4OBm9XD028273@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3da5cdc5dc5cca04dae105c5a33c87d1c99a5b6c
Commit:        3da5cdc5dc5cca04dae105c5a33c87d1c99a5b6c
Parent:        7a0f46e2f87f28e17c0ea6b6d58ffd90b37bc6f0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 24 13:47:45 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed May 24 13:47:45 2017 +0200

Fix typo

---
 lib/metadata/merge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 3d82a05..e642459 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -222,7 +222,7 @@ static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count
 }
 
 /*
- * Check RAID segment sruct members of @seg for acceptable
+ * Check RAID segment struct members of @seg for acceptable
  * properties and increment @error_count for any bogus ones.
  */
 static void _check_raid_seg(struct lv_segment *seg, int *error_count)


