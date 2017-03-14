From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Mar 2017 11:19:10 -0400
Subject: master - man clvmd: mention attempt for deactivate
Message-ID: <201703141519.v2EFJAw8020709@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88b05391ffbb168b6c35edc2f6b8428d8b22e815
Commit:        88b05391ffbb168b6c35edc2f6b8428d8b22e815
Parent:        c891918174f500f2508a5b69a4d55a427ac2b63c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 14 10:17:46 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 14 10:17:46 2017 -0500

man clvmd: mention attempt for deactivate

attempt is always the case, but mention it again
---
 man/clvmd.8_main |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/clvmd.8_main b/man/clvmd.8_main
index 21f8c7d..e629665 100644
--- a/man/clvmd.8_main
+++ b/man/clvmd.8_main
@@ -176,9 +176,9 @@ clvmd attempts to activate the LV only on the local node.
 If the LV type allows concurrent access, then shared mode is used,
 otherwise exclusive.
 .IP \fBn\fP
-clvmd deactivates the LV on all nodes.
+clvmd attempts to deactivate the LV on all nodes.
 .IP \fBln\fP
-clvmd deactivates the LV on the local node.
+clvmd attempts to deactivate the LV on the local node.
 .
 .SH ENVIRONMENT VARIABLES
 .TP


