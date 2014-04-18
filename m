From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:35 +0000 (UTC)
Subject: master - cleanup: dmeventd simplify buffer write loop
Message-ID: <20140418145535.B781260E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0503af846607121e8f8019e6d0b2a98c204c2b72
Commit:        0503af846607121e8f8019e6d0b2a98c204c2b72
Parent:        13d05211d006a63035afea44fa8a4b1222130cd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 14:43:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:50:55 2014 +0200

cleanup: dmeventd simplify buffer write loop

---
 daemons/dmeventd/dmeventd.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 81da166..8dac207 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1417,17 +1417,17 @@ static int _client_write(struct dm_event_fifos *fifos,
 	if (msg->data)
 		memcpy(buf + 2 * sizeof(uint32_t), msg->data, msg->size);
 
-	errno = 0;
-	while (bytes < size && errno != EIO) {
+	while (bytes < size) {
 		do {
 			/* Watch client write FIFO to be ready for output. */
 			FD_ZERO(&fds);
 			FD_SET(fifos->server, &fds);
-		} while (select(fifos->server + 1, NULL, &fds, NULL, NULL) !=
-			 1);
+		} while (select(fifos->server + 1, NULL, &fds, NULL, NULL) != 1);
 
-		ret = write(fifos->server, buf + bytes, size - bytes);
-		bytes += ret > 0 ? ret : 0;
+		if ((ret = write(fifos->server, buf + bytes, size - bytes)) > 0)
+			bytes += ret;
+		else if (errno == EIO)
+			break;
 	}
 
 	return bytes == size;


