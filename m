From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Jan 2015 13:12:31 +0000 (UTC)
Subject: master - dev-type: filter out partitioned device-mapper devices as unsuitable for use as PVs
Message-ID: <20150112131231.1FF14601E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99d895014d971395fe7a739838952e7405eb4dda
Commit:        99d895014d971395fe7a739838952e7405eb4dda
Parent:        8dbe76734049a225a34bbbab383418b62acdcce1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 12 14:02:57 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 12 14:10:44 2015 +0100

dev-type: filter out partitioned device-mapper devices as unsuitable for use as PVs

Normally, if there are partitions defined on top of device-mapper
device, there should be a device-mapper device created for each
partiton on top of the old one and once the underlying DM device
is used by another devices (partition mappings in this case),
it can't be used as a PV anymore.

However, sometimes, it may happen the partition mappings are
missing - either the partitioning tool is not creating them if
it does not contain full support for device-mapper devices or
the mappings were removed.

Better safe than sorry - check for partition header on DM devs
and filter them out as unsuitable for PVs in case the check is
positive. Whatever the user is doing, let's do our best to prevent
unwanted corruption (...by running pvcreate on top of such device
that would corrupt the partition header).
---
 WHATS_NEW                    |    1 +
 lib/device/dev-type.c        |    3 +++
 test/shell/test-partition.sh |    3 ++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11611dd..e295e6c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Filter out partitioned device-mapper devices as unsuitable for use as PVs.
   Also notify lvmetad about filtered device if using pvscan --cache DevicePath.
   Use LVM's own selection instead of awk expressions in clvmd startup scripts.
   Do not filter out snapshot origin LVs as unusable devices for an LVM stack.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 001248d..a84f7e9 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -272,6 +272,9 @@ static int _is_partitionable(struct dev_types *dt, struct device *dev)
 {
 	int parts = major_max_partitions(dt, MAJOR(dev->dev));
 
+	if (MAJOR(dev->dev) == dt->device_mapper_major)
+		return 1;
+
 	/* All MD devices are partitionable via blkext (as of 2.6.28) */
 	if (MAJOR(dev->dev) == dt->md_major)
 		return 1;
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index af04b4e..e79216e 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -28,4 +28,5 @@ pvs "$dev1"
 # create small partition table
 echo "1 2" | sfdisk "$dev1"
 
-pvs "$dev1"
+aux notify_lvmetad "$dev1"
+not pvs "$dev1"


