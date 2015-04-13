From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 13 Apr 2015 13:37:58 +0000 (UTC)
Subject: master - lvmconf: add --enable-halvm, --disable-halvm, --services, --mirrorservice, --startstopservices options and use proper global/use_lvmetad default value
Message-ID: <20150413133758.DB5BD60262@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f814d763c60f795dd7616b57fbcd55f1761fcc3c
Commit:        f814d763c60f795dd7616b57fbcd55f1761fcc3c
Parent:        cc26085b62d8cad265fca86426c65c88491a7473
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 13 15:27:17 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 13 15:27:17 2015 +0200

lvmconf: add --enable-halvm, --disable-halvm, --services, --mirrorservice, --startstopservices options and use proper global/use_lvmetad default value

This patch adds new options to lvmconf:

  --enable-halvm (just like --enable-cluster, but configure LVM
                  for use in HA LVM - meaning disabling lvmetad and
                  making sure we have locking_type=1)

  --disable-halvm (just like --disable-cluster, but configure LVM
                   back from HA LVM - meaning enabling lvmetad if
                   it's enabled by default and making sure we have
                   default locking type set)

  --services (causes clvmd and lvmetad services to be enabled or
              disabled appropriately and conforming to the changes
              in lvm configuration we've just made with lvmconf)

  --mirrorservice (in addition to clvmd and lvmetad services, also
                   enable or disable cmirrord service appropriately;
                   this is a separate option because cmirrord is
                   optional and it doesn't need to be always enabled
                   when clvmd is enabled)

  --startstopservices (in addition to enabling or disabling services,
                       start and stop these services immediately)

These options are supposed to help users to make their system ready
for cluster with clvmd (active-active) or HA LVM (active-passive) use
while lvmconf script can handle services as well so users don't need
to bother about setting them manually.

Also, before this patch, we hardcoded global/use_lvmetad=0 as default
value in lvmconf script. Howeverm this default may change by just
flipping the value in config_settings.h and we may forget to edit
the lvmconf. It's better to use lvm dumpconfig --type default global/use_lvmetad
to get the actual default value and use this one instead of hardcoded one.
---
 WHATS_NEW          |    2 +
 man/lvmconf.8.in   |   24 +++++++
 scripts/lvmconf.sh |  174 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 198 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b67635c..9928291 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.119 - 
 ==================================
+  Add --services, --mirrorservice and --startstopservices option to lvmconf.
+  Use proper default value of global/use_lvmetad when processing lvmconf script.
   Respect allocation/cling_tag_list during intial contiguous allocation.
   Add A_PARTITION_BY_TAGS set when allocated areas should not share tags.
   Set correct vgid when updating cache when writing PV metadata.
diff --git a/man/lvmconf.8.in b/man/lvmconf.8.in
index bfd539a..de86a2d 100644
--- a/man/lvmconf.8.in
+++ b/man/lvmconf.8.in
@@ -6,12 +6,17 @@ lvmconf \(em LVM configuration modifier
 .B lvmconf
 .RB [ \-\-disable-cluster ]
 .RB [ \-\-enable-cluster ]
+.RB [ \-\---enable-halvm ]
+.RB [ \-\---disable-halvm ]
 .RB [ \-\-file
 .RI < configfile >]
 .RB [ \-\-lockinglib
 .RI < lib >]
 .RB [ \-\-lockinglibdir
 .RI < dir >]
+.RB [ \-\-services ]
+.RB [ \-\-mirrorservice ]
+.RB [ \-\-startstopservices ]
 
 .SH "DESCRIPTION"
 lvmconf is a script that modifies the locking configuration in
@@ -27,6 +32,14 @@ lvmetad use to its default.
 Set \fBlocking_type\fR to the default clustered type on this system.
 Also disable lvmetad use as it is not yet supported in clustered environment.
 .TP
+.BR \-\-disable-halvm
+Set \fBlocking_type\fR to the default non-clustered type. Also reset
+lvmetad use to its default.
+.TP
+.BR \-\-enable-halvm
+Set \fBlocking_type\fR suitable for HA LVM use.
+Also disable lvmetad use as it is not yet supported in HA LVM environment.
+.TP
 .BR \-\-file " <" \fIconfigfile >
 Apply the changes to \fIconfigfile\fP instead of the default
 \fI#DEFAULT_SYS_DIR#/lvm.conf\fP.
@@ -35,6 +48,17 @@ Apply the changes to \fIconfigfile\fP instead of the default
 Set external \fBlocking_library\fR locking library to load if an external locking type is used.
 .TP
 .BR \-\-lockinglibdir " <" \fIdir >
+.TP
+.BR \-\-services
+In addition to setting the lvm configuration, also enable or disable related Systemd or SysV
+clvmd and lvmetad services.
+.TP
+.BR \-\-mirrorservice
+Also enable or disable optional cmirrord service when handling services (applicable only with \-\-services).
+.TP
+.BR \-\-startstopservices
+In addition to enabling or disabling related services, start or stop them immediately
+(applicable only with \-\-services).
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index bfe518e..6c2a167 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -16,7 +16,20 @@
 # Edit an lvm.conf file to adjust various properties
 #
 
-DEFAULT_USE_LVMETAD=0
+# cluster with clvmd and/or locking lib?
+HANDLE_CLUSTER=0
+
+# cluster without clvmd?
+HANDLE_HALVM=0
+
+# also enable services appropriately (lvmetad, clvmd)?
+HANDLE_SERVICES=0
+
+# also enable cmirrord service in addition?
+HANDLE_MIRROR_SERVICE=0
+
+# also start/start services in addition to enabling/disabling them?
+START_STOP_SERVICES=0
 
 function usage
 {
@@ -25,13 +38,25 @@ function usage
     echo "Commands:"
     echo "Enable clvm:  --enable-cluster [--lockinglibdir <dir>] [--lockinglib <lib>]"
     echo "Disable clvm: --disable-cluster"
+    echo "Enable halvm: --enable-halvm"
+    echo "Disable halvm: --disable-halvm"
     echo "Set locking library: --lockinglibdir <dir> [--lockinglib <lib>]"
     echo ""
     echo "Global options:"
     echo "Config file location: --file <configfile>"
+    echo "Set services: --services [--mirrorservice] [--startstopservices]"
     echo ""
 }
 
+function set_default_use_lvmetad_var
+{
+	eval $(lvm dumpconfig --type default global/use_lvmetad 2>/dev/null)
+	if [ "$?" != "0" ]; then
+		USE_LVMETAD=0
+	else
+                USE_LVMETAD=$use_lvmetad
+	fi
+}
 
 function parse_args
 {
@@ -40,13 +65,27 @@ function parse_args
             --enable-cluster)
                 LOCKING_TYPE=3
                 USE_LVMETAD=0
+                HANDLE_CLUSTER=1
                 shift
                 ;;
             --disable-cluster)
                 LOCKING_TYPE=1
-                USE_LVMETAD=$DEFAULT_USE_LVMETAD
+                set_default_use_lvmetad_var
+                HANDLE_CLUSTER=1
                 shift
                 ;;
+            --enable-halvm)
+                LOCKING_TYPE=1
+		USE_LVMETAD=0
+                HANDLE_HALVM=1
+		shift
+                ;;
+            --disable-halvm)
+                LOCKING_TYPE=1
+                set_default_use_lvmetad_var
+                HANDLE_HALVM=1
+		shift
+                ;;
             --lockinglibdir)
                 if [ -n "$2" ]; then
                     LOCKINGLIBDIR=$2
