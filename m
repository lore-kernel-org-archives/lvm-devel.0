From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 15:07:07 +0200
Subject: [PATCH 2/5] Udev integration: add semaphore IPC to wait for udev rule completion (updated)
Message-ID: <49F067FB.8020106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...resending updated and cleaned up patches for udev integration.

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..80ec533 100644
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
@@ -148,3 +149,8 @@ dm_list_last
 dm_list_prev
 dm_list_next
 dm_list_size
+dm_notification_sem_open
+dm_notification_sem_inc
+dm_notification_sem_dec
+dm_notification_sem_wait_zero
+dm_notification_sem_close
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3698eda..7bfc633 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -864,6 +864,13 @@ int dm_check_version(void)
 	return 0;
 }
 
+int dm_cookie_supported()
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
index ded0eaf..d07c82f 100644
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
@@ -983,4 +984,19 @@ int dm_report_field_uint64(struct dm_report *rh, struct dm_report_field *field,
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
+int dm_notification_sem_open(uint32_t *cookie);
+int dm_notification_sem_inc(uint32_t cookie);
+int dm_notification_sem_dec(uint32_t cookie);
+int dm_notification_sem_wait_zero(uint32_t cookie);
+int dm_notification_sem_close(uint32_t cookie);
+
 #endif				/* LIB_DEVICE_MAPPER_H */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bbb46f5..7f91ded 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -22,6 +22,9 @@
 #include <stdarg.h>
 #include <sys/param.h>
 #include <sys/ioctl.h>
+#include <sys/types.h>
+#include <sys/ipc.h>
+#include <sys/sem.h>
 #include <fcntl.h>
 
 #ifdef linux
@@ -222,6 +225,14 @@ int dm_task_set_mode(struct dm_task *dmt, mode_t mode)
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
@@ -711,3 +722,139 @@ out:
 	return r;
 }
 
+int dm_notification_sem_open(uint32_t *cookie)
+{
+	int semid;
+	int fd;
+	uint32_t gen_cookie;
+
+	if (!dm_cookie_supported())
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
+int dm_notification_sem_inc(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, 1, 0};
+
+	if (!dm_cookie_supported())
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
+int dm_notification_sem_dec(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, -1, 0};
+
+	if (!dm_cookie_supported())
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
+int dm_notification_sem_wait_zero(uint32_t cookie)
+{
+	int semid;
+	struct sembuf sb = {0, 0, 0};
+
+	if (!dm_cookie_supported())
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
+int dm_notification_sem_close(uint32_t cookie)
+{
+	int semid;
+
+	if (!dm_cookie_supported())
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


