From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Feb 2015 14:12:45 +0000 (UTC)
Subject: master - pvcreate: switch to "none" dev-ext source during pvcreate
Message-ID: <20150216141245.C5F8060661@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=727c7ff85d448743f751bc5218e73c41314ed5f1
Commit:        727c7ff85d448743f751bc5218e73c41314ed5f1
Parent:        032c9178ca72aef93bfef6e4952bb98d3373b642
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 16 14:43:03 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 16 15:07:00 2015 +0100

pvcreate: switch to "none" dev-ext source during pvcreate

pvcreate code path executes signature wiping if there are any signatures
found on device to prepare the device for PV. When the signature is wiped,
the WATCH udev rule triggers the event which then updates udev database
with fresh info, clearing the old record about previous signature.

However, when we're using udev db as dev-ext source, we'd need to wait
for this WATCH-triggered event. But we can't synchronize against such
events (at least not at this moment). Without this sync, if the code
continues, the device could still be marked as containing the old
signature if reading udev db. This may end up even with the device
to be still filtered, though the signature is already wiped.

This problem is then exposed as (an example with md components):

$  mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdb --run
$  mdadm -S /dev/md0
$  pvcreate -y /dev/sda
Wiping linux_raid_member signature on /dev/sda.
/dev/sda: Couldn't find device.  Check your filters?
$ echo $?
5

So we need to temporarily switch off "udev" dev-ext source here
in this part of pvcreate code until we find a way how to sync
with WATCH events.

(This problem does not occur with signature wiping which we do
on newly created LVs since we already handle this properly with
our udev flags - the LV_NOSCAN/LV_TEMPORARY flag. But we can't use
this technique for non-dm devices to keep WATCH rule under control.)
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f62127..c3dff92 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Enforce none external dev info for wiping during pvcreate to avoid races.
   Add support for VG system_id to control host access to VGs.
   Update vgextend to use process_each_vg.
   Add --ignoreskippedcluster to pvchange.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 138fdaf..55e6476 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1423,6 +1423,20 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	int r = 0;
 	int scan_needed = 0;
 	int filter_refresh_needed = 0;
+	dev_ext_t dev_ext_src = external_device_info_source();
+
+	if (dev_ext_src == DEV_EXT_UDEV)
+		/*
+		 * wipe_known_signatures called later fires WATCH event
+		 * to update udev database. But at the moment, we have
+		 * no way to synchronize with such event - we may end
+		 * up still seeing the old info in udev db and pvcreate
+		 * can fail to proceed because of the device still
+		 * being filtered (because of the stale info in udev db).
+		 * Disable udev dev-ext source temporarily here for
+		 * this reason.
+		 */
+		init_external_device_info_source(DEV_EXT_NONE);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -1512,6 +1526,7 @@ out:
 		}
 
 	free_pv_fid(pv);
+	init_external_device_info_source(dev_ext_src);
 	return r;
 }
 


