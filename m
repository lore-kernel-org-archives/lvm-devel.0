From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:23 +0000 (UTC)
Subject: master - lvmdump.8.in: describe lvmpolld related option
Message-ID: <20150515183723.2FE9E60E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f1c1f3d6bfa08b554caea0aae5590613c5ef05b
Commit:        4f1c1f3d6bfa08b554caea0aae5590613c5ef05b
Parent:        e93058ed814f4e669287a6c5e8fa913130f2d591
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 13:38:38 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:32 2015 +0200

lvmdump.8.in: describe lvmpolld related option

---
 man/lvmdump.8.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index 9a8c469..f9c2284 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -10,6 +10,7 @@ lvmdump \(em create lvm2 information dumps for diagnostic purposes
 .RB [ \-h ]
 .RB [ \-l ]
 .RB [ \-m ]
+.RB [ \-p ]
 .RB [ \-s ]
 .RB [ \-u ]
 .SH DESCRIPTION
@@ -41,6 +42,8 @@ The content of the tarball is as follows:
 .br
 - if enabled with \-l, lvmetad state if running
 .br
+- if enabled with \-p, lvmpolld state if running
+.br
 - if enabled with \-s, system info and context
 .br
 - if enabled with \-u, udev info and context
@@ -75,6 +78,12 @@ This option generates a 1:1 dump of the metadata area from all PVs visible
 to the system, which can cause the dump to increase in size considerably.
 However, the metadata dump may represent a valuable diagnostic resource.
 .TP
+.B \-p
+Include \fBlvmpolld\fP(8) daemon dump if it is running. The dump contains
+all in-progress operation currently monitored by the daemon and partial
+history for all yet uncollected results of polling operations already finished
+including reason.
+.TP
 .B \-s
 Gather system info and context. Currently, this encompasses systemd info
 and context only: overall state of systemd units present in the system,


