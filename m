From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:16:57 +0000 (UTC)
Subject: master - man: improve cmirrord.8 manpage
Message-ID: <20151116001657.DC03B60645@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd9a05b5ae7fb12cf2efd779f3f2da44698805b5
Commit:        dd9a05b5ae7fb12cf2efd779f3f2da44698805b5
Parent:        376892ddf8e6a1c3e50240193d6df63418d9392d
Author:        St??phane Aulery <saulery@free.fr>
AuthorDate:    Thu Nov 27 02:32:38 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:15:03 2015 +0100

man: improve cmirrord.8 manpage

- Keywords in bold
- Add syslog and signal ref.
- Sort see also sections

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 man/cmirrord.8.in |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/man/cmirrord.8.in b/man/cmirrord.8.in
index 383db65..ad604c7 100644
--- a/man/cmirrord.8.in
+++ b/man/cmirrord.8.in
@@ -6,7 +6,7 @@ cmirrord \(em cluster mirror log daemon
 \fBcmirrord\fR [\fB\-f\fR] [\fB\-h\fR]
 
 .SH DESCRIPTION
-cmirrord is the daemon that tracks mirror log information in a cluster.
+\fBcmirrord\fP is the daemon that tracks mirror log information in a cluster.
 It is specific to device-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
@@ -14,15 +14,16 @@ running.
 This daemon relies on the cluster infrastructure provided by the
 Cluster MANager (CMAN), which must be set up and running in order for
 cmirrord to function.  (The cluster infrastructure is also required for
-clvmd.)
+\fBclvmd\fP(8).)
 
-Output is logged via syslog.  The USR1 signal can be issued to cmirrord
-to gather current status information for debugging purposes.
+Output is logged via \fBsyslog\fP(3). The \fBSIGUSR1 signal\fP(7) can be
+issued to \fBcmirrord\fP to gather current status information for debugging
+purposes.
 
-Once started, cmirrord will run until it is shutdown via INT signal.  If
-there are still active cluster mirrors, however, the signal will be
-ignored.  Active cluster mirrors should be shutdown before stopping the
-cluster mirror log daemon.
+Once started, \fBcmirrord\fP will run until it is shutdown via \fBSIGINT\fP
+signal. If there are still active cluster mirrors, however, the signal will be
+ignored. Active cluster mirrors should be shutdown before stopping the cluster
+mirror log daemon.
 
 .SH OPTIONS
 .IP "\fB\-f\fR, \fB\-\-foreground\fR" 4
@@ -31,6 +32,8 @@ Do not fork and log to the terminal.
 Print usage.
 
 .SH SEE ALSO
+.BR syslog (3),
+.BR cluster.conf (5),
+.BR signal (7),
+.BR clvmd (8),
 .BR lvm (8)
-.BR clvmd (8)
-.BR cluster.conf (5)


