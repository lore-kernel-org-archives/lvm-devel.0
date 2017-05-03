From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:41:01 -0400
Subject: master - man lvm fullreport and lvpoll references
Message-ID: <201705032141.v43Lf1a4008407@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2d943a4b60465f9fe06a6742bd2789372c0d15b
Commit:        f2d943a4b60465f9fe06a6742bd2789372c0d15b
Parent:        1423ab93f9251d7c0c704bf40da0c0bd631bc08e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 16:38:19 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 16:40:44 2017 -0500

man lvm fullreport and lvpoll references

Add references to lvm-fullreport(8) and lvm-lvpoll(8).
---
 man/lvm-fullreport.8_des |    1 -
 man/lvm.8_main           |    2 ++
 man/lvmreport.7_main     |    2 +-
 man/see_also.end         |    2 ++
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/man/lvm-fullreport.8_des b/man/lvm-fullreport.8_des
index f350a0a..741cd12 100644
--- a/man/lvm-fullreport.8_des
+++ b/man/lvm-fullreport.8_des
@@ -3,4 +3,3 @@ and LV segments. The information is all gathered together for each VG
 (under a per-VG lock) so it is consistent. Information gathered from
 separate calls to \fBvgs\fP, \fBpvs\fP, and \fBlvs\fP can be inconsistent
 if information changes between commands.
-
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 7506eaf..bd5d8a7 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -537,6 +537,8 @@ directly.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 7a26401..7167df0 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -948,7 +948,7 @@ configuration directly on command line.
 
 You can obtain the same information with single command where all the
 information about PVs, PV segments, LVs and LV segments are obtained
-per VG under a single VG lock for consistency, see also \fBlvm fullreport\fP(8)
+per VG under a single VG lock for consistency, see also \fBlvm-fullreport\fP(8)
 man page for more information. The fullreport has its own configuration
 settings to define field sets to use, similar to individual reports as
 displayed above, but configuration settings have "_full" suffix now.
diff --git a/man/see_also.end b/man/see_also.end
index 9e7d3b2..5b07719 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -46,6 +46,8 @@
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)


