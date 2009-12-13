From: Malahal Naineni <malahal@us.ibm.com>
Date: Sun, 13 Dec 2009 01:18:44 -0800
Subject: [PATCH 2 of 4] Handle transient secondary mirror leg failures
In-Reply-To: <patchbomb.1260695922@localhost>
References: <patchbomb.1260695922@localhost>
Message-ID: <1e369d480df09d0fac6c.1260695924@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A new mirror_device_fault_policy, "retry", is added to handle transient
device failures. When this policy is selected, the mirror DSO will try
to resync the mirror upon a secondary leg failure. This will be tried
and tried until the mirror goes to in_sync state. Later patches make this a
configurable number spaced at some configurable timeout.

The patch uses dmsetup suspend and resume commands to attempt a resync.
It uses "lvm dumpconfig" to find out the mirror_device_fault_policy.

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r a74600c6163e -r 1e369d480df0 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 13 01:16:51 2009 -0800
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 13 01:17:52 2009 -0800
@@ -14,6 +14,7 @@
 
 #include "lvm2cmd.h"
 #include "errors.h"
+#include "defaults.h"
 
 #include <libdevmapper.h>
 #include <libdevmapper-event.h>
@@ -24,6 +25,7 @@
 #include <stdlib.h>
 #include <pthread.h>
 #include <unistd.h>
+#include <ctype.h>
 
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
@@ -56,6 +58,109 @@ static int _register_count = 0;
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
+#define CMD_SIZE 256	/* FIXME Use system restriction */
+#define LINE_SIZE 1024	/* FIXME Use system restriction */
+static int fill_config_str(char buf[], int bufsize, const char *path)
+{
+	char cmd_str[CMD_SIZE];
+	char data[LINE_SIZE], *ptr;
+	int ret = 0;
+	FILE *fp;
+
+	snprintf(cmd_str, sizeof(cmd_str), "lvm dumpconfig %s", path);
+	if ((fp = popen(cmd_str, "r")) == NULL) {
+		syslog(LOG_ERR, "fopen() failed.\n");
+		goto out;
+	}
+
+	if ((ptr = fgets(data, sizeof(data), fp)) == NULL) {
+		syslog(LOG_ERR, "fgets() failed.\n");
+		pclose(fp);
+		goto out;
+	}
+
+	/* Remove white space or quotes at the end */
+	for (ptr = &data[strlen(data)-1]; ptr >= data; --ptr)
+		if (isspace(*ptr) || *ptr == '\"' || *ptr == '\'')
+			*ptr = '\0';
+		else
+			break;
+	ptr = strchr(data, '=');
+	if (ptr) {
+		ptr++; /* After the '=' sign */
+		/* skip quotes or white space */
+		if (isspace(*ptr) || *ptr == '\"' || *ptr == '\'')
+			ptr++;
+		strncpy(buf, ptr, bufsize);
+		buf[bufsize-1] = '\0';
+		ret = 1; /* buf is valid */
+	}
+	if (pclose(fp) != 0)
+		syslog(LOG_ERR, "pclose() failed.\n");
+
+out:
+	return ret;
+}
+
+static enum fault_policy fault_policy_str2enum(const char *str)
+{
+	enum fault_policy ret = FAULT_POLICY_INVALID;
+
+	/* At most the loop is ran twice */
+	while (ret == FAULT_POLICY_INVALID) {
+		if (!strcmp(str, "remove"))
+			ret = FAULT_POLICY_REMOVE;
+		else if (!strcmp(str, "allocate"))
+			ret = FAULT_POLICY_ALLOCATE;
+		else if (!strcmp(str, "allocate_anywhere"))
+			ret = FAULT_POLICY_ALLOCATE_ANYWHERE;
+		else if (!strcmp(str, "retry"))
+			ret = FAULT_POLICY_RETRY;
+		else {
+			syslog(LOG_ERR, "Bad activation/"
+					"mirror_device_fault_policy: %s\n",
+					str);
+			str = DEFAULT_MIRROR_DEV_FAULT_POLICY;
+		}
+	}
+
+	return ret;
+}
+
+
+static enum fault_policy get_mirror_fault_policy()
+{
+	enum fault_policy ret;
+	char policy[LINE_SIZE];
+	const char *ptr;
+
+	ret = fill_config_str(policy, sizeof(policy),
+			"activation/mirror_device_fault_policy");
+	if (ret) {
+		if (!strcmp(policy, ""))
+			ptr = DEFAULT_MIRROR_DEV_FAULT_POLICY;
+		else
+			ptr = policy;
+	} else {
+		ptr = DEFAULT_MIRROR_DEV_FAULT_POLICY;
+	}
+	ret = fault_policy_str2enum(ptr);
+
+	return ret;
+}
+
 /*
  * Currently only one event can be processed at a time.
  */
