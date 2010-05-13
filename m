From: Milan Broz <mbroz@redhat.com>
Date: Thu, 13 May 2010 17:46:04 +0200
Subject: [PATCH v2] Skip also special lvm devices in scan (if ignore suspended is used).
In-Reply-To: <1273764262-15922-1-git-send-email-mbroz@redhat.com>
References: <1273764262-15922-1-git-send-email-mbroz@redhat.com>
Message-ID: <4BEC1EBC.8040005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Skip also special lvm devices in scan (if ignore suspended is used).

This shoud avoid various races between dmeventd on multiple nodes
in cluster where one node already repairing device and another
run full scan and locks the device.

Signed-off-by: Milan Broz <mbroz@redhat.com>

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d52d46f..f3cf631 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -130,7 +130,7 @@ int device_is_usable(dev_t dev)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
-	const char *name;
+	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
@@ -157,6 +157,7 @@ int device_is_usable(dev_t dev)
 		goto out;
 
 	name = dm_task_get_name(dmt);
+	uuid = dm_task_get_uuid(dmt);
 
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
 	/* For now, we exclude all mirrors */
@@ -165,12 +166,21 @@ int device_is_usable(dev_t dev)
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 		/* Skip if target type doesn't match */
-		if (target_type && !strcmp(target_type, "mirror"))
+		if (target_type && !strcmp(target_type, "mirror")) {
+			log_debug("%s: Mirror device not usable.", name);
 			goto out;
+		}
 	} while (next);
 
 	/* FIXME Also check dependencies? */
 
+	/* Check internal lvm devices */
+	if (is_reserved_lvname(name) && uuid &&
+	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+		log_debug("%s: Reserved internal LVM device not usable.", name);
+		goto out;
+	}
+
 	r = 1;
 
       out:
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index b33d099..03695e3 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -133,7 +133,7 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute((unus
 	/* Skip suspended devices */
 	if (MAJOR(dev->dev) == _device_mapper_major &&
 	    ignore_suspended_devices() && !device_is_usable(dev->dev)) {
-		log_debug("%s: Skipping: Suspended dm device", name);
+		log_debug("%s: Skipping: Suspended or internal dm device", name);
 		return 0;
 	}
 



