From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:27 +0000 (UTC)
Subject: dev-mornfall-activate - snapshot: fix check for snapshot-merge target presence
Message-ID: <20130604192627.203DC61020@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f6c2951d6495ee335ab69da44ae2647cd341276
Commit:        4f6c2951d6495ee335ab69da44ae2647cd341276
Parent:        f12d88f840474a75a58d1f7ae8d391ec5852b850
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 16 08:12:37 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 16 08:17:18 2013 +0200

snapshot: fix check for snapshot-merge target presence

If calling _snap_target_present on 2nd and later call and for
a segment with MERGING flag set, we must return the status of
snapshot as well as snapshot-merge target presence, not just
the snapshot one.
---
 lib/snapshot/snapshot.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 3c03ea9..2bab9d2 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -162,9 +162,11 @@ static int _snap_target_present(struct cmd_context *cmd,
 		_snap_checked = 1;
 	}
 
-	if (!_snap_merge_checked && seg && (seg->status & MERGING)) {
-		_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
-		_snap_merge_checked = 1;
+	if (seg && (seg->status & MERGING)) {
+		if (!_snap_merge_checked) {
+			_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
+			_snap_merge_checked = 1;
+		}
 		return _snap_present && _snap_merge_present;
 	}
 


