From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Jan 2010 20:58:51 -0000
Subject: LVM2/daemons/cmirrord compat.c functions.c local.c
Message-ID: <20100118205851.24142.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-18 20:58:50

Modified files:
	daemons/cmirrord: compat.c functions.c local.c 

Log message:
	Fix some compiler warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/cmirrord/compat.c	2010/01/18 20:08:44	1.2
+++ LVM2/daemons/cmirrord/compat.c	2010/01/18 20:58:50	1.3
@@ -201,7 +201,7 @@
 		if (data_len < (COMPAT_OFFSET + sizeof(*rq)))
 			return -ENOSPC;
 
-		rq = (char *)data + COMPAT_OFFSET;
+		rq = data + COMPAT_OFFSET;
 		break;
 	default:
 		LOG_ERROR("Unable to process cluster message: "
--- LVM2/daemons/cmirrord/functions.c	2010/01/18 20:08:44	1.12
+++ LVM2/daemons/cmirrord/functions.c	2010/01/18 20:58:50	1.13
@@ -933,13 +933,13 @@
 static int clog_is_clean(struct dm_ulog_request *rq)
 {
 	int64_t *rtn = (int64_t *)rq->data;
-	uint64_t region = *((uint64_t *)(rq->data));
+	uint64_t *region = (uint64_t *)rq->data;
 	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
 
-	*rtn = log_test_bit(lc->clean_bits, region);
+	*rtn = log_test_bit(lc->clean_bits, *region);
 	rq->data_size = sizeof(*rtn);
 
 	return 0;
@@ -958,7 +958,8 @@
 static int clog_in_sync(struct dm_ulog_request *rq)
 {
 	int64_t *rtn = (int64_t *)rq->data;
-	uint64_t region = *((uint64_t *)(rq->data));
+	uint64_t *region_p = (uint64_t *)rq->data;
+	uint64_t region = *region_p;
 	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
@@ -1487,7 +1488,8 @@
  */
 static int clog_is_remote_recovering(struct dm_ulog_request *rq)
 {
-	uint64_t region = *((uint64_t *)(rq->data));
+	uint64_t *region_p = (uint64_t *)rq->data;
+	uint64_t region = *region_p;
 	struct {
 		int64_t is_recovering;
 		uint64_t in_sync_hint;
--- LVM2/daemons/cmirrord/local.c	2010/01/18 20:08:44	1.5
+++ LVM2/daemons/cmirrord/local.c	2010/01/18 20:58:50	1.6
@@ -89,8 +89,10 @@
 {
 	int r = 0;
 	int len;
+	void *foo;
 	struct cn_msg *msg;
 	struct dm_ulog_request *u_rq;
+	struct nlmsghdr *nlmsg_h;
 
 	*rq = NULL;
 	memset(recv_buf, 0, sizeof(recv_buf));
@@ -102,7 +104,8 @@
 		goto fail;
 	}
 
-	switch (((struct nlmsghdr *)recv_buf)->nlmsg_type) {
+	nlmsg_h = (struct nlmsghdr *)recv_buf;
+	switch (nlmsg_h->nlmsg_type) {
 	case NLMSG_ERROR:
 		LOG_ERROR("Unable to recv message from kernel: NLMSG_ERROR");
 		r = -EBADE;
@@ -158,10 +161,9 @@
 		 * beyond what is available to us, but we need only check it
 		 * once... perhaps at compile time?
 		 */
-//		*rq = container_of(u_rq, struct clog_request, u_rq);
-		*rq = (char *)u_rq -
-			(sizeof(struct clog_request) -
-			 sizeof(struct dm_ulog_request));
+		foo = u_rq;
+		foo -= (sizeof(struct clog_request) - sizeof(struct dm_ulog_request));
+		*rq = foo;
 
 		/* Clear the wrapper container fields */
 		memset(*rq, 0, (char *)u_rq - (char *)(*rq));


