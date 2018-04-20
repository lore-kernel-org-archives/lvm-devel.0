From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:17 -0400
Subject: master - pvmove: support properly subLV locking
Message-ID: <201804201101.w3KB1HD2030979@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ace97c9f9cdc6f0bfd33ae465404169a33953c1e
Commit:        ace97c9f9cdc6f0bfd33ae465404169a33953c1e
Parent:        7a7b8a7778aace88c967ee8285485c494ce1f3f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 27 21:08:40 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:03:16 2018 +0200

pvmove: support properly subLV locking

Since we support snapshot of mirrors, we do need to properly check
for stacked lock holder - fixes problem of pvmove in cluster
with mirrors under snapshot.

WHATS_NEW for this patch goes with 'Restore pvmove support...'
---
 tools/pvmove.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 2a26a10..84efdf4 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -393,10 +393,15 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		}
 
 		seg = first_seg(lv);
-
-		/* Presence of exclusive LV decides whether pvmove must be also exclusive */
-		if ((seg_only_exclusive(seg) || lv_is_origin(lv) || lv_is_cow(lv)))
-			needs_exclusive = 1;
+		if (!needs_exclusive) {
+			/* Presence of exclusive LV decides whether pvmove must be also exclusive */
+			if (!seg_only_exclusive(seg)) {
+				holder = lv_lock_holder(lv);
+				if (seg_only_exclusive(first_seg(holder)) || lv_is_origin(holder) || lv_is_cow(holder))
+					needs_exclusive = 1;
+			} else
+				needs_exclusive = 1;
+		}
 
 		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
 			dm_list_init(&trim_list);


