From: Bastian Blank <waldi@debian.org>
Date: Sat, 8 Jun 2013 11:56:01 +0200
Subject: [PATCH 1/3] udev: Rip out semaphore synchronisation support
In-Reply-To: <20130608094939.GA3065@mail.waldi.eu.org>
References: <20130608094939.GA3065@mail.waldi.eu.org>
Message-ID: <20130608095600.GA3132@mail.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 libdm/libdm-common.c |  284 +++-----------------------------------------------
 1 file changed, 13 insertions(+), 271 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d18de9c..bcddc3b 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -26,9 +26,6 @@
 #include <dirent.h>
 
 #ifdef UDEV_SYNC_SUPPORT
-#  include <sys/types.h>
-#  include <sys/ipc.h>
-#  include <sys/sem.h>
 #  include <libudev.h>
 #endif
 
@@ -47,18 +44,6 @@
 
 #define DEV_DIR "/dev/"
 
-#ifdef UDEV_SYNC_SUPPORT
-#ifdef _SEM_SEMUN_UNDEFINED
-union semun
-{
-	int val;			/* value for SETVAL */
-	struct semid_ds *buf;		/* buffer for IPC_STAT & IPC_SET */
-	unsigned short int *array;	/* array for GETALL & SETALL */
-	struct seminfo *__buf;		/* buffer for IPC_INFO */
-};
-#endif
-#endif
-
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 static char _sysfs_dir[PATH_MAX] = "/sys/";
 static char _path0[PATH_MAX];           /* path buffer, safe 4kB on stack */
@@ -78,7 +63,6 @@ static struct selabel_handle *_selabel_handle = NULL;
 static int _udev_disabled = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
-static int _semaphore_supported = -1;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
@@ -1993,24 +1977,6 @@ int dm_udev_wait(uint32_t cookie)
 
 #else		/* UDEV_SYNC_SUPPORT */
 
