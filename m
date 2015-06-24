From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 24 Jun 2015 17:17:10 +0000 (UTC)
Subject: master - libdaemon: add comment about using main and init
Message-ID: <20150624171710.1A01B6106A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7760665fb8f4a85a244a9751a0a1d1cc46c157dc
Commit:        7760665fb8f4a85a244a9751a0a1d1cc46c157dc
Parent:        44c7bc0262b6719efe75ecb6eb32eaab359e5779
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 24 12:16:26 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 24 12:16:26 2015 -0500

libdaemon: add comment about using main and init

---
 libdaemon/server/daemon-server.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index ef0b964..8eda8cf 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -604,6 +604,11 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
+	/*
+	 * Use daemon_main for daemon-specific init and polling, or
+	 * use daemon_init for daemon-specific init and generic lib polling.
+	 */
+
 	if (s.daemon_main) {
 		if (!s.daemon_main(&s))
 			failed = 1;