@@ -55,6 +94,7 @@ function parse_args
                     usage
                     exit 1
                 fi
+                HANDLE_CLUSTER=1
                 ;;
             --lockinglib)
                 if [ -n "$2" ]; then
@@ -64,6 +104,7 @@ function parse_args
                     usage
                     exit 1
                 fi
+                HANDLE_CLUSTER=1
                 ;;
             --file)
                 if [ -n "$2" ]; then
@@ -74,6 +115,18 @@ function parse_args
                     exit 1
                 fi
                 ;;
+            --services)
+                HANDLE_SERVICES=1
+                shift
+                ;;
+            --mirrorservice)
+                HANDLE_MIRROR_SERVICE=1
+                shift
+                ;;
+            --startstopservices)
+                START_STOP_SERVICES=1
+                shift
+                ;;
             *)
                 usage
                 exit 1
@@ -91,6 +144,22 @@ function validate_args
             exit 10
     fi
 
+    if [ "$HANDLE_CLUSTER" = "1" -a "$HANDLE_HALVM" = "1" ]; then
+        echo "Either HA LVM or cluster method may be used at one time"
+	    exit 18
+    fi
+
+    if [ "$HANDLE_SERVICES" = "0" ]; then
+        if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+            echo "--mirrorservice may be used only with --services"
+            exit 19
+        fi
+        if [ "$START_STOP_SERVICES" = "1" ]; then
+            echo "--startstopservices may be used only with --services"
+            exit 19
+        fi
+    fi
+
     if [ -z "$LOCKING_TYPE" ] && [ -z "$LOCKINGLIBDIR" ]; then
         usage
         exit 1
