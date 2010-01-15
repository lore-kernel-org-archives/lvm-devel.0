From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 16:03:19 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20100115160319.21096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 16:03:19

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	At some point "clustered_[core|disk]" was changed to "clustered-[core|disk]".
	
	This patch makes the log server recognise the new format.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/daemons/cmirrord/functions.c	2009/08/28 05:27:09	1.9
+++ LVM2/daemons/cmirrord/functions.c	2010/01/15 16:03:19	1.10
@@ -382,7 +382,7 @@
 		disk_log = 1;
 
 		if ((argc < 2) || (argc > 4)) {
-			LOG_ERROR("Too %s arguments to clustered_disk log type",
+			LOG_ERROR("Too %s arguments to clustered-disk log type",
 				  (argc < 3) ? "few" : "many");
 			r = -EINVAL;
 			goto fail;
@@ -398,7 +398,7 @@
 		disk_log = 0;
 
 		if ((argc < 1) || (argc > 3)) {
-			LOG_ERROR("Too %s arguments to clustered_core log type",
+			LOG_ERROR("Too %s arguments to clustered-core log type",
 				  (argc < 2) ? "few" : "many");
 			r = -EINVAL;
 			goto fail;
@@ -406,7 +406,7 @@
 	}
 
 	if (!(region_size = strtoll(argv[disk_log], &p, 0)) || *p) {
-		LOG_ERROR("Invalid region_size argument to clustered_%s log type",
+		LOG_ERROR("Invalid region_size argument to clustered-%s log type",
 			  (disk_log) ? "disk" : "core");
 		r = -EINVAL;
 		goto fail;
@@ -572,8 +572,8 @@
 	for (i = 0; i < argc; i++, p = p + strlen(p) + 1)
 		argv[i] = p;
 
-	if (strcmp(argv[0], "clustered_disk") &&
-	    strcmp(argv[0], "clustered_core")) {
+	if (strcmp(argv[0], "clustered-disk") &&
+	    strcmp(argv[0], "clustered-core")) {
 		LOG_ERROR("Unsupported userspace log type, \"%s\"", argv[0]);
 		free(argv);
 		return -EINVAL;
@@ -1374,7 +1374,7 @@
 {
 	char *data = (char *)rq->data;
 
-	rq->data_size = sprintf(data, "1 clustered_core");
+	rq->data_size = sprintf(data, "1 clustered-core");
 
 	return 0;
 }
@@ -1389,7 +1389,7 @@
 		return -errno;
 	}
 
-	rq->data_size = sprintf(data, "3 clustered_disk %d:%d %c",
+	rq->data_size = sprintf(data, "3 clustered-disk %d:%d %c",
 				major(statbuf.st_rdev), minor(statbuf.st_rdev),
 				(lc->log_dev_failed) ? 'D' : 'A');
 
@@ -1424,7 +1424,7 @@
 {
 	char *data = (char *)rq->data;
 
-	rq->data_size = sprintf(data, "clustered_core %u %s%s ",
+	rq->data_size = sprintf(data, "clustered-core %u %s%s ",
 				lc->region_size,
 				(lc->sync == DEFAULTSYNC) ? "" :
 				(lc->sync == NOSYNC) ? "nosync " : "sync ",
@@ -1442,7 +1442,7 @@
 		return -errno;
 	}
 
-	rq->data_size = sprintf(data, "clustered_disk %d:%d %u %s%s ",
+	rq->data_size = sprintf(data, "clustered-disk %d:%d %u %s%s ",
 				major(statbuf.st_rdev), minor(statbuf.st_rdev),
 				lc->region_size,
 				(lc->sync == DEFAULTSYNC) ? "" :


