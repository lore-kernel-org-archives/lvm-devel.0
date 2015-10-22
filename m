From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:26 +0000 (UTC)
Subject: master - dmeventd: check for malloc return
Message-ID: <20151022213326.A58F0610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab6d16a8a5214ace81b9af346b9c065ec62fb04b
Commit:        ab6d16a8a5214ace81b9af346b9c065ec62fb04b
Parent:        09a62cca0ce259b207e85683dae47ac145590825
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 10:59:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:28:37 2015 +0200

dmeventd: check for malloc return

---
 daemons/dmeventd/dmeventd.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 56c504a..80e6b14 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1394,10 +1394,13 @@ static int _client_read(struct dm_event_fifos *fifos,
 		bytes += ret > 0 ? ret : 0;
 		if (header && (bytes == 2 * sizeof(uint32_t))) {
 			msg->cmd = ntohl(header[0]);
-			msg->size = ntohl(header[1]);
-			buf = msg->data = dm_malloc(msg->size);
-			size = msg->size;
+			size = msg->size = ntohl(header[1]);
 			bytes = 0;
+			if (!size)
+				break; /* No data -> error */
+			buf = msg->data = dm_malloc(msg->size);
+			if (!buf)
+				break; /* No mem -> error */
 			header = 0;
 		}
 	}


