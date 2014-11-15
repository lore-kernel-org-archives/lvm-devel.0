From: saulery@free.fr <saulery@free.fr>
Date: Sat, 15 Nov 2014 17:46:26 +0100
Subject: Improve clvmd.8 manpage and help output
In-Reply-To: <1416069988-13208-1-git-send-email-saulery@free.fr>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>
Message-ID: <1416069988-13208-2-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- closer to the recommendation of man-pages (7) if possible
- Add crossrefs
- Sort options and crossrefs
- Fix default timeout (60 secs) of -t
- Fix ambiguities in the use of spaces before values
- Documents -I[auto]

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 daemons/clvmd/clvmd.c |  16 +++---
 man/clvmd.8.in        | 140 +++++++++++++++++++++++++-------------------------
 2 files changed, 78 insertions(+), 78 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0c1cb44..5cd6874 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -153,16 +153,11 @@ static if_type_t get_cluster_type(void);
 static void usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage: %s [options]\n"
-		"   -V       Show version of clvmd\n"
-		"   -h       Show this help information\n"
+		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
 		"   -d[n]    Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
+		"   -E<uuid> Take this lock uuid as exclusively locked resource (for restart)\n"
 		"   -f       Don't fork, run in the foreground\n"
-		"   -E<lockuuid> Take this lock uuid as exclusively locked resource (for restart)\n"
-		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
-		"   -S       Restart clvmd, preserving exclusive locks\n"
-		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
-		"   -t<secs> Command timeout (default 60 seconds)\n"
-		"   -T<secs> Startup timeout (default none)\n"
+		"   -h       Show this help information\n"
 		"   -I<cmgr> Cluster manager (default: auto)\n"
 		"            Available cluster managers: "
 #ifdef USE_COROSYNC
@@ -177,6 +172,11 @@ static void usage(const char *prog, FILE *file)
 #ifdef USE_SINGLENODE
 		"singlenode "
 #endif
