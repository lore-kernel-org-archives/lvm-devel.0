From: Malahal Naineni <malahal@us.ibm.com>
Date: Sun, 13 Dec 2009 01:18:43 -0800
Subject: [PATCH 1 of 4] Add more error codes in mirror DSO
In-Reply-To: <patchbomb.1260695922@localhost>
References: <patchbomb.1260695922@localhost>
Message-ID: <a74600c6163e6640d0ca.1260695923@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The mirror DSO (daemons/dmeventd/plugins/mirror/dmeventd_mirror.c) logs
various device failure codes but only handles one failure, 'ME_FAILURE'.
This patchs adds more error codes to handle multiple types of device
failures.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

diff -r a48a5f0eea85 -r a74600c6163e daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 06 23:04:13 2009 -0800
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Sun Dec 13 01:16:51 2009 -0800
@@ -30,9 +30,17 @@
 /* FIXME Replace most syslogs with log_error() style messages and add complete context. */
 /* FIXME Reformat to 80 char lines. */
 
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
@@ -53,45 +61,68 @@ static void *_lvm_handle = NULL;
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
-static int _process_status_code(const char status_code, const char *dev_name,
-				const char *dev_type, int r)
+static int _process_status_code(const char *mirror, const char *device,
+			        const char status_code, int dev_index)
 {
-	/*
-	 *    A => Alive - No failures
-	 *    D => Dead - A write failure occurred leaving mirror out-of-sync
-	 *    F => Flush failed.
-	 *    S => Sync - A sychronization failure occurred, mirror out-of-sync
-	 *    R => Read - A read failure occurred, mirror data unaffected
-	 *    U => Unclassified failure (bug)
-	 */ 
-	if (status_code == 'F') {
-		syslog(LOG_ERR, "%s device %s flush failed.\n",
-		       dev_type, dev_name);
-		r = ME_FAILURE;
-	} else if (status_code == 'S')
-		syslog(LOG_ERR, "%s device %s sync failed.\n",
-		       dev_type, dev_name);
-	else if (status_code == 'R')
-		syslog(LOG_ERR, "%s device %s read failed.\n",
-		       dev_type, dev_name);
-	else if (status_code != 'A') {
-		syslog(LOG_ERR, "%s device %s has failed (%c).\n",
-		       dev_type, dev_name, status_code);
-		r = ME_FAILURE;
+	int r;
+	const char *error_string;
+	const char *dev_type = dev_index ? "Secondary" : "Primary";
+
+	switch (status_code) {
+	default:
+	case 'U': /* Unclassified failure (bug) */
+	case 'D': /* Write failure occurred leaving mirror out-of-sync */
+	case 'F': /* Flush failure, handled as write failure */
+		if (status_code == 'D')
+			error_string = "write";
+		else if (status_code == 'F')
+			error_string = "flush";
+		else if (status_code == 'U')
+			error_string = "unclassified";
+		else {
+			syslog(LOG_ERR, "Unknown device status code (%c).\n",
+					status_code);
+			error_string = "unknown";
+		}
+
+		syslog(LOG_ERR, "Mirror device: %s, %s leg: %s had a %s "
+				"failure.\n", mirror, dev_type, device,
+				error_string);
+
+		r = dev_index? ME_SECONDARY_WRITE_FAILURE :
+			ME_PRIMARY_WRITE_FAILURE;
+		break;
+
+	case 'S': /* Sychronization failure occurred, mirror out-of-sync */
+		syslog(LOG_ERR, "Mirror device: %s, %s leg: %s had "
+				"sync failure.\n", mirror, dev_type, device);
+		r = ME_SYNC_FAILURE;
+		break;
+
+	case 'R': /* Read failure occurred, mirror data unaffected */
+		syslog(LOG_ERR, "Mirror device: %s, %s leg: %s had a "
+				"read failure.\n", mirror, dev_type, device);
+		r = ME_READ_FAILURE;
+		break;
+
+	case 'A': /* Active, a good status */
+		r = 0;
+		break;
 	}
 
 	return r;
 }
 
-static int _get_mirror_event(char *params)
+static int _get_mirror_event(const char *mirror, char *params)
 {
-	int i, r = ME_INSYNC;
+	int i;
 	char **args = NULL;
 	char *dev_status_str;
 	char *log_status_str;
 	char *sync_str;
 	char *p = NULL;
 	int log_argc, num_devs;
+	int retval = 0;
 
 	/*
 	 * dm core parms:	     0 409600 mirror
@@ -122,23 +153,25 @@ static int _get_mirror_event(char *param
 
 	/* Check for bad mirror devices */
 	for (i = 0; i < num_devs; i++)
-		r = _process_status_code(dev_status_str[i], args[i],
-			i ? "Secondary mirror" : "Primary mirror", r);
+		retval |= _process_status_code(mirror, args[i],
+					       dev_status_str[i], i);
 
 	/* Check for bad disk log device */
-	if (log_argc > 1)
-		r = _process_status_code(log_status_str[0],
-					 args[2 + num_devs + log_argc],
-					 "Log", r);
+	if (log_argc > 1 && log_status_str[0] == 'D') {
+		syslog(LOG_ERR, "Mirror device: %s, log device: %s failed.\n",
+				mirror, args[2 + num_devs + log_argc]);
+		retval = retval | ME_LOG_FAILURE;
+	}
 
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
@@ -146,7 +179,7 @@ static int _get_mirror_event(char *param
 out:
 	if (args)
 		dm_free(args);
-	return r;
+	return retval;
 	
 out_parse:
 	if (args)
@@ -212,6 +245,7 @@ void process_event(struct dm_task *dmt,
 	char *target_type = NULL;
 	char *params;
 	const char *device = dm_task_get_name(dmt);
+	int error;
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
@@ -231,17 +265,11 @@ void process_event(struct dm_task *dmt,
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
@@ -250,13 +278,18 @@ void process_event(struct dm_task *dmt,
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


