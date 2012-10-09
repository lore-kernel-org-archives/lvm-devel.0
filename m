From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 23:49:08 +0000 (UTC)
Subject: master - lvmetad: Only create pidfile when running as a daemon (no -f).
Message-ID: <20121009234908.8723E246B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19971492632fb2273bb2a991858e5cd5b48e2c5d
Commit:        19971492632fb2273bb2a991858e5cd5b48e2c5d
Parent:        329d10268cf64f6d2ddb801f0191f3112c76ef66
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 20:25:17 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 20:37:34 2012 +0200

lvmetad: Only create pidfile when running as a daemon (no -f).

Additionally, -f now makes -s mandatory, so the foreground (debugging) lvmetad
does not steal the system-wide socket accidentally.
---
 daemons/lvmetad/lvmetad-core.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 4741649..ff861a2 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1060,6 +1060,7 @@ int main(int argc, char *argv[])
 	daemon_state s = { .private = NULL };
 	lvmetad_state ls;
 	int _restart = 0;
+	int _socket_override = 1;
 
 	s.name = "lvmetad";
 	s.private = &ls;
@@ -1067,8 +1068,10 @@ int main(int argc, char *argv[])
 	s.daemon_fini = fini;
 	s.handler = handler;
 	s.socket_path = getenv("LVM_LVMETAD_SOCKET");
-	if (!s.socket_path)
+	if (!s.socket_path) {
+		_socket_override = 0;
 		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
+	}
 	s.pidfile = LVMETAD_PIDFILE;
 	s.protocol = "lvmetad";
 	s.protocol_version = 1;
@@ -1094,6 +1097,7 @@ int main(int argc, char *argv[])
 			break;
 		case 's': // --socket
 			s.socket_path = optarg;
+			_socket_override = 1;
 			break;
 		case 'V':
 			printf("lvmetad version 0\n");
@@ -1101,6 +1105,13 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (s.foreground && !_socket_override) {
+		fprintf(stderr, "A socket path (-s) is required in foreground mode.");
+		exit(2);
+	} else {
+		s.pidfile = NULL;
+	}
+
 	daemon_start(s);
 	return 0;
 }


