From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:17 +0000 (GMT)
Subject: main - cov: hide false positive warning
Message-ID: <20210913103617.27A003858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a14371e4952f7a1b079a795c13927cea2eb196b6
Commit:        a14371e4952f7a1b079a795c13927cea2eb196b6
Parent:        63930f576a29d701894586c6ef1f90bf63f321d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 09:58:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: hide false positive warning

Here we have valid use case of strncpy() which just need
to fill precise buffer size - so no explicit \0 on buffer
end is needed.
---
 daemons/lvmlockd/lvmlockd-core.c  | 1 +
 device_mapper/ioctl/libdm-iface.c | 2 ++
 libdm/ioctl/libdm-iface.c         | 2 ++
 3 files changed, 5 insertions(+)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c570b9d14..a3964c857 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2989,6 +2989,7 @@ static int add_lockspace_thread(const char *ls_name,
 	}
 
 	if (vg_uuid)
+		/* coverity[buffer_size_warning] */
 		strncpy(ls->vg_uuid, vg_uuid, 64);
 
 	if (vg_name)
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index a2a56be45..b4f7a986d 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1250,9 +1250,11 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	/* FIXME Until resume ioctl supplies name, use dev_name for readahead */
 	if (DEV_NAME(dmt) && (dmt->type != DM_DEVICE_RESUME || dmt->minor < 0 ||
 			      dmt->major < 0))
+		/* coverity[buffer_size_warning] */
 		strncpy(dmi->name, DEV_NAME(dmt), sizeof(dmi->name));
 
 	if (DEV_UUID(dmt))
+		/* coverity[buffer_size_warning] */
 		strncpy(dmi->uuid, DEV_UUID(dmt), sizeof(dmi->uuid));
 
 	if (dmt->type == DM_DEVICE_SUSPEND)
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 47f14398c..d8f1c389d 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1245,9 +1245,11 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	     (dmt->minor < 0) || (dmt->major < 0)))
 		/* When RESUME or RELOAD sets maj:min and dev_name, use just maj:min,
 		 * passed dev_name is useful for better error/debug messages */
+		/* coverity[buffer_size_warning] */
 		strncpy(dmi->name, DEV_NAME(dmt), sizeof(dmi->name));
 
 	if (DEV_UUID(dmt))
+		/* coverity[buffer_size_warning] */
 		strncpy(dmi->uuid, DEV_UUID(dmt), sizeof(dmi->uuid));
 
 	if (dmt->type == DM_DEVICE_SUSPEND)


