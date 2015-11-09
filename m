From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:01 +0000 (UTC)
Subject: master - libdevmapper-event: fix fifo leak on error path
Message-ID: <20151109092801.35334601B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b857bfdc60668c3cdeeb6c11ffe32def0371a39
Commit:        8b857bfdc60668c3cdeeb6c11ffe32def0371a39
Parent:        459b3db61e14a9ac28fc9fd4d029accd6dee6330
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:10:38 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:00:13 2015 +0100

libdevmapper-event: fix fifo leak on error path

Coverity: when _init_client() fails, client fifo could have
been already openned and needs to be closed on error path.
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 113a4bb..9e6a849 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.111 - 
 ====================================
+  Add missing fifo close when failed to initialize client connection.
 
 Version 1.02.110 - 30th October 2015
 ====================================
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index ee4a35c..9b3b424 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -587,8 +587,8 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
 	};
 
 	if (!_init_client(dmeventd_path, &fifos)) {
-		stack;
-		return -ESRCH;
+		ret = -ESRCH;
+		goto_out;
 	}
 
 	ret = daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
@@ -598,7 +598,7 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
 
 	if (!ret)
 		ret = daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
-
+out:
 	/* what is the opposite of init? */
 	fini_fifos(&fifos);
 


