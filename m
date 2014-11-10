From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:08 +0000 (UTC)
Subject: master - raid: fix activation order
Message-ID: <20141110210608.C500D60E17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62c7027a7c675dfef8f772b1e20ac18705b847a9
Commit:        62c7027a7c675dfef8f772b1e20ac18705b847a9
Parent:        32e4af6479689c4e25ecd273368d22136c93a75d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 22:04:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

raid: fix activation order

Cannot 'activate' volumes in suspend state and we need to use
lock holding LV for suspend/resume.
---
 lib/metadata/raid_manip.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5237dc9..5eab551 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1136,7 +1136,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
-	if (!suspend_lv(cmd, lv)) {
+	if (!suspend_lv(cmd, lv_lock_holder(lv))) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
 		vg_revert(lv->vg);
@@ -1149,6 +1149,12 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
+	if (!resume_lv(lv->vg->cmd, lv_lock_holder(lv))) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/*
 	 * First activate the newly split LV and LVs on the removal list.
 	 * This is necessary so that there are no name collisions due to
@@ -1162,11 +1168,6 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		if (!activate_lv_excl_local(cmd, lvl->lv))
 			return_0;
 
-	if (!resume_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
 
 	/*
 	 * Eliminate the residual LVs


