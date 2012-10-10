From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:56:10 +0000 (UTC)
Subject: master - lvmetad: Fix help output (flags and their meaning).
Message-ID: <20121010195610.D4939236C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ba9fb4019f737783606d886b96db59570850937
Commit:        2ba9fb4019f737783606d886b96db59570850937
Parent:        14283662b9a1595e231f31bb7165a18d93d66cc2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 14:38:25 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 21:55:24 2012 +0200

lvmetad: Fix help output (flags and their meaning).

---
 daemons/lvmetad/lvmetad-core.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 22625c5..8a1378a 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1046,11 +1046,11 @@ static int fini(daemon_state *s)
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-d] [-d] [-d] [-f]\n\n"
+		"%s [-V] [-h] [-d [info[,debug[,wire]]]] [-f] [-s path]\n\n"
 		"   -V       Show version of lvmetad\n"
 		"   -h       Show this help information\n"
-		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
-		"   -R       Replace a running lvmetad instance, loading its data\n"
+		"   -s       Set path to the socket to listen on\n"
+		"   -d       Log messages to stderr (-d info,wire,debug)\n"
 		"   -f       Don't fork, run in the foreground\n\n", prog);
 }
 
@@ -1078,7 +1078,7 @@ int main(int argc, char *argv[])
 	ls.debug_config = "";
 
 	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVd:Rs:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVd:s:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1086,9 +1086,6 @@ int main(int argc, char *argv[])
 		case '?':
 			usage(argv[0], stderr);
 			exit(0);
-		case 'R':
-			_restart++;
-			break;
 		case 'f':
 			s.foreground = 1;
 			break;


