From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Sep 2019 07:40:32 -0400
Subject: stable-2.02 - lvmetad: fix timeout on shutdown
Message-ID: <201909301140.x8UBeWZ0002685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61358d92cbf202dbb483d63a63d5adf0463bb934
Commit:        61358d92cbf202dbb483d63a63d5adf0463bb934
Parent:        5d6bf1efb225b964bfff398277e68345acdac1d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 25 17:22:49 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 30 13:39:44 2019 +0200

lvmetad: fix timeout on shutdown

When lvmetad is going to be shutdown - there were 2 issue:
If there was endless stream of command contacting lvmetad - the process
would never finish - so now when we recieved  SIGTERM - we are no longer
accepting new connections and we just wait till the existing ones are
finished.

2nd. issue is that actually when we are waiting for finish of all client
threads - we basically want an usleep() and check if all threads
are already finished -  proper solution would be to singal from a thread
there is some work to do for master thread - but that would be a bigger
change and since lvmetad is no longer developed - keep the change
minimal and just use pselect() as our '1sec.' sleeping call once
we are in 'shutdown' mode.

Reported-by: wangjufeng at huawei.com
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3811c5c..80ba83d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Fix lvmetad shutdown and avoid lenghty timeouts when rebooting system.
   Prevent creating VGs with PVs with different logical block sizes.
   Pvmove runs in exlusively activating mode for exclusively active LVs.
   Activate thin-pool layered volume as 'read-only' device.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index bc58f7b..62f403a 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -89,6 +89,13 @@ static int _is_idle(daemon_state s)
 
 static struct timespec *_get_timeout(daemon_state s)
 {
+	static struct timespec _tm = { 0 };
+
+	if (_shutdown_requested) {
+		_tm.tv_sec = 1;
+		return &_tm;
+	}
+
 	return s.idle ? s.idle->ptimeout : NULL;
 }
 
@@ -506,7 +513,7 @@ static int _handle_connect(daemon_state s)
 	socklen_t sl = sizeof(sockaddr);
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
-	if (client.socket_fd < 0) {
+	if (client.socket_fd < 0 || _shutdown_requested) {
 		if (errno != EAGAIN || !_shutdown_requested)
 			ERROR(&s, "Failed to accept connection: %s.", strerror(errno));
 		return 0;
@@ -672,7 +679,7 @@ void daemon_start(daemon_state s)
 			continue;
 		}
 
-		if (FD_ISSET(s.socket_fd, &in)) {
+		if (!_shutdown_requested && FD_ISSET(s.socket_fd, &in)) {
 			timeout_count = 0;
 			_handle_connect(s);
 		}


