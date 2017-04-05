From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 5 Apr 2017 05:10:53 -0400
Subject: master - lvmconf: fix systemd unit existence check for lvmconf --services --startstopservices
Message-ID: <201704050910.v359Ar3N029511@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=448bf9491a10715650569d5eeceb1026941d70ae
Commit:        448bf9491a10715650569d5eeceb1026941d70ae
Parent:        afa844817a716f054f1e56612fa19522225797f4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 5 11:06:56 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 5 11:06:56 2017 +0200

lvmconf: fix systemd unit existence check for lvmconf --services --startstopservices

We have to unset the LoadState variable from previous use when we check
for systemd unit state. We use this variable to check if systemd services
are loaded or not and if it is loaded, we issue systemctl commands to
enable/disable and start/stop the service. We don't issue these commands
if the unit is not loaded to avoid error messages which may confuse users.
---
 WHATS_NEW          |    1 +
 scripts/lvmconf.sh |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index abff1c8..57e01d4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.170 - 
 ==================================
+  Fix systemd unit existence check for lvmconf --services --startstopservices.
   Check and use PATH_MAX buffers when creating vgrename device paths.
 
 Version 2.02.169 - 28th March 2017
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index a86036d..caf7fae 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -361,7 +361,8 @@ function set_service {
     if [ "$type" = "systemd" ]; then
         if [ "$action" = "activate" ]; then
             for i in $@; do
-                eval $($SYSTEMCTL_BIN show $i -p LoadState)
+                unset LoadState
+                eval $($SYSTEMCTL_BIN show $i -p LoadState 2>/dev/null)
                 test  "$LoadState" = "loaded" || continue
                 $SYSTEMCTL_BIN enable $i
                 if [ "$START_STOP_SERVICES" = "1" ]; then
@@ -370,7 +371,8 @@ function set_service {
             done
         elif [ "$action" = "deactivate" ]; then
             for i in $@; do
-                eval $($SYSTEMCTL_BIN show $i -p LoadState)
+                unset LoadState
+                eval $($SYSTEMCTL_BIN show $i -p LoadState 2>/dev/null)
                 test  "$LoadState" = "loaded" || continue
                 $SYSTEMCTL_BIN disable $i
                 if [ "$START_STOP_SERVICES" = "1" ]; then


