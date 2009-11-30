From: Malahal Naineni <malahal@us.ibm.com>
Date: Mon, 30 Nov 2009 02:22:30 -0800
Subject: [PATCH 2 of 2] [RFC] handle a temporary secondary mirror device failure
In-Reply-To: <patchbomb.1259576548@localhost>
References: <patchbomb.1259576548@localhost>
Message-ID: <a0324c61e9fc527d6a9d.1259576550@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If "retry" policy is selected, then the mirror DSO uses "dmsetup"
command to restart a resync. Right now, it is done immediately but we
should do it after a configured time. Also, this is done endlessly but
should be done only few configured times.

Calling 'lvchange --refresh' to re-integrate the secondary mirror upon a
leg failure works if there are no device failures while the "lvchange"
is running.  Otherwise, the failed device is replaced with "error"
target which is not what we want. For now, this patch calls "dmsetup",
but should be replaced with a suitable "LVM" command.

Can the DSO call __find_config_tree_str() to get the mirror fault policy
set in /etc/lvm/lvm.conf file? For now, this is hardcoded.

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r e5581203d547 -r a0324c61e9fc daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Mon Nov 30 02:12:18 2009 -0800
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Mon Nov 30 02:22:09 2009 -0800
@@ -25,6 +25,9 @@
 #include <pthread.h>
 #include <unistd.h>
 
+#include "config.h"
+#include "defaults.h"
+
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
@@ -54,6 +57,53 @@ static int _register_count = 0;
 static struct dm_pool *_mem_pool = NULL;
 static void *_lvm_handle = NULL;
 
+enum fault_policy {
+	FAULT_POLICY_INVALID,
+	FAULT_POLICY_REMOVE,
+	FAULT_POLICY_ALLOCATE,
+	FAULT_POLICY_ALLOCATE_ANYWHERE,
+	FAULT_POLICY_RETRY,
+};
+
+struct mirror_device_info {
+	enum fault_policy fault_policy;
+};
+
+static enum fault_policy fault_policy_str2enum(const char *str)
+{
+	enum fault_policy ret = FAULT_POLICY_INVALID;
+
+	if (!strcmp(str, "remove"))
+		ret = FAULT_POLICY_REMOVE;
+	else if (!strcmp(str, "allocate"))
+		ret = FAULT_POLICY_ALLOCATE;
+	else if (!strcmp(str, "allocate_anywhere"))
+		ret = FAULT_POLICY_ALLOCATE_ANYWHERE;
+	else if (!strcmp(str, "retry"))
+		ret = FAULT_POLICY_RETRY;
+
+	return ret;
+}
+
+static enum fault_policy get_mirror_fault_policy()
+{
+	const char *policy;
+	enum fault_policy ret;
+
+	/* FIXME: Malahal
+	   policy = __find_config_tree_str(NULL, "activation/mirror_device_fault_policy",
+			         DEFAULT_MIRROR_DEV_FAULT_POLICY); */
+	policy = "retry";
+	ret = fault_policy_str2enum(policy);
+	if (ret == FAULT_POLICY_INVALID) {
+		syslog(LOG_ERR, "Bad activation/mirror_device_fault_policy: "
+				"%s\n", policy);
+		ret = fault_policy_str2enum(DEFAULT_MIRROR_DEV_FAULT_POLICY);
+	}
+
+	return ret;
+}
+
 /*
  * Currently only one event can be processed at a time.
  */
@@ -168,10 +218,49 @@ static void _temporary_log_fn(int level,
 		syslog(LOG_DEBUG, "%s", format);
 }
 
