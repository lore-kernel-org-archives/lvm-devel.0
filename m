From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:46 -0500
Subject: master - man: remove clvmd man page
Message-ID: <201811132328.wADNSkAr006688@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c203ce7f8614226bc2f76f0eba3797e43add3de6
Commit:        c203ce7f8614226bc2f76f0eba3797e43add3de6
Parent:        970f49dcab64bdef45bce2122ead51dd17e3c48b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 16:17:17 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 16:17:17 2018 -0600

man: remove clvmd man page

---
 man/Makefile.in  |    1 -
 man/clvmd.8_main |  204 ------------------------------------------------------
 2 files changed, 0 insertions(+), 205 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 6d5e2ac..25e6fa6 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -159,7 +159,6 @@ $(Q)$(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+" \
 	-e "s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+" \
 	-e "s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" \
-	-e "s+#CLVMD_PATH#+$(exec_prefix)/clvmd+" \
 	-e "s+#LVM_PATH#+$(exec_prefix)/lvm+" \
 	-e "s+#DEFAULT_RUN_DIR#+$(DEFAULT_RUN_DIR)+" \
 	-e "s+#DEFAULT_PID_DIR#+$(DEFAULT_PID_DIR)+" \
diff --git a/man/clvmd.8_main b/man/clvmd.8_main
deleted file mode 100644
index de6ce25..0000000
--- a/man/clvmd.8_main
+++ /dev/null
@@ -1,204 +0,0 @@
-.TH CLVMD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
-.
-.SH NAME
-.
-clvmd \(em cluster LVM daemon
-.
-.SH SYNOPSIS
-.
-.ad l
-.B clvmd
-.RB [ -C ]
-.RB [ -d
-.RI [ value ]]
-.RB [ -E
-.IR lock_uuid ]
-.RB [ -f ]
-.RB [ -h ]
-.RB [ -I
-.IR cluster_manager ]
-.RB [ -R ]
-.RB [ -S ]
-.RB [ -t
-.IR timeout ]
-.RB [ -T
-.IR start_timeout ]
-.RB [ -V ]
-.ad b
-.
-.SH DESCRIPTION
-.
-clvmd is the daemon that distributes LVM metadata updates around a cluster.
-It must be running on all nodes in the cluster and will give an error
-if a node in the cluster does not have this daemon running.
-
-Also see \fBlvmlockd\fP(8) for a newer method of using LVM on shared
-storage.
-.
-.SH OPTIONS
-.
-.HP
-.BR -C
-.br
-Only valid if \fB-d\fP is also specified.
-Tells all clvmds in a cluster to enable/disable debug logging.
-Without this switch, only the local clvmd will change its debug level to that
-given with \fB-d\fP.
-.br
-This does not work correctly if specified on the command-line that starts clvmd.
-If you want to start clvmd \fBand\fP
-enable cluster-wide logging then the command needs to be issued twice, eg:
-.br
-.BR clvmd
-.br
-.BR clvmd\ -d2
-.
-.HP
-.BR -d
-.RI [ value ]
-.br
-Set debug logging level.
-If \fB-d\fP is specified without a \fIvalue\fP
-then 1 is assumed. \fIValue\fP can be:
-.PD 0
-.IP
-.BR 0
-\(em Disabled
-.IP
-.BR 1
-\(em Sends debug logs to stderr (implies \fB-f\fP)
-.IP
-.BR 2
-\(em Sends debug logs to \fBsyslog\fP(3)
-.PD
-.
-.HP
-.BR -E
-.IR lock_uuid
-.br
-Pass lock uuid to be reacquired exclusively when clvmd is restarted.
-.
-.HP
-.BR -f
-.br
-Don't fork, run in the foreground.
-.
-.HP
-.BR -h
-.br
-Show help information.
-.
-.HP
-.BR -I
-.IR cluster_manager
-.br
-Selects the cluster manager to use for locking and internal
-communications. As it is quite possible to have multiple managers available on
-the same system you might have to manually specify this option to override the
-search.
-
-By default, omit \fB-I\fP is equivalent to \fB-Iauto\fP.
-Clvmd will use the first cluster manager that succeeds,
-and it checks them in a predefined order
-.BR cman ,
-.BR corosync ,
-.BR openais .
-The available managers will be listed by order as part of the
-\fBclvmd -h\fP output.
-.
-.HP
-.BR -R
-.br
-Tells all the running instance of \fBclvmd\fP in the cluster to reload their device cache and
-re-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
-devices on a cluster system are changed.
-.
-.HP
-.BR -S
-.br
-Tells the running \fBclvmd\fP to exit and reexecute itself, for example at the
-end of a package upgrade. The new instance is instructed to reacquire
-any locks in the same state as they were previously held. (Alternative
-methods of restarting the daemon have the side effect of changing
-exclusive LV locks into shared locks.)
-.
-.HP
-.BR -t
-.IR timeout
-.br
-Specifies the \fItimeout\fP for commands to run around the cluster. This should not
-be so small that commands with many disk updates to do will fail, so you
-may need to increase this on systems with very large disk farms.
-The default is 60 seconds.
-.
-.HP
-.BR -T
-.IR start_timeout
-.br
-Specifies the start timeout for \fBclvmd\fP daemon startup. If the
-daemon does not report that it has started up within this time then the parent
-command will exit with status of 5. This does NOT mean that \fBclvmd\fP has
-not started! What it means is that the startup has been delayed for some
-reason; the most likely cause of this is an inquorate cluster though it
-could be due to locking latencies on a cluster with large numbers of logical
-volumes. If you get the return code of 5 it is usually not necessary to
-restart \fBclvmd\fP it will start as soon as that blockage has cleared.
-This flag is to allow startup scripts to exit in a timely fashion even if the
-cluster is stalled for some reason.
-
-The default is \fB0\fP (no timeout) and the value is in seconds. Don't set this too
-small or you will experience spurious errors. 10 or 20 seconds might be
-sensible.
-
-This timeout will be ignored if you start \fBclvmd\fP with the \fB-d\fP.
-.
-.HP
-.BR -V
-.br
-Display the version of the cluster LVM daemon.
-.
-.SH NOTES
-.
-.SS Activation
-.
-In a clustered VG, clvmd is used for activation, and the following values are
-possible with \fBlvchange/vgchange -a\fP:
-.IP \fBy\fP|\fBsy\fP
-clvmd activates the LV in shared mode (with a shared lock),
-allowing multiple nodes to activate the LV concurrently.
-If the LV type prohibits shared access, such as an LV with a snapshot,
-an exclusive lock is automatically used instead.
-clvmd attempts to activate the LV concurrently on all nodes.
-.IP \fBey\fP
-clvmd activates the LV in exclusive mode (with an exclusive lock),
-allowing a single node to activate the LV.
-clvmd attempts to activate the LV concurrently on all nodes, but only
-one will succeed.
-.IP \fBly\fP
-clvmd attempts to activate the LV only on the local node.
-If the LV type allows concurrent access, then shared mode is used,
-otherwise exclusive.
-.IP \fBn\fP
-clvmd attempts to deactivate the LV on all nodes.
-.IP \fBln\fP
-clvmd attempts to deactivate the LV on the local node.
-.
-.SH ENVIRONMENT VARIABLES
-.TP
-.B LVM_CLVMD_BINARY
-The CLVMD binary to use when \fBclvmd\fP restart is requested.
-Defaults to \fI#CLVMD_PATH#\fP.
-.TP
-.B LVM_BINARY
-The LVM2 binary to use.
-Defaults to \fI#LVM_PATH#\fP.
-.SH FILES
-.I #CLVMD_PATH#
-.br
-.I #LVM_PATH#
-.SH SEE ALSO
-.BR syslog (3),
-.BR lvm.conf (5),
-.BR lvm (8),
-.BR lvmlockd (8),
-.BR lvmsystemid (7)


