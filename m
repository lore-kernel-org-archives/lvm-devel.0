From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 10:52:27 +0000 (UTC)
Subject: master - dev-cache: remove spurious error msg if no value found in /sys/dev/block/<major>:<minor>/dm/uuid during dev scan
Message-ID: <20160330105227.854C460FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52e0d0db4460d90172e9bd45b9ef30e7f4f75ae7
Commit:        52e0d0db4460d90172e9bd45b9ef30e7f4f75ae7
Parent:        8c27c5274980dddf64283602bc23b89a5623da0a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 11:11:37 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 11:30:09 2016 +0200

dev-cache: remove spurious error msg if no value found in /sys/dev/block/<major>:<minor>/dm/uuid during dev scan

It's correct to have a DM device that has no DM UUID assigned
so no need to issue error message in this case. Also, if the
device doesn't have DM UUID, it's also clear it's not an LVM LV
(...when looking for VGID/LVID while creating VGID/LVID indices
in dev cache).

For example:

$ dmsetup create test --table "0 1 linear /dev/sda 0"
And there's no PV in the system.

Before this patch (spurious error message issued):
$ pvs
  _get_sysfs_value: /sys/dev/block/253:2/dm/uuid: no value

With this patch applied (no spurious error message):
$ pvs
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   12 +++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b389926..dae6a10 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.149 - 
 ==================================
+  Remove spurious error about no value in /sys/dev/block/major:minor/dm/uuid.
   Fix device mismatch detection for LV if persistent .cache file is used.
   Fix holder device not being found in /dev while sysfs has it during dev scan.
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9989066..1729aba 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -363,7 +363,7 @@ static int _add_alias(struct device *dev, const char *path)
 	return 1;
 }
 
-static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
+static int _get_sysfs_value(const char *path, char *buf, size_t buf_size, int error_if_no_value)
 {
 	FILE *fp;
 	size_t len;
@@ -380,8 +380,10 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 	}
 
 	if (!(len = strlen(buf)) || (len == 1 && buf[0] == '\n')) {
-		log_error("_get_sysfs_value: %s: no value", path);
-		goto out;
+		if (error_if_no_value) {
+			log_error("_get_sysfs_value: %s: no value", path);
+			goto out;
+		}
 	}
 
 	if (buf[len - 1] == '\n')
@@ -404,7 +406,7 @@ static int _get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int mi
 		return 0;
 	}
 
-	return _get_sysfs_value(path, buf, buf_size);
+	return _get_sysfs_value(path, buf, buf_size, 0);
 }
 
 static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx, const char *key)
@@ -442,7 +444,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return NULL;
 	}
 
-	if (!_get_sysfs_value(path, buf, sizeof(buf)))
+	if (!_get_sysfs_value(path, buf, sizeof(buf), 1))
 		return_NULL;
 
 	if (sscanf(buf, "%d:%d", &major, &minor) != 2) {


