From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 21 Sep 2015 18:52:18 +0000 (UTC)
Subject: master - lvmcache: Remove verbose msg when rescanning dev.
Message-ID: <20150921185218.0B54560357@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce80d736848135851bb9961cec8cb361911fe455
Commit:        ce80d736848135851bb9961cec8cb361911fe455
Parent:        804c25a81a297753aa60f47f36c21149e9479c22
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 21 19:51:15 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 21 19:51:15 2015 +0100

lvmcache: Remove verbose msg when rescanning dev.

---
 WHATS_NEW            |    3 ++-
 lib/cache/lvmcache.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 30f047b..cade4b2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.132 - 
 ======================================
-  Add origin_uuid, mirror_log_uuid, move_pv_uuid, convert_lv_uuid reporting fields.
+  Remove verbose message when rescanning an unchanged device. (2.02.119)
+  Add origin_uuid, mirror_log_uuid, move_pv_uuid, convert_lv_uuid report fields.
   Add pool_lv_uuid, metadata_lv_uuid, data_lv_uuid reporting fields.
   Fix PV label processing failure after pvcreate in lvm shell with lvmetad.
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index cfa1d5f..c495fa7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1871,8 +1871,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			 * device already exists?  Things don't seem to work
 			 * if we do that for some reason.
 			 */
-			log_verbose("Found same device %s with same pvid %s",
-				    dev_name(existing->dev), pvid_s);
+			log_debug_cache("Found same device %s with same pvid %s",
+					dev_name(existing->dev), pvid_s);
 		}
 
 		/*


