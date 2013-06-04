From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:23 +0000 (UTC)
Subject: dev-mornfall-activate - dmeventd: cleanup
Message-ID: <20130604192423.E690060E7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bee3f4b930dc38142b218d0e097388ffa36c586c
Commit:        bee3f4b930dc38142b218d0e097388ffa36c586c
Parent:        8184a57c2b18d606fb533a87319768c90000e308
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 20:50:46 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:02:43 2013 +0200

dmeventd: cleanup

Drop unneeded reset of data pointer to NULL, since this if() code path
is executed when data is NULL.
---
 daemons/dmeventd/dmeventd.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index c3d9671..95fb837 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1454,10 +1454,8 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO",
                                                 DM_EVENT_PROTOCOL_VERSION);
 			dm_free(answer);
-		} else {
+		} else
 			msg->size = 0;
-			msg->data = NULL;
-		}
 	} else if (msg->cmd != DM_EVENT_CMD_ACTIVE && !_parse_message(&message_data)) {
 		stack;
 		ret = -EINVAL;


