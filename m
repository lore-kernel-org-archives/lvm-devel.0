From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:58 +0000 (UTC)
Subject: master - cleanup: use display_lvname
Message-ID: <20151109092858.0156F601A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ba219e87a37cd18aa75971370254ed1fbdfde53
Commit:        5ba219e87a37cd18aa75971370254ed1fbdfde53
Parent:        04f76d9020dc1301540c949e0a0212e1ad44ff6d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 5 12:29:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: use display_lvname

---
 lib/metadata/lv_manip.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fbb5322..74b574a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4018,13 +4018,12 @@ int lv_extend(struct logical_volume *lv,
 			dm_percent_t sync_percent = DM_PERCENT_INVALID;
 
 			if (!lv_is_active_locally(lv)) {
-				log_error("%s/%s is not active locally."
-					  "  Unable to get sync percent.",
-					  lv->vg->name, lv->name);
+				log_error("Unable to read sync percent while LV %s "
+					  "is not locally active.", display_lvname(lv));
 				/* FIXME Support --force */
 				if (yes_no_prompt("Do full resync of extended "
-						  "portion of %s/%s?  [y/n]: ",
-						  lv->vg->name, lv->name) == 'n') {
+						  "portion of %s?  [y/n]: ",
+						  display_lvname(lv)) == 'n') {
 					r = 0;
 					goto_out;
 				}
@@ -4033,19 +4032,18 @@ int lv_extend(struct logical_volume *lv,
 
 			if (!(r = lv_mirror_percent(lv->vg->cmd, lv, 0,
 						    &sync_percent, NULL))) {
-				log_error("Failed to get sync percent for %s/%s",
-					  lv->vg->name, lv->name);
+				log_error("Failed to get sync percent for %s.",
+					  display_lvname(lv));
 				goto out;
 			} else if (sync_percent == DM_PERCENT_100) {
 				log_verbose("Skipping initial resync for "
-					    "extended portion of %s/%s",
-					    lv->vg->name, lv->name);
+					    "extended portion of %s",
+					    display_lvname(lv));
 				init_mirror_in_sync(1);
 				lv->status |= LV_NOTSYNCED;
 			} else {
-				log_error("%s/%s cannot be extended while"
-					  " it is recovering.",
-					  lv->vg->name, lv->name);
+				log_error("LV %s cannot be extended while it "
+					  "is recovering.", display_lvname(lv));
 				r = 0;
 				goto out;
 			}