+#define CMD_SIZE 256	/* FIXME Use system restriction */
+
+static int retry_failed_devices(const char *device)
+{
+	int r;
+	char cmd_str[CMD_SIZE];
+	char *vg = NULL, *lv = NULL, *layer = NULL;
+
+	if (strlen(device) > 200)  /* FIXME Use real restriction */
+		/* FIXME These return code distinctions are not used so
+		 * remove them! */
+		return -ENAMETOOLONG;
+
+	if (!dm_split_lvm_name(_mem_pool, device, &vg, &lv, &layer)) {
+		syslog(LOG_ERR, "Unable to determine VG name from %s",
+		       device);
+		/* FIXME Replace with generic error return - reason for
+		 * failure has already got logged */
+		return -ENOMEM;
+	}
+
+	/* FIXME: should be running an LVM command that is pinned.
+	 * dmsetup command may not be pinned in memory all the time.
+	 * "lvchange --refresh vg/lv" only works if there are no device
+	 * failures while it is running. Otherwise, the failed device
+	 * is replaced with "error" target which is not what we want.
+	 */
+	snprintf(cmd_str, CMD_SIZE, "dmsetup suspend %s-%s", vg, lv);
+	syslog(LOG_ERR, "Running command: %s", cmd_str);
+	r = system(cmd_str);
+	if (r == 0) {
+		snprintf(cmd_str, CMD_SIZE, "dmsetup resume %s-%s", vg, lv);
+		syslog(LOG_ERR, "Running command: %s", cmd_str);
+		r = system(cmd_str);
+	}
+
+	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
+	return r;
+}
+
 static int _remove_failed_devices(const char *device)
 {
 	int r;
-#define CMD_SIZE 256	/* FIXME Use system restriction */
 	char cmd_str[CMD_SIZE];
 	char *vg = NULL, *lv = NULL, *layer = NULL;
 
@@ -206,7 +295,7 @@ static int _remove_failed_devices(const 
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute((unused)),
-		   void **unused __attribute((unused)))
+		   void **private)
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -214,6 +303,7 @@ void process_event(struct dm_task *dmt,
 	char *params;
 	const char *device = dm_task_get_name(dmt);
 	int error;
+	struct mirror_device_info *mirror_info = *private;
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
@@ -236,8 +326,17 @@ void process_event(struct dm_task *dmt,
 		error = _get_mirror_event(device, params);
 		if (error & ME_LOG_FAILURE ||
 		    error & ME_PRIMARY_WRITE_FAILURE ||
-		    error & ME_SECONDARY_WRITE_FAILURE) {
-			if (_remove_failed_devices(device)) {
+		    error & ME_SECONDARY_WRITE_FAILURE ||
+		    error & ME_SYNC_FAILURE) {
+ 			if (mirror_info->fault_policy == FAULT_POLICY_RETRY &&
+					(error & ME_SECONDARY_WRITE_FAILURE ||
+					 error & ME_SYNC_FAILURE)) {
+ 				syslog(LOG_ERR, "Retrying the failed mirror "
+ 						"device.\n");
+ 				if (retry_failed_devices(device))
+ 					syslog(LOG_ERR, "Failed to refresh the "
+ 							"mirror: %s\n", device);
+ 			} else if (_remove_failed_devices(device)) {
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
 				       device);
@@ -253,9 +352,8 @@ void process_event(struct dm_task *dmt,
 			   Also, this is not an error
 			*/
 			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
-		} else if (error & ME_READ_FAILURE ||
-			   error & ME_SYNC_FAILURE) {
-			/* Ignore these for now */
+		} else if (error & ME_READ_FAILURE) {
+			/* Ignore it for now */
 		} else
 			syslog(LOG_INFO, "Unknown event:%u received.\n", error);
 	} while (next);
@@ -267,9 +365,10 @@ int register_device(const char *device,
 		    const char *uuid __attribute((unused)),
 		    int major __attribute((unused)),
 		    int minor __attribute((unused)),
-		    void **unused __attribute((unused)))
+		    void **private)
 {
 	int r = 0;
+	struct mirror_device_info *mirror_info;
 
 	pthread_mutex_lock(&_register_mutex);
 
@@ -282,9 +381,19 @@ int register_device(const char *device,
 	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
 		goto out;
 
+	mirror_info = dm_malloc(sizeof(struct mirror_device_info));
+	if (!mirror_info) {
+		dm_pool_destroy(_mem_pool);
+		_mem_pool = NULL;
+		goto out;
+	}
+	mirror_info->fault_policy = get_mirror_fault_policy();
+	*private = mirror_info;
+
 	if (!_lvm_handle) {
 		lvm2_log_fn(_temporary_log_fn);
 		if (!(_lvm_handle = lvm2_init())) {
+			dm_free(mirror_info);
 			dm_pool_destroy(_mem_pool);
 			_mem_pool = NULL;
 			goto out;
@@ -307,8 +416,11 @@ int unregister_device(const char *device
 		      const char *uuid __attribute((unused)),
 		      int major __attribute((unused)),
 		      int minor __attribute((unused)),
-		      void **unused __attribute((unused)))
+		      void **private)
 {
+	struct mirror_device_info *mirror_info = *private;
+
+	dm_free(mirror_info);
 	pthread_mutex_lock(&_register_mutex);
 
 	syslog(LOG_INFO, "No longer monitoring mirror device %s for events\n",
diff -r e5581203d547 -r a0324c61e9fc doc/example.conf
--- a/doc/example.conf	Mon Nov 30 02:12:18 2009 -0800
+++ b/doc/example.conf	Mon Nov 30 02:22:09 2009 -0800
@@ -392,6 +392,9 @@ activation {
     #            since it would break the redundant nature of the mirror. This
     #            policy acts like "remove" if no suitable device and space can
     #            be allocated for the replacement.
+    #
+    # "retry" - Try to re-integrate the failed mirror leg assuming that the
+    #           failure is transient. Not implemented yet, so don't use it.
 
     mirror_log_fault_policy = "allocate"
     mirror_device_fault_policy = "remove"
diff -r e5581203d547 -r a0324c61e9fc lib/metadata/mirror.c
--- a/lib/metadata/mirror.c	Mon Nov 30 02:12:18 2009 -0800
+++ b/lib/metadata/mirror.c	Mon Nov 30 02:22:09 2009 -0800
@@ -36,6 +36,7 @@
 #define MIRROR_REMOVE		 0
 #define MIRROR_ALLOCATE		 1
 #define MIRROR_ALLOCATE_ANYWHERE 2
+#define MIRROR_RETRY	 	 3
 
 /*
  * Returns true if the lv is temporary mirror layer for resync
@@ -773,6 +774,8 @@ static int get_mirror_fault_policy(struc
 		return MIRROR_ALLOCATE;
 	else if (!strcmp(policy, "allocate_anywhere"))
 		return MIRROR_ALLOCATE_ANYWHERE;
+	else if (!strcmp(policy, "retry"))
+		return MIRROR_RETRY;
 
 	if (log_policy)
 		log_error("Bad activation/mirror_log_fault_policy");