@@ -277,3 +346,104 @@ if [ $? != 0 ]
 fi
 
 rm -f $SCRIPTFILE $TMPFILE
+
+function set_service {
+    local type="$1"
+    local action="$2"
+    shift 2
+
+    if [ "$type" = "systemd" ]; then
+        if [ "$action" = "activate" ]; then
+            for i in $@; do
+                eval $($SYSTEMCTL_BIN show $i -p LoadState)
+                test  "$LoadState" = "loaded" || continue
+                $SYSTEMCTL_BIN enable $i
+                if [ "$START_STOP_SERVICES" = "1" ]; then
+                    $SYSTEMCTL_BIN start $i
+                fi
+            done
+        elif [ "$action" = "deactivate" ]; then
+            for i in $@; do
+                eval $($SYSTEMCTL_BIN show $i -p LoadState)
+                test  "$LoadState" = "loaded" || continue
+                $SYSTEMCTL_BIN disable $i
+                if [ "$START_STOP_SERVICES" = "1" ]; then
+                    $SYSTEMCTL_BIN stop $i
+                fi
+            done
+        fi
+    elif [ "$type" = "sysv" ]; then
+        if [ "$action" = "activate" ]; then
+            for i in $@; do
+                $CHKCONFIG_BIN --list $i > /dev/null || continue
+                $CHKCONFIG_BIN $i on
+                if [ "$START_STOP_SERVICES" = "1" ]; then
+                    $SERVICE_BIN $i start
+                fi
+            done
+        elif [ "$action" = "deactivate" ]; then
+            for i in $@; do
+                $CHKCONFIG_BIN --list $i > /dev/null  || continue
+                if [ "$START_STOP_SERVICES" = "1" ]; then
+                    $SERVICE_BIN $i stop
+                fi
+                $CHKCONFIG_BIN $i off
+            done
+        fi
+    fi
+}
+
+# Start/stop and enable/disable services if needed.
+
+if [ "$HANDLE_SERVICES" == "1" ]; then
+
+    SYSTEMCTL_BIN=$(which systemctl 2>/dev/null)
+    CHKCONFIG_BIN=$(which chkconfig 2>/dev/null)
+    SERVICE_BIN=$(which service 2>/dev/null)
+
+    # Systemd services
+    if [ -n "$SYSTEMCTL_BIN" ]; then
+        if [ "$USE_LVMETAD" = "0" ]; then
+            set_service systemd deactivate lvm2-lvmetad.service lvm2-lvmetad.socket
+        else
+            set_service systemd activate lvm2-lvmetad.socket
+        fi
+
+        if [ "$LOCKING_TYPE" = "3" ]; then
+            set_service systemd activate lvm2-cluster-activation.service
+            if [ "$HANDLE_CMIRROR_SERVICE" ]; then
+                set_service activate lvm2-cmirrord.service
+            fi
+        else
+            set_service systemd deactivate lvm2-cluster-activation.service
+            if [ "$HANDLE_CMIRROR_SERVICE" ]; then
+                set_service systemd deactivate lvm2-cmirrord.service
+            fi
+        fi
+
+    # System V init scripts
+    elif [ -n "$SERVICE_BIN" -a -n "$CHKCONFIG_BIN" ]; then
+        if [ "$USE_LVMETAD" = "0" ]; then
+            set_service sysv deactivate lvm2-lvmetad
+        else
+            set_service sysv activate lvm2-lvmetad
+        fi
+
+        if [ "$LOCKING_TYPE" = "3" ]; then
+            set_service sysv activate clvmd
+            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+                set_service sysv activate cmirrord
+            fi
+        else
+            set_service sysv deactivate clvmd
+            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+                set_service sysv deactivate cmirrord
+            fi
+        fi
+
+    # None of the service tools found, error out
+    else
+        echo "Missing tools to handle services"
+        exit 20
+    fi
+fi


