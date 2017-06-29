From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:09 -0400
Subject: master - lvmconf: prefer well defined and
Message-ID: <201706292026.v5TKQ9PC025775@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6330e2dc8621e0383a5606acbfb9687a34f1a668
Commit:        6330e2dc8621e0383a5606acbfb9687a34f1a668
Parent:        ccdb75adcc737a6d5b510adbb69373016c27d827
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 19:25:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmconf: prefer well defined and

Prefer [ p ] && [ q ] as [ p -a q ] is not well defined.
---
 scripts/lvmconf.sh |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index e78a27e..cbeb4eb 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -150,7 +150,7 @@ function validate_args
             exit 10
     fi
 
-    if [ "$HANDLE_CLUSTER" = "1" -a "$HANDLE_HALVM" = "1" ]; then
+    if [ "$HANDLE_CLUSTER" = 1 ] && [ "$HANDLE_HALVM" = 1 ]; then
         echo "Either HA LVM or cluster method may be used at one time"
 	    exit 18
     fi
@@ -187,8 +187,10 @@ function validate_args
 
     fi
 
-    if [ "$LOCKING_TYPE" = "1" ] && [ -n "$LOCKINGLIBDIR" -o -n "$LOCKINGLIB" ]; then
-	echo "Superfluous locking lib parameter, ignoring"
+    if [ "$LOCKING_TYPE" = 1 ] ; then
+	if [ -n "$LOCKINGLIBDIR" ] || [ -n "$LOCKINGLIB" ]; then
+		echo "Superfluous locking lib parameter, ignoring"
+	fi
     fi
 }
 
@@ -224,7 +226,7 @@ grep -q '^[[:blank:]]*use_lvmetad[[:blank:]]*=' $CONFIGFILE
 have_use_lvmetad=$?
 
 # Those options are in section "global {" so we must have one if any are present.
-if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" -o "$have_use_lvmetad" = "0" ]
+if [ "$have_type" = 0 ] || [ "$have_dir" = 0 ] || [ "$have_library" = 0 ] || [ "$have_use_lvmetad" = 0 ]
 then
 
     # See if we can find it...
@@ -430,7 +432,7 @@ if [ "$HANDLE_SERVICES" == "1" ]; then
         fi
 
     # System V init scripts
-    elif [ -n "$SERVICE_BIN" -a -n "$CHKCONFIG_BIN" ]; then
+    elif [ -n "$SERVICE_BIN" ] && [ -n "$CHKCONFIG_BIN" ]; then
         if [ "$USE_LVMETAD" = "0" ]; then
             set_service sysv deactivate lvm2-lvmetad
         else


