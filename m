From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Dec 2012 10:26:42 +0000 (UTC)
Subject: master - mirrors: fix leak in device_is_usable mirror check
Message-ID: <20121211102642.924191465@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec49f07b0dc89720f4a74a1212e106990099d2d6
Commit:        ec49f07b0dc89720f4a74a1212e106990099d2d6
Parent:        f942ae4a7af0f9b93c6a6aacb1793ee22f87ed13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 6 23:37:21 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 11 11:15:22 2012 +0100

mirrors: fix leak in device_is_usable mirror check

Function _ignore_blocked_mirror_devices was not release
allocated strings images_health and log_health.

In error paths it was also not releasing dm_task structure.

Swaped return code of _ignore_blocked_mirror_devices and
use 1 as success.

In _parse_mirror_status use log_error if memory allocation
fails and few more errors so they are no going unnoticed
as debug messages.

On error path always clear return values and free strings.

For dev_create_file  use cache mem pool to avoid memleak.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   60 ++++++++++++++++++++++++++++++--------------
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2fa5e56..a9aa152 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix memleak in device_is_usable mirror testing function.
   Do not ignore -f in lvconvert --repair -y -f for mirror and raid volumes.
   Disallow pvmove on RAID LVs until they are addressed properly
   Allow empty activation/{auto_activation|read_only|}_volume_list config option.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 40f719e..3f74c2d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -158,6 +158,10 @@ static int _parse_mirror_status(char *mirror_status_str,
 	char **args, **log_args;
 	unsigned num_devs, log_argc;
 
+	*images_health = NULL;
+	*log_health = NULL;
+	*log_dev = 0;
+
 	if (!dm_split_words(mirror_status_str, 1, 0, &p) ||
 	    !(num_devs = (unsigned) atoi(p)))
 		/* On errors, we must assume the mirror is to be avoided */
@@ -176,19 +180,31 @@ static int _parse_mirror_status(char *mirror_status_str,
 				     log_argc, 0, log_args) < log_argc)
 		return_0;
 
-	*log_health = NULL;
-	*log_dev = 0;
 	if (!strcmp(log_args[0], "disk")) {
-		if (!(*log_health = dm_strdup(log_args[2])))
-			return_0;
-		if (sscanf(log_args[1], "%d:%d", &major, &minor) != 2)
-			return_0;
+		if (!(*log_health = dm_strdup(log_args[2]))) {
+			log_error("Allocation of log string failed.");
+			return 0;
+		}
+		if (sscanf(log_args[1], "%d:%d", &major, &minor) != 2) {
+			log_error("Parsing of log's major minor failed.");
+			goto out;
+		}
 		*log_dev = MKDEV((dev_t)major, minor);
 	}
-	if (!(*images_health = dm_strdup(args[2 + num_devs])))
-		return_0;
+
+	if (!(*images_health = dm_strdup(args[2 + num_devs]))) {
+		log_error("Allocation of images string failed.");
+		goto out;
+	}
 
 	return 1;
+
+out:
+	dm_free(*log_health);
+	*log_health = NULL;
+	*log_dev = 0;
+
+	return 0;
 }
 
 /*
@@ -227,11 +243,12 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	uint64_t s,l;
 	char *params, *target_type = NULL;
 	void *next = NULL;
-	struct dm_task *dmt;
+	struct dm_task *dmt = NULL;
+	int r = 0;
 
 	if (!_parse_mirror_status(mirror_status_str,
 				  &images_health, &log_dev, &log_health))
-		goto_out;
+		return_0;
 
 	for (i = 0; images_health[i]; i++)
 		if (images_health[i] != 'A') {
@@ -254,7 +271,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					(int)MINOR(log_dev)) < 0)
 				goto_out;
 
-			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 1)))
+			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 0)))
 				goto_out;
 
 			tmp_dev->dev = log_dev;
@@ -263,8 +280,10 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 		}
 	}
 
-	if (!check_for_blocking)
-		return 0;
+	if (!check_for_blocking) {
+		r = 1;
+		goto out;
+	}
 
 	/*
 	 * We avoid another system call if we can, but if a device is
@@ -293,16 +312,19 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			    strstr(params, "handle_errors")) {
 				log_debug("%s: I/O blocked to mirror device",
 					  dev_name(dev));
-				return 1;
+				goto out;
 			}
 		}
 	} while (next);
-	dm_task_destroy(dmt);
-
-	return 0;
 
+	r = 1;
 out:
-	return 1;
+	if (dmt)
+		dm_task_destroy(dmt);
+	dm_free(log_health);
+	dm_free(images_health);
+
+	return r;
 }
 
 int device_is_usable(struct device *dev)
@@ -356,7 +378,7 @@ int device_is_usable(struct device *dev)
 					  &target_type, &params);
 
 		if (target_type && !strcmp(target_type, "mirror") &&
-		    _ignore_blocked_mirror_devices(dev, start, length, params)) {
+		    !_ignore_blocked_mirror_devices(dev, start, length, params)) {
 			log_debug("%s: Mirror device %s not usable.",
 				  dev_name(dev), name);
 			goto out;


