From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 6 Dec 2018 11:51:42 -0500
Subject: 2018-06-01-stable - libdm: do not add params for resume and remove
Message-ID: <201812061651.wB6GpgjK031599@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5234e1b7eceeb1eb9ceff9877aea2a39fde1906
Commit:        d5234e1b7eceeb1eb9ceff9877aea2a39fde1906
Parent:        a188b1e513ed5ca0f5f3702c823490f5610d4495
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:54:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 6 17:46:51 2018 +0100

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
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ee5bcfa..d219f3d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.154 - 
 ====================================
+  Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
 
 Version 1.02.152 - 30th October 2018
 ====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 769b69c..5068d4c 100644
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


