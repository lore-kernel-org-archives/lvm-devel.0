From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:10 +0000 (UTC)
Subject: master - cache: add missing udev wait
Message-ID: <20170103135610.EF1E86100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95d5877f7af781c53c7865868745dc683d2b0413
Commit:        95d5877f7af781c53c7865868745dc683d2b0413
Parent:        4fd41cf67f0b9ea44a103b059dbbb2d74d8289eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 3 14:47:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

cache: add missing udev wait

When we need to clear dirty cache content of cached LV, there
is table reload which usually is shortly followed by next metadata
change.  However  udev  can't (as of now)  process   udev event
while device is 'suspended'.

So whenever sequence of  'suspend/resume/suspend' is needed,
we need to wait first for finishing of 'resume' processing before
starting next 'suspend'. Otherwise there is  'race' danger of triggering
unwantend umount by systemd as  such event will trigger
SYSTEMD_READY=0 state for a moment for such changed device.

Such race is pretty ugly to trace so we may need to review more
sequencies for missing 'sync'.

(Other option is to enhnace 'udev' rules processing to avoid
such dramatic actions to be happening for suspended devices).
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9e16b27..5fb5904 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add missing udev sync when flushing dirty cache content.
   vgchange -p accepts only uint32 numbers.
   Report thin LV date for merged LV when the merge is in progress.
   Detect if snapshot merge really started before polling for progress.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 404b1af..cddaf82 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -424,9 +424,15 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 		/* Switch to cleaner policy to flush the cache */
 		cache_seg->cleaner_policy = 1;
-		/* Reaload kernel with "cleaner" policy */
+		/* Reload cache volume with "cleaner" policy */
 		if (!lv_update_and_reload_origin(cache_lv))
 			return_0;
+
+		if (!sync_local_dev_names(cache_lv->vg->cmd)) {
+			log_error("Failed to sync local devices when clearing cache volume %s.",
+				  display_lvname(cache_lv));
+			return 0;
+		}
 	}
 
 	/*
@@ -436,6 +442,12 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	if (1) {
 		if (!lv_refresh_suspend_resume(lock_lv))
 			return_0;
+
+		if (!sync_local_dev_names(cache_lv->vg->cmd)) {
+			log_error("Failed to sync local devices after final clearing of cache %s.",
+				  display_lvname(cache_lv));
+			return 0;
+		}
 	}
 
 	cache_seg->cleaner_policy = 0;


