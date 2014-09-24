From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:47 +0000 (UTC)
Subject: master - snapshot: add missing vg_revert
Message-ID: <20140924085647.E081C6109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29970b0c177d14dd041f0564a9bdcd0c3429a885
Commit:        29970b0c177d14dd041f0564a9bdcd0c3429a885
Parent:        736f40134b5a9bcc0335a8054d1838129952a5fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:10:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:50:29 2014 +0200

snapshot: add missing vg_revert

Error path missed vg_revert call.
---
 WHATS_NEW                     |    2 +-
 lib/metadata/snapshot_manip.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b0766a0..7f37f24 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -24,7 +24,7 @@ Version 2.02.112 -
   Don't leak alloc_handle on raid target error path.
   Properly validate raid leg names.
   Archive metadata before starting their modification in raid target.
-  Add missing vg_revert in suspend_lv() error path in raid target.
+  Add missing vg_revert() in suspend_lv() raid and snapshot error path.
   Add missing backup of lvm2 metadata after some raid modifications.
   Use vg memory pool for extent allocation.
   Add allocation/physical_extent_size config option for default PE size of VGs.
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 36a685f..a52b00c 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -325,6 +325,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	if (is_origin_active && !suspend_lv(origin->vg->cmd, origin)) {
 		log_error("Failed to refresh %s without snapshot.",
 			  origin->name);
+		vg_revert(origin->vg);
 		return 0;
 	}
 	if (!vg_commit(origin->vg))


