From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:42 +0000 (UTC)
Subject: master - cleanup: dmeventd improve _clien_write code
Message-ID: <20140418145542.07C9D61056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0927605ec3214349f69d849f72d138696231f3e7
Commit:        0927605ec3214349f69d849f72d138696231f3e7
Parent:        3febd2c9d47eb2af60a576a07c4042331930c2c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 14:42:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:52:35 2014 +0200

cleanup: dmeventd improve _clien_write code

Switch to allocate buffer from heap, since it might be potentially
bigger when extremaly large set of volumes would be monitored.
In case of allocation failure send ENOMEM message.
Also implicitelly ignore msg->size when msg->data is NULL.
---
 daemons/dmeventd/dmeventd.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f8b5470..b4080db 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1397,18 +1397,27 @@ static int _client_read(struct dm_event_fifos *fifos,
 static int _client_write(struct dm_event_fifos *fifos,
 			struct dm_event_daemon_message *msg)
 {
+	uint32_t temp[2];
 	unsigned bytes = 0;
 	int ret = 0;
 	fd_set fds;
 
-	size_t size = 2 * sizeof(uint32_t) + msg->size;
-	uint32_t *header = alloca(size);
+	size_t size = 2 * sizeof(uint32_t) + ((msg->data) ? msg->size : 0);
+	uint32_t *header = dm_malloc(size);
 	char *buf = (char *)header;
 
-	header[0] = htonl(msg->cmd);
-	header[1] = htonl(msg->size);
-	if (msg->data)
-		memcpy(buf + 2 * sizeof(uint32_t), msg->data, msg->size);
+	if (!header) {
+		/* Reply with ENOMEM message */
+		header = temp;
+		size = sizeof(temp);
+		header[0] = htonl(-ENOMEM);
+		header[1] = 0;
+	} else {
+		header[0] = htonl(msg->cmd);
+		header[1] = htonl((msg->data) ? msg->size : 0);
+		if (msg->data)
+			memcpy(buf + 2 * sizeof(uint32_t), msg->data, msg->size);
+	}
 
 	while (bytes < size) {
 		do {
@@ -1423,7 +1432,10 @@ static int _client_write(struct dm_event_fifos *fifos,
 			break;
 	}
 
-	return bytes == size;
+	if (header != temp)
+		dm_free(header);
+
+	return (bytes == size);
 }
 
 /*