-static int _check_semaphore_is_supported(void)
-{
-	int maxid;
-	union semun arg;
-	struct seminfo seminfo;
-
-	arg.__buf = &seminfo;
-	maxid = semctl(0, 0, SEM_INFO, arg);
-
-	if (maxid < 0) {
-		log_warn("Kernel not configured for semaphores (System V IPC). "
-			 "Not using udev synchronisation code.");
-		return 0;
-	}
-
-	return 1;
-}
-
 static int _check_udev_is_running(void)
 {
 	struct udev *udev;
@@ -2041,9 +2007,6 @@ bad:
 
 static void _check_udev_sync_requirements_once(void)
 {
-	if (_semaphore_supported < 0)
-		_semaphore_supported = _check_semaphore_is_supported();
-
 	if (_udev_running < 0) {
 		_udev_running = _check_udev_is_running();
 		if (_udev_disabled && _udev_running)
@@ -2063,7 +2026,7 @@ int dm_udev_get_sync_support(void)
 {
 	_check_udev_sync_requirements_once();
 
-	return !_udev_disabled && _semaphore_supported &&
+	return !_udev_disabled &&
 		dm_cookie_supported() &&_udev_running && _sync_with_udev;
 }
 
@@ -2080,125 +2043,11 @@ int dm_udev_get_checking(void)
 	return _udev_checking;
 }
 
-static int _get_cookie_sem(uint32_t cookie, int *semid)
-{
-	if (cookie >> 16 != DM_COOKIE_MAGIC) {
-		log_error("Could not continue to access notification "
-			  "semaphore identified by cookie value %"
-			  PRIu32 " (0x%x). Incorrect cookie prefix.",
-			  cookie, cookie);
-		return 0;
-	}
-
-	if ((*semid = semget((key_t) cookie, 1, 0)) >= 0)
-		return 1;
-
-	switch (errno) {
-		case ENOENT:
-			log_error("Could not find notification "
-				  "semaphore identified by cookie "
-				  "value %" PRIu32 " (0x%x)",
-				  cookie, cookie);
-			break;
-		case EACCES:
-			log_error("No permission to access "
-				  "notificaton semaphore identified "
-				  "by cookie value %" PRIu32 " (0x%x)",
-				  cookie, cookie);
-			break;
-		default:
-			log_error("Failed to access notification "
-				   "semaphore identified by cookie "
-				   "value %" PRIu32 " (0x%x): %s",
-				  cookie, cookie, strerror(errno));
-			break;
-	}
-
-	return 0;
-}
-
-static int _udev_notify_sem_inc(uint32_t cookie, int semid)
-{
-	struct sembuf sb = {0, 1, 0};
-	int val;
-
-	if (semop(semid, &sb, 1) < 0) {
-		log_error("semid %d: semop failed for cookie 0x%" PRIx32 ": %s",
-			  semid, cookie, strerror(errno));
-		return 0;
-	}
-
- 	if ((val = semctl(semid, 0, GETVAL)) < 0) {
-		log_error("semid %d: sem_ctl GETVAL failed for "
-			  "cookie 0x%" PRIx32 ": %s",
-			  semid, cookie, strerror(errno));
-		return 0;		
-	}
-
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
-		  cookie, semid, val);
-
-	return 1;
-}
-
-static int _udev_notify_sem_dec(uint32_t cookie, int semid)
-{
-	struct sembuf sb = {0, -1, IPC_NOWAIT};
-	int val;
-
- 	if ((val = semctl(semid, 0, GETVAL)) < 0) {
-		log_error("semid %d: sem_ctl GETVAL failed for "
-			  "cookie 0x%" PRIx32 ": %s",
-			  semid, cookie, strerror(errno));
-		return 0;
-	}
-
-	if (semop(semid, &sb, 1) < 0) {
-		switch (errno) {
-			case EAGAIN:
-				log_error("semid %d: semop failed for cookie "
-					  "0x%" PRIx32 ": "
-					  "incorrect semaphore state",
-					  semid, cookie);
-				break;
-			default:
-				log_error("semid %d: semop failed for cookie "
-					  "0x%" PRIx32 ": %s",
-					  semid, cookie, strerror(errno));
-				break;
-		}
-		return 0;
-	}
-
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) decremented to %d",
-			     cookie, semid, val - 1);
-
-	return 1;
-}
-
-static int _udev_notify_sem_destroy(uint32_t cookie, int semid)
-{
-	if (semctl(semid, 0, IPC_RMID, 0) < 0) {
-		log_error("Could not cleanup notification semaphore "
-			  "identified by cookie value %" PRIu32 " (0x%x): %s",
-			  cookie, cookie, strerror(errno));
-		return 0;
-	}
-
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) destroyed", cookie,
-			     semid);
-
-	return 1;
-}
-
-static int _udev_notify_sem_create(uint32_t *cookie, int *semid)
+static int _udev_create_cookie(uint32_t *cookie)
 {
 	int fd;
-	int gen_semid;
-	int val;
 	uint16_t base_cookie;
 	uint32_t gen_cookie;
-	union semun sem_arg;
 
 	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
 		log_error("Failed to open /dev/urandom "
@@ -2208,68 +2057,19 @@ static int _udev_notify_sem_create(uint32_t *cookie, int *semid)
 	}
 
 	/* Generate random cookie value. Be sure it is unique and non-zero. */
-	do {
-		/* FIXME Handle non-error returns from read(). Move _io() into libdm? */
-		if (read(fd, &base_cookie, sizeof(base_cookie)) != sizeof(base_cookie)) {
-			log_error("Failed to initialize notification cookie");
-			goto bad;
-		}
-
-		gen_cookie = DM_COOKIE_MAGIC << 16 | base_cookie;
-
-		if (base_cookie && (gen_semid = semget((key_t) gen_cookie,
-				    1, 0600 | IPC_CREAT | IPC_EXCL)) < 0) {
-			switch (errno) {
-				case EEXIST:
-					/* if the semaphore key exists, we
-					 * simply generate another random one */
-					base_cookie = 0;
-					break;
-				case ENOMEM:
-					log_error("Not enough memory to create "
-						  "notification semaphore");
-					goto bad;
-				case ENOSPC:
-					log_error("Limit for the maximum number "
-						  "of semaphores reached. You can "
-						  "check and set the limits in "
-						  "/proc/sys/kernel/sem.");
-					goto bad;
-				default:
-					log_error("Failed to create notification "
-						  "semaphore: %s", strerror(errno));
-					goto bad;
-			}
-		}
-	} while (!base_cookie);
-
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) created",
-			     gen_cookie, gen_semid);
-
-	sem_arg.val = 1;
-
-	if (semctl(gen_semid, 0, SETVAL, sem_arg) < 0) {
-		log_error("semid %d: semctl failed: %s", gen_semid, strerror(errno));
-		/* We have to destroy just created semaphore
-		 * so it won't stay in the system. */
-		(void) _udev_notify_sem_destroy(gen_cookie, gen_semid);
+	/* FIXME Handle non-error returns from read(). Move _io() into libdm? */
+	if (read(fd, &base_cookie, sizeof(base_cookie)) != sizeof(base_cookie)) {
+		log_error("Failed to initialize notification cookie");
 		goto bad;
 	}
 
- 	if ((val = semctl(gen_semid, 0, GETVAL)) < 0) {
-		log_error("semid %d: sem_ctl GETVAL failed for "
-			  "cookie 0x%" PRIx32 ": %s",
-			  gen_semid, gen_cookie, strerror(errno));
-		goto bad;
-	}
+	gen_cookie = DM_COOKIE_MAGIC << 16 | base_cookie;
 
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
-			     gen_cookie, gen_semid, val);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " created", gen_cookie);
 
 	if (close(fd))
 		stack;
 
