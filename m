From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:08:50 +0000 (UTC)
Subject: master - filters: drop extra slash from sysfs path
Message-ID: <20131122200850.8421560EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08d6d81cc24a3c3b780fe25ed49aefc9a9b61586
Commit:        08d6d81cc24a3c3b780fe25ed49aefc9a9b61586
Parent:        4c1f281b43175e69a73fcc59a9142fd374e8b70c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 21 17:50:12 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:53:31 2013 +0100

filters: drop extra slash from sysfs path

Sysfs filter was using '/sys//class/block' with double '//' inside.
Remove this extra '/'.
Also simplify code around and use loop to try those paths.
---
 WHATS_NEW                  |    1 +
 lib/filters/filter-sysfs.c |  109 +++++++++++++++++++++----------------------
 2 files changed, 54 insertions(+), 56 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 647c810..b7a1e84 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Drop extra unneeded '/' when scanning sysfs directory.
   Fix undef value if skipped clustered VG ignored for toollib PV seg. (2.02.103)
   liblvm/python API Add ability to validate VG/LV names.
   liblvm/python API Add ability to create PV with arguments.
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index af3ed07..ff94810 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -23,64 +23,61 @@ static int _locate_sysfs_blocks(const char *sysfs_dir, char *path, size_t len,
 				unsigned *sysfs_depth)
 {
 	struct stat info;
-
-	/*
-	 * unified classification directory for all kernel subsystems
-	 *
-	 * /sys/subsystem/block/devices
-	 * |-- sda -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
-	 * |-- sda1 -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
-	 *  `-- sr0 -> ../../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
-	 *
-	 */
-	if (dm_snprintf(path, len, "%s/%s", sysfs_dir,
-			"subsystem/block/devices") >= 0) {
-		if (!stat(path, &info)) {
-			*sysfs_depth = 0;
-			return 1;
-		}
-	}
-
-	/*
-	 * block subsystem as a class
-	 *
-	 * /sys/class/block
-	 * |-- sda -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
-	 * |-- sda1 -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
-	 *  `-- sr0 -> ../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
-	 *
-	 */
-	if (dm_snprintf(path, len, "%s/%s", sysfs_dir, "class/block") >= 0) {
-		if (!stat(path, &info)) {
-			*sysfs_depth = 0;
+	unsigned i;
+	static const struct dir_class {
+		const char path[32];
+		int depth;
+	} classes[] = {
+		/*
+		 * unified classification directory for all kernel subsystems
+		 *
+		 * /sys/subsystem/block/devices
+		 * |-- sda -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
+		 * |-- sda1 -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
+		 *  `-- sr0 -> ../../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
+		 *
+		 */
+		{ "subsystem/block/devices", 0 },
+
+		/*
+		 * block subsystem as a class
+		 *
+		 * /sys/class/block
+		 * |-- sda -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
+		 * |-- sda1 -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
+		 *  `-- sr0 -> ../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
+		 *
+		 */
+		{ "class/block", 0 },
+
+		/*
+		 * old block subsystem layout with nested directories
+		 *
+		 * /sys/block/
+		 * |-- sda
+		 * |   |-- capability
+		 * |   |-- dev
+		 * ...
+		 * |   |-- sda1
+		 * |   |   |-- dev
+		 * ...
+		 * |
+		 * `-- sr0
+		 *     |-- capability
+		 *     |-- dev
+		 * ...
+		 *
+		 */
+
+		{ "block", 1 }
+	};
+
+	for (i = 0; i < DM_ARRAY_SIZE(classes); ++i)
+		if ((dm_snprintf(path, len, "%s%s", sysfs_dir, classes[i].path) >= 0) &&
+		    (stat(path, &info) == 0)) {
+			*sysfs_depth = classes[i].depth;
 			return 1;
 		}
-	}
-
-	/*
-	 * old block subsystem layout with nested directories
-	 *
-	 * /sys/block/
-	 * |-- sda
-	 * |   |-- capability
-	 * |   |-- dev
-	 * ...
-	 * |   |-- sda1
-	 * |   |   |-- dev
-	 * ...
-	 * |
-	 * `-- sr0
-	 *     |-- capability
-	 *     |-- dev
-	 * ...
-	 *
-	 */
-	if (dm_snprintf(path, len, "%s/%s", sysfs_dir, "block") >= 0) {
-		if (!stat(path, &info)) {
-			*sysfs_depth = 1;
-			return 1;
-		}
-	}
 
 	return 0;
 }


