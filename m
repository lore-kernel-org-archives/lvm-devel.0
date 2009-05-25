From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:18:54 +0200
Subject: [PATCH 3/9] Udev integration: add semaphore IPC to wait for udev rule completion
Message-ID: <4A1A8CAE.2000803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've added these functions :

dm_udev_notif_enable -- enable wait for udev's completion
dm_udev_notif_disable -- disable wait for udev's completion
dm_udev_notif_is_enabled -- is it enabled? :)

I added the conditional compilation, too, so when the wait for
udev completion is disabled at compilation time, we use only
dummy functions.

I use a global var as enable/disable flag to enable/disable the
wait in runtime. I think it's better this way than having IFs all
around the code. It's cleaner and less complicated...

Peter


diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 2c80b05..ff2e103 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -21,6 +21,7 @@ dm_task_get_uuid
 dm_task_get_read_ahead
 dm_task_set_ro
 dm_task_set_newname
+dm_task_set_cookie
 dm_task_set_event_nr
 dm_task_set_major
 dm_task_set_minor
@@ -149,3 +150,11 @@ dm_list_last
 dm_list_prev
 dm_list_next
 dm_list_size
+dm_udev_notif_enable
+dm_udev_notif_disable
+dm_udev_notif_is_enabled
+dm_udev_notif_sem_open
+dm_udev_notif_sem_inc
+dm_udev_notif_sem_dec
+dm_udev_notif_sem_wait_zero
+dm_udev_notif_sem_close
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3698eda..935a3ea 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -864,6 +864,13 @@ int dm_check_version(void)
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
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 09b1036..7674e04 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -155,6 +155,7 @@ int dm_task_set_major(struct dm_task *dmt, int major);
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t cookie);
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
@@ -984,4 +985,22 @@ int dm_report_field_uint64(struct dm_report *rh, struct dm_report_field *field,
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+int dm_cookie_supported(void);
+
+/*
+ * Functions to set simple notification channel between instances of libdm
+ * code by means of using semaphore identified by a cookie. Primarily used
+ * to provide a way of notification that related udev rule is completed as
+ * a consequence of libdm actions fired before and marked by the value of
+ * the cookie.
+ */
+void dm_udev_notif_enable(void);
+void dm_udev_notif_disable(void);
+int dm_udev_notif_is_enabled(void);
+int dm_udev_notif_sem_open(uint32_t *cookie);
+int dm_udev_notif_sem_inc(uint32_t cookie);
+int dm_udev_notif_sem_dec(uint32_t cookie);
+int dm_udev_notif_sem_wait_zero(uint32_t cookie);
+int dm_udev_notif_sem_close(uint32_t cookie);
+
 #endif				/* LIB_DEVICE_MAPPER_H */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bbb46f5..ef249dc 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -24,6 +24,12 @@
 #include <sys/ioctl.h>
 #include <fcntl.h>
 
+#ifdef WAITFORUDEV_SUPPORT
+#  include <sys/types.h>
+#  include <sys/ipc.h>
+#  include <sys/sem.h>
+#endif
+
 #ifdef linux
 #  include <linux/fs.h>
 #endif
@@ -38,6 +44,10 @@ static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 
 static int _verbose = 0;
 
+#ifdef WAITFORUDEV_SUPPORT
+static int _wait_for_udev = 1;
+#endif
+
 /*
  * Library users can provide their own logging
  * function.
@@ -222,6 +232,14 @@ int dm_task_set_mode(struct dm_task *dmt, mode_t mode)
 	return 1;
 }
 
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t cookie)
+{
+	/* We reuse event_nr field to pass the cookie in.*/
+	dmt->event_nr = cookie;
+
+	return 1;
+}
+
 int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 		       const char *ttype, const char *params)
 {
@@ -711,3 +729,200 @@ out:
 	return r;
 }
 
