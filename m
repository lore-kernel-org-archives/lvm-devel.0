From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 11:57:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c d ...
Message-ID: <20101025115708.2744.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 11:57:07

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c libdevmapper-event.c 

Log message:
	Fix clang warning for ntohl(*((uint32_t *)buf))
	
	We cast (char*) to (uint32_t*) that changes alignment requierements.
	For our case the code has been correct as alloca() returns properly
	aligned buffer, however this patch make it cleaner and more readable
	and avoids warning generation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1769&r2=1.1770
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/10/25 11:20:54	1.1769
+++ LVM2/WHATS_NEW	2010/10/25 11:57:06	1.1770
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix warning for changed alignment requirements for dmeventd read/write func.
   Add global/metadata_read_only to use unrepaired metadata in read-only cmds.
   Don't take write lock in vgchange --refresh, --poll or --monitor.
   Skip dm devices in scan if they contain only error targets or are empty.
--- LVM2/daemons/dmeventd/dmeventd.c	2010/10/20 15:12:12	1.67
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/10/25 11:57:07	1.68
@@ -1300,9 +1300,9 @@
 	unsigned bytes = 0;
 	int ret = 0;
 	fd_set fds;
-	int header = 1;
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
-	char *buf = alloca(size);
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 
 	msg->data = NULL;
 
@@ -1326,9 +1326,9 @@
 
 		ret = read(fifos->client, buf + bytes, size - bytes);
 		bytes += ret > 0 ? ret : 0;
-		if (bytes == 2 * sizeof(uint32_t) && header) {
-			msg->cmd = ntohl(*((uint32_t *) buf));
-			msg->size = ntohl(*((uint32_t *) buf + 1));
+		if (header && (bytes == 2 * sizeof(uint32_t))) {
+			msg->cmd = ntohl(header[0]);
+			msg->size = ntohl(header[1]);
 			buf = msg->data = dm_malloc(msg->size);
 			size = msg->size;
 			bytes = 0;
@@ -1356,10 +1356,11 @@
 	fd_set fds;
 
 	size_t size = 2 * sizeof(uint32_t) + msg->size;
-	char *buf = alloca(size);
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 
-	*((uint32_t *)buf) = htonl(msg->cmd);
-	*((uint32_t *)buf + 1) = htonl(msg->size);
+	header[0] = htonl(msg->cmd);
+	header[1] = htonl(msg->size);
 	if (msg->data)
 		memcpy(buf + 2 * sizeof(uint32_t), msg->data, msg->size);
 
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/10/20 15:12:12	1.35
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/10/25 11:57:07	1.36
@@ -230,8 +230,8 @@
 	fd_set fds;
 	struct timeval tval = { 0, 0 };
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
-	char *buf = alloca(size);
-	int header = 1;
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 
 	while (bytes < size) {
 		for (i = 0, ret = 0; (i < 20) && (ret < 1); i++) {
@@ -262,9 +262,9 @@
 		}
 
 		bytes += ret;
-		if (bytes == 2 * sizeof(uint32_t) && header) {
-			msg->cmd = ntohl(*((uint32_t *)buf));
-			msg->size = ntohl(*((uint32_t *)buf + 1));
+		if (header && (bytes == 2 * sizeof(uint32_t))) {
+			msg->cmd = ntohl(header[0]);
+			msg->size = ntohl(header[1]);
 			buf = msg->data = dm_malloc(msg->size);
 			size = msg->size;
 			bytes = 0;
@@ -288,12 +288,13 @@
 	fd_set fds;
 
 	size_t size = 2 * sizeof(uint32_t) + msg->size;
-	char *buf = alloca(size);
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 	char drainbuf[128];
 	struct timeval tval = { 0, 0 };
 
-	*((uint32_t *)buf) = htonl(msg->cmd);
-	*((uint32_t *)buf + 1) = htonl(msg->size);
+	header[0] = htonl(msg->cmd);
+	header[1] = htonl(msg->size);
 	memcpy(buf + 2 * sizeof(uint32_t), msg->data, msg->size);
 
 	/* drain the answer fifo */
@@ -323,8 +324,7 @@
 			}
 		} while (ret < 1);
 
-		ret = write(fifos->client, ((char *) buf) + bytes,
-			    size - bytes);
+		ret = write(fifos->client, buf + bytes, size - bytes);
 		if (ret < 0) {
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;


