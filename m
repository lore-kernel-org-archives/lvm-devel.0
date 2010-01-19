From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2010 15:58:46 -0000
Subject: LVM2/daemons/cmirrord clogd.c link_mon.c local.c
Message-ID: <20100119155846.15479.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-19 15:58:45

Modified files:
	daemons/cmirrord: clogd.c link_mon.c local.c 

Log message:
	Signal handling FIXMEs.
	A few integer type changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/cmirrord/clogd.c	2010/01/18 21:07:24	1.8
+++ LVM2/daemons/cmirrord/clogd.c	2010/01/19 15:58:45	1.9
@@ -21,9 +21,10 @@
 #include <sys/wait.h>
 #include <unistd.h>
 
-static int exit_now = 0;
+static volatile sig_atomic_t exit_now = 0;
+/* FIXME Review signal handling.  Should be volatile sig_atomic_t */
 static sigset_t signal_mask;
-static int signal_received;
+static volatile sig_atomic_t signal_received;
 
 static void process_signals(void);
 static void daemonize(void);
@@ -96,7 +97,8 @@
 
 	sprintf(buffer, "%d\n", getpid());
 
-	if(write(fd, buffer, strlen(buffer)) < strlen(buffer)){
+	/* FIXME Handle other non-error returns without aborting */
+	if (write(fd, buffer, strlen(buffer)) < strlen(buffer)){
 		close(fd);
 		unlink(lockfile);
 		return -errno;
@@ -107,8 +109,9 @@
 
 static void sig_handler(int sig)
 {
+	/* FIXME Races - don't touch signal_mask here. */
 	sigaddset(&signal_mask, sig);
-	++signal_received;
+	signal_received = 1;
 }
 
 static void process_signal(int sig){
@@ -225,6 +228,7 @@
 	if (create_lockfile(CMIRRORD_PIDFILE))
 		exit(EXIT_LOCKFILE);
 
+	/* FIXME Replace with sigaction. (deprecated) */
 	signal(SIGINT, &sig_handler);
 	signal(SIGQUIT, &sig_handler);
 	signal(SIGTERM, &sig_handler);
--- LVM2/daemons/cmirrord/link_mon.c	2010/01/18 21:07:24	1.4
+++ LVM2/daemons/cmirrord/link_mon.c	2010/01/19 15:58:45	1.5
@@ -25,14 +25,14 @@
 	struct link_callback *next;
 };
 
-static int used_pfds = 0;
-static int free_pfds = 0;
+static unsigned used_pfds = 0;
+static unsigned free_pfds = 0;
 static struct pollfd *pfds = NULL;
 static struct link_callback *callbacks = NULL;
 
 int links_register(int fd, const char *name, int (*callback)(void *data), void *data)
 {
-	int i;
+	unsigned i;
 	struct link_callback *lc;
 
 	for (i = 0; i < used_pfds; i++) {
@@ -72,7 +72,7 @@
 	lc->next = callbacks;
 	callbacks = lc;
 	LOG_DBG("Adding %s/%d", lc->name, lc->fd);
-	LOG_DBG(" used_pfds = %d, free_pfds = %d",
+	LOG_DBG(" used_pfds = %u, free_pfds = %u",
 		used_pfds, free_pfds);
 
 	return 0;
@@ -80,7 +80,7 @@
 
 int links_unregister(int fd)
 {
-	int i;
+	unsigned i;
 	struct link_callback *p, *c;
 
 	for (i = 0; i < used_pfds; i++)
@@ -94,7 +94,7 @@
 	for (p = NULL, c = callbacks; c; p = c, c = c->next)
 		if (fd == c->fd) {
 			LOG_DBG("Freeing up %s/%d", c->name, c->fd);
-			LOG_DBG(" used_pfds = %d, free_pfds = %d",
+			LOG_DBG(" used_pfds = %u, free_pfds = %u",
 				used_pfds, free_pfds);
 			if (p)
 				p->next = c->next;
@@ -109,7 +109,8 @@
 
 int links_monitor(void)
 {
-	int i, r;
+	unsigned i;
+	int r;
 
 	for (i = 0; i < used_pfds; i++) {
 		pfds[i].revents = 0;
@@ -134,7 +135,7 @@
 
 int links_issue_callbacks(void)
 {
-	int i;
+	unsigned i;
 	struct link_callback *lc;
 
 	for (i = 0; i < used_pfds; i++)
--- LVM2/daemons/cmirrord/local.c	2010/01/18 21:07:24	1.7
+++ LVM2/daemons/cmirrord/local.c	2010/01/19 15:58:45	1.8
@@ -82,8 +82,8 @@
 static int kernel_recv(struct clog_request **rq)
 {
 	int r = 0;
-	int len;
-	void *foo;
+	ssize_t len;
+	char *foo;
 	struct cn_msg *msg;
 	struct dm_ulog_request *u_rq;
 	struct nlmsghdr *nlmsg_h;
@@ -106,9 +106,9 @@
 		goto fail;
 	case NLMSG_DONE:
 		msg = (struct cn_msg *)NLMSG_DATA((struct nlmsghdr *)recv_buf);
-		len -= sizeof(struct nlmsghdr);
+		len -= (ssize_t)sizeof(struct nlmsghdr);
 
-		if (len < sizeof(struct cn_msg)) {
+		if (len < (ssize_t)sizeof(struct cn_msg)) {
 			LOG_ERROR("Incomplete request from kernel received");
 			r = -EBADE;
 			goto fail;
@@ -124,10 +124,10 @@
 		if (!msg->len)
 			LOG_ERROR("Zero length message received");
 
-		len -= sizeof(struct cn_msg);
+		len -= (ssize_t)sizeof(struct cn_msg);
 
 		if (len < msg->len)
-			LOG_ERROR("len = %d, msg->len = %d", len, msg->len);
+			LOG_ERROR("len = %zd, msg->len = %" PRIu16, len, msg->len);
 
 		msg->data[msg->len] = '\0'; /* Cleaner way to ensure this? */
 		u_rq = (struct dm_ulog_request *)msg->data;
@@ -155,12 +155,12 @@
 		 * beyond what is available to us, but we need only check it
 		 * once... perhaps at compile time?
 		 */
-		foo = u_rq;
+		foo = (char *)u_rq;
 		foo -= (sizeof(struct clog_request) - sizeof(struct dm_ulog_request));
-		*rq = foo;
+		*rq = (struct clog_request *) foo;
 
 		/* Clear the wrapper container fields */
-		memset(*rq, 0, (char *)u_rq - (char *)(*rq));
+		memset(*rq, 0, (size_t)((char *)u_rq - (char *)(*rq)));
 		break;
 	default:
 		LOG_ERROR("Unknown nlmsg_type");
@@ -174,7 +174,7 @@
 	return (r == -EAGAIN) ? 0 : r;
 }
 
-static int kernel_send_helper(void *data, int out_size)
+static int kernel_send_helper(void *data, uint16_t out_size)
 {
 	int r;
 	struct nlmsghdr *nlh;
@@ -327,12 +327,12 @@
 int kernel_send(struct dm_ulog_request *u_rq)
 {
 	int r;
-	int size;
+	uint16_t size;
 
 	if (!u_rq)
 		return -EINVAL;
 
-	size = sizeof(struct dm_ulog_request) + u_rq->data_size;
+	size = (uint16_t)(sizeof(struct dm_ulog_request) + u_rq->data_size);
 
 	if (!u_rq->data_size && !u_rq->error) {
 		/* An ACK is all that is needed */
@@ -368,7 +368,7 @@
 int init_local(void)
 {
 	int r = 0;
-	int opt;
+	unsigned opt;
 	struct sockaddr_nl addr;
 
 	cn_fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);


