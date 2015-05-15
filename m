From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:08 +0000 (UTC)
Subject: master - libdaemon: suggest daemon already running
Message-ID: <20150515183708.17F8C610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f653b123cf41751ebabfc910061c07e6e3c47149
Commit:        f653b123cf41751ebabfc910061c07e6e3c47149
Parent:        c0d30da60968e202d1e834dea28869a571bee991
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 15:43:43 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:31:36 2015 +0200

libdaemon: suggest daemon already running

when dm_creat_lockfile fails, it's probably due to
another instance is holding the same pid file...
---
 libdaemon/server/daemon-server.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index e1a9da9..6e497b8 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -568,8 +568,10 @@ void daemon_start(daemon_state s)
 		 * NB. Take care to not keep stale locks around. Best not exit(...)
 		 * after this point.
 		 */
-		if (dm_create_lockfile(s.pidfile) == 0)
+		if (dm_create_lockfile(s.pidfile) == 0) {
+			ERROR(&s, "Failed to acquire lock on %s. Already running?\n", s.pidfile);
 			exit(EXIT_ALREADYRUNNING);
+		}
 
 		(void) dm_prepare_selinux_context(NULL, 0);
 	}


