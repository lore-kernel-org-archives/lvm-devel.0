From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:04 +0000 (UTC)
Subject: dev-mornfall-activate - snapshot: add lv_is_cow_covering_origin
Message-ID: <20130604192704.9AFFC61265@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77952151af683eda4210cbfe4f9928f736ee92a9
Commit:        77952151af683eda4210cbfe4f9928f736ee92a9
Parent:        e992cb253cb4c9bf027dd7852d4399d2b439621c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 27 10:18:20 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:34:53 2013 +0200

snapshot: add lv_is_cow_covering_origin

Add function to check is size of cow is already big enough
to cover whole origin.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/snapshot_manip.c    |    7 +++++++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 734e86c..7f6c134 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lv_is_cow_covering_origin() to check if cow covers origin size.
   Use libdm dm_get_status_snapshot() to parse snapshot status.
   Add detection of mounted fs also for vgchange deactivation.
   Replace 'lv_is_active' with more correct/specific variants (e.g. *_locally).
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c3cb116..cd82368 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -717,6 +717,7 @@ int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
+int lv_is_cow_covering_origin(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 11f60d8..a7f57a6 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -31,6 +31,13 @@ int lv_is_cow(const struct logical_volume *lv)
 	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
+int lv_is_cow_covering_origin(const struct logical_volume *lv)
+{
+	/* TODO: we need less then 1% of origin size, depends on chunk size */
+	return lv_is_cow(lv) ?
+		(origin_from_cow(lv)->size * UINT64_C(101) <= lv->size * UINT64_C(100)) : 0;
+}
+
 int lv_is_visible(const struct logical_volume *lv)
 {
 	if (lv->status & SNAPSHOT)


