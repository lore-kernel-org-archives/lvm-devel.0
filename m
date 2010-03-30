From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:39:56 -0000
Subject: LVM2/daemons/dmeventd/plugins/mirror dmeventd_ ...
Message-ID: <20100330143956.18955.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:39:55

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Updated syslog messages
	
	Use our common '.' end format for syslog messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/03/26 22:15:43	1.32
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/03/30 14:39:55	1.33
@@ -42,17 +42,17 @@
 	 *    U => Unclassified failure (bug)
 	 */ 
 	if (status_code == 'F') {
-		syslog(LOG_ERR, "%s device %s flush failed.\n",
+		syslog(LOG_ERR, "%s device %s flush failed.",
 		       dev_type, dev_name);
 		r = ME_FAILURE;
 	} else if (status_code == 'S')
-		syslog(LOG_ERR, "%s device %s sync failed.\n",
+		syslog(LOG_ERR, "%s device %s sync failed.",
 		       dev_type, dev_name);
 	else if (status_code == 'R')
-		syslog(LOG_ERR, "%s device %s read failed.\n",
+		syslog(LOG_ERR, "%s device %s read failed.",
 		       dev_type, dev_name);
 	else if (status_code != 'A') {
-		syslog(LOG_ERR, "%s device %s has failed (%c).\n",
+		syslog(LOG_ERR, "%s device %s has failed (%c).",
 		       dev_type, dev_name, status_code);
 		r = ME_FAILURE;
 	}
@@ -143,7 +143,7 @@
 		return -ENAMETOOLONG;	/* FIXME These return code distinctions are not used so remove them! */
 
 	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
-		syslog(LOG_ERR, "Unable to determine VG name from %s",
+		syslog(LOG_ERR, "Unable to determine VG name from %s.",
 		       device);
 		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
@@ -156,7 +156,7 @@
 	/* FIXME Is any sanity-checking required on %s? */
 	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
-		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
+		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
@@ -184,12 +184,12 @@
 					  &target_type, &params);
 
 		if (!target_type) {
-			syslog(LOG_INFO, "%s mapping lost.\n", device);
+			syslog(LOG_INFO, "%s mapping lost.", device);
 			continue;
 		}
 
 		if (strcmp(target_type, "mirror")) {
-			syslog(LOG_INFO, "%s has unmirrored portion.\n", device);
+			syslog(LOG_INFO, "%s has unmirrored portion.", device);
 			continue;
 		}
 
@@ -199,13 +199,13 @@
 			   _part_ of the device is in sync
 			   Also, this is not an error
 			*/
-			syslog(LOG_NOTICE, "%s is now in-sync\n", device);
+			syslog(LOG_NOTICE, "%s is now in-sync.", device);
 			break;
 		case ME_FAILURE:
-			syslog(LOG_ERR, "Device failure in %s\n", device);
+			syslog(LOG_ERR, "Device failure in %s.", device);
 			if (_remove_failed_devices(device))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
-				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
+				syslog(LOG_ERR, "Failed to remove faulty devices in %s.",
 				       device);
 			/* Should check before warning user that device is now linear
 			else
@@ -217,7 +217,7 @@
 			break;
 		default:
 			/* FIXME Provide value then! */
-			syslog(LOG_INFO, "Unknown event received.\n");
+			syslog(LOG_INFO, "Unknown event received.");
 		}
 	} while (next);
 
@@ -231,7 +231,7 @@
 		    void **unused __attribute((unused)))
 {
 	int r = dmeventd_lvm2_init();
-	syslog(LOG_INFO, "Monitoring mirror device %s for events", device);
+	syslog(LOG_INFO, "Monitoring mirror device %s for events.", device);
 	return r;
 }
 
@@ -241,7 +241,7 @@
 		      int minor __attribute((unused)),
 		      void **unused __attribute((unused)))
 {
-	syslog(LOG_INFO, "No longer monitoring mirror device %s for events\n",
+	syslog(LOG_INFO, "No longer monitoring mirror device %s for events.",
 	       device);
 	dmeventd_lvm2_exit();
 	return 1;


