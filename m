From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 15:34:48 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20110708153448.8406.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 15:34:47

Modified files:
	libdm          : libdm-common.c 

Log message:
	Log cookie values when incrementing/decrementing to give clues about races.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/libdm/libdm-common.c	2011/07/05 16:17:14	1.123
+++ LVM2/libdm/libdm-common.c	2011/07/08 15:34:47	1.124
@@ -1240,6 +1240,7 @@
 static int _udev_notify_sem_inc(uint32_t cookie, int semid)
 {
 	struct sembuf sb = {0, 1, 0};
+	int val;
 
 	if (semop(semid, &sb, 1) < 0) {
 		log_error("semid %d: semop failed for cookie 0x%" PRIx32 ": %s",
@@ -1247,8 +1248,15 @@
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented",
-		  cookie, semid);
+ 	if ((val = semctl(semid, 0, GETVAL)) < 0) {
+		log_error("semid %d: sem_ctl GETVAL failed for "
+			  "cookie 0x%" PRIx32 ": %s",
+			  semid, cookie, strerror(errno));
+		return 0;		
+	}
+
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
+		  cookie, semid, val);
 
 	return 1;
 }
@@ -1256,6 +1264,14 @@
 static int _udev_notify_sem_dec(uint32_t cookie, int semid)
 {
 	struct sembuf sb = {0, -1, IPC_NOWAIT};
+	int val;
+
+ 	if ((val = semctl(semid, 0, GETVAL)) < 0) {
+		log_error("semid %d: sem_ctl GETVAL failed for "
+			  "cookie 0x%" PRIx32 ": %s",
+			  semid, cookie, strerror(errno));
+		return 0;
+	}
 
 	if (semop(semid, &sb, 1) < 0) {
 		switch (errno) {
@@ -1274,8 +1290,8 @@
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) decremented",
-		  cookie, semid);
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) decremented to %d",
+		  cookie, semid, val - 1);
 
 	return 1;
 }
@@ -1299,6 +1315,7 @@
 {
 	int fd;
 	int gen_semid;
+	int val;
 	uint16_t base_cookie;
 	uint32_t gen_cookie;
 	union semun sem_arg;
@@ -1359,8 +1376,15 @@
 		goto bad;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented",
-		  gen_cookie, gen_semid);
+ 	if ((val = semctl(gen_semid, 0, GETVAL)) < 0) {
+		log_error("semid %d: sem_ctl GETVAL failed for "
+			  "cookie 0x%" PRIx32 ": %s",
+			  gen_semid, gen_cookie, strerror(errno));
+		return 0;		
+	}
+
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
+		  gen_cookie, gen_semid, val);
 
 	if (close(fd))
 		stack;


