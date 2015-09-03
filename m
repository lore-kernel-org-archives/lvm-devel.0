From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:13 +0000 (UTC)
Subject: master - thin: do not flush when quering for thin percent
Message-ID: <20150903213613.8CC7860F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=872ea3b98710c2a45c76dc22a606a40b13440d13
Commit:        872ea3b98710c2a45c76dc22a606a40b13440d13
Parent:        df110bccbed2bc7f53355fcb16309eb2727ba483
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 22:57:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

thin: do not flush when quering for thin percent

Since we may easily get blocked when checking for percentage
of thin-pool - do not flush and just show current values.
This avoids holding VG locked when pool is overfilled.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cb9e1f1..6336f45 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Read thin-pool data and metadata percent without flush.
   Detect blocked thin-pool and avoid scanning their thin volumes.
   Check if dm device is usable before checking its size (2.02.116).
   Extend parsing of cache_check version in configure.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6a26d37..d4a349b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1045,6 +1045,11 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
+	/* No freeze on overfilled thin-pool, read existing slightly outdated data */
+	if (lv && lv_is_thin_pool(lv) &&
+	    !dm_task_no_flush(dmt))
+		log_warn("Can't set no_flush flag."); /* Non fatal */
+
 	if (!dm_task_run(dmt))
 		goto_out;
 


