From: David Teigland <teigland@sourceware.org>
Date: Wed, 14 Nov 2018 11:01:32 -0500
Subject: master - man: remove some clvmd references
Message-ID: <201811141601.wAEG1WnF029545@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16fed9ef0c4ea5ba20063c9fbf36c0c1292f87b3
Commit:        16fed9ef0c4ea5ba20063c9fbf36c0c1292f87b3
Parent:        e6be10ffd2d9d5037d3e140157539edbb0a9d396
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 14 10:00:23 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 14 10:00:23 2018 -0600

man: remove some clvmd references

---
 man/cmirrord.8_main |   13 +++++--------
 man/lvm.8_main      |    1 -
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/man/cmirrord.8_main b/man/cmirrord.8_main
index 026c19b..d49fa52 100644
--- a/man/cmirrord.8_main
+++ b/man/cmirrord.8_main
@@ -11,10 +11,8 @@ It is specific to device-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
 
-This daemon relies on the cluster infrastructure provided by the
-Cluster MANager (CMAN), which must be set up and running in order for
-cmirrord to function.  (The cluster infrastructure is also required for
-\fBclvmd\fP(8).)
+This daemon relies on the cluster infrastructure provided by the corosync,
+which must be set up and running in order for cmirrord to function.
 
 Output is logged via \fBsyslog\fP(3). The \fBSIGUSR1 signal\fP(7) can be
 issued to \fBcmirrord\fP to gather current status information for debugging
@@ -32,8 +30,7 @@ Do not fork and log to the terminal.
 Print usage.
 
 .SH SEE ALSO
+.BR lvmlockd (8),
+.BR lvm (8),
 .BR syslog (3),
-.BR cluster.conf (5),
-.BR signal (7),
-.BR clvmd (8),
-.BR lvm (8)
+.BR signal (7)
diff --git a/man/lvm.8_main b/man/lvm.8_main
index d4ce3da..b9abf58 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -544,7 +544,6 @@ Prepends source file name and code line number with libdm debugging.
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 


