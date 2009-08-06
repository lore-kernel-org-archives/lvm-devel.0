From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:04:31 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-common.c ...
Message-ID: <20090806150431.28587.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:04:30

Modified files:
	libdm          : libdevmapper.h libdm-common.c 
	tools          : dmsetup.c 

Log message:
	Add 'udevcomplete_all' command for dmsetup. Export DM_COOKIE_MAGIC in libdevmapper.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/libdm/libdevmapper.h	2009/08/03 18:01:47	1.95
+++ LVM2/libdm/libdevmapper.h	2009/08/06 15:04:30	1.96
@@ -1014,6 +1014,8 @@
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+#define DM_COOKIE_MAGIC 0x0D4D
+
 int dm_cookie_supported(void);
 
 /*
--- LVM2/libdm/libdm-common.c	2009/08/06 15:00:25	1.75
+++ LVM2/libdm/libdm-common.c	2009/08/06 15:04:30	1.76
@@ -39,7 +39,6 @@
 #endif
 
 #define DEV_DIR "/dev/"
-#define COOKIE_MAGIC 0x0D4D
 
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 
@@ -837,7 +836,7 @@
 
 static int _get_cookie_sem(uint32_t cookie, int *semid)
 {
-	if (!(cookie >> 16 & COOKIE_MAGIC)) {
+	if (cookie >> 16 != DM_COOKIE_MAGIC) {
 		log_error("Could not continue to access notification "
 			  "semaphore identified by cookie value %"
 			  PRIu32 " (0x%x). Incorrect cookie prefix.",
@@ -952,7 +951,7 @@
 			goto bad;
 		}
 
-		gen_cookie = COOKIE_MAGIC << 16 | base_cookie;
+		gen_cookie = DM_COOKIE_MAGIC << 16 | base_cookie;
 
 		if (base_cookie && (gen_semid = semget((key_t) gen_cookie,
 				    1, 0600 | IPC_CREAT | IPC_EXCL)) < 0) {
@@ -1093,6 +1092,9 @@
 	if (semop(semid, &sb, 1) < 0) {
 		if (errno == EINTR)
 			goto repeat_wait;
+		else if (errno == EIDRM)
+			return 1;
+
 		log_error("Could not set wait state for notification semaphore "
 			  "identified by cookie value %" PRIu32 " (0x%x): %s",
 			  cookie, cookie, strerror(errno));
--- LVM2/tools/dmsetup.c	2009/08/03 18:01:46	1.120
+++ LVM2/tools/dmsetup.c	2009/08/06 15:04:30	1.121
@@ -40,6 +40,12 @@
 #include <fcntl.h>
 #include <sys/stat.h>
 
+#ifdef UDEV_SYNC_SUPPORT
+#  include <sys/types.h>
+#  include <sys/ipc.h>
+#  include <sys/sem.h>
+#endif
+
 /* FIXME Unused so far */
 #undef HAVE_SYS_STATVFS_H
 
@@ -273,6 +279,34 @@
 	struct dm_split_name *split_name;
 };
 
+static char _yes_no_prompt(const char *prompt, ...)
+{
+	int c = 0, ret = 0;
+	va_list ap;
+
+	do {
+		if (c == '\n' || !c) {
+			va_start(ap, prompt);
+			vprintf(prompt, ap);
+			va_end(ap);
+		}
+
+		if ((c = getchar()) == EOF) {
+			ret = 'n';
+			break;
+		}
+
+		c = tolower(c);
+		if ((c == 'y') || (c == 'n'))
+			ret = c;
+	} while (!ret || c != '\n');
+
+	if (c != '\n')
+		printf("\n");
+
+	return ret;
+}
+
 static struct dm_task *_get_deps_task(int major, int minor)
 {
 	struct dm_task *dmt;
@@ -763,6 +797,62 @@
 	return dm_udev_complete(cookie);
 }
 
+#ifndef UDEV_SYNC_SUPPORT
+static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	return 1;
+}
+
+#else
+
+static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	int max_id, id, sid;
+	struct seminfo sinfo;
+	struct semid_ds sdata;
+	int counter = 0;
+
+	log_warn("This operation will destroy all semaphores with keys "
+		 "that have a prefix %" PRIu16 " (0x%" PRIx16 ").",
+		 DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+
+	if (_yes_no_prompt("Do you really want to continue? [y/n]: ") == 'n') {
+		log_print("Semaphores with keys prefixed by %" PRIu16
+			  " (0x%" PRIx16 ") NOT destroyed.",
+			  DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+		return 1;
+	}
+
+	if ((max_id = semctl(0, 0, SEM_INFO, &sinfo)) < 0) {
+		log_sys_error("semctl", "SEM_INFO");
+		return 0;
+	}
+
+	for (id = 0; id <= max_id; id++) {
+		if ((sid = semctl(id, 0, SEM_STAT, &sdata)) < 0)
+			continue;
+
+		if (sdata.sem_perm.__key >> 16 == DM_COOKIE_MAGIC) {
+			if (semctl(sid, 0, IPC_RMID, 0) < 0) {
+				log_error("Could not cleanup notification semaphore "
+					  "with semid %d and cookie value "
+					  "%" PRIu32 " (0x%" PRIx32 ")", sid,
+					  sdata.sem_perm.__key, sdata.sem_perm.__key);
+				continue;
+			}
+
+			counter++;
+		}
+	}
+
+	log_print("%d semaphores with keys prefixed by "
+		  "%" PRIu16 " (0x%" PRIx16 ") destroyed.",
+		  counter, DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+
+	return 1;
+}
+#endif
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -2294,6 +2384,7 @@
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
+	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},


