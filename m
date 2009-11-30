From: Malahal Naineni <malahal@us.ibm.com>
Date: Mon, 30 Nov 2009 02:22:29 -0800
Subject: [PATCH 1 of 2] Improve mirror DSO's failure logging
In-Reply-To: <patchbomb.1259576548@localhost>
References: <patchbomb.1259576548@localhost>
Message-ID: <e5581203d547fd7f4d45.1259576549@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The mirror target has the following device states. The mirror DSO
(daemons/dmeventd/plugins/mirror/dmeventd_mirror.c) doesn't know any of these
states. This patchs adds these states to the DSO for better error reporting.

	A => Alive - No failures
	D => Dead - A write failure occurred leaving mirror out-of-sync
	S => Sync - A sychronization failure occurred, mirror out-of-sync
	R => Read - A read failure occurred, mirror data unaffected

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

diff -r fff61ad560ad -r e5581203d547 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Thu Oct 22 18:32:27 2009 -0700
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Mon Nov 30 02:12:18 2009 -0800
@@ -28,9 +28,17 @@
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
-#define ME_IGNORE    0
-#define ME_INSYNC    1
-#define ME_FAILURE   2
+/* 
+ * An event may contain more than one error type. The following are bit
+ * flags that indicate each error type.
+ */
+#define ME_IGNORE    			0x01U
+#define ME_INSYNC    			0x02U
+#define ME_READ_FAILURE   		0x04U
+#define ME_SYNC_FAILURE   		0x08U
+#define ME_LOG_FAILURE 			0x10U
+#define ME_SECONDARY_WRITE_FAILURE	0x20U
+#define ME_PRIMARY_WRITE_FAILURE	0x40U
 
 /*
  * register_device() is called first and performs initialisation.
@@ -51,15 +59,16 @@ static void *_lvm_handle = NULL;
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
-static int _get_mirror_event(char *params)
+static int _get_mirror_event(const char *device, char *params)
 {
-	int i, r = ME_INSYNC;
+	int i, r;
 	char **args = NULL;
 	char *dev_status_str;
 	char *log_status_str;
 	char *sync_str;
 	char *p = NULL;
 	int log_argc, num_devs;
+	int retval = 0;
 
 	/*
 	 * dm core parms:	     0 409600 mirror
@@ -89,27 +98,48 @@ static int _get_mirror_event(char *param
 	sync_str = args[num_devs];
 
 	/* Check for bad mirror devices */
-	for (i = 0; i < num_devs; i++)
-		if (dev_status_str[i] == 'D') {
-			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
-			r = ME_FAILURE;
+	for (i = 0; i < num_devs; i++) {
+		r = 0;
+		switch (dev_status_str[i]) {
+		case 'D': /* write failure */
+		case 'F': /* flush failure, handled as write failure */
+			syslog(LOG_ERR, "Mirror device: %s, leg: %s had a "
+					"write failure.\n", device, args[i]);
+			if (i == 0)
+				r = ME_PRIMARY_WRITE_FAILURE;
+			else 
+				r = ME_SECONDARY_WRITE_FAILURE;
+			break;
+		case 'S':
+			syslog(LOG_ERR, "Mirror device: %s, leg: %s had "
+					"sync failure.\n", device, args[i]);
+			r = ME_SYNC_FAILURE;
+			break;
+		case 'R':
+			syslog(LOG_ERR, "Mirror device: %s, leg: %s had a "
+					"read failure.\n", device, args[i]);
+			r = ME_READ_FAILURE;
+			break;
 		}
+		retval = retval | r;
+	}
 
 	/* Check for bad disk log device */
 	if (log_argc > 1 && log_status_str[0] == 'D') {
-		syslog(LOG_ERR, "Log device, %s, has failed.\n",
-		       args[2 + num_devs + log_argc]);
-		r = ME_FAILURE;
+		syslog(LOG_ERR, "Mirror device: %s, log device: %s failed.\n",
+				device, args[2 + num_devs + log_argc]);
+		retval = retval | ME_LOG_FAILURE;
 	}
 
-	if (r == ME_FAILURE)
+	if (retval)	/* A failure occurred */
 		goto out;
 
+	retval = ME_INSYNC;	/* assume INSYNC event */
 	p = strstr(sync_str, "/");
 	if (p) {
 		p[0] = '\0';
 		if (strcmp(sync_str, p+1))
-			r = ME_IGNORE;
+			retval = ME_IGNORE;
 		p[0] = '/';
 	} else
 		goto out_parse;
@@ -117,7 +147,7 @@ static int _get_mirror_event(char *param
 out:
 	if (args)
 		dm_free(args);
-	return r;
+	return retval;
 	
 out_parse:
 	if (args)
@@ -183,6 +213,7 @@ void process_event(struct dm_task *dmt,
 	char *target_type = NULL;
 	char *params;
 	const char *device = dm_task_get_name(dmt);
+	int error;
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
@@ -202,17 +233,11 @@ void process_event(struct dm_task *dmt,
 			continue;
 		}
 
-		switch(_get_mirror_event(params)) {
-		case ME_INSYNC:
-			/* FIXME: all we really know is that this
-			   _part_ of the device is in sync
-			   Also, this is not an error
-			*/
-			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
-			break;
-		case ME_FAILURE:
-			syslog(LOG_ERR, "Device failure in %s\n", device);
-			if (_remove_failed_devices(device))
+		error = _get_mirror_event(device, params);
+		if (error & ME_LOG_FAILURE ||
+		    error & ME_PRIMARY_WRITE_FAILURE ||
+		    error & ME_SECONDARY_WRITE_FAILURE) {
+			if (_remove_failed_devices(device)) {
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
 				       device);
@@ -221,13 +246,18 @@ void process_event(struct dm_task *dmt,
 				syslog(LOG_NOTICE, "%s is now a linear device.\n",
 					device);
 			*/
-			break;
-		case ME_IGNORE:
-			break;
-		default:
-			/* FIXME Provide value then! */
-			syslog(LOG_INFO, "Unknown event received.\n");
-		}
+			}
+		} else if (error & ME_INSYNC) {
+			/* FIXME: all we really know is that this
+			   _part_ of the device is in sync
+			   Also, this is not an error
+			*/
+			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
+		} else if (error & ME_READ_FAILURE ||
+			   error & ME_SYNC_FAILURE) {
+			/* Ignore these for now */
+		} else
+			syslog(LOG_INFO, "Unknown event:%u received.\n", error);
 	} while (next);
 
 	pthread_mutex_unlock(&_event_mutex);


