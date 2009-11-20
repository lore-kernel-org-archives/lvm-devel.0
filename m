From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 20 Nov 2009 15:36:38 -0800
Subject: [PATCH] Improve mirror DSO's failure logging
Message-ID: <c107c082a3a5ab4f4a95.1258760198@localhost>
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

diff -r fff61ad560ad -r c107c082a3a5 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Thu Oct 22 18:32:27 2009 -0700
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	Fri Nov 20 15:33:30 2009 -0800
@@ -28,9 +28,13 @@
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
-#define ME_IGNORE    0
-#define ME_INSYNC    1
-#define ME_FAILURE   2
+#define ME_IGNORE    			0
+#define ME_INSYNC    			1
+#define ME_SYNC_FAILURE   		2
+#define ME_LOG_FAILURE 			3
+#define ME_READ_FAILURE   		4
+#define ME_PRIMARY_WRITE_FAILURE	5
+#define ME_SECONDARY_WRITE_FAILURE	6
 
 /*
  * register_device() is called first and performs initialisation.
@@ -53,7 +57,7 @@ static pthread_mutex_t _event_mutex = PT
 
 static int _get_mirror_event(char *params)
 {
-	int i, r = ME_INSYNC;
+	int i, r;
 	char **args = NULL;
 	char *dev_status_str;
 	char *log_status_str;
@@ -89,22 +93,40 @@ static int _get_mirror_event(char *param
 	sync_str = args[num_devs];
 
 	/* Check for bad mirror devices */
-	for (i = 0; i < num_devs; i++)
-		if (dev_status_str[i] == 'D') {
+	r = -1;
+	for (i = 0; i < num_devs && r == -1; i++) {
+		switch (dev_status_str[i]) {
+		case 'D':
 			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
-			r = ME_FAILURE;
+			if (i == 0)
+				r = ME_PRIMARY_WRITE_FAILURE;
+			else 
+				r = ME_SECONDARY_WRITE_FAILURE;
+			break;
+		case 'S':
+			syslog(LOG_ERR, "Mirror synchronization failed. "
+					"device, %s, failed.\n", args[i]);
+			r = ME_SYNC_FAILURE;
+			break;
+		case 'R':
+			syslog(LOG_ERR, "Mirror device, %s, read failed.\n",
+					args[i]);
+			r = ME_READ_FAILURE;
+			break;
 		}
+	}
 
 	/* Check for bad disk log device */
 	if (log_argc > 1 && log_status_str[0] == 'D') {
 		syslog(LOG_ERR, "Log device, %s, has failed.\n",
 		       args[2 + num_devs + log_argc]);
-		r = ME_FAILURE;
+		r = ME_LOG_FAILURE;
 	}
 
-	if (r == ME_FAILURE)
+	if (r != -1)	/* if a failure occurred */
 		goto out;
 
+	r = ME_INSYNC;	/* assume INSYNC event */
 	p = strstr(sync_str, "/");
 	if (p) {
 		p[0] = '\0';
@@ -210,7 +232,9 @@ void process_event(struct dm_task *dmt,
 			*/
 			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
 			break;
-		case ME_FAILURE:
+		case ME_LOG_FAILURE:
+		case ME_PRIMARY_WRITE_FAILURE:
+		case ME_SECONDARY_WRITE_FAILURE:
 			syslog(LOG_ERR, "Device failure in %s\n", device);
 			if (_remove_failed_devices(device))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
@@ -222,6 +246,8 @@ void process_event(struct dm_task *dmt,
 					device);
 			*/
 			break;
+		case ME_READ_FAILURE: /* we just ignore for now */
+		case ME_SYNC_FAILURE:
 		case ME_IGNORE:
 			break;
 		default:


