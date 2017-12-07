From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:53 -0500
Subject: master - cleanup: use log_warn
Message-ID: <201712072003.vB7K3r4R005668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=717714b24ffbf648a1b22e9306484944a514c565
Commit:        717714b24ffbf648a1b22e9306484944a514c565
Parent:        f173274fe4888cc73eb573cf2c6913f54641c1aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 10:42:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:39 2017 +0100

cleanup: use log_warn

---
 libdm/libdm-common.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index f5c6062..2ab5bd1 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1917,13 +1917,13 @@ int dm_device_has_holders(uint32_t major, uint32_t minor)
 
 	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32
 			":%" PRIu32 "/holders", _sysfs_dir, major, minor) < 0) {
-		log_error("sysfs_path dm_snprintf failed");
+		log_warn("WARNING: sysfs_path dm_snprintf failed.");
 		return 0;
 	}
 
 	if (stat(sysfs_path, &st)) {
 		if (errno != ENOENT)
-			log_sys_error("stat", sysfs_path);
+			log_sys_debug("stat", sysfs_path);
 		return 0;
 	}
 
@@ -1939,13 +1939,13 @@ static int _mounted_fs_on_device(const char *kernel_dev_name)
 	int r = 0;
 
 	if (dm_snprintf(sysfs_path, PATH_MAX, "%sfs", _sysfs_dir) < 0) {
-		log_error("sysfs_path dm_snprintf failed");
+		log_warn("WARNING: sysfs_path dm_snprintf failed.");
 		return 0;
 	}
 
 	if (!(d = opendir(sysfs_path))) {
 		if (errno != ENOENT)
-			log_sys_error("opendir", sysfs_path);
+			log_sys_debug("opendir", sysfs_path);
 		return 0;
 	}
 
@@ -1955,7 +1955,7 @@ static int _mounted_fs_on_device(const char *kernel_dev_name)
 
 		if (dm_snprintf(sysfs_path, PATH_MAX, "%sfs/%s/%s",
 				_sysfs_dir, dirent->d_name, kernel_dev_name) < 0) {
-			log_error("sysfs_path dm_snprintf failed");
+			log_warn("WARNING: sysfs_path dm_snprintf failed.");
 			break;
 		}
 
@@ -1965,13 +1965,13 @@ static int _mounted_fs_on_device(const char *kernel_dev_name)
 			break;
 		}
 		else if (errno != ENOENT) {
-			log_sys_error("stat", sysfs_path);
+			log_sys_debug("stat", sysfs_path);
 			break;
 		}
 	}
 
 	if (closedir(d))
-		log_error("_fs_present_on_device: %s: closedir failed", kernel_dev_name);
+		log_sys_debug("closedir", kernel_dev_name);
 
 	return r;
 }


