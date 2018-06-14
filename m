From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:52 -0400
Subject: master - device_mapper: drop unneeded function
Message-ID: <201806142002.w5EK2qQl003547@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3eff3aa4f8faa5a84de2ba696b15a976fad31852
Commit:        3eff3aa4f8faa5a84de2ba696b15a976fad31852
Parent:        5b515db71ba13d2a4f328be6a97bb309401c5c69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 20:47:23 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

device_mapper: drop unneeded function

Subdir without stats.
---
 device_mapper/ioctl/libdm-iface.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index bec7f0f..733eece 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -624,20 +624,6 @@ static int _dm_inactive_supported(void)
 	return inactive_supported;
 }
 
-int dm_message_supports_precise_timestamps(void)
-{
-	/*
-	 * 4.32.0 supports "precise_timestamps" and "histogram:" options
-	 * to @stats_create messages but lacks the ability to report
-	 * these properties via a subsequent @stats_list: require at
-	 * least 4.33.0 in order to use these features.
-	 */
-	if (dm_check_version() && _dm_version >= 4)
-		if (_dm_version_minor >= 33)
-			return 1;
-	return 0;
-}
-
 void *dm_get_next_target(struct dm_task *dmt, void *next,
 			 uint64_t *start, uint64_t *length,
 			 char **target_type, char **params)


