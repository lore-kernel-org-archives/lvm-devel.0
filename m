From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 27 Jul 2016 21:15:18 +0000 (UTC)
Subject: master - vg_validate: add missing check for raid6 segment types
Message-ID: <20160727211518.DE5A66118F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d46de28a6c6107dceec1c61b76234e84c421b840
Commit:        d46de28a6c6107dceec1c61b76234e84c421b840
Parent:        df02917d7eef511f16edb195198f5f85583b44f0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 27 23:14:46 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 27 23:14:46 2016 +0200

vg_validate: add missing check for raid6 segment types

---
 lib/metadata/merge.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 681ec72..33aa421 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -308,6 +308,7 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 		_check_raid1_seg(seg, error_count);
 	else if (seg_is_raid4(seg) ||
 		 seg_is_any_raid5(seg) ||
+		 seg_is_any_raid6(seg) ||
 		 seg_is_raid10(seg))
 		_check_raid45610_seg(seg, error_count);
 	else


