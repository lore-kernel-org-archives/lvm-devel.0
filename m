From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:04:37 +0000 (UTC)
Subject: master - libdm: use dm_bit_get_last() in _stats_group_tag_fill()
Message-ID: <20161213210437.67033603B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8d966bc31741f846dc6d0d4af9a565d19560b98
Commit:        e8d966bc31741f846dc6d0d4af9a565d19560b98
Parent:        5d1d65e735b6dcc5f02d0e536e3b63617f40ce83
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 10:32:29 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 21:02:18 2016 +0000

libdm: use dm_bit_get_last() in _stats_group_tag_fill()

Instead of iterating over all bits, use dm_bit_get_last() to find
the last set bit in the group bitmap.
---
 libdm/libdm-stats.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 471bd7b..8210a93 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1716,9 +1716,7 @@ static size_t _stats_group_tag_fill(const struct dm_stats *dms,
 	int i, j, r, next, last = 0;
 	size_t used = 0;
 
-	i = dm_bit_get_first(regions);
-	for (; i >= 0; i = dm_bit_get_next(regions, i))
-		last = i;
+	last = dm_bit_get_last(regions);
 
 	i = dm_bit_get_first(regions);
 	for(; i >= 0; i = dm_bit_get_next(regions, i)) {


