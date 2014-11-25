From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Nov 2014 14:19:45 +0000 (UTC)
Subject: master - initscripts: fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored
Message-ID: <20141125141945.5C26D60E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13e2049c32f016cd7f2d93d98fd47178f139fc81
Commit:        13e2049c32f016cd7f2d93d98fd47178f139fc81
Parent:        62f3a4d2d88576ac160f7a7a5f5dc7608c7a1c04
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 25 15:18:58 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 25 15:19:11 2014 +0100

initscripts: fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored

---
 WHATS_NEW                     |    1 +
 scripts/clvmd_init_red_hat.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f655f24..e279c38 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored.
   Fix size in pvresize "Resizing to ..." verbose msg to show proper result size.
 
 Version 2.02.113 - 24th November 2014
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index 86dea4c..8c46c06 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -38,7 +38,7 @@ CLVMDOPTS="-T30"
 # allow up to $CLVMD_STOP_TIMEOUT seconds to clvmd to complete exit operations
 # default to 10 seconds
 
-[ -z $CLMVD_STOP_TIMEOUT ] && CLVMD_STOP_TIMEOUT=10
+[ -z $CLVMD_STOP_TIMEOUT ] && CLVMD_STOP_TIMEOUT=10
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 


