From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:27:59 +0000 (UTC)
Subject: master - devmapper-event: always initialize timeout
Message-ID: <20140430082759.339C760DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=816cc94ac1a8a1048a5f737e9bc3f9e251773bf7
Commit:        816cc94ac1a8a1048a5f737e9bc3f9e251773bf7
Parent:        675fcfe9b7f5d624f8b9e45bc61869ef0ff830b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 13:23:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:29 2014 +0200

devmapper-event: always initialize timeout

Always pass fully initialized timeval struct to select.
---
 daemons/dmeventd/libdevmapper-event.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 51c925f..57185b9 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -224,7 +224,6 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 	unsigned bytes = 0;
 	int ret, i;
 	fd_set fds;
-	struct timeval tval = { 0, 0 };
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
 	uint32_t *header = alloca(size);
 	char *buf = (char *)header;
@@ -232,11 +231,10 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 	while (bytes < size) {
 		for (i = 0, ret = 0; (i < 20) && (ret < 1); i++) {
 			/* Watch daemon read FIFO for input. */
+			struct timeval tval = { .tv_sec = 1 };
 			FD_ZERO(&fds);
 			FD_SET(fifos->server, &fds);
-			tval.tv_sec = 1;
-			ret = select(fifos->server + 1, &fds, NULL, NULL,
-				     &tval);
+			ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
 			if (ret < 0 && errno != EINTR) {
 				log_error("Unable to read from event server");
 				return 0;


