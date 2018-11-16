From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:32:53 -0500
Subject: master - libdm: do not add params for resume and remove
Message-ID: <201811162332.wAGNWraB015673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10e191fd124e89d40518a7cba5d61c47be5a0969
Commit:        10e191fd124e89d40518a7cba5d61c47be5a0969
Parent:        d44bfe90f1b609d23566ba26c4d51ba167f2368d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:54:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

libdm: do not add params for resume and remove

DM_DEVICE_CREATE with table is doing several ioctl operations,
however only some of then takes parameters.
Since _create_and_load_v4() reused already existing dm task from
DM_DEVICE_RELOAD it has also kept passing its table parameters
to DM_DEVICE_RESUME ioctl - but this ioctl is supposed to not take
any argument and thus there is no wiping of passed data - and
since kernel returns buffer and shortens dmi->data_size accordingly,
anything past returned data size remained uncleared in zfree()
function.

This has problem if the user used dm_task_secure_data (i.e. cryptsetup),
as in this case binary expact secured data are erased from main memory
after use, but they may have been left in place.

This patch is also closing the possible hole for error path,
which also reuse same dm task structure for DM_DEVICE_REMOVE.
---
 WHATS_NEW_DM                      |    1 +
 device_mapper/ioctl/libdm-iface.c |    2 ++
 libdm/ioctl/libdm-iface.c         |    2 ++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7049a4c..d0088c4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.155 - 
 ====================================
+  Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
 
 Version 1.02.153 - 31st October 2018
 ====================================
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 27db622..cc69317 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1454,6 +1454,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->uuid = NULL;
 	free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
+	_dm_task_free_targets(dmt);
 
 	if (dm_task_run(dmt))
 		return 1;
@@ -1464,6 +1465,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->uuid = NULL;
 	free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
+	_dm_task_free_targets(dmt);
 
 	/*
 	 * Also udev-synchronize "remove" dm task that is a part of this revert!
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 6d87749..5c418a9 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1466,6 +1466,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->uuid = NULL;
 	dm_free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
+	_dm_task_free_targets(dmt);
 
 	if (dm_task_run(dmt))
 		return 1;
@@ -1476,6 +1477,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->uuid = NULL;
 	dm_free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
+	_dm_task_free_targets(dmt);
 
 	/*
 	 * Also udev-synchronize "remove" dm task that is a part of this revert!


