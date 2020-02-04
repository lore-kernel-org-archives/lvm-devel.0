From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:03 -0500
Subject: master - dmeventd: nicer error path for reading pipe
Message-ID: <56678.120020411225500979@us-mta-318.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4791d0f035e006e9541d27ef2c3dcb6ea561324a
Commit:        4791d0f035e006e9541d27ef2c3dcb6ea561324a
Parent:        91d16fc049ba2034708aa6a0bab5f548040dfd3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 16:41:28 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

dmeventd: nicer error path for reading pipe

When _daemon_read()/_client_read() fails during the read,
ensure memory allocated withing function is also release here
(so caller does not need to care). Also improve code readbility a bit
a for same functionality use more similar code.
---
 daemons/dmeventd/dmeventd.c           | 39 ++++++++++++++++-------------------
 daemons/dmeventd/libdevmapper-event.c | 35 ++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4fcb381..36a35ba 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1485,37 +1485,34 @@ static int _client_read(struct dm_event_fifos *fifos,
 		t.tv_usec = 0;
 		ret = select(fifos->client + 1, &fds, NULL, NULL, &t);
 
-		if (!ret && !bytes)	/* nothing to read */
-			return 0;
+		if (!ret && bytes)
+			continue; /* trying to finish read */
 
-		if (!ret)	/* trying to finish read */
-			continue;
-
-		if (ret < 0)	/* error */
-			return 0;
+		if (ret <= 0)	/* nothing to read */
+			goto bad;
 
 		ret = read(fifos->client, buf + bytes, size - bytes);
 		bytes += ret > 0 ? ret : 0;
-		if (header && (bytes == 2 * sizeof(uint32_t))) {
+		if (!msg->data && (bytes == 2 * sizeof(uint32_t))) {
 			msg->cmd = ntohl(header[0]);
-			size = msg->size = ntohl(header[1]);
 			bytes = 0;
-			if (!size)
-				break; /* No data -> error */
-			buf = msg->data = malloc(msg->size);
-			if (!buf)
-				break; /* No mem -> error */
-			header = 0;
+
+			if (!(size = msg->size = ntohl(header[1])))
+				break;
+
+			if (!(buf = msg->data = malloc(msg->size)))
+				goto bad;
 		}
 	}
 
-	if (bytes != size) {
-		free(msg->data);
-		msg->data = NULL;
-		return 0;
-	}
+	if (bytes == size)
+		return 1;
 
-	return 1;
+bad:
+	free(msg->data);
+	msg->data = NULL;
+
+	return 0;
 }
 
 /*
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 491374e..780d10d 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -237,16 +237,16 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 			ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
 			if (ret < 0 && errno != EINTR) {
 				log_error("Unable to read from event server.");
-				return 0;
+				goto bad;
 			}
 			if ((ret == 0) && (i > 4) && !bytes) {
 				log_error("No input from event server.");
-				return 0;
+				goto bad;
 			}
 		}
 		if (ret < 1) {
 			log_error("Unable to read from event server.");
-			return 0;
+			goto bad;
 		}
 
 		ret = read(fifos->server, buf + bytes, size);
@@ -255,25 +255,32 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 				continue;
 
 			log_error("Unable to read from event server.");
-			return 0;
+			goto bad;
 		}
 
 		bytes += ret;
-		if (header && (bytes == 2 * sizeof(uint32_t))) {
+		if (!msg->data && (bytes == 2 * sizeof(uint32_t))) {
 			msg->cmd = ntohl(header[0]);
-			msg->size = ntohl(header[1]);
-			buf = msg->data = malloc(msg->size);
-			size = msg->size;
 			bytes = 0;
-			header = 0;
+
+			if (!(size = msg->size = ntohl(header[1])))
+				break;
+
+			if (!(buf = msg->data = malloc(msg->size))) {
+				log_error("Unable to allocate message data.");
+				return 0;
+			}
 		}
 	}
 
-	if (bytes != size) {
-		free(msg->data);
-		msg->data = NULL;
-	}
-	return bytes == size;
+	if (bytes == size)
+		return 1;
+
+bad:
+	free(msg->data);
+	msg->data = NULL;
+
+	return 0;
 }
 
 /* Write message to daemon. */



