From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Oct 2006 17:18:40 -0000
Subject: LVM2/lib/misc timestamp.c
Message-ID: <20061012171840.30493.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-12 17:18:40

Modified files:
	lib/misc       : timestamp.c 

Log message:
	remove unused variable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/timestamp.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/misc/timestamp.c	2006/09/30 20:02:02	1.1
+++ LVM2/lib/misc/timestamp.c	2006/10/12 17:18:40	1.2
@@ -39,7 +39,6 @@
 struct timestamp *get_timestamp(void)
 {
 	struct timestamp *ts = NULL;
-	int err = 0;
 
 	if (!(ts = dm_malloc(sizeof(*ts))))
 		return_NULL;
@@ -89,12 +88,11 @@
 struct timestamp *get_timestamp(void)
 {
 	struct timestamp *ts = NULL;
-	int err = 0;
 
 	if (!(ts = dm_malloc(sizeof(*ts))))
 		return_NULL;
 
-	if ((err = gettimeofday(&ts->t, NULL))) {
+	if (gettimeofday(&ts->t, NULL)) {
 		log_sys_error("gettimeofday", "get_timestamp");
 		return NULL;
 	}


