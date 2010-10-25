From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:08 +0200
Subject: [PATCH 01/30] Fix clang warning for ntohl(*((uint32_t *)buf))
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <37b83dcc9cb1168d88a1e665654c8bbf1c299879.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We cast (char*) to (uint32_t*) that changes alignment requierements.
For our case the code has been correct as alloca() returns properly
aligned buffer, however this patch make it cleaner and more readable
and avoids warning generation.

FIXME: code duplication

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c           |   17 +++++++++--------
 daemons/dmeventd/libdevmapper-event.c |   20 ++++++++++----------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 639f200..d179879 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1300,9 +1300,9 @@ static int _client_read(struct dm_event_fifos *fifos,
 	unsigned bytes = 0;
 	int ret = 0;
 	fd_set fds;
-	int header = 1;
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
-	char *buf = alloca(size);
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 
 	msg->data = NULL;
 
@@ -1326,9 +1326,9 @@ static int _client_read(struct dm_event_fifos *fifos,
 
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
@@ -1356,10 +1356,11 @@ static int _client_write(struct dm_event_fifos *fifos,
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
 
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index abbb968..bc8ad99 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -230,8 +230,8 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 	fd_set fds;
 	struct timeval tval = { 0, 0 };
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
-	char *buf = alloca(size);
-	int header = 1;
+	uint32_t *header = alloca(size);
+	char *buf = (char *)header;
 
 	while (bytes < size) {
 		for (i = 0, ret = 0; (i < 20) && (ret < 1); i++) {
@@ -262,9 +262,9 @@ static int _daemon_read(struct dm_event_fifos *fifos,
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
@@ -288,12 +288,13 @@ static int _daemon_write(struct dm_event_fifos *fifos,
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
@@ -323,8 +324,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 			}
 		} while (ret < 1);
 
-		ret = write(fifos->client, ((char *) buf) + bytes,
-			    size - bytes);
+		ret = write(fifos->client, buf + bytes, size - bytes);
 		if (ret < 0) {
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
-- 
1.7.3.1


