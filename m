From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Jun 2014 10:04:23 +0000 (UTC)
Subject: master - cleanup: rename variable wait
Message-ID: <20140619100423.4782560D6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b193a3b09ffd28b7a170acc74095a05fa8fe2f8e
Commit:        b193a3b09ffd28b7a170acc74095a05fa8fe2f8e
Parent:        00af0d13c91d24952ec0542b5fe8323835d59051
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 19 11:33:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 19 12:02:48 2014 +0200

cleanup: rename variable wait

With older system headers (sys/wait.h) this shadows declaration.
---
 libdaemon/server/daemon-server.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0ea3f69..8ed3cce 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -490,13 +490,13 @@ static int handle_connect(daemon_state s)
 	return 1;
 }
 
-static void reap(daemon_state s, int wait)
+static void reap(daemon_state s, int waiting)
 {
 	thread_state *last = s.threads, *ts = last->next;
 	void *rv;
 
 	while (ts) {
-		if (wait || !ts->active) {
+		if (waiting || !ts->active) {
 			pthread_join(ts->client.thread_id, &rv);
 			last->next = ts->next;
 			dm_free(ts);


