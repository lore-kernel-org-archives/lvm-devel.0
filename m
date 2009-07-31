From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 15:53:13 -0000
Subject: LVM2 ./WHATS_NEW libdm/.exported_symbols libdm ...
Message-ID: <20090731155313.21984.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 15:53:12

Modified files:
	.              : WHATS_NEW 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add libdevmapper functions to support synchronisation with udev.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1220&r2=1.1221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2009/07/31 13:31:53	1.1220
+++ LVM2/WHATS_NEW	2009/07/31 15:53:11	1.1221
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Add libdevmapper functions to support synchronisation with udev.
   Added configure --enable-udev_rules --enable-udev_sync.
   Added configure --with-udev-prefix --with-udevdir.
   Added udev dir to hold udev rules.
--- LVM2/libdm/.exported_symbols	2009/07/10 09:59:38	1.38
+++ LVM2/libdm/.exported_symbols	2009/07/31 15:53:12	1.39
@@ -24,6 +24,7 @@
 dm_task_get_read_ahead
 dm_task_set_ro
 dm_task_set_newname
+dm_task_set_cookie
 dm_task_set_event_nr
 dm_task_set_major
 dm_task_set_minor
@@ -154,3 +155,8 @@
 dm_list_prev
 dm_list_next
 dm_list_size
+dm_udev_set_sync_support
+dm_udev_get_sync_support
+dm_udev_notify
+dm_udev_wait
+dm_udev_cleanup
--- LVM2/libdm/libdevmapper.h	2009/07/10 09:59:38	1.91
+++ LVM2/libdm/libdevmapper.h	2009/07/31 15:53:12	1.92
@@ -164,6 +164,7 @@
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie);
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
@@ -1010,4 +1011,15 @@
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+int dm_cookie_supported(void);
+
+/*
+ * Udev notification functions.
+ */
+void dm_udev_set_sync_support(int sync_with_udev);
+int dm_udev_get_sync_support(void);
+int dm_udev_notify(uint32_t cookie);
+int dm_udev_wait(uint32_t cookie);
+int dm_udev_cleanup(uint32_t cookie);
+
 #endif				/* LIB_DEVICE_MAPPER_H */
--- LVM2/libdm/libdm-common.c	2009/07/10 09:59:38	1.66
+++ LVM2/libdm/libdm-common.c	2009/07/31 15:53:12	1.67
@@ -24,6 +24,12 @@
 #include <sys/ioctl.h>
 #include <fcntl.h>
 
+#ifdef UDEV_SYNC_SUPPORT
+#  include <sys/types.h>
+#  include <sys/ipc.h>
+#  include <sys/sem.h>
+#endif
+
 #ifdef linux
 #  include <linux/fs.h>
 #endif
@@ -33,11 +39,16 @@
 #endif
 
 #define DEV_DIR "/dev/"
+#define COOKIE_MAGIC 0x0D4D
 
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 
 static int _verbose = 0;
 
