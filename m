From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 May 2010 15:02:58 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20100527150258.3489.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-05-27 15:02:57

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Use expected union semun for arguments in selected semaphore operations.
	
	This is standard and expected use. It also prevents errors related with
	misalignment of the arguments for semaphore operations on some architectures.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.373&r2=1.374
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW_DM	2010/05/20 23:21:53	1.373
+++ LVM2/WHATS_NEW_DM	2010/05/27 15:02:56	1.374
@@ -1,5 +1,6 @@
 Version 1.02.49 - 
 ================================
+  Use expected union semun for arguments in selected semaphore operations.
 
 Version 1.02.48 - 17th May 2010
 ================================
--- LVM2/libdm/libdm-common.c	2010/05/03 21:06:53	1.95
+++ LVM2/libdm/libdm-common.c	2010/05/27 15:02:56	1.96
@@ -43,6 +43,18 @@
 
 #define DEV_DIR "/dev/"
 
+#ifdef UDEV_SYNC_SUPPORT
+#ifdef _SEM_SEMUN_UNDEFINED
+union semun
+{
+	int val;			/* value for SETVAL */
+	struct semid_ds *buf;		/* buffer for IPC_STAT & IPC_SET */
+	unsigned short int *array;	/* array for GETALL & SETALL */
+	struct seminfo *__buf;		/* buffer for IPC_INFO */
+};
+#endif
+#endif
+
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 
 static int _verbose = 0;
@@ -1076,6 +1088,7 @@
 	int gen_semid;
 	uint16_t base_cookie;
 	uint32_t gen_cookie;
+	union semun sem_arg;
 
 	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
 		log_error("Failed to open /dev/urandom "
@@ -1123,7 +1136,9 @@
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) created",
 		  gen_cookie, gen_semid);
 
-	if (semctl(gen_semid, 0, SETVAL, 1) < 0) {
+	sem_arg.val = 1;
+
+	if (semctl(gen_semid, 0, SETVAL, sem_arg) < 0) {
 		log_error("semid %d: semctl failed: %s", gen_semid, strerror(errno));
 		/* We have to destroy just created semaphore
 		 * so it won't stay in the system. */


