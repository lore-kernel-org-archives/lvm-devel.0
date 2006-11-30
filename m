From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 30 Nov 2006 09:44:07 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20061130094407.12204.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-11-30 09:44:07

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Add -T (startup timeout) switch to clvmd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.507&r2=1.508
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2006/11/23 17:23:14	1.507
+++ LVM2/WHATS_NEW	2006/11/30 09:44:06	1.508
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Add -T (startup timeout) switch to clvmd.
   Improve lvm_dump.sh robustness.
   Update lvm2create_initrd to support gentoo.
 
--- LVM2/daemons/clvmd/clvmd.c	2006/10/09 14:11:57	1.29
+++ LVM2/daemons/clvmd/clvmd.c	2006/11/30 09:44:07	1.30
@@ -99,6 +99,7 @@
 #define DFAIL_LOCAL_SOCK 2
 #define DFAIL_CLUSTER_IF 3
 #define DFAIL_MALLOC     4
+#define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
 /* Prototypes for code further down */
@@ -122,7 +123,7 @@
 static int open_local_sock(void);
 static struct local_client *find_client(int clientid);
 static void main_loop(int local_sock, int cmd_timeout);
-static void be_daemon(void);
+static void be_daemon(int start_timeout);
 static int check_all_clvmds_running(struct local_client *client);
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 				     int len, char *csid,
@@ -146,6 +147,7 @@
 	fprintf(file, "   -d       Don't fork, run in the foreground\n");
 	fprintf(file, "   -R       Tell all running clvmds in the cluster to reload their device cache\n");
 	fprintf(file, "   -t<secs> Command timeout (default 60 seconds)\n");
+	fprintf(file, "   -T<secs> Startup timeout (default none)\n");
 	fprintf(file, "\n");
 }
 
@@ -169,13 +171,14 @@
 	signed char opt;
 	int debug = 0;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
+	int start_timeout = 0;
 	sigset_t ss;
 	int using_gulm = 0;
 
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhdt:R")) != EOF) {
+	while ((opt = getopt(argc, argv, "?vVhdt:RT:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -200,6 +203,14 @@
 				exit(1);
 			}
 			break;
+		case 'T':
+			start_timeout = atoi(optarg);
+			if (start_timeout <= 0) {
+				fprintf(stderr, "startup timeout is invalid\n");
+				usage(argv[0], stderr);
+				exit(1);
+			}
+			break;
 
 		case 'V':
 		        printf("Cluster LVM daemon version: %s\n", LVM_VERSION);
@@ -214,7 +225,7 @@
 
 	/* Fork into the background (unless requested not to) */
 	if (!debug) {
-		be_daemon();
+		be_daemon(start_timeout);
 	}
 
 	DEBUGLOG("CLVMD started\n");
@@ -647,16 +658,66 @@
 	close(local_sock);
 }
 
+static void wait_for_child(int c_pipe, int timeout)
+{
+	int child_status;
+	int sstat;
+	fd_set fds;
+	struct timeval tv = {timeout, 0};
+
+	FD_ZERO(&fds);
+	FD_SET(c_pipe, &fds);
+
+	sstat = select(c_pipe+1, &fds, NULL, NULL, timeout? &tv: NULL);
+	if (sstat == 0) {
+		fprintf(stderr, "clvmd startup timed out\n");
+		exit(DFAIL_TIMEOUT);
+	}
+	if (sstat == 1) {
+		if (read(c_pipe, &child_status, sizeof(child_status)) !=
+		    sizeof(child_status)) {
+
+			fprintf(stderr, "clvmd failed in initialisation\n");
+			exit(DFAIL_INIT);
+		}
+		else {
+			switch (child_status) {
+			case SUCCESS:
+				break;
+			case DFAIL_INIT:
+				fprintf(stderr, "clvmd failed in initialisation\n");
+				break;
+			case DFAIL_LOCAL_SOCK:
+				fprintf(stderr, "clvmd could not create local socket\n");
+				fprintf(stderr, "Another clvmd is probably already running\n");
+				break;
+			case DFAIL_CLUSTER_IF:
+				fprintf(stderr, "clvmd could not connect to cluster manager\n");
+				fprintf(stderr, "Consult syslog for more information\n");
+				break;
+			case DFAIL_MALLOC:
+				fprintf(stderr, "clvmd failed, not enough memory\n");
+				break;
+			default:
+				fprintf(stderr, "clvmd failed, error was %d\n", child_status);
+				break;
+			}
+			exit(child_status);
+		}
+	}
+	fprintf(stderr, "clvmd startup, select failed: %s\n", strerror(errno));
+	exit(DFAIL_INIT);
+}
+
 /*
  * Fork into the background and detach from our parent process.
  * In the interests of user-friendliness we wait for the daemon
  * to complete initialisation before returning its status
  * the the user.
  */
-static void be_daemon()
+static void be_daemon(int timeout)
 {
         pid_t pid;
-	int child_status;
 	int devnull = open("/dev/null", O_RDWR);
 	if (devnull == -1) {
 		perror("Can't open /dev/null");
@@ -676,36 +737,7 @@
 
 	default:       /* Parent */
 		close(child_pipe[1]);
-		if (read(child_pipe[0], &child_status, sizeof(child_status)) !=
-		    sizeof(child_status)) {
-
-		        fprintf(stderr, "clvmd failed in initialisation\n");
-		        exit(DFAIL_INIT);
-		}
-		else {
-		        switch (child_status) {
-			case SUCCESS:
-			        break;
-			case DFAIL_INIT:
-			        fprintf(stderr, "clvmd failed in initialisation\n");
-				break;
-			case DFAIL_LOCAL_SOCK:
-			        fprintf(stderr, "clvmd could not create local socket\n");
-				fprintf(stderr, "Another clvmd is probably already running\n");
-				break;
-			case DFAIL_CLUSTER_IF:
-			        fprintf(stderr, "clvmd could not connect to cluster manager\n");
-				fprintf(stderr, "Consult syslog for more information\n");
-				break;
-			case DFAIL_MALLOC:
-			        fprintf(stderr, "clvmd failed, not enough memory\n");
-				break;
-			default:
-			        fprintf(stderr, "clvmd failed, error was %d\n", child_status);
-				break;
-			}
-			exit(child_status);
-		}
+		wait_for_child(child_pipe[0], timeout);
 	}
 
 	/* Detach ourself from the calling environment */


