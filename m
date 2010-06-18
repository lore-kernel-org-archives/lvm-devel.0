From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 18 Jun 2010 16:10:20 -0500
Subject: [PATCH] Missing error checking in cmirrord
Message-ID: <1276895420.26585.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are missing error checks... it's possible for
sprintf to fail.

 brassow

Index: LVM2/daemons/cmirrord/functions.c
===================================================================
--- LVM2.orig/daemons/cmirrord/functions.c
+++ LVM2/daemons/cmirrord/functions.c
@@ -1371,15 +1371,21 @@ static int clog_get_sync_count(struct dm
 
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
 
@@ -1388,9 +1394,13 @@ static int disk_status_info(struct log_c
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
@@ -1421,18 +1431,24 @@ static int clog_status_info(struct dm_ul
 
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
 
@@ -1441,12 +1457,16 @@ static int disk_status_table(struct log_
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
 