-	*semid = gen_semid;
 	*cookie = gen_cookie;
 
 	return 1;
@@ -2285,14 +2085,12 @@ bad:
 
 int dm_udev_create_cookie(uint32_t *cookie)
 {
-	int semid;
-
 	if (!dm_udev_get_sync_support()) {
 		*cookie = 0;
 		return 1;
 	}
 
-	return _udev_notify_sem_create(cookie, &semid);
+	return _udev_create_cookie(cookie);
 }
 
 static const char *_task_type_disp(int type)
@@ -2342,8 +2140,6 @@ static const char *_task_type_disp(int type)
 
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
-	int semid;
-
 	_set_cookie_flags(dmt, flags);
 
 	if (!dm_udev_get_sync_support()) {
@@ -2352,24 +2148,14 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 		return 1;
 	}
 
-	if (*cookie) {
-		if (!_get_cookie_sem(*cookie, &semid))
-			goto_bad;
-	} else if (!_udev_notify_sem_create(cookie, &semid))
+	if (!*cookie && !_udev_create_cookie(cookie))
 		goto_bad;
 
-	if (!_udev_notify_sem_inc(*cookie, semid)) {
-		log_error("Could not set notification semaphore "
-			  "identified by cookie value %" PRIu32 " (0x%x)",
-			  *cookie, *cookie);
-		goto bad;
-	}
-
 	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
 
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) assigned to "
-			     "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, semid, _task_type_disp(dmt->type), dmt->type, 
+	log_debug_activation("Udev cookie 0x%" PRIx32 " assigned to "
+			     "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, _task_type_disp(dmt->type), dmt->type, 
 			     (flags & DM_UDEV_DISABLE_DM_RULES_FLAG) ? " DISABLE_DM_RULES" : "",
 			     (flags & DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) ? " DISABLE_SUBSYSTEM_RULES" : "",
 			     (flags & DM_UDEV_DISABLE_DISK_RULES_FLAG) ? " DISABLE_DISK_RULES" : "",
@@ -2388,62 +2174,18 @@ bad:
 
 int dm_udev_complete(uint32_t cookie)
 {
-	int semid;
-
 	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
 
-	if (!_get_cookie_sem(cookie, &semid))
-		return_0;
-
-	if (!_udev_notify_sem_dec(cookie, semid)) {
-		log_error("Could not signal waiting process using notification "
-			  "semaphore identified by cookie value %" PRIu32 " (0x%x)",
-			  cookie, cookie);
-		return 0;
-	}
-
-	return 1;
+	return_0;
 }
 
 static int _udev_wait(uint32_t cookie)
 {
-	int semid;
-	struct sembuf sb = {0, 0, 0};
-
 	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
 
-	if (!_get_cookie_sem(cookie, &semid))
-		return_0;
-
-	if (!_udev_notify_sem_dec(cookie, semid)) {
-		log_error("Failed to set a proper state for notification "
-			  "semaphore identified by cookie value %" PRIu32 " (0x%x) "
-			  "to initialize waiting for incoming notifications.",
-			  cookie, cookie);
-		(void) _udev_notify_sem_destroy(cookie, semid);
-		return 0;
-	}
-
-	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) waiting for zero",
-			     cookie, semid);
-
-repeat_wait:
-	if (semop(semid, &sb, 1) < 0) {
-		if (errno == EINTR)
-			goto repeat_wait;
-		else if (errno == EIDRM)
-			return 1;
-
-		log_error("Could not set wait state for notification semaphore "
-			  "identified by cookie value %" PRIu32 " (0x%x): %s",
-			  cookie, cookie, strerror(errno));
-		(void) _udev_notify_sem_destroy(cookie, semid);
-		return 0;
-	}
-
-	return _udev_notify_sem_destroy(cookie, semid);
+	return_0;
 }
 
 int dm_udev_wait(uint32_t cookie)
-- 
You're dead, Jim.
		-- McCoy, "The Tholian Web", stardate unknown


