From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:41 +0000 (UTC)
Subject: master - dmeventd: no registering of 0 event mask
Message-ID: <20151022213341.5C9F9610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9488cbdd0bd3a410ec1e77454c6a18bdfe8612f5
Commit:        9488cbdd0bd3a410ec1e77454c6a18bdfe8612f5
Parent:        fa9e41d2e373e7e8017b158f60eb3e77a582f532
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 11:10:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:33:19 2015 +0200

dmeventd: no registering of 0 event mask

Whenever user tries to register 0 mask report this as EINVAL.
---
 daemons/dmeventd/dmeventd.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 80e6b14..f2c417c 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1472,6 +1472,8 @@ static int _handle_request(struct dm_event_daemon_message *msg,
 {
 	switch (msg->cmd) {
 	case DM_EVENT_CMD_REGISTER_FOR_EVENT:
+		if (!message_data->events_field)
+			return -EINVAL;
 		return _register_for_event(message_data);
 	case DM_EVENT_CMD_UNREGISTER_FOR_EVENT:
 		return _unregister_for_event(message_data);


