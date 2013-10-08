From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:42:35 +0000 (UTC)
Subject: master - thin: fix lvconvert in external origin conversion
Message-ID: <20131008114235.812A760F40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92bafade6051f95d49b35a53c77d0fc25a1fb7ec
Commit:        92bafade6051f95d49b35a53c77d0fc25a1fb7ec
Parent:        30746f31dd1db63e0c83e6f8c7ae65dab3f69a4b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 13:24:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 13:41:06 2013 +0200

thin: fix lvconvert in external origin conversion

Patch 562ad293fd52b8f3096b28bcac20e32aa1e8c1b0 introduced code regression
when LV was converted to a thin LV with external origin and at the same time,
conversion of LV to a thin pool has been requested.
(RHBZ: #997704)

data_lv needs to be assigned after test for external conversion find pool.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 93a156a..cd9f00a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,6 +2,7 @@ Version 2.02.104
 ===================================
   Improve message when unable to change discards setting on active thin pool.
   Run full scan before vgrename operation to avoid any cache name collision.
+  Fix lvconvert when converting to a thin pool and thin LV at once.
 
 Version 2.02.103 - 4th October 2013
 ===================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 49881fa..1970ca3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2266,7 +2266,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	int r = 0;
 	const char *old_name;
 	struct lv_segment *seg;
-	struct logical_volume *data_lv = pool_lv;
+	struct logical_volume *data_lv;
 	struct logical_volume *metadata_lv;
 	struct logical_volume *pool_metadata_lv;
 	struct logical_volume *external_lv = NULL;
@@ -2304,6 +2304,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 	}
 
+	data_lv = pool_lv;
 	if (lv_is_thin_type(pool_lv) && !lp->pool_metadata_lv_name) {
 		log_error("Can't use thin logical volume %s/%s for thin pool data.",
 			  pool_lv->vg->name, pool_lv->name);


