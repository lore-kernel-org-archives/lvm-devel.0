From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:45 +0000 (UTC)
Subject: master - dmeventd: fix test for select return value
Message-ID: <20140819141845.24C6A6020C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d7f260f92329d394ece7447e58a46cd26d9a5a9
Commit:        6d7f260f92329d394ece7447e58a46cd26d9a5a9
Parent:        84860fd54f05ca24c389ee60c4aef6903ae227ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:20:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

dmeventd: fix test for select return value

Do not call read when select return -1 && EINTR.
Also check for return valuer from read() and
abort write function when unexpected error happens.
---
 daemons/dmeventd/libdevmapper-event.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 6b7338f..6e41b0a 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -297,13 +297,21 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		FD_ZERO(&fds);
 		FD_SET(fifos->server, &fds);
 		ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
-		if ((ret < 0) && (errno != EINTR)) {
+		if (ret < 0) {
+			if (errno == EINTR)
+				continue;
 			log_error("Unable to talk to event daemon");
 			return 0;
 		}
 		if (ret == 0)
 			break;
 		ret = read(fifos->server, drainbuf, sizeof(drainbuf));
+		if (ret < 0) {
+			if ((errno == EINTR) || (errno == EAGAIN))
+				continue;
+			log_error("Unable to talk to event daemon");
+			return 0;
+		}
 	}
 
 	while (bytes < size) {


