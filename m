From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:48 +0000 (UTC)
Subject: master - cleanup: dmeventd simplify restart message parsing
Message-ID: <20140418145548.41B7E61056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a1777302ff21bbc7cd81a1141f9c88c8fac2511
Commit:        7a1777302ff21bbc7cd81a1141f9c88c8fac2511
Parent:        1f701c7bf6dfd9893f7ebf18cb572de4fd3fcdde
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 15:17:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:53:29 2014 +0200

cleanup: dmeventd simplify restart message parsing

Since we already check every characted in the message,
skip extra callback to strlen, and do the implicit
message length checking.
---
 daemons/dmeventd/dmeventd.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 7decbcb..dcde7b1 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1918,7 +1918,6 @@ static void restart(void)
 	struct dm_event_daemon_message msg = { 0 };
 	int i, count = 0;
 	char *message;
-	int length;
 	int version;
 	const char *e;
 
@@ -1943,16 +1942,12 @@ static void restart(void)
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0))
 		goto bad;
 
-	message = msg.data;
-	message = strchr(message, ' ');
-	++ message;
-	length = strlen(msg.data);
-	for (i = 0; i < length; ++i) {
+	message = strchr(msg.data, ' ') + 1;
+	for (i = 0; msg.data[i]; ++i)
 		if (msg.data[i] == ';') {
 			msg.data[i] = 0;
 			++count;
 		}
-	}
 
 	if (!(_initial_registrations = dm_malloc(sizeof(char*) * (count + 1)))) {
 		fprintf(stderr, "Memory allocation registration failed.\n");


