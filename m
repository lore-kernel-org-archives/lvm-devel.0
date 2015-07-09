From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jul 2015 08:40:39 +0000 (UTC)
Subject: master - lvmconf: fix ignored --startstopservices in lvmconf ... --mirrorservice on systemd
Message-ID: <20150709084039.093416022F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb305b9fc0ae3f554b71aa3839d091424c660e63
Commit:        cb305b9fc0ae3f554b71aa3839d091424c660e63
Parent:        a0cc570f86ad267e4903aac9bedaecaf22e8d714
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 9 10:35:41 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 9 10:40:14 2015 +0200

lvmconf: fix ignored --startstopservices in lvmconf ... --mirrorservice on systemd

If running lvmconf ... --startstopservice --mirrorservice in systemd
environment, handle lvm2-cmirrord accordingly. A typo in the script
caused the lvm2-cmirrord to not start/stop immediately, it was
only enabled/disabled (so the --startstopservice was ignored in this
case).
---
 WHATS_NEW          |    1 +
 scripts/lvmconf.sh |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1a8bbbb..f3da3e0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix ignored --startstopservices option if running lvmconf with systemd.
 
 Version 2.02.125 - 7th July 2015
 ================================
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index 396f7a1..c3c1700 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -412,12 +412,12 @@ if [ "$HANDLE_SERVICES" == "1" ]; then
 
         if [ "$LOCKING_TYPE" = "3" ]; then
             set_service systemd activate lvm2-cluster-activation.service
-            if [ "$HANDLE_CMIRROR_SERVICE" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
                 set_service activate lvm2-cmirrord.service
             fi
         else
             set_service systemd deactivate lvm2-cluster-activation.service
-            if [ "$HANDLE_CMIRROR_SERVICE" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
                 set_service systemd deactivate lvm2-cmirrord.service
             fi
         fi


