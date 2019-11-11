From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:25 -0500
Subject: master - daemons: check for non-zero thread_id
Message-ID: <54930.119111116462300640@us-mta-386.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cc13335998558b84750fc2ba25c8b9f7b053746
Commit:        1cc13335998558b84750fc2ba25c8b9f7b053746
Parent:        cc865749ae443cca276ac411f302fd8989a843ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:10:49 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

daemons: check for non-zero thread_id

Do not call pthread_join if thread_id would be 0.
---
 libdaemon/server/daemon-server.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index b45c0e5..66e43d4 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -551,7 +551,8 @@ static void _reap(daemon_state s, int waiting)
 
 	while (ts) {
 		if (waiting || !ts->active) {
-			if ((errno = pthread_join(ts->client.thread_id, &rv)))
+			if (ts->client.thread_id &&
+			    (errno = pthread_join(ts->client.thread_id, &rv)))
 				ERROR(&s, "pthread_join failed: %s", strerror(errno));
 			last->next = ts->next;
 			free(ts);



