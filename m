From: saulery@free.fr <saulery@free.fr>
Date: Tue, 25 Nov 2014 02:57:21 +0100
Subject: Improve manpage clvmd.8.in
In-Reply-To: <1416880642-26059-1-git-send-email-saulery@free.fr>
References: <1416880642-26059-1-git-send-email-saulery@free.fr>
Message-ID: <1416880642-26059-2-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- Standardize the form of arguments
- clvmd references in bold
- Highlight arguments used in text
- Simplify reading of debug levels (omitted = 1)
- Document the cluster manager "singlenode" that has been forgotten.
- Simplify -d highlights for "maintenability"

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/clvmd.8.in | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 9b2bd4e..22f0979 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -10,7 +10,7 @@ clvmd \(em cluster LVM daemon
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-I
-.IR "cluster_manager" ]
+.RI < "cluster manager" >]
 .RB [ \-R ]
 .RB [ \-S ]
 .RB [ \-t
@@ -25,9 +25,10 @@ if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
 .BR \-d [< \fIvalue >]
-Set debug logging level.If \fB\-d\fP is specified without a \fIvalue\fP 
-then 1 is assumed. \fIValue\fP can be:
+Set debug logging level. \fIValue\fP can be:
 .RS
+.IP [\fIOmitted\fP]
+Equivalent to \fI1\fP.
 .IP \fI0\fP
 Disabled
 .IP \fI1\fP
@@ -40,15 +41,12 @@ Sends debug logs to \fBsyslog\fP(3)
 Only valid if
 .B \-d
 is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
-Without this switch, only the local clvmd will change its debug level to that
-given with
-.B \-d
-.
-.br
-This does not work correctly if specified on the command-line that starts clvmd.
-If you want to start clvmd
-.B and
-enable cluster-wide logging then the command needs to be issued twice, eg:
+Without this switch, only the local \fBclvmd\fP will change its debug level to that
+given with \fB\-d\fP.
+
+This does not work correctly if specified on the command-line that starts
+\fBclvmd\fP. If you want to start clvmd \fBand\fP enable cluster-wide logging
+then the command needs to be issued twice, eg:
 .br
 .B clvmd
 .br
@@ -56,7 +54,7 @@ enable cluster-wide logging then the command needs to be issued twice, eg:
 .br
 .TP
 .BR \-E < "\fIlock uuid" >
-Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+Pass \fIlock uuid\fP to be reacquired exclusively when \fBclvmd\fP is restarted.
 .TP
 .B \-f
 Don't fork, run in the foreground.
@@ -64,7 +62,7 @@ Don't fork, run in the foreground.
 .B \-h
 Show help information.
 .TP
-.BR \-I " \fIcluster_manager\fP"
+.BR \-I < "\fIcluster manager\fP" >
 Selects the \fIcluster manager\fP to use for locking and internal
 communications. As it is quite possible to have multiple managers available on
 the same system you might have to manually specify this option to override the
@@ -72,7 +70,7 @@ search.
 
 By default, omit \fB-I\fP is equivalent to \fB\-I\fP\fIauto\fP. \fBClvmd\fP
 will use the first cluster manager that succeeds, and it checks them in a
-predefined order cman,corosync,openais.
+predefined order: \fIcman, corosync, openais, singlenode\fP.
 The available managers will be listed by order as part of the
 \fBclvmd \-h\fP output.
 .TP
-- 
2.1.3


