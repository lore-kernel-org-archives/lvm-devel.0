From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jul 2012 14:55:55 +0000 (UTC)
Subject: master - daemon-server: fix error message on daemon shutdown
Message-ID: <20120719145555.9277E173B@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d5ae472e5226f87175d51722fb5942c531bb8bb
Commit:        8d5ae472e5226f87175d51722fb5942c531bb8bb
Parent:        48367c5be9b39cd118caeb6b8e554be347d2fd8c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 19 16:45:08 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 19 16:45:08 2012 +0200

daemon-server: fix error message on daemon shutdown

If a daemon (like lvmetad that is using common daemon-server code)
received a kill signal that was supposed to shut the daemon down,
a spurious message was issued: "Failed to handle a client connection".

This happened if the kill signal came just in the middle of waiting
for a client request in "select" - the request that was supposed to
be handled was blank at that moment of course.
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 925ae23..4f23c39 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Do not issue "Failed to handle a client connection" error if lvmetad killed.
   Support changing of discard and zeroing for thin pool.
   Report used discard for thin pool and volume.
   Add support for controlling discard behavior of thin pool.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 65b28e4..5ca9231 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -510,7 +510,7 @@ void daemon_start(daemon_state s)
 		if (select(FD_SETSIZE, &in, NULL, NULL, NULL) < 0 && errno != EINTR)
 			perror("select error");
 		if (FD_ISSET(s.socket_fd, &in))
-			if (!handle_connect(s))
+			if (!_shutdown_requested && !handle_connect(s))
 				syslog(LOG_ERR, "Failed to handle a client connection.");
 	}
 


