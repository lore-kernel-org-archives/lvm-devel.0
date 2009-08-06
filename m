From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:05:11 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20090806150511.30932.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:05:11

Modified files:
	tools          : dmsetup.c 

Log message:
	Add 'udevcookies' command for dmsetup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/tools/dmsetup.c	2009/08/06 15:04:30	1.121
+++ LVM2/tools/dmsetup.c	2009/08/06 15:05:10	1.122
@@ -36,6 +36,7 @@
 #include <sys/param.h>
 #include <locale.h>
 #include <langinfo.h>
+#include <time.h>
 
 #include <fcntl.h>
 #include <sys/stat.h>
@@ -853,6 +854,45 @@
 }
 #endif
 
+static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	int max_id, id, sid;
+	struct seminfo sinfo;
+	struct semid_ds sdata;
+	int val;
+	char *time_str;
+
+	if ((max_id = semctl(0, 0, SEM_INFO, &sinfo)) < 0) {
+		log_sys_error("sem_ctl", "SEM_INFO");
+		return 0;
+	}
+
+	printf("cookie       semid      value      last_semop_time\n");
+
+	for (id = 0; id <= max_id; id++) {
+		if ((sid = semctl(id, 0, SEM_STAT, &sdata)) < 0)
+			continue;
+
+		if (sdata.sem_perm.__key >> 16 == DM_COOKIE_MAGIC) {
+			if ((val = semctl(sid, 0, GETVAL)) < 0) {
+				log_error("semid %d: sem_ctl failed for "
+					  "cookie 0x%" PRIx32 ": %s",
+					  sid, sdata.sem_perm.__key,
+					  strerror(errno));
+				continue;
+			}
+
+			time_str = ctime((const time_t *) &sdata.sem_otime);
+
+			printf("0x%-10x %-10d %-10d %s", sdata.sem_perm.__key,
+				sid, val, time_str ? time_str : "unknown");
+		}
+	}
+
+	return 1;
+}
+
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -2385,6 +2425,7 @@
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
 	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
+	{"udevcookies", "", 0, 0, _udevcookies},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},


