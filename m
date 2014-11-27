From: saulery@free.fr <saulery@free.fr>
Date: Thu, 27 Nov 2014 02:32:38 +0100
Subject: Improve cmirrord.8 manpage
In-Reply-To: <1417051960-2920-1-git-send-email-saulery@free.fr>
References: <1417051960-2920-1-git-send-email-saulery@free.fr>
Message-ID: <1417051960-2920-2-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- Keywords in bold
- Add syslog and signal ref.
- Sort see also sections

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/cmirrord.8.in | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/man/cmirrord.8.in b/man/cmirrord.8.in
index 8ef6794..bf30cc8 100644
--- a/man/cmirrord.8.in
+++ b/man/cmirrord.8.in
@@ -6,7 +6,7 @@ cmirrord \(em cluster mirror log daemon
 .B cmirrord
 
 .SH DESCRIPTION
-cmirrord is the daemon that tracks mirror log information in a cluster.
+\fBcmirrord\fP is the daemon that tracks mirror log information in a cluster.
 It is specific to device-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
@@ -14,17 +14,20 @@ running.
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
 
 .SH SEE ALSO
+.BR syslog (3),
+.BR cluster.conf (5),
+.BR signal (7),
+.BR clvmd (8),
 .BR lvm (8)
-.BR clvmd (8)
-.BR cluster.conf (5)
-- 
2.1.3


