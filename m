From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:58 +0100
Subject: [PATCH 4/6] Use dm_pool_set_uint64
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <33e9694717f50fe65664cfa9e0ebe00d0e18ea7c.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the new dm_pool API call for the update of content of the locked
shared VG mempool.  Save the original value of the VG into an extra
allocated volatile area.  Currently only simple preallocated memory
area is used - with expectation there should not be too many updates here.

Otherwisee more effective algorithm would be needed to get better perfomance.
(most probably some resizable heap??)

Original code is kept in comments to make it more obvious what it is
supposed to do.

Note:  (snapshot is kept 64bit aligned in union)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c       |    5 ++++-
 lib/metadata/lv.h             |    5 ++++-
 lib/metadata/snapshot_manip.c |   15 ++++++++++++---
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1ec518d..4d257f1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1411,7 +1411,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	lv_calculate_readahead(lv, NULL);
 
 	if (exclusive)
-		lv->status |= ACTIVATE_EXCL;
+		/* lv->status |= ACTIVATE_EXCL */
+		if (!dm_pool_set_uint64(lv->vg->vgmem, &lv->status,
+					lv->status | ACTIVATE_EXCL))
+			goto_out;
 
 	critical_section_inc(cmd);
 	if (!(r = _lv_activate_lv(lv, 0)))
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 1c3640b..66db813 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -38,7 +38,10 @@ struct logical_volume {
 
 	uint32_t origin_count;
 	struct dm_list snapshot_segs;
-	struct lv_segment *snapshot;
+	union {
+		struct lv_segment *snapshot;
+		uint64_t snapshot_64;	/* Keep the size 64bit on 32bit arch */
+	};
 
 	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
 	struct dm_list rsites;	/* For replicators - all sites */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index cb5df6b..0dc8620 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -130,9 +130,18 @@ void init_snapshot_merge(struct lv_segment *cow_seg,
 void clear_snapshot_merge(struct logical_volume *origin)
 {
 	/* clear merge attributes */
-	origin->snapshot->status &= ~MERGING;
-	origin->snapshot = NULL;
-	origin->status &= ~MERGING;
+
+	/* origin->snapshot->status &= ~MERGING */
+	/* origin->snapshot = NULL */
+	/* origin->status &= ~MERGING */
+	if (!dm_pool_set_uint64(origin->vg->vgmem,
+				&origin->snapshot->status,
+				origin->snapshot->status & ~MERGING) ||
+	    !dm_pool_set_uint64(origin->vg->vgmem,
+				&origin->snapshot_64, 0) ||
+	    !dm_pool_set_uint64(origin->vg->vgmem, &origin->status,
+				origin->status & ~MERGING))
+		stack; /* FIXME: change to return error value */
 }
 
 int vg_add_snapshot(struct logical_volume *origin,
-- 
1.7.4.1


