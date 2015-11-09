From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:16 +0000 (UTC)
Subject: master - raid: mark intententional copy and paste
Message-ID: <20151109092916.DABC86053B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57c2a1ae8c9f59d301ff34068fa893f04f713fe2
Commit:        57c2a1ae8c9f59d301ff34068fa893f04f713fe2
Parent:        846adadbcc0356e2642ac211de3235f2bfb105a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:30:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

raid: mark intententional copy and paste

Coverity: add this extra comment, to let Coverity know this
slightly changed copy&paste code is intentional.
---
 lib/metadata/raid_manip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c420733..ee1f2be 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1802,6 +1802,7 @@ try_again:
 			lvl = dm_list_item(dm_list_first(&new_data_lvs),
 					   struct lv_list);
 			dm_list_del(&lvl->list);
+			/* coverity[copy_paste_error] intentional */
 			if (!(tmp_names[sd] = _generate_raid_name(lv, "rimage", s)))
 				return_0;
 			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,


