From: okozina <okozina@fedoraproject.org>
Date: Mon,  2 Feb 2015 09:21:12 +0000 (UTC)
Subject: master - libdaemon: set CLOEXEC on client socket fd
Message-ID: <20150202092112.49FCD60324@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9dd81df8b25a51c919679b5f1c4e5fea9269972b
Commit:        9dd81df8b25a51c919679b5f1c4e5fea9269972b
Parent:        99c443facce33d2c666b0e043d9e8a6bd1cb40a2
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Nov 12 09:50:59 2014 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Feb 2 10:15:52 2015 +0100

libdaemon: set CLOEXEC on client socket fd

---
 libdaemon/server/daemon-server.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index a8afcc1..3dffdbb 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -470,6 +470,9 @@ static int handle_connect(daemon_state s)
 	if (client.socket_fd < 0)
 		return 0;
 
+	 if (fcntl(client.socket_fd, F_SETFD, FD_CLOEXEC))
+		WARN(&s, "setting CLOEXEC on client socket fd %d failed", client.socket_fd);
+
 	if (!(ts = dm_malloc(sizeof(thread_state)))) {
 		if (close(client.socket_fd))
 			perror("close");


