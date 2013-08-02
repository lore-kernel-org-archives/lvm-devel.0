From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  2 Aug 2013 14:57:30 +0000 (UTC)
Subject: master - clvmd: verify messages before processing
Message-ID: <20130802145730.0BBAA60E24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19baf84290186a550b212260144523266350252b
Commit:        19baf84290186a550b212260144523266350252b
Parent:        5ca54c4f0b27125bc385d55ea0b44853fc7744dd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 30 14:12:33 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 2 09:55:54 2013 -0500

clvmd: verify messages before processing

Check that fields in clvm_header are valid when
local or remote messages are received.  If not,
log an error, dump the message data and ignore
the message.
---
 daemons/clvmd/clvmd.c |  109 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a276cbc..f05776f 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -21,6 +21,7 @@
 
 #include <pthread.h>
 #include <getopt.h>
+#include <ctype.h>
 
 #include "clvmd-comms.h"
 #include "clvm.h"
@@ -1088,7 +1089,90 @@ static void be_daemon(int timeout)
 		log_error("Error setting current directory to /: %m");
 		exit(6);
 	}
+}
+
+static int verify_message(char *buf, int len)
+{
+	struct clvm_header *h = (struct clvm_header *)buf;
+
+	if (len < sizeof(struct clvm_header)) {
+		log_error("verify_message short len %d", len);
+		return -1;
+	}
+
+	switch (h->cmd) {
+	case CLVMD_CMD_REPLY:
+	case CLVMD_CMD_VERSION:
+	case CLVMD_CMD_GOAWAY:
+	case CLVMD_CMD_TEST:
+	case CLVMD_CMD_LOCK:
+	case CLVMD_CMD_UNLOCK:
+	case CLVMD_CMD_LOCK_LV:
+	case CLVMD_CMD_LOCK_VG:
+	case CLVMD_CMD_LOCK_QUERY:
+	case CLVMD_CMD_REFRESH:
+	case CLVMD_CMD_GET_CLUSTERNAME:
+	case CLVMD_CMD_SET_DEBUG:
+	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_RESTART:
+	case CLVMD_CMD_SYNC_NAMES:
+		break;
+	default:
+		log_error("verify_message bad cmd %x", h->cmd);
+		return -1;
+	};
+
+	/* TODO: we may be able to narrow len/flags/clientid/arglen checks based on cmd */
+
+	if (h->flags & ~(CLVMD_FLAG_LOCAL | CLVMD_FLAG_SYSTEMLV | CLVMD_FLAG_NODEERRS)) {
+		log_error("verify_message bad flags %x", h->flags);
+		return -1;
+	}
 
+	if (h->clientid < 0) {
+		log_error("verify_message bad clientid %x", h->clientid);
+		return -1;
+	}
+
+	if (h->arglen > max_cluster_message) {
+		log_error("verify_message bad arglen %x max %d", h->arglen, max_cluster_message);
+		return -1;
+	}
+
+	return 0;
+}
+
+static void dump_message(char *buf, int len)
+{
+	unsigned char row[8];
+	char str[9];
+	int i, j, pos;
+
+	if (len > 128)
+		len = 128;
+
+	pos = 0;
+	memset(row, 0, sizeof(row));
+
+	for (i = 0; i < len; i++) {
+		row[pos++] = buf[i];
+
+		if ((pos == 8) || (i + 1 == len)) {
+			memset(str, 0, sizeof(str));
+
+			for (j = 0; j < 8; j++) {
+				if (isprint(row[j]))
+					str[j] = row[j];
+				else
+					str[j] = ' ';
+			}
+
+			log_error("%02x %02x %02x %02x %02x %02x %02x %02x [%s]",
+				  row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], str);
+			pos = 0;
+			memset(row, 0, sizeof(row));
+		}
+	}
 }
 
 /* Called when we have a read from the local socket.
@@ -1100,12 +1184,25 @@ static int read_from_local_sock(struct local_client *thisfd)
 	int missing_len;
 	char buffer[PIPE_BUF + 1];
 
+	memset(buffer, 0, sizeof(buffer));
+
 	len = read(thisfd->fd, buffer, sizeof(buffer) - 1);
 	if (len == -1 && errno == EINTR)
 		return 1;
 
 	DEBUGLOG("Read on local socket %d, len = %d\n", thisfd->fd, len);
 
+	if (len) {
+		int rv = verify_message(buffer, len);
+		if (rv < 0) {
+			log_error("read_from_local_sock from %d len %d bad verify",
+				  thisfd->fd, len);
+			dump_message(buffer, len);
+			/* force error handling below */
+			len = 0;
+		}
+	}
+
 	/* EOF or error on socket */
 	if (len <= 0) {
 		int *status;
@@ -2189,10 +2286,22 @@ error:
 void process_message(struct local_client *client, char *buf, int len,
 		     const char *csid)
 {
+	char nodename[max_cluster_member_name_len];
 	struct clvm_header *inheader;
+	int rv;
 
 	inheader = (struct clvm_header *) buf;
 	ntoh_clvm(inheader);	/* Byteswap fields */
+
+	rv = verify_message(buf, len);
+	if (rv < 0) {
+		memset(nodename, 0, sizeof(nodename));
+		clops->name_from_csid(csid, nodename);
+		log_error("process_message from %s len %d bad verify", nodename, len);
+		dump_message(buf, len);
+		return;
+	}
+
 	if (inheader->cmd == CLVMD_CMD_REPLY)
 		process_reply(inheader, len, csid);
 	else


