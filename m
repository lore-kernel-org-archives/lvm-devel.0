From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 12 Apr 2017 11:35:37 -0400
Subject: master - Typo: change loose to lose
Message-ID: <201704121535.v3CFZbuM013701@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba12a2e81a319c22353c8e52bf29f55c924b2d9f
Commit:        ba12a2e81a319c22353c8e52bf29f55c924b2d9f
Parent:        532388fad510c7ba706ecbd4b5fbd2643134d63b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Apr 12 10:28:19 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Apr 12 10:28:19 2017 -0500

Typo: change loose to lose

loose (v): set free; release
lose (v) : be deprived of or cease to have or retain

We 'lose' redundancy or 'lose' meaning.
---
 daemons/cmirrord/cluster.c |    2 +-
 lib/metadata/raid_manip.c  |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index e196eb2..94be563 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -182,7 +182,7 @@ int cluster_send(struct clog_request *rq)
 	}
 
 	/*
-	 * Once the request heads for the cluster, the luid looses
+	 * Once the request heads for the cluster, the luid loses
 	 * all its meaning.
 	 */
 	rq->u_rq.luid = 0;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9614179..b58ba2d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2932,7 +2932,7 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 
 	/* Convert to linear? */
 	if (new_count == 1) {
-		if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to type %s loosing all resilience? [y/n]: ",
+		if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to type %s losing all resilience? [y/n]: ",
 					  lvseg_name(first_seg(lv)), display_lvname(lv), SEG_TYPE_NAME_LINEAR) == 'n') {
 			log_error("Logical volume %s NOT converted to \"%s\".",
 				  display_lvname(lv), SEG_TYPE_NAME_LINEAR);
@@ -3072,9 +3072,9 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 		return 0;
 	}
 
-	/* Split on a 2-legged raid1 LV causes loosing all resilience */
+	/* Split on a 2-legged raid1 LV causes losing all resilience */
 	if (new_count == 1 &&
-	    !yes && yes_no_prompt("Are you sure you want to split %s LV %s loosing all resilience? [y/n]: ",
+	    !yes && yes_no_prompt("Are you sure you want to split %s LV %s losing all resilience? [y/n]: ",
 				  lvseg_name(first_seg(lv)), display_lvname(lv)) == 'n') {
 		log_error("Logical volume %s NOT split.", display_lvname(lv));
 		return 0;
@@ -3214,9 +3214,9 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
-	/* Split and track changes on a 2-legged raid1 LV causes loosing resilience for newly written data. */
+	/* Split and track changes on a 2-legged raid1 LV causes losing resilience for newly written data. */
 	if (seg->area_count == 2 &&
-	    !yes && yes_no_prompt("Are you sure you want to split and track %s LV %s loosing resilience for any newly written data? [y/n]: ",
+	    !yes && yes_no_prompt("Are you sure you want to split and track %s LV %s losing resilience for any newly written data? [y/n]: ",
 				  lvseg_name(seg), display_lvname(lv)) == 'n') {
 		log_error("Logical volume %s NOT split.", display_lvname(lv));
 		return 0;


