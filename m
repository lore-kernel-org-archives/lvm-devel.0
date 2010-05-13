From: Milan Broz <mbroz@redhat.com>
Date: Thu, 13 May 2010 17:24:22 +0200
Subject: [PATCH] Skip also special lvm devices in scan (if ignore suspended is used).
Message-ID: <1273764262-15922-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This shoud avoid various races between dmeventd on multiple nodes
in cluster where one node already repairing device and another
run full scan and locks the device.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/dev_manager.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d52d46f..ccafc1e 100644
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
@@ -171,6 +172,11 @@ int device_is_usable(dev_t dev)
 
 	/* FIXME Also check dependencies? */
 
+	/* Check internal lvm devices */
+	if (!is_reserved_lvname(name) && uuid &&
+	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1))
+		goto out;
+
 	r = 1;
 
       out:
-- 
1.7.1


