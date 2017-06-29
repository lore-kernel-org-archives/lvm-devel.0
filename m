From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:45 -0400
Subject: master - lvmconf_lockingtype2: double quote
Message-ID: <201706292026.v5TKQjav026516@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=051c7f88cf8968feab241604cb09547e23a79599
Commit:        051c7f88cf8968feab241604cb09547e23a79599
Parent:        ef8691a2d22e6a7afabdcdde93676b562a5fcfa1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 21:13:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmconf_lockingtype2: double quote

---
 scripts/lvmconf_lockingtype2.sh |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/scripts/lvmconf_lockingtype2.sh b/scripts/lvmconf_lockingtype2.sh
index 225b41d..52929d3 100644
--- a/scripts/lvmconf_lockingtype2.sh
+++ b/scripts/lvmconf_lockingtype2.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the lvm2-cluster package.
 #
@@ -34,7 +34,7 @@ function usage
 function parse_args
 {
     while [ -n "$1" ]; do
-        case $1 in
+        case "$1" in
             --enable-cluster)
                 LOCKING_TYPE=2
                 shift
@@ -135,19 +135,19 @@ have_dir=1
 have_library=1
 have_global=1
 
-grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' "$CONFIGFILE"
 have_type=$?
 
-grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' "$CONFIGFILE"
 have_dir=$?
 
-grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' "$CONFIGFILE"
 have_library=$?
 
 # Those options are in section "global {" so we must have one if any are present.
 if [ "$have_type" = "0" ] || [ "$have_dir" = "0" ] || [ "$have_library" = "0" ]; then
     # See if we can find it...
-    grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
+    grep -q '^[[:blank:]]*global[[:blank:]]*{' "$CONFIGFILE"
     have_global=$?
     
     if [ "$have_global" = "1" ] 
@@ -171,7 +171,7 @@ then
 	LOCKING_TYPE=1
     fi
     if [ "$LOCKING_TYPE" = "2" ]; then
-        cat $CONFIGFILE - <<EOF > $TMPFILE
+        cat "$CONFIGFILE" - <<EOF > $TMPFILE
 global {
     # Enable locking for cluster LVM
     locking_type = $LOCKING_TYPE
@@ -230,8 +230,8 @@ else
         fi
     fi
 
-    echo -e $SEDCMD > $SCRIPTFILE
-    sed  <$CONFIGFILE >$TMPFILE -f $SCRIPTFILE
+    echo -e "$SEDCMD" > "$SCRIPTFILE"
+    sed  <"$CONFIGFILE" >"$TMPFILE" -f "$SCRIPTFILE"
     if [ $? != 0 ]
     then
 	echo "sed failed, $CONFIGFILE not updated"
@@ -242,18 +242,18 @@ fi
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


