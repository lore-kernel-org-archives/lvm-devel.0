From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Sep 2020 14:16:39 +0000 (GMT)
Subject: master - integrity: fix segfault for lv with no seg
Message-ID: <20200902141639.CF4AB388C02B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a7b81fb7262dbd896b74bc76a98f070a9309fed
Commit:        9a7b81fb7262dbd896b74bc76a98f070a9309fed
Parent:        739827ef1c1a256114aa0b2a385baa0983fac289
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 2 09:15:58 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 2 09:15:58 2020 -0500

integrity: fix segfault for lv with no seg

in lv_raid_has_integrity
---
 lib/metadata/integrity_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 6b2d352a7..5854a2a52 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -847,7 +847,8 @@ int lv_raid_has_integrity(struct logical_volume *lv)
 	struct lv_segment *seg, *seg_image;
 	uint32_t s;
 
-	seg = first_seg(lv);
+	if (!(seg = first_seg(lv)))
+		return 0;
 
 	if (seg_is_raid(seg)) {
 		for (s = 0; s < seg->area_count; s++) {


