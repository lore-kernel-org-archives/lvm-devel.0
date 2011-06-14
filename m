From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Jun 2011 02:36:39 -0000
Subject: LVM2/daemons/lvmetad lvmetad-client.h Makefile ...
Message-ID: <20110614023639.13104.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-14 02:36:38

Modified files:
	daemons/lvmetad: lvmetad-client.h 
Added files:
	daemons/lvmetad: Makefile lvmetad-core.c testclient.c 

Log message:
	Add a skeleton for lvmetad, a test client, and a temporary Makefile to build
	them. These are currently mostly for testing the daemon-common code. LVMetaD
	functionality is expected to trickle in soon though.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/daemons/lvmetad/Makefile,v  -->  standard output
revision 1.1
--- LVM2/daemons/lvmetad/Makefile
+++ -	2011-06-14 02:36:38.688218000 +0000
@@ -0,0 +1,26 @@
+#
+# WARNING
+#
+# This is a temporary Makefile. You need to edit the IPATH/LPATH variables to
+# point to build-dir of LVM2. You may then just run "make" to build the lvmetad
+# binary and the test client.
+#
+
+SHARED = ../common/daemon-shared.c
+CLIENT = ../common/daemon-client.c $(SHARED)
+SERVER = ../common/daemon-server.c $(SHARED)
+SHARED_H = ../common/daemon-shared.h
+CLIENT_H = ../common/daemon-client.h $(SHARED_H)
+SERVER_H = ../common/daemon-server.h $(SHARED_H)
+
+LIBS = -ldevmapper -lpthread
+IPATH = -I../common -I/srv/build/lvm2/cvs-lvmetad/default/include
+LPATH = -L/srv/build/lvm2/cvs-lvmetad/default/libdm
+
+all: testclient lvmetad
+
+testclient: testclient.c $(CLIENT_H) $(CLIENT)
+	gcc -g testclient.c $(CLIENT) $(IPATH) $(LPATH) $(LIBS) -o testclient
+
+lvmetad: lvmetad-core.c ../common/daemon-server.c ../common/daemon-server.h ../common/daemon-shared.h ../common/daemon-shared.c
+	gcc -g lvmetad-core.c $(SERVER) $(IPATH) $(LPATH) $(LIBS) -o lvmetad
/cvs/lvm2/LVM2/daemons/lvmetad/lvmetad-core.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/lvmetad/lvmetad-core.c
+++ -	2011-06-14 02:36:38.790300000 +0000
@@ -0,0 +1,76 @@
+#include "metadata-exported.h"
+#include "../common/daemon-server.h"
+
+typedef struct {
+} lvmetad_state;
+
+static response handler(daemon_state s, client_handle h, request r)
+{
+	response res;
+	fprintf(stderr, "handling client request: %s\n", r.buffer);
+	res.error = 1;
+	res.buffer = strdup("hey hey.\n\n");
+	return res;
+}
+
+static int setup_post(daemon_state *s)
+{
+	lvmetad_state *ls = s->private;
+
+	/* if (ls->initial_registrations)
+	   _process_initial_registrations(ds->initial_registrations); */
+
+	return 1;
+}
+
+static void usage(char *prog, FILE *file)
+{
+	fprintf(file, "Usage:\n"
+		"%s [-V] [-h] [-d] [-d] [-d] [-f]\n\n"
+		"   -V       Show version of lvmetad\n"
+		"   -h       Show this help information\n"
+		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
+		"   -R       Replace a running lvmetad instance, loading its data\n"
+		"   -f       Don't fork, run in the foreground\n\n", prog);
+}
+
+int main(int argc, char *argv[])
+{
+	signed char opt;
+	daemon_state s;
+	lvmetad_state ls;
+	int _restart = 0;
+
+	s.private = &ls;
+	s.setup_post = setup_post;
+	s.handler = handler;
+	s.socket_path = "/var/run/lvm/lvmetad.socket";
+	s.pidfile = "/var/run/lvm/lvmetad.pid";
+
+	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
+		switch (opt) {
+		case 'h':
+			usage(argv[0], stdout);
+			exit(0);
+		case '?':
+			usage(argv[0], stderr);
+			exit(0);
+		case 'R':
+			_restart++;
+			break;
+		case 'f':
+			s.foreground = 1;
+			break;
+		case 'd':
+			s.log_level++;
+			break;
+		case 'V':
+			printf("lvmetad version 0\n");
+			exit(1);
+			break;
+		}
+	}
+
+	daemon_start(s);
+	return 0;
+}
/cvs/lvm2/LVM2/daemons/lvmetad/testclient.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/lvmetad/testclient.c
+++ -	2011-06-14 02:36:38.888671000 +0000
@@ -0,0 +1,12 @@
+#include "lvmetad-client.h"
+
+int main() {
+	daemon_handle h = lvmetad_open();
+	daemon_request rq = { .buffer= "hello worldn\n" };
+	int i;
+	for (i = 0; i < 5; ++i ) {
+		daemon_reply reply = daemon_send(h, rq);
+		fprintf(stderr, "daemon says: %s\n", reply.buffer);
+	}
+	return 0;
+}
--- LVM2/daemons/lvmetad/lvmetad-client.h	2011/06/02 08:58:05	1.2
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2011/06/14 02:36:38	1.3
@@ -16,6 +16,7 @@
 #define _LVM_LVMETAD_CLIENT_H
 
 #include "daemon-client.h"
+#include "metadata-exported.h"
 
 /* Different types of replies we may get from lvmetad. */
 


