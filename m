From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Jul 2015 12:21:10 +0000 (UTC)
Subject: master - WHATS_NEW: Update. Fix renamed config setting vsn.
Message-ID: <20150707122110.6891A60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88760141da6593373f64a0791edd4bbea29680cc
Commit:        88760141da6593373f64a0791edd4bbea29680cc
Parent:        b174c27d4dd0081396048102e0f6decb8cd569bd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 7 13:20:01 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 7 13:20:01 2015 +0100

WHATS_NEW: Update. Fix renamed config setting vsn.

---
 WHATS_NEW                    |    2 ++
 lib/config/config_settings.h |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 82195d6..f9ff8db 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,8 @@
 Version 2.02.125 -
 ================================
   Add support --clear-needs-check-flag for cache_check of cache pool metadata.
+  Add lvmetactl for developer use only.
+  Rename global/lock_retries to lvmlockd_retries.
   Replace --enable-lvmlockd by --enable-lockd-sanlock and --enable-lockd-dlm.
 
 Version 2.02.124 - 3rd July 2015
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index baa8609..44f1e04 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -834,7 +834,7 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n")
 
-cfg(global_lvmlockd_lock_retries_CFG, "lvmlockd_lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMLOCKD_LOCK_RETRIES, vsn(2, 2, 124), NULL, 0, NULL,
+cfg(global_lvmlockd_lock_retries_CFG, "lvmlockd_lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMLOCKD_LOCK_RETRIES, vsn(2, 2, 125), NULL, 0, NULL,
 	"Retry lvmlockd lock requests this many times.\n")
 
 cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SANLOCK_LV_EXTEND_MB, vsn(2, 2, 124), NULL, 0, NULL,


