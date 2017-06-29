From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:04 -0400
Subject: master - lvmconf: double quote
Message-ID: <201706292026.v5TKQ4hC025765@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccdb75adcc737a6d5b510adbb69373016c27d827
Commit:        ccdb75adcc737a6d5b510adbb69373016c27d827
Parent:        de04e36fda20dbf1bcfb155e6b2faf584cde791d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 17:22:08 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmconf: double quote

---
 scripts/lvmconf.sh |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index 3aab4a0..e78a27e 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -51,7 +51,7 @@ function usage
 
 function set_default_use_lvmetad_var
 {
-	eval $(lvm dumpconfig --type default global/use_lvmetad 2>/dev/null)
+	eval "$(lvm dumpconfig --type default global/use_lvmetad 2>/dev/null)"
 	if [ "$?" != "0" ]; then
 		USE_LVMETAD=0
 	else
@@ -325,8 +325,8 @@ else
         SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ use_lvmetad = $USE_LVMETAD"
     fi
 
-    echo -e $SEDCMD > $SCRIPTFILE
-    sed  <$CONFIGFILE >$TMPFILE -f $SCRIPTFILE
+    echo -e "$SEDCMD" > "$SCRIPTFILE"
+    sed  <"$CONFIGFILE" >"$TMPFILE" -f "$SCRIPTFILE"
     if [ $? != 0 ]
     then
 	echo "sed failed, $CONFIGFILE not updated"
@@ -337,21 +337,21 @@ fi
 # Now we have a suitably editted config file in a temp place,
 # backup the original and copy our new one into place.
 
-cp $CONFIGFILE $CONFIGFILE.lvmconfold
+cp "$CONFIGFILE" "$CONFIGFILE.lvmconfold"
 if [ $? != 0 ]
     then
     echo "failed to backup old config file, $CONFIGFILE not updated"
     exit 2
 fi
 
-cp $TMPFILE $CONFIGFILE
+cp "$TMPFILE" "$CONFIGFILE"
 if [ $? != 0 ]
     then
     echo "failed to copy new config file into place, check $CONFIGFILE is still OK"
     exit 3
 fi
 
-rm -f $SCRIPTFILE $TMPFILE
+rm -f "$SCRIPTFILE" "$TMPFILE"
 
 function set_service {
     local type="$1"
@@ -360,42 +360,42 @@ function set_service {
 
     if [ "$type" = "systemd" ]; then
         if [ "$action" = "activate" ]; then
-            for i in $@; do
+            for i in "$@"; do
                 unset LoadState
-                eval $($SYSTEMCTL_BIN show $i -p LoadState 2>/dev/null)
+                eval "$($SYSTEMCTL_BIN show "$i" -p LoadState 2>/dev/null)"
                 test  "$LoadState" = "loaded" || continue
-                $SYSTEMCTL_BIN enable $i
+                $SYSTEMCTL_BIN enable "$i"
                 if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SYSTEMCTL_BIN start $i
+                    $SYSTEMCTL_BIN start "$i"
                 fi
             done
         elif [ "$action" = "deactivate" ]; then
-            for i in $@; do
+            for i in "$@"; do
                 unset LoadState
-                eval $($SYSTEMCTL_BIN show $i -p LoadState 2>/dev/null)
+                eval "$($SYSTEMCTL_BIN show "$i" -p LoadState 2>/dev/null)"
                 test  "$LoadState" = "loaded" || continue
-                $SYSTEMCTL_BIN disable $i
+                $SYSTEMCTL_BIN disable "$i"
                 if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SYSTEMCTL_BIN stop $i
+                    $SYSTEMCTL_BIN stop "$i"
                 fi
             done
         fi
     elif [ "$type" = "sysv" ]; then
         if [ "$action" = "activate" ]; then
-            for i in $@; do
-                $CHKCONFIG_BIN --list $i > /dev/null || continue
-                $CHKCONFIG_BIN $i on
+            for i in "$@"; do
+                $CHKCONFIG_BIN --list "$i" > /dev/null || continue
+                $CHKCONFIG_BIN "$i" on
                 if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SERVICE_BIN $i start
+                    $SERVICE_BIN "$i" start
                 fi
             done
         elif [ "$action" = "deactivate" ]; then
-            for i in $@; do
-                $CHKCONFIG_BIN --list $i > /dev/null  || continue
+            for i in "$@"; do
+                $CHKCONFIG_BIN --list "$i" > /dev/null  || continue
                 if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SERVICE_BIN $i stop
+                    $SERVICE_BIN "$i" stop
                 fi
-                $CHKCONFIG_BIN $i off
+                $CHKCONFIG_BIN "$i" off
             done
         fi
     fi


