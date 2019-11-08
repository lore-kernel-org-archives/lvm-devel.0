From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:15:01 -0500
Subject: stable-2.02 - daemons: check for non-zero thread_id
Message-ID: <201911081415.xA8EF1l4008326@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbdcdc12b2240e00f6ab8ff105e954629412b234
Commit:        bbdcdc12b2240e00f6ab8ff105e954629412b234
Parent:        e9b2148dab3a1f501637b628978c93be4d2be086
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:10:49 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 15:12:51 2019 +0100

daemons: check for non-zero thread_id

Do not call pthread_join if thread_id would be 0.
---
 libdaemon/server/daemon-server.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index aa9ff2a..9408440 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -560,7 +560,8 @@ static void _reap(daemon_state s, int waiting)
 
 	while (ts) {
 		if (waiting || !ts->active) {
-			if ((errno = pthread_join(ts->client.thread_id, &rv)))
+			if (ts->client.thread_id &&
+			    (errno = pthread_join(ts->client.thread_id, &rv)))
 				ERROR(&s, "pthread_join failed: %s", strerror(errno));
 			last->next = ts->next;
 			dm_free(ts);


