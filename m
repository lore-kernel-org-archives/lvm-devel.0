From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 13:23:11 +0000 (UTC)
Subject: master - clean-up: Remove a FIXME question that has been settled
Message-ID: <20130221132311.7746B1277@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc2ce71313cef15efa2ba0addfb0f4115af80ca6
Commit:        dc2ce71313cef15efa2ba0addfb0f4115af80ca6
Parent:        bd0ee420b597d38e37cfe738951cb1242f527638
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 20 15:03:58 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 20 15:03:58 2013 -0600

clean-up:  Remove a FIXME question that has been settled

It is ok for us to use the shorthand 'lv_is_virtual' to detect error
targets in a RAID LV when searching for candidates for device replacement.
---
 lib/metadata/raid_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f716664..b1ada5c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1675,7 +1675,6 @@ int lv_raid_replace(struct logical_volume *lv,
 			return 0;
 		}
 
-		// FIXME: safe to use 'virtual' as a substitute for 'error'?
 		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
 		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
 		    _lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||


