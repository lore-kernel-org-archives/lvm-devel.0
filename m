From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 23 Oct 2012 11:25:21 +0000 (UTC)
Subject: master - udev_sync: cookie_set=1 on each dm_task_set_cookie call
Message-ID: <20121023112521.98EE2A0C5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a820a68619c10108666f8093545837233c954046
Commit:        a820a68619c10108666f8093545837233c954046
Parent:        fc849a9eebecf77c75d016fad2b83fd3b2950474
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 23 11:40:53 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 23 13:23:35 2012 +0200

udev_sync: cookie_set=1 on each dm_task_set_cookie call

cookie_set variable found in the struct dm_task should be always
set to 1 after dm_task_set_cookie_call, even if udev_sync is disabled
as the cookie itself carries synchronization informations *as well as*
extra flags to control other aspects of udev support.

For example, one could disable the synchronization itself, but still
direct the libdm code to disable library fallback via
DM_UDEV_DISABLE_LIBRARY_FALLBACK flag. These extra flags still need
to be carried out!

A concrete example:
  $ dmsetup create test --table "0 1 zero" --noudevsync

This disables synchronization with udev. As the --verifyudev option is
not used, we don't want to do any corrections. In other words, we
need DM_UDEV_DISABLE_LIBRARY_FALLBACK flag to be used. However,
with --noudevsync this was not the case - the flag was ignored!

This patch fixes the case when noudevsync is used but there are still
some extra flags passed within the cookie flag part. The synchronization
part of the cookie stays zero (which is ok as dm_udev_wait call on such a
cookie is simply a NOOP).
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2d0b05c..7c636f0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.77 - 15th October 2012
 ===================================
+  Fix dm_task_set_cookie to properly process udev flags if udev_sync disabled.
   Support unmount of thin volumes from pool above thin pool threshold.
   Update man page to reflect that dm UUIDs are being mangled as well.
   Apply 'dmsetup mangle' for dm UUIDs besides dm names.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b8533ed..afdac89 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1838,6 +1838,7 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 	if (dm_cookie_supported())
 		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
 	*cookie = 0;
+	dmt->cookie_set = 1;
 
 	return 1;
 }
@@ -2207,6 +2208,7 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 
 	if (!dm_udev_get_sync_support()) {
 		*cookie = 0;
+		dmt->cookie_set = 1;
 		return 1;
 	}
 


