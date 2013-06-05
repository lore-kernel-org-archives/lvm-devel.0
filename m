From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:01:37 +0000 (UTC)
Subject: dev-mornfall-lvmcache - raid: test for target_pvs
Message-ID: <20130605120137.CFEE761134@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24f8daa13d82869fbe088f7edf3c95c11660b186
Commit:        24f8daa13d82869fbe088f7edf3c95c11660b186
Parent:        9e24d563c6e281a582bf1a98673305ce88d6cd05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 12:53:04 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:07:00 2013 +0200

raid: test for target_pvs

If target_pvs is NULL do not call lv_is_on_pvs()
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 38ea2c2..f9d3861 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -934,7 +934,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 				  seg_metalv(seg, s)->name, seg_lv(seg, s)->name);
 		} else {
 			/* Conditions for second pass */
-			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+			if (!target_pvs || !lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
 			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
 


