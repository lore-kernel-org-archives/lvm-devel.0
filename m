From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:33 +0000 (GMT)
Subject: main - debug: change sys_error to sys_debug
Message-ID: <20210310003633.15224385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7342ab06fcce5f386e1fd58fa9e82352d570398e
Commit:        7342ab06fcce5f386e1fd58fa9e82352d570398e
Parent:        5f7a7af7f201fea454bc4200bc76c4c75ef95463
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 11:08:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:11:52 2021 +0100

debug: change sys_error to sys_debug

These messages do not cause command error - so changing logging level
to just 'sys_debug' (so visible only with -vvvv)
---
 device_mapper/ioctl/libdm-iface.c |  2 +-
 device_mapper/libdm-common.c      |  2 +-
 device_mapper/libdm-file.c        |  2 +-
 lib/activate/fs.c                 | 10 +++++-----
 lib/device/dev-cache.c            |  2 +-
 lib/filters/filter-mpath.c        |  2 +-
 lib/filters/filter-sysfs.c        | 10 +++++-----
 libdm/dm-tools/dmfilemapd.c       |  8 ++++----
 libdm/ioctl/libdm-iface.c         |  2 +-
 libdm/libdm-common.c              |  2 +-
 libdm/libdm-file.c                |  2 +-
 tools/lvmcmdline.c                |  2 +-
 12 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 6b3818e3a..536e4b238 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1352,7 +1352,7 @@ static int _process_mapper_dir(struct dm_task *dmt)
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return r;
 }
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 9b87e4e74..a2304b603 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -382,7 +382,7 @@ static int _find_dm_name_of_device(dev_t st_rdev, char *buf, size_t buf_len)
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", _dm_dir);
+		log_sys_debug("closedir", _dm_dir);
 
 	return r;
 }
diff --git a/device_mapper/libdm-file.c b/device_mapper/libdm-file.c
index 94ca146f1..74d9968df 100644
--- a/device_mapper/libdm-file.c
+++ b/device_mapper/libdm-file.c
@@ -119,7 +119,7 @@ int dm_is_empty_dir(const char *dir)
 			break;
 
 	if (closedir(d))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return dirent ? 0 : 1;
 }
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 2e8098ddf..60ced8fb5 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -93,7 +93,7 @@ static void _rm_blks(const char *dir)
 	DIR *d;
 
 	if (!(d = opendir(dir))) {
-		log_sys_error("opendir", dir);
+		log_sys_debug("opendir", dir);
 		return;
 	}
 
@@ -104,7 +104,7 @@ static void _rm_blks(const char *dir)
 			continue;
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir, name) == -1) {
-			log_error("Couldn't create path for %s", name);
+			log_debug("Couldn't create path for %s.", name);
 			continue;
 		}
 
@@ -113,12 +113,12 @@ static void _rm_blks(const char *dir)
 				continue;
 			log_very_verbose("Removing %s", path);
 			if (unlink(path) < 0)
-				log_sys_error("unlink", path);
+				log_sys_debug("unlink", path);
 		}
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 }
 
 static int _mk_link(const char *dev_dir, const char *vg_name,
@@ -169,7 +169,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 
 			log_very_verbose("Removing %s", lvm1_group_path);
 			if (unlink(lvm1_group_path) < 0)
-				log_sys_error("unlink", lvm1_group_path);
+				log_sys_debug("unlink", lvm1_group_path);
 		}
 	}
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index cf6334564..6cf798858 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -666,7 +666,7 @@ static int _index_dev_by_vgid_and_lvid(struct device *dev)
 	r = 1;
 out:
 	if (closedir(d))
-		log_sys_error("closedir", path);
+		log_sys_debug("closedir", path);
 
 	return r;
 }
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 202296458..57ed79908 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -158,7 +158,7 @@ static int _get_holder_name(const char *dir, char *name, int max_size)
 	}
 
 	if (closedir(dr))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return r;
 }
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index b2ac63d7b..b626144b2 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -218,15 +218,15 @@ static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir,
 				 d->d_name) < 0) {
-			log_error("sysfs path name too long: %s in %s",
-				  d->d_name, dir);
+			log_warn("WARGNING: sysfs path name too long: %s in %s.",
+				 d->d_name, dir);
 			continue;
 		}
 
 		/* devices have a "dev" file */
 		if (dm_snprintf(file, sizeof(file), "%s/dev", path) < 0) {
-			log_error("sysfs path name too long: %s in %s",
-				  d->d_name, dir);
+			log_warn("WARGNING: sysfs path name too long: %s in %s.",
+				 d->d_name, dir);
 			continue;
 		}
 
@@ -242,7 +242,7 @@ static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 	}
 
 	if (closedir(dr))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return r;
 }
diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index 856df3df2..e15f0015f 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -180,14 +180,14 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 		link_buf[len] = '\0';
 		if (!strcmp(deleted_path, link_buf)) {
 			if (closedir(pid_d))
-				log_sys_error("closedir", path_buf);
+				log_sys_debug("closedir", path_buf);
 			return 1;
 		}
 	}
 
 bad:
 	if (closedir(pid_d))
-		log_sys_error("closedir", path_buf);
+		log_sys_debug("closedir", path_buf);
 
 	return 0;
 }
@@ -230,13 +230,13 @@ static int _is_open(const char *path)
 			continue;
 		if (_is_open_in_pid(pid, path)) {
 			if (closedir(proc_d))
-				log_sys_error("closedir", DEFAULT_PROC_DIR);
+				log_sys_debug("closedir", DEFAULT_PROC_DIR);
 			return 1;
 		}
 	}
 
 	if (closedir(proc_d))
-		log_sys_error("closedir", DEFAULT_PROC_DIR);
+		log_sys_debug("closedir", DEFAULT_PROC_DIR);
 
 	return 0;
 }
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f4be478da..f35ddeb07 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1346,7 +1346,7 @@ static int _process_mapper_dir(struct dm_task *dmt)
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return r;
 }
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index a28829765..f2ea64905 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -380,7 +380,7 @@ static int _find_dm_name_of_device(dev_t st_rdev, char *buf, size_t buf_len)
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", _dm_dir);
+		log_sys_debug("closedir", _dm_dir);
 
 	return r;
 }
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 290ad3234..2e5f14f6f 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -118,7 +118,7 @@ int dm_is_empty_dir(const char *dir)
 			break;
 
 	if (closedir(d))
-		log_sys_error("closedir", dir);
+		log_sys_debug("closedir", dir);
 
 	return dirent ? 0 : 1;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 588c78d72..796ecfa78 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3510,7 +3510,7 @@ static int _close_stray_fds(const char *command, struct custom_fds *custom_fds)
 	}
 
 	if (closedir(d))
-		log_sys_error("closedir", _fd_dir);
+		log_sys_debug("closedir", _fd_dir);
 #endif
 
 	return 1;


