From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:17 +0000 (UTC)
Subject: master - cleanup: fix typo and use vg mempool
Message-ID: <20140924085717.3AB2F613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30777fa46fb21001f3e5a9ba610d50c57c6dfe27
Commit:        30777fa46fb21001f3e5a9ba610d50c57c6dfe27
Parent:        914be0696daf3603b6db055b2afe146190e9a7f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:16:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: fix typo and use vg mempool

Since we are updating VG -  we can use its own mempool.
---
 lib/metadata/snapshot_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index a52b00c..e6a420f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -283,9 +283,9 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		clear_snapshot_merge(origin);
 		/*
 		 * preload origin IFF "snapshot-merge" target is active
-		 * - IMPORTANT: avoids preload if onactivate merge is pending
+		 * - IMPORTANT: avoids preload if inactivate merge is pending
 		 */
-		if (lv_has_target_type(origin->vg->cmd->mem, origin, NULL,
+		if (lv_has_target_type(origin->vg->vgmem, origin, NULL,
 				       "snapshot-merge")) {
 			/*
 			 * preload origin to:


