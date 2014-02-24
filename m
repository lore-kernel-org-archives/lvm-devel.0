From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:12 +0000 (UTC)
Subject: master - cleanup: reorder commonly available devs in system to the front
Message-ID: <20140224201712.6FC3460FC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=710c0df68a74c8da03eba62b43ae9080dd4a6ffe
Commit:        710c0df68a74c8da03eba62b43ae9080dd4a6ffe
Parent:        5097463fb326df3f1dde654da4b59011b6135f1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 20 17:06:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:35 2014 +0100

cleanup: reorder commonly available devs in system to the front

Just shorting strcmp....
---
 lib/device/device-types.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 666f7b6..463f847 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -28,11 +28,13 @@ typedef struct {
  * The list can be supplemented with devices/types in the config file.
  */
 static const dev_known_type_t _dev_known_types[] = {
-	{"ide", 64, "IDE disk"},
 	{"sd", 16, "SCSI disk"},
+	{"ide", 64, "IDE disk"},
 	{"md", 1, "Multiple Disk (MD/SoftRAID)"},
-	{"mdp", 1, "Partitionable MD"},
 	{"loop", 1, "Loop device"},
+	{"ramdisk", 1, "RAM disk"},
+	{"device-mapper", 1, "Mapped device"},
+	{"mdp", 1, "Partitionable MD"},
 	{"dasd", 4, "DASD disk (IBM S/390, zSeries)"},
 	{"dac960", 8, "DAC960"},
 	{"nbd", 16, "Network Block Device"},
@@ -46,9 +48,7 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"i2o_block", 16, "i2o Block Disk"},
 	{"iseries/vd", 8, "iSeries disks"},
 	{"gnbd", 1, "Network block device"},
-	{"ramdisk", 1, "RAM disk"},
 	{"aoe", 16, "ATA over Ethernet"},
-	{"device-mapper", 1, "Mapped device"},
 	{"xvd", 16, "Xen virtual block device"},
 	{"vdisk", 8, "SUN's LDOM virtual block device"},
 	{"ps3disk", 16, "PlayStation 3 internal disk"},


