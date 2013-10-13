From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:30:58 +0000 (UTC)
Subject: master - snapshot: deactivate virtual snapshot first
Message-ID: <20131013223058.0C31160CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1146691afc740257d03c7ca53bfa07918a4bc715
Commit:        1146691afc740257d03c7ca53bfa07918a4bc715
Parent:        ac961087b0fe9846f95bedee7687d9ca840b217d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 23:53:28 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 00:25:15 2013 +0200

snapshot: deactivate virtual snapshot first

Since the virtual snapshot has no reason to stay alive once we
detach related snapshot - deactivate whole thing in front of
snapshot removal - otherwice the code would get tricky for
support in cluster.

The correct full solution would require to have transactions
for libdm operations.

Also enable to the check for snapshot being opened prior
the origin deactivation, otherwise we could easily end
with the origin being deactivate, but snapshot still kept
active, desynchronizing locking state in cluster.
---
 WHATS_NEW                     |    1 +
 lib/activate/activate.c       |    2 +-
 lib/metadata/snapshot_manip.c |   10 ++++++++++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 37fe7ad..6539f19 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Add workaround for deactivation problem of opened virtual snapshot.
   Disable unsupported merge for virtual snapshot.
   Move code to remove virtual snapshot from tools to lib for lvm2app.
   Fix possible race during daemon worker thread creation (lvmetad).
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c077113..7621f44 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1929,7 +1929,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_vo
 		goto out;
 	}
 
-	if (lv_is_visible(lv)) {
+	if (lv_is_visible(lv) || lv_is_virtual_origin(lv)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
 			goto_out;
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 325a4e8..fc1273e 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -227,6 +227,16 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	struct logical_volume *origin = origin_from_cow(cow);
 	int is_origin_active = lv_is_active(origin);
 
+	if (is_origin_active &&
+	    lv_is_virtual_origin(origin)) {
+		if (!deactivate_lv(origin->vg->cmd, origin)) {
+			log_error("Failed to deactivate logical volume \"%s\"",
+				  origin->name);
+			return 0;
+		}
+		is_origin_active = 0;
+	}
+
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
 


