From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 21 Oct 2015 18:37:57 +0000 (UTC)
Subject: master - man: document possible lvmetad -l values
Message-ID: <20151021183757.AC06060243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73e679f33f411c65c9b7c7e4e501d97245f0bf5d
Commit:        73e679f33f411c65c9b7c7e4e501d97245f0bf5d
Parent:        a0d819172fde16913347e5c0984dc4d67ae6befe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 13:36:57 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 13:36:57 2015 -0500

man: document possible lvmetad -l values

In the man page and the lvmetad help output.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    4 ++--
 man/lvmetad.8.in               |   14 +++++---------
 3 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 983b2b4..ece92e0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Allow all log levels to be used with the lvmetad -l option.
   Add optional shutdown when idle support for lvmetad.
   Fix missing in-sync progress info while lvconvert used with lvmpolld.
   Add report/compact_output_cols to lvm.conf to define report cols to compact.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7ec3a3a..64d998e 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1637,11 +1637,11 @@ static int process_timeout_arg(const char *str, unsigned *max_timeouts)
 static void usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path] [-t secs]\n\n"
+		"%s [-V] [-h] [-f] [-l level[,level ...]] [-s path] [-t secs]\n\n"
 		"   -V       Show version of lvmetad\n"
 		"   -h       Show this help information\n"
 		"   -f       Don't fork, run in the foreground\n"
-		"   -l       Logging message level (-l {all|wire|debug})\n"
+		"   -l       Logging message levels (all,fatal,error,warn,info,wire,debug)\n"
 		"   -p       Set path to the pidfile\n"
 		"   -s       Set path to the socket to listen on\n"
 		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog);
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 2acfd8b..3e895ce 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -5,7 +5,7 @@ lvmetad \(em LVM metadata cache daemon
 .SH SYNOPSIS
 .B lvmetad
 .RB [ \-l
-.RI { all | wire | debug }]
+.IR level [,level...]]
 .RB [ \-p
 .IR pidfile_path ]
 .RB [ \-s
@@ -77,15 +77,11 @@ Don't fork, but run in the foreground.
 .BR \-h ", " \-?
 Show help information.
 .TP
-.IR \fB\-l " {" all | wire | debug }
-Select the type of log messages to generate.
-Messages are logged by syslog.  
+.B \-l \fIlevels
+Specify the levels of log messages to generate as a comma separated list.
+Messages are logged by syslog.
 Additionally, when \-f is given they are also sent to standard error.
-Since release 2.02.98, there are two classes of messages: wire and debug.
-Selecting 'all' supplies both and is equivalent to a comma-separated list
-\-l wire,debug.
-Prior to release 2.02.98, repeating \-d from 1 to 3 times, viz. \-d, \-dd, \-ddd,
-increased the detail of messages.
+Possible levels are: all, fatal, error, warn, info, wire, debug.
 .TP
 .B \-p \fIpidfile_path
 Path to the pidfile. This overrides both the built-in default


