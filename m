From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Aug 2009 19:50:09 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090805195009.6429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-05 19:50:08

Modified files:
	libdm          : libdm-common.c 

Log message:
	Additional logging

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/libdm/libdm-common.c	2009/08/03 18:33:08	1.73
+++ LVM2/libdm/libdm-common.c	2009/08/05 19:50:08	1.74
@@ -854,41 +854,50 @@
 	return 0;
 }
 
-static int _udev_notify_sem_inc(int semid)
+static int _udev_notify_sem_inc(uint32_t cookie, int semid)
 {
 	struct sembuf sb = {0, 1, 0};
 
 	if (semop(semid, &sb, 1) < 0) {
-		log_error("semid %d: semop failed: %s", semid, strerror(errno));
+		log_error("semid %d: semop failed for cookie 0x%" PRIx32 ": %s",
+			  semid, cookie, strerror(errno));
 		return 0;
 	}
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented",
+		  cookie, semid);
+
 	return 1;
 }
 
-static int _udev_notify_sem_dec(int semid)
+static int _udev_notify_sem_dec(uint32_t cookie, int semid)
 {
 	struct sembuf sb = {0, -1, IPC_NOWAIT};
 
 	if (semop(semid, &sb, 1) < 0) {
 		switch (errno) {
 			case EAGAIN:
-				log_error("semid %d: semop failed: "
+				log_error("semid %d: semop failed for cookie "
+					  "0x%" PRIx32 ": "
 					  "incorrect semaphore state",
-					  semid);
+					  semid, cookie);
 				break;
 			default:
-				log_error("semid %d: semop failed: %s",
-					  semid, strerror(errno));
+				log_error("semid %d: semop failed for cookie "
+					  "0x%" PRIx32 ": %s",
+					  semid, cookie, strerror(errno));
 				break;
 		}
 		return 0;
 	}
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) decremented",
+		  cookie, semid);
+
 	return 1;
 }
 
-static int _udev_notify_sem_destroy(int semid, uint32_t cookie)
+static int _udev_notify_sem_destroy(uint32_t cookie, int semid)
 {
 	if (semctl(semid, 0, IPC_RMID, 0) < 0) {
 		log_error("Could not cleanup notification semaphore "
@@ -897,6 +906,9 @@
 		return 0;
 	}
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) destroyed", cookie,
+		  semid);
+
 	return 1;
 }
 
@@ -950,14 +962,20 @@
 		}
 	} while (!base_cookie);
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) created",
+		  gen_cookie, gen_semid);
+
 	if (semctl(gen_semid, 0, SETVAL, 1) < 0) {
 		log_error("semid %d: semctl failed: %s", gen_semid, strerror(errno));
 		/* We have to destroy just created semaphore
 		 * so it won't stay in the system. */
-		(void) _udev_notify_sem_destroy(gen_semid, gen_cookie);
+		(void) _udev_notify_sem_destroy(gen_cookie, gen_semid);
 		goto bad;
 	}
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented",
+		  gen_cookie, gen_semid);
+
 	if (close(fd))
 		stack;
 
@@ -990,7 +1008,7 @@
 	} else if (!_udev_notify_sem_create(cookie, &semid))
 		goto_bad;
 
-	if (!_udev_notify_sem_inc(semid)) {
+	if (!_udev_notify_sem_inc(*cookie, semid)) {
 		log_error("Could not set notification semaphore "
 			  "identified by cookie value %" PRIu32 " (0x%x)",
 			  *cookie, *cookie);
@@ -999,6 +1017,10 @@
 
 	dmt->event_nr = *cookie;
 	dmt->cookie_set = 1;
+
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task",
+		  dmt->event_nr, semid);
+
 	return 1;
 
 bad:
@@ -1016,7 +1038,7 @@
 	if (!_get_cookie_sem(cookie, &semid))
 		return_0;
 
-	if (!_udev_notify_sem_dec(semid)) {
+	if (!_udev_notify_sem_dec(cookie, semid)) {
 		log_error("Could not signal waiting process using notification "
 			  "semaphore identified by cookie value %" PRIu32 " (0x%x)",
 			  cookie, cookie);
@@ -1037,15 +1059,18 @@
 	if (!_get_cookie_sem(cookie, &semid))
 		return_0;
 
-	if (!_udev_notify_sem_dec(semid)) {
+	if (!_udev_notify_sem_dec(cookie, semid)) {
 		log_error("Failed to set a proper state for notification "
 			  "semaphore identified by cookie value %" PRIu32 " (0x%x) "
 			  "to initialize waiting for incoming notifications.",
 			  cookie, cookie);
-		(void) _udev_notify_sem_destroy(semid, cookie);
+		(void) _udev_notify_sem_destroy(cookie, semid);
 		return 0;
 	}
 
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d): Waiting for zero",
+		  cookie, semid);
+
 repeat_wait:
 	if (semop(semid, &sb, 1) < 0) {
 		if (errno == EINTR)
@@ -1053,11 +1078,11 @@
 		log_error("Could not set wait state for notification semaphore "
 			  "identified by cookie value %" PRIu32 " (0x%x): %s",
 			  cookie, cookie, strerror(errno));
-		(void) _udev_notify_sem_destroy(semid, cookie);
+		(void) _udev_notify_sem_destroy(cookie, semid);
 		return 0;
 	}
 
-	return _udev_notify_sem_destroy(semid, cookie);
+	return _udev_notify_sem_destroy(cookie, semid);
 }
 
 #endif		/* UDEV_SYNC_SUPPORT */


