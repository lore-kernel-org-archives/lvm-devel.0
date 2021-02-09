From: David Teigland <teigland@sourceware.org>
Date: Tue,  9 Feb 2021 15:56:10 +0000 (GMT)
Subject: main - dev_get_primary_dev: fix invalid path check
Message-ID: <20210209155610.F204E3938C31@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f74f94c2ddb1d33d75d325c959344a566a621fd5
Commit:        f74f94c2ddb1d33d75d325c959344a566a621fd5
Parent:        427121efc76f1a11df5d06c11ea4f095305b6333
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 9 09:47:08 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 9 09:52:53 2021 -0600

dev_get_primary_dev: fix invalid path check

Fix commit bee9f4efdd81 "filter-mpath: work with nvme devices"
which removed setting the path for readlink.
---
 lib/device/dev-type.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index b7bca361f..0411572fa 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -614,7 +614,12 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 * - basename ../../block/md0/md0  = md0
 	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
 	 */
-	if ((size = readlink(dirname(path), temp_path, sizeof(temp_path) - 1)) < 0) {
+	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d",
+			dm_sysfs_dir(), major, minor) < 0) {
+		log_warn("WARNING: %s: major:minor sysfs path is too long.", dev_name(dev));
+		return 0;
+	}
+	if ((size = readlink(path, temp_path, sizeof(temp_path) - 1)) < 0) {
 		log_warn("WARNING: Readlink of %s failed.", path);
 		goto out;
 	}


