From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:33 +0000 (UTC)
Subject: master - lvmetad: cleanup
Message-ID: <20130421211633.4583817AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=377e06b0f8ea10c222a0d38472dbbb05fde1f2d3
Commit:        377e06b0f8ea10c222a0d38472dbbb05fde1f2d3
Parent:        bee3f4b930dc38142b218d0e097388ffa36c586c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 20:52:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:02:43 2013 +0200

lvmetad: cleanup

Move individual assignments to simplier structure setup.
---
 daemons/lvmetad/lvmetad-core.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index bbad69c..4f7bf59 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1168,23 +1168,24 @@ static void usage(char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	signed char opt;
-	daemon_state s = { .private = NULL };
 	lvmetad_state ls;
 	int _socket_override = 1;
+	daemon_state s = {
+		.daemon_fini = fini,
+		.daemon_init = init,
+		.handler = handler,
+		.name = "lvmetad",
+		.pidfile = LVMETAD_PIDFILE,
+		.private = &ls,
+		.protocol = "lvmetad",
+		.protocol_version = 1,
+		.socket_path = getenv("LVM_LVMETAD_SOCKET"),
+	};
 
-	s.name = "lvmetad";
-	s.private = &ls;
-	s.daemon_init = init;
-	s.daemon_fini = fini;
-	s.handler = handler;
-	s.socket_path = getenv("LVM_LVMETAD_SOCKET");
 	if (!s.socket_path) {
 		_socket_override = 0;
 		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
 	}
-	s.pidfile = LVMETAD_PIDFILE;
-	s.protocol = "lvmetad";
-	s.protocol_version = 1;
 	ls.log_config = "";
 
 	// use getopt_long
@@ -1216,9 +1217,9 @@ int main(int argc, char *argv[])
 		if (!_socket_override) {
 			fprintf(stderr, "A socket path (-s) is required in foreground mode.");
 			exit(2);
-		} else {
-			s.pidfile = NULL;
 		}
+
+		s.pidfile = NULL;
 	}
 
 	daemon_start(s);


