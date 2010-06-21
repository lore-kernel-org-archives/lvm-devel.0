From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Jun 2010 16:07:07 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20100621160707.5431.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-21 16:07:06

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	Add error checking for calls to sprintf - it can fail for more
	reasons than just 'out-of-space'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/daemons/cmirrord/functions.c	2010/06/18 20:58:04	1.19
+++ LVM2/daemons/cmirrord/functions.c	2010/06/21 16:07:06	1.20
@@ -1371,15 +1371,21 @@
 
 static int core_status_info(struct log_c *lc __attribute((unused)), struct dm_ulog_request *rq)
 {
+	int r;
 	char *data = (char *)rq->data;
 
-	rq->data_size = sprintf(data, "1 clustered-core");
+	r = sprintf(data, "1 clustered-core");
+	if (r < 0)
+		return r;
+
+	rq->data_size = r;
 
 	return 0;
 }
 
 static int disk_status_info(struct log_c *lc, struct dm_ulog_request *rq)
 {
+	int r;
 	char *data = (char *)rq->data;
 	struct stat statbuf;
 
@@ -1388,9 +1394,13 @@
 		return -errno;
 	}
 
-	rq->data_size = sprintf(data, "3 clustered-disk %d:%d %c",
-				major(statbuf.st_rdev), minor(statbuf.st_rdev),
-				(lc->log_dev_failed) ? 'D' : 'A');
+	r = sprintf(data, "3 clustered-disk %d:%d %c",
+		    major(statbuf.st_rdev), minor(statbuf.st_rdev),
+		    (lc->log_dev_failed) ? 'D' : 'A');
+	if (r < 0)
+		return r;
+
+	rq->data_size = r;
 
 	return 0;
 }
@@ -1421,18 +1431,24 @@
 
 static int core_status_table(struct log_c *lc, struct dm_ulog_request *rq)
 {
+	int r;
 	char *data = (char *)rq->data;
 
-	rq->data_size = sprintf(data, "clustered-core %u %s%s ",
-				lc->region_size,
-				(lc->sync == DEFAULTSYNC) ? "" :
-				(lc->sync == NOSYNC) ? "nosync " : "sync ",
-				(lc->block_on_error) ? "block_on_error" : "");
+	r = sprintf(data, "clustered-core %u %s%s ",
+		    lc->region_size,
+		    (lc->sync == DEFAULTSYNC) ? "" :
+		    (lc->sync == NOSYNC) ? "nosync " : "sync ",
+		    (lc->block_on_error) ? "block_on_error" : "");
+	if (r < 0)
+		return r;
+
+	rq->data_size = r;
 	return 0;
 }
 
 static int disk_status_table(struct log_c *lc, struct dm_ulog_request *rq)
 {
+	int r;
 	char *data = (char *)rq->data;
 	struct stat statbuf;
 
@@ -1441,12 +1457,16 @@
 		return -errno;
 	}
 
-	rq->data_size = sprintf(data, "clustered-disk %d:%d %u %s%s ",
-				major(statbuf.st_rdev), minor(statbuf.st_rdev),
-				lc->region_size,
-				(lc->sync == DEFAULTSYNC) ? "" :
-				(lc->sync == NOSYNC) ? "nosync " : "sync ",
-				(lc->block_on_error) ? "block_on_error" : "");
+	r = sprintf(data, "clustered-disk %d:%d %u %s%s ",
+		    major(statbuf.st_rdev), minor(statbuf.st_rdev),
+		    lc->region_size,
+		    (lc->sync == DEFAULTSYNC) ? "" :
+		    (lc->sync == NOSYNC) ? "nosync " : "sync ",
+		    (lc->block_on_error) ? "block_on_error" : "");
+	if (r < 0)
+		return r;
+
+	rq->data_size = r;
 	return 0;
 }
 
@@ -1555,6 +1575,11 @@
  * from this function.  However, an inability to successfully
  * perform the request will fill in the 'rq->error' field.
  *
+ * 'rq' (or more correctly, rq->u_rq.data) should be of sufficient
+ * size to hold any returning data.  Currently, local.c uses 2kiB
+ * to hold 'rq' - leaving ~1.5kiB for return data... more than
+ * enough for all the implemented functions here.
+ *
  * Returns: 0 on success, -EXXX on error
  */
 int do_request(struct clog_request *rq, int server)


