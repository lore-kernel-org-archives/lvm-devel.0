From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Jan 2016 22:40:31 +0000 (UTC)
Subject: master - lvmlockd: fix exit code
Message-ID: <20160113224031.B7E4960E28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b1f42b49005665e669b52f78864cad59d81f64b
Commit:        1b1f42b49005665e669b52f78864cad59d81f64b
Parent:        be1b1f3d8941543bcde2f42e65ed0f22fd07b122
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 13 14:44:01 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 13 16:40:02 2016 -0600

lvmlockd: fix exit code

libdaemon uses 1 for success
---
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index efb0180..c4def0b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -5935,7 +5935,7 @@ static int main_loop(daemon_state *ds_arg)
 	close_client_thread();
 	closelog();
 	daemon_close(lvmetad_handle);
-	return 0;
+	return 1; /* libdaemon uses 1 for success */
 }
 
 static void usage(char *prog, FILE *file)


