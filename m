From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:40 +0000 (UTC)
Subject: master - lvmpolld: add long option variants for all short ones
Message-ID: <20150515183740.00F6C602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d34de2d91270a1f3cd427e1dab4a6df8789de7e5
Commit:        d34de2d91270a1f3cd427e1dab4a6df8789de7e5
Parent:        b91e1ea95ec3b1196eade0bbd9f539bf3c7c460a
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 19:18:32 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:34 2015 +0200

lvmpolld: add long option variants for all short ones

---
 daemons/lvmpolld/lvmpolld-core.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 5385a04..a141d77 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -65,17 +65,17 @@ static const char *_strerror_r(int errnum, struct lvmpolld_thread_data *data)
 static void _usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n"
+		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path] [-B path] [-p path] [-t secs]\n"
 		"%s --dump [-s path]\n"
-		"   -V       Show version info\n"
-		"   -h       Show this help information\n"
-		"   -f       Don't fork, run in the foreground\n"
-		"   --dump   Dump full lvmpolld state\n"
-		"   -l       Logging message level (-l {all|wire|debug})\n"
-		"   -p       Set path to the pidfile\n"
-		"   -s       Set path to the communication socket\n"
-		"   -B       Path to lvm2 binary\n"
-		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog, prog);
+		"   -V|--version     Show version info\n"
+		"   -h|--help        Show this help information\n"
+		"   -f|--foreground  Don't fork, run in the foreground\n"
+		"   --dump           Dump full lvmpolld state\n"
+		"   -l|--log         Logging message level (-l {all|wire|debug})\n"
+		"   -p|--pidfile     Set path to the pidfile\n"
+		"   -s|--socket      Set path to the communication socket\n"
+		"   -B|--binary      Path to lvm2 binary\n"
+		"   -t|--timeout     Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog, prog);
 }
 
 static int _init(struct daemon_state *s)
@@ -882,8 +882,13 @@ static struct option long_options[] = {
 	{"dump",	no_argument,		&action_idx,	ACTION_DUMP }, /* or an option_index ? */
 
 	/* other options */
+	{"binary",	required_argument,	0,		'B' },
+	{"foreground",	no_argument,		0,		'f' },
 	{"help",	no_argument,		0,		'h' },
+	{"log",		required_argument,	0,		'l' },
+	{"pidfile",	required_argument,	0,		'p' },
 	{"socket",	required_argument,	0,		's' },
+	{"timeout",	required_argument,	0,		't' },
 	{"version",	no_argument,		0,		'V' },
 	{0,		0,			0,		0 }
 };
@@ -928,21 +933,21 @@ int main(int argc, char *argv[])
 			ls.lvm_binary = optarg;
 			server = 1;
 			break;
-		case 'V':
+		case 'V': /* --version */
 			printf("lvmpolld version: " LVM_VERSION "\n");
 			exit(EXIT_SUCCESS);
-		case 'f':
+		case 'f': /* --foreground */
 			s.foreground = 1;
 			server = 1;
 			break;
-		case 'h':
+		case 'h': /* --help */
 			_usage(argv[0], stdout);
 			exit(EXIT_SUCCESS);
-		case 'l':
+		case 'l': /* --log */
 			ls.log_config = optarg;
 			server = 1;
 			break;
-		case 'p':
+		case 'p': /* --pidfile */
 			s.pidfile = optarg;
 			server = 1;
 			break;


