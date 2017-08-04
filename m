From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 4 Aug 2017 09:57:40 -0400
Subject: master - ioctl: Allow minor without major.
Message-ID: <201708041357.v74Dve0G001823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6afe9e7820da5d5086dbcf82532bb9d0daafb00
Commit:        e6afe9e7820da5d5086dbcf82532bb9d0daafb00
Parent:        5dd53943c9bee9d55cde9c8fee27a2e3ea031327
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 4 14:45:20 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 4 14:45:20 2017 +0100

ioctl: Allow minor without major.

There's no need to insist on a major number being supplied when the
code's going to override it if it's wrong anyway.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c41bcfd..514973b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.143 - 
 =================================
+  Accept minor number without major in library when it knows dm major number.
   Introduce single-line concise table output format: dmsetup table --concise
 
 Version 1.02.142 - 20th July 2017
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index c47e084..e32af80 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1172,11 +1172,6 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	dmi->data_start = sizeof(struct dm_ioctl);
 
 	if (dmt->minor >= 0) {
-		if (dmt->major <= 0) {
-			log_error("Missing major number for persistent device.");
-			goto bad;
-		}
-
 		if (!_dm_multiple_major_support && dmt->allow_default_major_fallback &&
 		    dmt->major != (int) _dm_device_major) {
 			log_verbose("Overriding major number of %d "
@@ -1185,6 +1180,11 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 			dmt->major = _dm_device_major;
 		}
 
+		if (dmt->major <= 0) {
+			log_error("Missing major number for persistent device.");
+			goto bad;
+		}
+
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
 		dmi->dev = MKDEV((dev_t)dmt->major, (dev_t)dmt->minor);
 	}