+		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
+		"   -S       Restart clvmd, preserving exclusive locks\n"
+		"   -t<secs> Command timeout (default: 60 seconds)\n"
+		"   -T<secs> Startup timeout (default:  0 seconds)\n"
+		"   -V       Show version of clvmd\n"
 		"\n", prog);
 }
 
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index d79c29b..d94d920 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -3,62 +3,55 @@
 clvmd \(em cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
-.RB [ \-d
-.RI [< value >]
-.RB [ \-C ]]
-.RB [ \-E
-.RI < "lock uuid" >]
+.RB [
+.RB [ \-C ]
+.RB [ \-d [< \fIvalue\fP >]
+.RB ]
+.RB [ \-E < "\fIlock uuid\fP" >]
 .RB [ \-f ]
 .RB [ \-h ]
-.RB [ \-I
-.IR "cluster_manager" ]
+.RB [ \-I < "\fIcluster manager\fP" >]
 .RB [ \-R ]
 .RB [ \-S ]
-.RB [ \-t
-.RI < timeout >]
-.RB [ \-T
-.RI < "start timeout" >]
+.RB [ \-t < "\fItimeout\fP" >]
+.RB [ \-T < "\fIstart timeout\fP" >]
 .RB [ \-V ]
 .SH DESCRIPTION
-clvmd is the daemon that distributes LVM metadata updates around a cluster.
-It must be running on all nodes in the cluster and will give an error
-if a node in the cluster does not have this daemon running.
+.B Clvmd
+is the daemon that distributes LVM metadata updates around a cluster. It
+must be running on all nodes in the cluster and will give an error if a node
+in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
-.BR \-d [< \fIvalue >]
-Enable debug logging. Value can be 0, 1 or 2.
-.br
-0 disables debug logging
+.B \-C
+Sets debug level on all \fBclvmd\fP instances clusterwide (Only valid if
+\fB\-d\fP is also specified). Tells all instances of \fBclvmd\fP in a
+cluster to enable/disable debug logging. Without this switch, only the local
+\fBclvmd\fP will change its debug level to that given with \fB\-d\fP.
+
+This does not work correctly if specified on the command-line that starts
+\fBclvmd\fP. If you want to start a new instance \fBand\fP enable cluster-wide
+logging then the command needs to be issued twice, eg:
 .br
-1 sends debug logs to stderr (implies \fB\-f\fP option)
+.B clvmd
 .br
-2 sends debug logs to syslog
+.B clvmd \-d2
 .br
-If
-.B \-d
-is specified without a value then 1 is assumed.
 .TP
-.B \-C
-Only valid if
-.B \-d
-is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
-Without this switch, only the local clvmd will change its debug level to that
-given with
-.B \-d
-.
+.BR "\-d" "[<" "\fIvalue\fP" ">]"
+Set debug logging level. \fIValue\fP can be:
 .br
-This does not work correctly if specified on the command-line that starts clvmd.
-If you want to start clvmd
-.B and
-enable cluster-wide logging then the command needs to be issued twice, eg:
+0: disabled;
 .br
-.B clvmd
+1: sends debug logs to stderr (implies \fB\-f\fP);
 .br
-.B clvmd \-d2
+2: sends debug logs to
+.BR syslog "(3).
 .br
+If \fB\-d\fP is specified without a \fIvalue\fP then 1 is assumed.
 .TP
-.BR \-E < "\fIlock uuid" >
-Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.BR "\-E" "<" "\fIlock uuid\fP" ">"
+Pass \fIlock uuid\fP to be reacquired exclusively when \fBclvmd\fP is restarted.
 .TP
 .B \-f
 Don't fork, run in the foreground.
@@ -66,48 +59,52 @@ Don't fork, run in the foreground.
 .B \-h
 Show help information.
 .TP
-.B \-I \fIcluster manager
-Selects the cluster manager to use for locking and internal communications,
-the available managers will be listed as part of the \fBclvmd \-h\fP output.
-clvmd will use the first cluster manager that succeeds, and it checks them
-in the order cman,corosync,openais. As it is quite possible to have
-(eg) corosync and cman available on the same system you might have to
-manually specify this option to override the search.
+.BR "\-I" "<" "\fIcluster manager\fP" ">"
+Selects the \fIcluster manager\fP to use for locking and internal
+communications. As it is quite possible to have multiple managers available on
+the same system you might have to manually specify this option to override the
+search.
+
+By default, omit \fB-I\fP is equivalent to \fB\-I\fP\fIauto\fP. \fBClvmd\fP
+will use the first cluster manager that succeeds, and it checks them in a
+predefined order. The available managers will be listed by order as part of the
+\fBclvmd \-h\fP output.
 .TP
 .B \-R
-Tells all the running clvmds in the cluster to reload their device cache and
-re-read the lvm configuration file. This command should be run whenever the
+Tells all the running instance of \fBclvmd\fP in the cluster to reload their device cache and
+re-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
 devices on a cluster system are changed.
 .TP
 .B \-S
-Tells the running clvmd to exit and reexecute itself, for example at the
-end of a package upgrade.  The new instance is instructed to reacquire
-any locks in the same state as they were previously held.  (Alternative
+Tells the running \fBclvmd\fP to exit and reexecute itself, for example at the
+end of a package upgrade. The new instance is instructed to reacquire
+any locks in the same state as they were previously held. (Alternative
 methods of restarting the daemon have the side effect of changing
 exclusive LV locks into shared locks.)
 .TP
-.BR \-t < \fItimeout >
-Specifies the timeout for commands to run around the cluster. This should not
+.BR "\-t" "<" "\fItimeout\fP" ">"
+Specifies the \fItimeout\fP for commands to run around the cluster. This should not
 be so small that commands with many disk updates to do will fail, so you
 may need to increase this on systems with very large disk farms.
-The default is 30 seconds.
+The default is 60 seconds.
 .TP
-.BR \-T < "\fIstart timeout" >
-Specifies the timeout for clvmd daemon startup. If the daemon does not report
-that it has started up within this time then the parent command will exit with
-status of 5. This does NOT mean that clvmd has not started! What it means is
-that the startup of clvmd has been delayed for some reason; the most likely
-cause of this is an inquorate cluster though it could be due to locking
-latencies on a cluster with large numbers of logical volumes. If you get the
-return code of 5 it is usually not necessary to restart clvmd - it will start
-as soon as that blockage has cleared. This flag is to allow startup scripts
-to exit in a timely fashion even if the cluster is stalled for some reason.
-.br
+.BR "\-T" "<" "\fIstart timeout\fP" ">"
+Specifies the \fIstart timeout\fP for \fBclvmd\fP daemon startup. If the
+daemon does not report that it has started up within this time then the parent
+command will exit with status of 5. This does NOT mean that \fBclvmd\fP has
+not started! What it means is that the startup has been delayed for some
+reason; the most likely cause of this is an inquorate cluster though it
+could be due to locking latencies on a cluster with large numbers of logical
+volumes. If you get the return code of 5 it is usually not necessary to
+restart \fBclvmd\fP ? it will start as soon as that blockage has cleared.
+This flag is to allow startup scripts to exit in a timely fashion even if the
+cluster is stalled for some reason.
+
 The default is 0 (no timeout) and the value is in seconds. Don't set this too
 small or you will experience spurious errors. 10 or 20 seconds might be
 sensible.
-.br
-This timeout will be ignored if you start clvmd with the \-d switch.
+
+This timeout will be ignored if you start \fBclvmd\fP with the \fB\-d\fP.
 .TP
 .B \-V
 Display the version of the cluster LVM daemon.
@@ -115,11 +112,14 @@ Display the version of the cluster LVM daemon.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_CLVMD_BINARY
-The CLVMD binary to use when clmvd restart is requested.
+The CLVMD binary to use when \fBclmvd\fP restart is requested.
 Defaults to #CLVMD_PATH#.
 .TP
 .B LVM_BINARY
-The LVM2 binary to use. Defaults to #LVM_PATH#.
+The LVM2 binary to use.
+Defaults to #LVM_PATH#.
 
 .SH SEE ALSO
-.BR lvm (8)
+.BR syslog (3),
+.BR lvm.conf (5),
+.BR lvm (8).
-- 
2.1.3


