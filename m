From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:58 +0000 (UTC)
Subject: master - cleanup: static with _
Message-ID: <20151013140358.D2F1561207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=903e9af1b2c1972a897b7dd61e6e463a03cad648
Commit:        903e9af1b2c1972a897b7dd61e6e463a03cad648
Parent:        e261af52eb26c22aebd62cdbd8bb79c195274ee9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 8 11:59:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:16:56 2015 +0200

cleanup: static with _

Document ? is printing to stderr.
---
 daemons/dmeventd/dmeventd.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e34c4c1..f775fb9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -931,7 +931,7 @@ static int _lookup_symbol(void *dl, void **symbol, const char *name)
 	return 0;
 }
 
-static int lookup_symbols(void *dl, struct dso_data *data)
+static int _lookup_symbols(void *dl, struct dso_data *data)
 {
 	return _lookup_symbol(dl, (void *) &data->process_event,
 			     "process_event") &&
@@ -962,7 +962,7 @@ static struct dso_data *_load_dso(struct message_data *data)
 		return NULL;
 	}
 
-	if (!(lookup_symbols(dl, ret))) {
+	if (!(_lookup_symbols(dl, ret))) {
 		_free_dso_data(ret);
 		dlclose(dl);
 		return NULL;
@@ -1931,7 +1931,7 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
 	return 1;
 }
 
-static void restart(void)
+static void _restart_dmeventd(void)
 {
 	struct dm_event_fifos fifos = {
 		.server = -1,
@@ -2048,13 +2048,14 @@ bad:
 	exit(EXIT_FAILURE);
 }
 
-static void usage(char *prog, FILE *file)
+static void _usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
 		"%s [-d [-d [-d]]] [-f] [-h] [-R] [-V] [-?]\n\n"
 		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
 		"   -f       Don't fork, run in the foreground\n"
-		"   -h -?    Show this help information\n"
+		"   -h       Show this help information\n"
+		"   -?       Show this help information on stderr\n"
 		"   -R       Restart dmeventd\n"
 		"   -V       Show version of dmeventd\n\n", prog);
 }
@@ -2077,10 +2078,10 @@ int main(int argc, char *argv[])
 	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
 		switch (opt) {
 		case 'h':
-			usage(argv[0], stdout);
+			_usage(argv[0], stdout);
 			exit(EXIT_SUCCESS);
 		case '?':
-			usage(argv[0], stderr);
+			_usage(argv[0], stderr);
 			exit(EXIT_SUCCESS);
 		case 'R':
 			_restart++;
@@ -2106,7 +2107,7 @@ int main(int argc, char *argv[])
 		perror("Cannot set LC_ALL to C");
 
 	if (_restart)
-		restart();
+		_restart_dmeventd();
 
 #ifdef __linux__
 	_systemd_activation = _systemd_handover(&fifos);


