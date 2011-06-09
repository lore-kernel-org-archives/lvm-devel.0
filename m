From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 15:53:01 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20110609155301.19117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 15:53:00

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Fix another occurrence of linux kernel version check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/libdm/libdm-deptree.c	2011/03/29 20:19:04	1.92
+++ LVM2/libdm/libdm-deptree.c	2011/06/09 15:52:59	1.93
@@ -1544,13 +1544,20 @@
 	int dm_log_userspace = 0;
 	struct utsname uts;
 	unsigned log_parm_count;
-	int pos = 0;
+	int pos = 0, parts;
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
-	unsigned kmaj, kmin, krel;
+	unsigned kmaj = 0, kmin = 0, krel = 0;
+
+	if (uname(&uts) == -1) {
+		log_error("Cannot read kernel release version.");
+		return 0;
+	}
 
-	if (uname(&uts) == -1 || sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) != 3) {
-		log_error("Cannot read kernel release version");
+	/* Kernels with a major number of 2 always had 3 parts. */
+	parts = sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel);
+	if (parts < 1 || (kmaj < 3 && parts < 3)) {
+		log_error("Wrong kernel release version %s.", uts.release);
 		return 0;
 	}
 


