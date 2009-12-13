From: Malahal Naineni <malahal@us.ibm.com>
Date: Sun, 13 Dec 2009 01:18:46 -0800
Subject: [PATCH 4 of 4] Attempt to resync a failed secondary leg few times before giving up
In-Reply-To: <patchbomb.1260695922@localhost>
References: <patchbomb.1260695922@localhost>
Message-ID: <bebd880d74762d7693f3.1260695926@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds the capability to attempt resync of a failed mirror
device at a given timeout interval and given number of attempts.

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r 1c364c686b5e -r bebd880d7476 daemons/dmeventd/plugins/mirror/Makefile.in
--- a/daemons/dmeventd/plugins/mirror/Makefile.in	Sun Dec 13 01:17:57 2009 -0800
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in	Sun Dec 13 01:17:57 2009 -0800
@@ -32,7 +32,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+LIBS += -ldevmapper -ldevmapper-event @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff -r 1c364c686b5e -r bebd880d7476 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 13 01:17:57 2009 -0800
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 13 01:17:57 2009 -0800
@@ -68,6 +68,9 @@ enum fault_policy {
 
 struct mirror_device_info {
 	enum fault_policy fault_policy;
+	int retry_total;	/* number of retries before giving up */
+	int retry_current;	/* number of retries already tried */
+	int retry_timeout;	/* timeout between retry attepts, in seconds */
 };
 
 #define CMD_SIZE 256	/* FIXME Use system restriction */
@@ -161,6 +164,16 @@ static enum fault_policy get_mirror_faul
 	return ret;
 }
 
+static int get_mirror_retry_num()
+{
+	return 10; /* FIXME: make it configurable */
+}
+
+static int get_mirror_retry_timeout()
+{
+	return 30; /* 30 seconds. FIXME: make it configurable */
+}
+
 /*
  * Currently only one event can be processed at a time.
  */
@@ -305,8 +318,22 @@ static void _temporary_log_fn(int level,
 		syslog(LOG_DEBUG, "%s", format);
 }
 
+static int start_retry_failed_devices(const char *device,
+				     struct mirror_device_info *mirror_info)
+{
+	/* Schedule a timeout for retrying failed devices. Note that
+	 * our process_event gets called@every retry_timeout interval
+	 * until we remove it by calling dm_event_unset_timeout */
+	return dm_event_set_timeout(device, mirror_info->retry_timeout);
+}
 
-static int retry_failed_devices(const char *device)
+static int stop_retry_failed_devices(const char *device)
+{
+	return dm_event_unset_timeout(device);
+}
+
+static int retry_failed_devices(const char *device,
+			        struct mirror_device_info *mirror_info)
 {
 	int r;
 	char cmd_str[CMD_SIZE];
@@ -348,6 +375,32 @@ static int retry_failed_devices(const ch
 	return r;
 }
 
+static int process_timeout(const char *device,
+			   struct mirror_device_info *mirror_info)
+{
+	int ret;
+
+	if (mirror_info->retry_current > mirror_info->retry_total) {
+		syslog(LOG_ERR, "Unable to resync the mirror: %s after %d "
+				"attempts. Giving up.\n", device,
+				mirror_info->retry_total);
+		stop_retry_failed_devices(device);
+		ret = -ENOMEM;
+	} else {
+		mirror_info->retry_current++;
+		syslog(LOG_ERR, "Trying to resync the failed mirror: %s "
+				"attepmt number: %d\n", device,
+				 mirror_info->retry_current);
+		ret = retry_failed_devices(device, mirror_info);
+
+		/* If we successfully retried failed device, stop the timer */
+		if (!ret)
+			stop_retry_failed_devices(device);
+	}
+
+	return ret;
+}
+
 static int _remove_failed_devices(const char *device)
 {
 	int r;
@@ -384,7 +437,7 @@ static int _remove_failed_devices(const 
 }
 
 void process_event(struct dm_task *dmt,
-		   enum dm_event_mask event __attribute((unused)),
+		   enum dm_event_mask event,
 		   void **private)
 {
 	void *next = NULL;
@@ -399,6 +452,12 @@ void process_event(struct dm_task *dmt,
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
 		pthread_mutex_lock(&_event_mutex);
 	}
+
+	if (event & DM_EVENT_TIMEOUT) {
+		process_timeout(device, mirror_info);
+		goto out;
+	}
+
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
@@ -421,11 +480,14 @@ void process_event(struct dm_task *dmt,
  			if (mirror_info->fault_policy == FAULT_POLICY_RETRY &&
 					(error & ME_SECONDARY_WRITE_FAILURE ||
 					 error & ME_SYNC_FAILURE)) {
- 				syslog(LOG_ERR, "Retrying the failed mirror "
- 						"device.\n");
- 				if (retry_failed_devices(device))
- 					syslog(LOG_ERR, "Failed to reload the "
- 							"mirror: %s\n", device);
+ 				syslog(LOG_ERR, "Start recovery for the "
+						"failed mirror device: %s.\n",
+						device);
+ 				if (!start_retry_failed_devices(device,
+								mirror_info))
+ 					syslog(LOG_ERR, "Failed to start retry "
+							"for the failed mirror "
+ 							"device: %s\n", device);
  			} else if (_remove_failed_devices(device)) {
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
@@ -441,6 +503,11 @@ void process_event(struct dm_task *dmt,
 			   _part_ of the device is in sync
 			   Also, this is not an error
 			*/
+ 			if (mirror_info->fault_policy == FAULT_POLICY_RETRY) {
+				/* stop if we scheduled any timeouts for retry */
+				mirror_info->retry_current = 0;
+				stop_retry_failed_devices(device);
+			}
 			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
 		} else if (error & ME_READ_FAILURE) {
 			/* Ignore it for now */
@@ -448,6 +515,7 @@ void process_event(struct dm_task *dmt,
 			syslog(LOG_INFO, "Unknown event:%u received.\n", error);
 	} while (next);
 
+out:
 	pthread_mutex_unlock(&_event_mutex);
 }
 
@@ -476,6 +544,11 @@ int register_device(const char *device,
 		goto out;
 	}
 	mirror_info->fault_policy = get_mirror_fault_policy();
+	if (mirror_info->fault_policy == FAULT_POLICY_RETRY) {
+		mirror_info->retry_total = get_mirror_retry_num();
+		mirror_info->retry_current = 0;
+		mirror_info->retry_timeout = get_mirror_retry_timeout();
+	}
 	*private = mirror_info;
 
 	if (!_lvm_handle) {
@@ -511,8 +584,12 @@ int unregister_device(const char *device
 	struct mirror_device_info *mirror_info = *private;
 
 	dm_free(mirror_info);
+
 	pthread_mutex_lock(&_register_mutex);
 
+	/* Stop the retry timer, if any */
+	stop_retry_failed_devices(device);
+
 	syslog(LOG_INFO, "No longer monitoring mirror device %s for events\n",
 	       device);
 


