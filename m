From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Oct 2012 12:08:42 +0000 (UTC)
Subject: master - lvmetad: Fix the -f pidfile (non-)creation logic.
Message-ID: <20121010120842.E53ADA0D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=622fb968a22d5b2c6ba3dcd9155743adfe5dec8c
Commit:        622fb968a22d5b2c6ba3dcd9155743adfe5dec8c
Parent:        6e523f01d07d7d819c2f0d9b1595e628ddffea24
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 12:32:24 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 13:53:21 2012 +0200

lvmetad: Fix the -f pidfile (non-)creation logic.

---
 daemons/lvmetad/lvmetad-core.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ff861a2..22625c5 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1105,11 +1105,13 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (s.foreground && !_socket_override) {
-		fprintf(stderr, "A socket path (-s) is required in foreground mode.");
-		exit(2);
-	} else {
-		s.pidfile = NULL;
+	if (s.foreground) {
+		if (!_socket_override) {
+			fprintf(stderr, "A socket path (-s) is required in foreground mode.");
+			exit(2);
+		} else {
+			s.pidfile = NULL;
+		}
 	}
 
 	daemon_start(s);


