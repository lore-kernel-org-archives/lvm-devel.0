From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 May 2010 08:40:38 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100525084038.27701.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-25 08:40:37

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Fix copy&paste detection of kernel release version.
	Add log_error to avoid return_0 without log_error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/libdm/libdm-deptree.c	2010/05/24 23:11:35	1.81
+++ LVM2/libdm/libdm-deptree.c	2010/05/25 08:40:36	1.82
@@ -1542,8 +1542,10 @@
 	const char *logtype;
 	unsigned kmaj, kmin, krel;
 
-	if (!uname(&uts) || sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) != 3)
-		return_0;
+	if (uname(&uts) == -1 || sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) != 3) {
+		log_error("Cannot read kernel release version");
+		return 0;
+	}
 
 	if ((seg->flags & DM_BLOCK_ON_ERROR)) {
 		/*


