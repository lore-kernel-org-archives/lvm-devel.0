From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:36 +0000 (UTC)
Subject: master - cleanup: use NULL for pointer reset
Message-ID: <20140325102336.F2B6860F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b2c08a6b30422cfa95da0348876f54b6f4cf6f
Commit:        c7b2c08a6b30422cfa95da0348876f54b6f4cf6f
Parent:        b714c7ebc618872abca1c6c7764c84c50b7fbcbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:18:53 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:58 2014 +0100

cleanup: use NULL for pointer reset

---
 daemons/dmeventd/libdevmapper-event.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index db9200f..1e723d7 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -372,14 +372,13 @@ int daemon_talk(struct dm_event_fifos *fifos,
 	if (!_daemon_write(fifos, msg)) {
 		stack;
 		dm_free(msg->data);
-		msg->data = 0;
+		msg->data = NULL;
 		return -EIO;
 	}
 
 	do {
-
 		dm_free(msg->data);
-		msg->data = 0;
+		msg->data = NULL;
 
 		if (!_daemon_read(fifos, msg)) {
 			stack;


