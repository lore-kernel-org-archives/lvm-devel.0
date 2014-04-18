From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:02 +0000 (UTC)
Subject: master - devmapper-event: always initialize timeout
Message-ID: <20140418145502.5E63760758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db0045dfc9403f1276682831ecbd4b83e2f72ebc
Commit:        db0045dfc9403f1276682831ecbd4b83e2f72ebc
Parent:        08e7de986cf2b4f8a05d6f1a7e996e4f298bfd1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 11:31:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:48 2014 +0200

devmapper-event: always initialize timeout

Before calling select, always set all struct members of timeout.
---
 daemons/dmeventd/libdevmapper-event.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index b6e2f0d..b8a0b90 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -291,7 +291,6 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 	uint32_t *header = alloca(size);
 	char *buf = (char *)header;
 	char drainbuf[128];
-	struct timeval tval = { 0, 0 };
 
 	header[0] = htonl(msg->cmd);
 	header[1] = htonl(msg->size);
@@ -299,9 +298,9 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 
 	/* drain the answer fifo */
 	while (1) {
+		struct timeval tval = { .tv_usec = 100 };
 		FD_ZERO(&fds);
 		FD_SET(fifos->server, &fds);
-		tval.tv_usec = 100;
 		ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
 		if ((ret < 0) && (errno != EINTR)) {
 			log_error("Unable to talk to event daemon");


