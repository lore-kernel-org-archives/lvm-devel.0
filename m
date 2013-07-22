From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 14:27:38 +0000 (UTC)
Subject: master - snapshot: fix merging
Message-ID: <20130722142738.A3E97614AE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6ded62291682e40c7976d27e48915d9d1538940
Commit:        f6ded62291682e40c7976d27e48915d9d1538940
Parent:        6ca81a091c5a79bee0ec46c21aea643907ab2ca7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 22 16:20:36 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 16:26:00 2013 +0200

snapshot: fix merging

When the merging of snapshot is finished, we need to clean dm table
intries for snapshot and -cow device. So for merging snapshot
we have to activate_lv plain 'cow' LV and let the table
resolver to its work - shortly deactivation_lv() request
will follow - in cluster this needs LV lock to be held by clvmd.

Also update a test - add small wait - if lvremove is not 'fast enough'
and merging process has not been stopped and $lv1 removed in background.
Ortherwise the following lvcreate occasionally finds name $lv1 still in use.

(in release fix)
---
 lib/metadata/snapshot_manip.c |    9 +++++++++
 test/shell/snapshot-merge.sh  |    6 ++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index f949b23..ab28890 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -296,6 +296,15 @@ int vg_remove_snapshot(struct logical_volume *cow)
 			log_error("Failed to resume %s.", origin->name);
 			return 0;
 		}
+
+		/*
+		 * For merged snapshot we activate cow so it can clean
+		 * left table entries and deactivate_lv() follows shortly.
+		 */
+		if (merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
+			log_error("Failed to activate %s.", cow->name);
+			return 0;
+		}
 	}
 
 	return 1;
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 6e59ea7..0713934 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -78,6 +78,12 @@ dm_table $vg-$lv1 | grep " snapshot-merge " || dm_table $vg-$lv1 | grep " linear
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
 
+# wait a while if the merge and remove is still not finished
+# since it may still keep  $lv1  in vg being present
+for i in 1 2 3 4 ; do
+	lvs $vg/$lv1 2>/dev/null || break;
+	sleep .2
+done
 
 # "onactivate merge" test
 # -- deactivate/remove after disallowed merge attempt, tests


