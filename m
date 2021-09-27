From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:48 +0000 (GMT)
Subject: main - make: fix compilation for undefined RAID_INTERNAL
Message-ID: <20210927165748.BB5693858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e585c10fade006e5fe3643b76b09501d54c20c9b
Commit:        e585c10fade006e5fe3643b76b09501d54c20c9b
Parent:        6c85ea50de2fbdf2c923b0739171661ecdd63832
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 17:36:29 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

make: fix compilation for undefined RAID_INTERNAL

Reported-by: adamboardman of gemian
---
 lib/metadata/segtype.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index d7cfc2b72..2f4949267 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -326,9 +326,9 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
  */
 #define RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD	(1U << 6) /* version 1.9.0 */
 
+bool raid_is_available(const struct logical_volume *lv);
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
-bool raid_is_available(const struct logical_volume *lv);
 #endif
 
 #define THIN_FEATURE_DISCARDS			(1U << 0)


