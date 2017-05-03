From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:26:53 -0400
Subject: master - man clvmd: mention lvmlockd is another option
Message-ID: <201705032126.v43LQrbU007108@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1423ab93f9251d7c0c704bf40da0c0bd631bc08e
Commit:        1423ab93f9251d7c0c704bf40da0c0bd631bc08e
Parent:        a7a28bd9985c5630990215045adb8d76c9b099e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 16:26:21 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 16:26:21 2017 -0500

man clvmd: mention lvmlockd is another option

---
 man/clvmd.8_main |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/man/clvmd.8_main b/man/clvmd.8_main
index 8e9921d..de6ce25 100644
--- a/man/clvmd.8_main
+++ b/man/clvmd.8_main
@@ -31,6 +31,9 @@ clvmd \(em cluster LVM daemon
 clvmd is the daemon that distributes LVM metadata updates around a cluster.
 It must be running on all nodes in the cluster and will give an error
 if a node in the cluster does not have this daemon running.
+
+Also see \fBlvmlockd\fP(8) for a newer method of using LVM on shared
+storage.
 .
 .SH OPTIONS
 .
@@ -196,4 +199,6 @@ Defaults to \fI#LVM_PATH#\fP.
 .SH SEE ALSO
 .BR syslog (3),
 .BR lvm.conf (5),
-.BR lvm (8)
+.BR lvm (8),
+.BR lvmlockd (8),
+.BR lvmsystemid (7)


