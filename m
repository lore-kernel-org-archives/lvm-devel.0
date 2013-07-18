From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:24 +0000 (UTC)
Subject: master - cleanup: stack and remove braces
Message-ID: <20130718162624.DE71D6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd31cc9dfc2de1d2867c1c9f09e17403441ca6ad
Commit:        fd31cc9dfc2de1d2867c1c9f09e17403441ca6ad
Parent:        8606bf316a683ebd14bb4cdf4eb1b3477a790b62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 16 23:35:56 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:16:17 2013 +0200

cleanup: stack and remove braces

Add stack trace for error path.
Remove unneeded braces.
---
 lib/activate/dev_manager.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 281041b..50e52d1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -817,7 +817,7 @@ static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 				 event_nr, fail_if_percent_unsupported))
 		return 1;
 
-	return 0;
+	return_0;
 }
 
 /* FIXME Merge with the percent function */
@@ -985,8 +985,8 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	 * Try and get some info on this device.
 	 */
 	log_debug_activation("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
-		       NULL, fail_if_percent_unsupported)))
+	if (!_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+		      NULL, fail_if_percent_unsupported))
 		return_0;
 
 	/* If the snapshot isn't available, percent will be -1 */
@@ -1017,8 +1017,8 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 
 	log_debug_activation("Getting device %s status percentage for %s",
 			     target_type, name);
-	if (!(_percent(dm, name, dlid, target_type, wait, lv, percent,
-		       event_nr, 0)))
+	if (!_percent(dm, name, dlid, target_type, wait, lv, percent,
+		      event_nr, 0))
 		return_0;
 
 	return 1;


