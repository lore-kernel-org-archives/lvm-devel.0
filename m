From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:31 +0000 (UTC)
Subject: master - cleanup: move detection of change mode before commit point
Message-ID: <20130718162631.314AF6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8fc77bd6d8986c5c289d4deaaab0120d646b077
Commit:        e8fc77bd6d8986c5c289d4deaaab0120d646b077
Parent:        20187fc190c248c556fdc44f5651eaa99219d2fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:25:16 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:42 2013 +0200

cleanup: move detection of change mode before commit point

Following patch will need to know change state before commit point.
Also the test mode should properly report all ongoing operation.
---
 lib/metadata/lv_manip.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0999bd0..7815e53 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5685,13 +5685,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	lv_set_activation_skip(lv, lp->activation_skip & ACTIVATION_SKIP_SET,
 			       lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED);
-
-	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_NULL;
-
-	backup(vg);
-
 	/*
 	 * Check for autoactivation.
 	 * If the LV passes the auto activation filter, activate
@@ -5701,17 +5694,23 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		lp->activate = lv_passes_auto_activation_filter(cmd, lv) ?
 				CHANGE_ALY : CHANGE_ALN;
 
-	if (test_mode()) {
-		log_verbose("Test mode: Skipping activation and zeroing.");
-		goto out;
-	}
-
 	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE, 0)) {
 		log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
 			    lv->vg->name, lv->name);
 		lp->activate = CHANGE_AN;
 	}
 
+	/* store vg on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_NULL;
+
+	backup(vg);
+
+	if (test_mode()) {
+		log_verbose("Test mode: Skipping activation and zeroing.");
+		goto out;
+	}
+
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {


