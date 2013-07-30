From: David Teigland <teigland@redhat.com>
Date: Tue, 30 Jul 2013 15:46:49 -0400
Subject: [PATCH RFC] clvmd: verify messages before processing
Message-ID: <20130730194649.GA3707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Does this look like it would be useful?  More checks can be
added over time, but are there any that would be obvious to
add now?  I'm mainly trying to catch non-message data, and
not risk rejecting any proper messages.


Check that fields in clvm_header are valid when
local or remote messages are received.  If not,
log an error, dump the message data and ignore
the message.
---
 daemons/clvmd/clvmd.c | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a276cbc..468dc31 100644
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
+		log_error("verify_message short len %d\n", len);
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
+		log_error("verify_message bad cmd %x\n", h->cmd);
+		return -1;
+	};
+
+	/* TODO: we may be able to narrow len/flags/clientid/arglen checks based on cmd */
+
+	if (h->flags & ~(CLVMD_FLAG_LOCAL | CLVMD_FLAG_SYSTEMLV | CLVMD_FLAG_NODEERRS)) {
+		log_error("verify_message bad flags %x\n", h->flags);
+		return -1;
+	}
 
+	if (h->clientid < 0) {
+		log_error("verify_message bad clientid %x\n", h->clientid);
+		return -1;
+	}
+
+	if (h->arglen > max_cluster_message) {
+		log_error("verify_message bad arglen %x max %d\n", h->arglen, max_cluster_message);
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
+			log_error("%02x %02x %02x %02x %02x %02x %02x %02x [%s]\n",
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
+			log_error("read_from_local_sock from %d len %d bad verify\n",
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
+		log_error("process_message from %s len %d bad verify\n", nodename, len);
+		dump_message(buf, len);
+		return;
+	}
+
 	if (inheader->cmd == CLVMD_CMD_REPLY)
 		process_reply(inheader, len, csid);
 	else
-- 
1.8.3.1


