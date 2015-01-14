From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:52 +0000 (UTC)
Subject: master - lv_status: enable lv_status for thinpool
Message-ID: <20150114135452.A153260C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0869631d7d197fec3ea909c243a5e1f2901bea5c
Commit:        0869631d7d197fec3ea909c243a5e1f2901bea5c
Parent:        0b7ccf835bf90b6cb75cdeb6615163835a988107
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 12:51:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:50:08 2015 +0100

lv_status: enable lv_status for thinpool

Support also status for thin pools.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c134e1b..f310a67 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -128,7 +128,7 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	 * linear/striped, old snapshots and raids have proper
 	 * segment selected for status!
 	 */
-	if (strcmp(target_name, "cache"))
+	if (strcmp(target_name, "cache") && strcmp(target_name, "thin-pool"))
 		return 1;
 
 	if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))


