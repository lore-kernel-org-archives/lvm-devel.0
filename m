From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 11:01:27 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090803110127.31230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 11:01:26

Modified files:
	libdm          : libdm-common.c 

Log message:
	deal with error-related FIXMEs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/libdm/libdm-common.c	2009/07/31 17:51:46	1.69
+++ LVM2/libdm/libdm-common.c	2009/08/03 11:01:26	1.70
@@ -818,7 +818,13 @@
 
 static int _get_cookie_sem(uint32_t cookie, int *semid)
 {
-	/* FIXME Ensure cookie has COOKIE_MAGIC prefix */
+	if (!(cookie >> 16 & COOKIE_MAGIC)) {
+		log_error("Could not continue to access notification "
+			  "semaphore identified by cookie value %"
+			  PRIu32 " (0x%x). Incorrect cookie prefix.");
+		return 0;
+	}
+
 	if ((*semid = semget((key_t) cookie, 1, 0)) >= 0)
 		return 1;
 
@@ -836,11 +842,10 @@
 				  cookie, cookie);
 			break;
 		default:
-			/* FIXME errno use missing */
 			log_error("Failed to access notification "
 				   "semaphore identified by cookie "
-				   "value %" PRIu32 " (0x%x)",
-				  cookie, cookie);
+				   "value %" PRIu32 " (0x%x): %s",
+				  cookie, cookie, strerror(errno));
 			break;
 	}
 
@@ -851,26 +856,42 @@
 {
 	struct sembuf sb = {0, 1, 0};
 
-	/* FIXME errno use missing */
-	return semop(semid, &sb, 1) == 0;
+	if (semop(semid, &sb, 1) < 0) {
+		log_error("semid %d: semop failed: %s", semid, strerror(errno));
+		return 0;
+	}
+
+	return 1;
 }
 
 static int _udev_notify_sem_dec(int semid)
 {
-	/* FIXME Think we should have IPC_NOWAIT here in case something went wrong and it's already 0 */
-	struct sembuf sb = {0, -1, 0};
+	struct sembuf sb = {0, -1, IPC_NOWAIT};
+
+	if (semop(semid, &sb, 1) < 0) {
+		switch (errno) {
+			case EAGAIN:
+				log_error("semid %d: semop failed: "
+					  "incorrect semaphore state",
+					  semid);
+				break;
+			default:
+				log_error("semid %d: semop failed: %s",
+					  semid, strerror(errno));
+				break;
+		}
+		return 0;
+	}
 
-	/* FIXME errno use missing */
-	return semop(semid, &sb, 1) == 0;
+	return 1;
 }
 
 static int _udev_notify_sem_destroy(int semid, uint32_t cookie)
 {
-	/* FIXME errno use missing */
 	if (semctl(semid, 0, IPC_RMID, 0) < 0) {
 		log_error("Could not cleanup notification semaphore "
-			  "identified by cookie value %" PRIu32 " (0x%x)",
-			  cookie, cookie);
+			  "identified by cookie value %" PRIu32 " (0x%x): %s",
+			  cookie, cookie, strerror(errno));
 		return 0;
 	}
 
@@ -914,22 +935,21 @@
 						  "notification semaphore");
 					goto bad;
 				case ENOSPC:
-					/* FIXME Suggest what to check & do */
 					log_error("Limit for the maximum number "
-						  "of semaphores reached");
+						  "of semaphores reached. You can "
+						  "check and set the limits in "
+						  "/proc/sys/kernel/sem.");
 					goto bad;
 				default:
-					/* FIXME Use errno */
-					log_error("Failed to create "
-						  "notification semaphore");
+					log_error("Failed to create notification "
+						  "semaphore: %s", strerror(errno));
 					goto bad;
 			}
 		}
 	} while (!base_cookie);
 
 	if (semctl(gen_semid, 0, SETVAL, 1) < 0) {
-		/* FIXME Use errno and give gen_semid */
-		log_error("Failed to initialize notification semaphore");
+		log_error("semid %d: semctl failed: %s", gen_semid, strerror(errno));
 		/* We have to destroy just created semaphore
 		 * so it won't stay in the system. */
 		_udev_notify_sem_destroy(gen_semid, gen_cookie);
@@ -1027,10 +1047,9 @@
 	if (semop(semid, &sb, 1) < 0) {
 		if (errno == EINTR)
 			goto repeat_wait;
-		/* FIXME missing errno use */
 		log_error("Could not set wait state for notification semaphore "
-			  "identified by cookie value %" PRIu32 " (0x%x)",
-			  cookie, cookie);
+			  "identified by cookie value %" PRIu32 " (0x%x): %s",
+			  cookie, cookie, strerror(errno));
 		_udev_notify_sem_destroy(semid, cookie);
 		return 0;
 	}


