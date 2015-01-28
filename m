From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 12:45:55 +0000 (UTC)
Subject: master - raid: fix raid image splitting
Message-ID: <20150128124555.0ECC260314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93b90157605f557cd4b0e48c38e6f290eaa871b1
Commit:        93b90157605f557cd4b0e48c38e6f290eaa871b1
Parent:        b254d330e4410e3eb10ab65fbe892ba56f95e2e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 13:39:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 13:45:18 2015 +0100

raid: fix raid image splitting

When raid leg is extracted, now the preload code handles this state
correctly and put proper new table entry into dm tree,
so the activation of extracted leg and removed metadata works
after commit.
---
 WHATS_NEW                    |    1 +
 lib/metadata/raid_manip.c    |   30 ++++++++++--------------------
 test/shell/lvconvert-raid.sh |    6 ++++++
 3 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1424fab..45a02d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Fix raid --splitmirror 1 functionality (2.02.112).
   Fix tree preload to handle splitting raid images.
   Do not support unpartitioned DASD devices.
   Improve config validation to check if setting with string value can be empty.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5c2ca95..4ce84a0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1149,12 +1149,6 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
-	if (!resume_lv(lv->vg->cmd, lv_lock_holder(lv))) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
 	/*
 	 * First activate the newly split LV and LVs on the removal list.
 	 * This is necessary so that there are no name collisions due to
@@ -1164,26 +1158,22 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
 
+	dm_list_iterate_items(lvl, &removal_list)
+		if (!activate_lv_excl_local(cmd, lvl->lv))
+			return_0;
+
+	if (!resume_lv(cmd, lv_lock_holder(lv))) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/*
 	 * Since newly split LV is typically already active - we need to call
 	 * suspend() and resume() to also rename it.
 	 *
 	 * TODO: activate should recognize it and avoid these 2 calls
 	 */
-	if (!suspend_lv(cmd, lvl->lv)) {
-		log_error("Failed to suspend %s.", lvl->lv->name);
-		return 0;
-	}
-
-	if (!resume_lv(cmd, lvl->lv)) {
-		log_error("Failed to reactivate %s.", lvl->lv->name);
-		return 0;
-	}
-
-	dm_list_iterate_items(lvl, &removal_list)
-		if (!activate_lv_excl_local(cmd, lvl->lv))
-			return_0;
-
 
 	/*
 	 * Eliminate the residual LVs
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 8621311..12e0420 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -121,6 +121,12 @@ check active $vg $lv2
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
+# 4-way
+lvcreate --type raid1 -m 4 -l 2 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvconvert --yes --splitmirrors 1 --name $lv2 $vg/$lv1 "$dev2"
+lvremove -ff $vg
+
 ###########################################
 # RAID1 split + trackchanges / merge
 ###########################################