+#ifdef UDEV_SYNC_SUPPORT
+static int _sync_with_udev = 1;
+#endif
+
 /*
  * Library users can provide their own logging
  * function.
@@ -761,3 +772,281 @@
 	return r;
 }
 
+#ifndef UDEV_SYNC_SUPPORT
+void dm_udev_set_sync_support(int sync_with_udev)
+{
+}
+
+int dm_udev_get_sync_support(void)
+{
+	return 0;
+}
+
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+{
+	*cookie = 0;
+
+	return 1;
+}
+
+int dm_udev_notify(uint32_t cookie)
+{
+	return 1;
+}
+
+int dm_udev_wait(uint32_t cookie)
+{
+	return 1;
+}
+
+int dm_udev_cleanup(uint32_t cookie)
+{
+	return 1;
+}
+
+#else		/* UDEV_SYNC_SUPPORT */
+
+void dm_udev_set_sync_support(int sync_with_udev)
+{
+	_sync_with_udev = sync_with_udev;
+}
+
+int dm_udev_get_sync_support(void)
+{
+	return _sync_with_udev;
+}
+
+static int _get_cookie_sem(uint32_t cookie, int *semid)
+{
+	if ((*semid = semget((key_t) cookie, 1, 0)) >= 0)
+		return 1;
+
+	switch (errno) {
+		case ENOENT:
+			log_error("Could not find notification "
+				  "semaphore identified by cookie "
+				  "value %" PRIu32 " (0x%x)",
+				  cookie, cookie);
+			break;
+		case EACCES:
+			log_error("No permission to access "
+				  "notificaton semaphore identified "
+				  "by cookie value %" PRIu32 " (0x%x)",
+				  cookie, cookie);
+			break;
+		default:
+			/* FIXME errno use missing */
+			log_error("Failed to access notification "
+				   "semaphore identified by cookie "
+				   "value %" PRIu32 " (0x%x)",
+				  cookie, cookie);
+			break;
+	}
+
+	return 0;
+}
+
+static int _udev_notify_sem_inc(int semid)
+{
+	struct sembuf sb = {0, 1, 0};
+
+	/* FIXME errno use missing */
+	return semop(semid, &sb, 1) == 0;
+}
+
+static int _udev_notify_sem_dec(int semid)
+{
+	/* FIXME Think we should have IPC_NOWAIT here in case something went wrong and it's already 0 */
+	struct sembuf sb = {0, -1, 0};
+
+	/* FIXME errno use missing */
+	return semop(semid, &sb, 1) == 0;
+}
+
+static int _udev_notify_sem_destroy(int semid, uint32_t cookie)
+{
+	/* FIXME errno use missing */
+	if (semctl(semid, 0, IPC_RMID, 0) < 0) {
+		log_error("Could not cleanup notification semaphore "
+			  "identified by cookie value %" PRIu32 " (0x%x)",
+			  cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _udev_notify_sem_create(uint32_t *cookie, int *semid)
+{
+	int fd;
+	int gen_semid;
+	uint16_t base_cookie;
+	uint32_t gen_cookie;
+
+	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
+		log_error("Failed to open /dev/urandom "
+			  "to create random cookie value");
+		*cookie = 0;
+		return 0;
+	}
+
+	/* Generate random cookie value. Be sure it is unique and non-zero. */
+	do {
+		/* FIXME Handle non-error returns from read(). Move _io() into libdm? */
+		if (read(fd, &base_cookie, sizeof(base_cookie)) != sizeof(base_cookie)) {
+			log_error("Failed to initialize notification cookie");
+			goto bad;
+		}
+
+		gen_cookie = COOKIE_MAGIC << 16 | base_cookie;
+
+		if (base_cookie && (gen_semid = semget((key_t) gen_cookie,
+				    1, 0600 | IPC_CREAT | IPC_EXCL)) < 0) {
+			switch (errno) {
+				case EEXIST:
+					/* if the semaphore key exists, we
+					 * simply generate another random one */
+					base_cookie = 0;
+					break;
+				case ENOMEM:
+					log_error("Not enough memory to create "
+						  "notification semaphore");
+					goto bad;
+				case ENOSPC:
+					/* FIXME Suggest what to check & do */
+					log_error("Limit for the maximum number "
+						  "of semaphores reached");
+					goto bad;
+				default:
+					/* FIXME Use errno */
+					log_error("Failed to create "
+						  "notification semaphore");
+					goto bad;
+			}
+		}
+	} while (!base_cookie);
+
+	if (semctl(gen_semid, 0, SETVAL, 1) < 0) {
+		/* FIXME Use errno and give gen_semid */
+		log_error("Failed to initialize notification semaphore");
+		/* We have to destroy just created semaphore
+		 * so it won't stay in the system. */
+		_udev_notify_sem_destroy(gen_semid, gen_cookie);
+		goto bad;
+	}
+
+	if (close(fd))
+		stack;
+
+	*semid = gen_semid;
+	*cookie = gen_cookie;
+
+	return 1;
+
+bad:
+	if (close(fd))
+		stack;
+
+	*cookie = 0;
+
+	return 0;
+}
+
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+{
+	int semid;
+
+	if (!dm_udev_get_sync_support() || !dm_cookie_supported()) {
+		dmt->event_nr = *cookie = 0;
+		return 1;
+	}
+
+	if (*cookie) {
+		if (!_get_cookie_sem(*cookie, &semid))
+			goto_bad;
+	} else if (!_udev_notify_sem_create(cookie, &semid))
+		goto_bad;
+
+	if (!_udev_notify_sem_inc(semid)) {
+		log_error("Could not set notification semaphore "
+			  "identified by cookie value %" PRIu32 " (0x%x)",
+			  *cookie, *cookie);
+		goto bad;
+	}
+
+	dmt->event_nr = *cookie;
+	return 1;
+
+bad:
+	dmt->event_nr = 0;
+	return 0;
+}
+
+int dm_udev_notify(uint32_t cookie)
+{
+	int semid;
+
+	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return_0;
+
+	if (!_udev_notify_sem_dec(semid)) {
+		log_error("Could not signal waiting process using notification "
+			  "semaphore identified by cookie value %" PRIu32 " (0x%x)",
+			  cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+int dm_udev_wait(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, 0, 0};
+
+	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return_0;
+
+	if (!_udev_notify_sem_dec(semid)) {
+		log_error("Failed to set a proper state for notification "
+			  "semaphore identified by cookie value %" PRIu32 " (0x%x) "
+			  "to initialize waiting for incoming notifications.",
+			  cookie, cookie);
+		_udev_notify_sem_destroy(semid, cookie);
+		return 0;
+	}
+
+repeat_wait:
+	if (semop(semid, &sb, 1) < 0) {
+		if (errno == EINTR)
+			goto repeat_wait;
+		/* FIXME missing errno use */
+		log_error("Could not set wait state for notification semaphore "
+			  "identified by cookie value %" PRIu32 " (0x%x)",
+			  cookie, cookie);
+		_udev_notify_sem_destroy(semid, cookie);
+		return 0;
+	}
+
+	return _udev_notify_sem_destroy(semid, cookie);
+}
+
+int dm_udev_cleanup(uint32_t cookie)
+{
+	int semid;
+
+	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return 0;
+
+	return _udev_notify_sem_destroy(semid, cookie);
+}
+#endif		/* UDEV_SYNC_SUPPORT */
--- LVM2/libdm/ioctl/libdm-iface.c	2009/06/17 20:55:25	1.58
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/07/31 15:53:12	1.59
@@ -864,6 +864,13 @@
 	return 0;
 }
 
+int dm_cookie_supported(void)
+{
+	return (dm_check_version() &&
+	        _dm_version >= 4 &&
+	        _dm_version_minor >= 15);
+}
+
 void *dm_get_next_target(struct dm_task *dmt, void *next,
 			 uint64_t *start, uint64_t *length,
 			 char **target_type, char **params)


