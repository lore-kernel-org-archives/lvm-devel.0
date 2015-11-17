From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:35 +0000 (UTC)
Subject: master - raid: drop unneeded NULL test
Message-ID: <20151117180135.EC87A60F16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cad3568def7f82ae58c3585a94ceb377bb155167
Commit:        cad3568def7f82ae58c3585a94ceb377bb155167
Parent:        51dfba002b05cc65346b539b4b030f0c2dfffeaf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:17:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

raid: drop unneeded NULL test

Skip testing target_pvs for NULL, we already
dereference it in many other places.
If check would ever be needed - it needs to be
in front of _raid_extract_images().
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4b2cb61..b99b671 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -913,7 +913,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 				  display_lvname(seg_lv(seg, s)));
 		} else {
 			/* Conditions for second pass */
-			if (!target_pvs || !lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
 			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
 