+#ifndef WAITFORUDEV_SUPPORT
+
+void dm_udev_notif_enable(void)
+{
+}
+
+void dm_udev_notif_disable(void)
+{
+}
+
+int dm_udev_notif_is_enabled(void)
+{
+	return 0;
+}
+
+int dm_udev_notif_sem_open(uint32_t *cookie)
+{
+	*cookie = 0;
+
+	return 1;
+}
+
+int dm_udev_notif_sem_inc(uint32_t cookie)
+{
+	return 1;
+}
+
+int dm_udev_notif_sem_dec(uint32_t cookie)
+{
+	return 1;
+}
+
+int dm_udev_notif_sem_wait_zero(uint32_t cookie)
+{
+	return 1;
+}
+
+int dm_udev_notif_sem_close(uint32_t cookie)
+{
+	return 1;
+}
+
+#else		/* WAITFORUDEV_SUPPORT */
+
+void dm_udev_notif_enable(void)
+{
+	_wait_for_udev = 1;
+}
+
+void dm_udev_notif_disable(void)
+{
+	_wait_for_udev = 0;
+}
+
+int dm_udev_notif_is_enabled(void)
+{
+	return _wait_for_udev;
+}
+
+int dm_udev_notif_sem_open(uint32_t *cookie)
+{
+	int semid;
+	int fd;
+	uint32_t gen_cookie;
+
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+		return 1;
+
+	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
+		log_error("Failed to open /dev/urandom to create random cookie value.");
+		return 0;
+	}
+
+	/* Generate random cookie value. Be sure it is unique and != 0. */
+	do {
+		if (read(fd, &gen_cookie, sizeof(gen_cookie)) != sizeof(gen_cookie))
+			goto out;
+
+		if ((semid = semget((key_t) gen_cookie, 1, 0600 | IPC_CREAT | IPC_EXCL)) < 0) {
+			/* if the semaphore key exists, we simply generate another random one */
+			if (errno == EEXIST)
+				gen_cookie = 0;
+			else
+				goto out;
+		}
+	} while (!gen_cookie);
+
+	if (semctl(semid, 0, SETVAL, 0) < 0)
+		goto out;
+
+	if (close(fd))
+		stack;
+	*cookie = gen_cookie;
+
+	return 1;
+
+out:
+	log_error("Failed to create and initialize notification cookie");
+	if (close(fd))
+		stack;
+	return 0;
+}
+
+static int _get_cookie_sem(uint32_t cookie, int *semid)
+{
+	if ((*semid = semget((key_t) cookie, 1, 0)) < 0) {
+		log_error("Could not find notification cookie %" PRIu32 " (0x%x)",
+			cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+int dm_udev_notif_sem_inc(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, 1, 0};
+
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return 0;
+
+	if (semop(semid, &sb, 1) < 0) {
+		log_error("Could not set notification cookie %" PRIu32 " (0x%x)",
+			cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+int dm_udev_notif_sem_dec(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, -1, 0};
+
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return 0;
+
+	if (semop(semid, &sb, 1) < 0) {
+		log_error("Could not signal waiting process using notification cookie %" PRIu32 " (0x%x)",
+			cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+int dm_udev_notif_sem_wait_zero(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, 0, 0};
+
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return 0;
+
+repeat_wait:
+	if (semop(semid, &sb, 1) < 0) {
+		if (errno == EINTR)
+			goto repeat_wait;
+		log_error("Could not set wait state for notification cookie %" PRIu32 " (0x%x)",
+			cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+int dm_udev_notif_sem_close(uint32_t cookie)
+{
+	int semid;
+
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+		return 1;
+
+	if (!_get_cookie_sem(cookie, &semid))
+		return 0;
+
+	if (semctl(semid, 0, IPC_RMID, cookie) < 0) {
+		log_error("Could not remove notification cookie '%" PRIu32 " (0x%x)",
+			cookie, cookie);
+		return 0;
+	}
+
+	return 1;
+}
+
+#endif		/* WAITFORUDEV_SUPPORT */


