From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:12 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: skip unused assign
Message-ID: <20140922153812.1A1C560D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae08a3a2945b277af81a4cff42c6dcfb26f12fae
Commit:        ae08a3a2945b277af81a4cff42c6dcfb26f12fae
Parent:        07b3e6cd746ed7633c6ce2540c675797c04a34b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:39:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:31 2014 +0200

cleanup: skip unused assign

Reset of tmp_names is only needed in else{} path.
---
 lib/metadata/raid_manip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b72b839..c9ac405 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1712,9 +1712,7 @@ try_again:
 	 */
 
 	for (s = 0; s < raid_seg->area_count; s++) {
-		tmp_names[s] = NULL;
 		sd = s + raid_seg->area_count;
-		tmp_names[sd] = NULL;
 
 		if ((seg_type(raid_seg, s) == AREA_UNASSIGNED) &&
 		    (seg_metatype(raid_seg, s) == AREA_UNASSIGNED)) {
@@ -1745,7 +1743,8 @@ try_again:
 				return 0;
 			}
 			lv_set_hidden(lvl->lv);
-		}
+		} else
+			tmp_names[s] = tmp_names[sd] = NULL;
 	}
 
 	if (!lv_update_and_reload_origin(lv))


