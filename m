From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:31 +0000 (UTC)
Subject: master - snapshot: check snapshot exists
Message-ID: <20140617132431.815B661207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c46d4a745dc8c5cb4cfc0c94863e555387e9af75
Commit:        c46d4a745dc8c5cb4cfc0c94863e555387e9af75
Parent:        435c82f8f6312758e1d198d4cb0a2158b7a51bac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 12:41:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:36:07 2014 +0200

snapshot: check snapshot exists

Return 0 if the LV is not even snapshot.
---
 lib/metadata/snapshot_manip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5df0f98..278edc8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -141,8 +141,9 @@ int lv_is_merging_origin(const struct logical_volume *origin)
 
 int lv_is_merging_cow(const struct logical_volume *snapshot)
 {
+	struct lv_segment *snap_seg = find_snapshot(snapshot);
 	/* checks lv_segment's status to see if cow is merging */
-	return (find_snapshot(snapshot)->status & MERGING) ? 1 : 0;
+	return (snap_seg && (snap_seg->status & MERGING)) ? 1 : 0;
 }
 
 struct lv_segment *find_snapshot(const struct logical_volume *lv)


