From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 14:05:13 +0000 (UTC)
Subject: master - cleanup: move var declaration
Message-ID: <20150818140513.8228260DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abb24370e9bee7e218c333a23c574fed0b4d95ff
Commit:        abb24370e9bee7e218c333a23c574fed0b4d95ff
Parent:        6e1feb0f736f4ebd819f25eb53f7f7ab74bb0678
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 15:47:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 16:05:04 2015 +0200

cleanup: move var declaration

---
 daemons/clvmd/clvmd.c            |    4 ++--
 libdaemon/server/daemon-server.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 99d01d0..c6d51bd 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -855,12 +855,12 @@ static void main_loop(int cmd_timeout)
 		int quorate = clops->is_quorate();
 		int client_count = 0;
 		int max_fd = 0;
+		struct local_client *lastfd = &local_client_head;
+		struct local_client *nextfd = local_client_head.next;
 
 		/* Wait on the cluster FD and all local sockets/pipes */
 		local_client_head.fd = clops->get_main_cluster_fd();
 		FD_ZERO(&in);
-		struct local_client *lastfd = &local_client_head;
-		struct local_client *nextfd = local_client_head.next;
 
 		for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
 			client_count++;
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 4f34aaf..d9d60d1 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -539,6 +539,7 @@ void daemon_start(daemon_state s)
 	log_state _log = { { 0 } };
 	thread_state _threads = { .next = NULL };
 	unsigned timeout_count = 0;
+	fd_set in;
 
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
@@ -623,7 +624,6 @@ void daemon_start(daemon_state s)
 
 	while (!_shutdown_requested && !failed) {
 		_reset_timeout(s);
-		fd_set in;
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
 		if (select(FD_SETSIZE, &in, NULL, NULL, _get_timeout(s)) < 0 && errno != EINTR)


