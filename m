From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon,  7 Mar 2016 14:25:45 +0000 (UTC)
Subject: master - raid_manip: allow for raid leg to be replaced when not both data and metadata image are on pvs
Message-ID: <20160307142545.8D73160DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18cf5e8e6758db59c9413bd9c9abcc183c49293d
Commit:        18cf5e8e6758db59c9413bd9c9abcc183c49293d
Parent:        d03b1779b4e2edaec221e2c29d3384d4c86052cd
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Mar 7 15:25:30 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Mar 7 15:25:30 2016 +0100

raid_manip: allow for raid leg to be replaced when not both data and metadata image are on pvs

resolves rhbz#1130329
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3b9f81c..887b27f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -914,7 +914,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 				  display_lvname(seg_lv(seg, s)));
 		} else {
 			/* Conditions for second pass */
-			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) &&
 			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
 