@@ -200,10 +305,52 @@ static void _temporary_log_fn(int level,
 		syslog(LOG_DEBUG, "%s", format);
 }
 
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
+	snprintf(cmd_str, CMD_SIZE, "dmsetup suspend --noflush %s-%s", vg, lv);
+	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
+	r = system(cmd_str);
+
+	snprintf(cmd_str, CMD_SIZE, "dmsetup table %s-%s | dmsetup load "
+			"%s-%s", vg, lv, vg, lv);
+	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
+	r |= system(cmd_str);
+
+	snprintf(cmd_str, CMD_SIZE, "dmsetup resume %s-%s", vg, lv);
+	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
+	r |= system(cmd_str);
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
 
@@ -238,7 +385,7 @@ static int _remove_failed_devices(const 
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute((unused)),
-		   void **unused __attribute((unused)))
+		   void **private)
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -246,6 +393,7 @@ void process_event(struct dm_task *dmt,
 	char *params;
 	const char *device = dm_task_get_name(dmt);
 	int error;
+	struct mirror_device_info *mirror_info = *private;
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
@@ -268,8 +416,17 @@ void process_event(struct dm_task *dmt,
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
+ 					syslog(LOG_ERR, "Failed to reload the "
+ 							"mirror: %s\n", device);
+ 			} else if (_remove_failed_devices(device)) {
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
 				       device);
@@ -285,9 +442,8 @@ void process_event(struct dm_task *dmt,
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
@@ -299,9 +455,10 @@ int register_device(const char *device,
 		    const char *uuid __attribute((unused)),
 		    int major __attribute((unused)),
 		    int minor __attribute((unused)),
-		    void **unused __attribute((unused)))
+		    void **private)
 {
 	int r = 0;
+	struct mirror_device_info *mirror_info;
 
 	pthread_mutex_lock(&_register_mutex);
 
@@ -312,9 +469,19 @@ int register_device(const char *device,
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
@@ -339,8 +506,11 @@ int unregister_device(const char *device
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
diff -r a74600c6163e -r 1e369d480df0 doc/example.conf
--- a/doc/example.conf	Sun Dec 13 01:16:51 2009 -0800
+++ b/doc/example.conf	Sun Dec 13 01:17:52 2009 -0800
@@ -403,6 +403,9 @@ activation {
     #            since it would break the redundant nature of the mirror. This
     #            policy acts like "remove" if no suitable device and space can
     #            be allocated for the replacement.
+    #
+    # "retry" - Try to re-integrate the failed mirror leg assuming that the
+    #           failure is transient. Not implemented yet, so don't use it.
 
     mirror_log_fault_policy = "allocate"
     mirror_device_fault_policy = "remove"
diff -r a74600c6163e -r 1e369d480df0 lib/metadata/mirror.c
--- a/lib/metadata/mirror.c	Sun Dec 13 01:16:51 2009 -0800
+++ b/lib/metadata/mirror.c	Sun Dec 13 01:17:52 2009 -0800
@@ -37,6 +37,7 @@
 #define MIRROR_REMOVE		 0
 #define MIRROR_ALLOCATE		 1
 #define MIRROR_ALLOCATE_ANYWHERE 2
+#define MIRROR_RETRY	 	 3
 
 /*
  * Returns true if the lv is temporary mirror layer for resync
@@ -787,6 +788,8 @@ static int get_mirror_fault_policy(struc
 		return MIRROR_ALLOCATE;
 	else if (!strcmp(policy, "allocate_anywhere"))
 		return MIRROR_ALLOCATE_ANYWHERE;
+	else if (!strcmp(policy, "retry"))
+		return MIRROR_RETRY;
 
 	if (log_policy)
 		log_error("Bad activation/mirror_log_fault_policy");


