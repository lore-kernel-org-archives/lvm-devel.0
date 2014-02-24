From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:16 +0000 (UTC)
Subject: master - cleanup: extend struct init usage
Message-ID: <20140224201716.ACBB760FC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=408e276a615faf22e829cea385738dce02edae26
Commit:        408e276a615faf22e829cea385738dce02edae26
Parent:        0118d6aa48c5d69b7b5f264f6f93ddb51a4379ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 20:28:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:35 2014 +0100

cleanup: extend struct init usage

---
 daemons/lvmetad/lvmetad-core.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index eefbf1d..ab0573f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1189,7 +1189,7 @@ static int fini(daemon_state *s)
 	return 1;
 }
 
-static void usage(char *prog, FILE *file)
+static void usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
 		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n\n"
@@ -1204,27 +1204,19 @@ static void usage(char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	signed char opt;
-	lvmetad_state ls;
+	lvmetad_state ls = { .log_config = "" };
 	daemon_state s = {
 		.daemon_fini = fini,
 		.daemon_init = init,
 		.handler = handler,
 		.name = "lvmetad",
-		.pidfile = getenv("LVM_LVMETAD_PIDFILE"),
+		.pidfile = getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE,
 		.private = &ls,
 		.protocol = "lvmetad",
 		.protocol_version = 1,
-		.socket_path = getenv("LVM_LVMETAD_SOCKET"),
+		.socket_path = getenv("LVM_LVMETAD_SOCKET") ? : LVMETAD_SOCKET,
 	};
 
-	if (!s.pidfile)
-		s.pidfile = LVMETAD_PIDFILE;
-
-	if (!s.socket_path)
-		s.socket_path = LVMETAD_SOCKET;
-
-	ls.log_config = "";
-
 	// use getopt_long
 	while ((opt = getopt(argc, argv, "?fhVl:p:s:")) != EOF) {
 		switch (opt) {
@@ -1253,5 +1245,6 @@ int main(int argc, char *argv[])
 	}
 
 	daemon_start(s);
+
 	return 0;
 }


