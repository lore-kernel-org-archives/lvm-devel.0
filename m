From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:40 -0400
Subject: master - clvmd_fix_conf.sh: double quote
Message-ID: <201706292027.v5TKRe5Y026667@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=191dadc623e6fe07c380744c5a88b29d0f868a30
Commit:        191dadc623e6fe07c380744c5a88b29d0f868a30
Parent:        99925d0d416dd7664af0fc507480499f44a7915e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 22:07:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

clvmd_fix_conf.sh: double quote

---
 scripts/clvmd_fix_conf.sh |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/scripts/clvmd_fix_conf.sh b/scripts/clvmd_fix_conf.sh
index 079cf30..5716d06 100644
--- a/scripts/clvmd_fix_conf.sh
+++ b/scripts/clvmd_fix_conf.sh
@@ -63,21 +63,20 @@ have_dir=1
 have_library=1
 have_global=1
 
-grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' $LVMCONF
+grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' "$LVMCONF"
 have_type=$?
 
-grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' $LVMCONF
+grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' "$LVMCONF"
 have_dir=$?
 
-grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $LVMCONF
+grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' "$LVMCONF"
 have_library=$?
 
 # Those options are in section "global {" so we must have one if any are present.
-if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" ]
-then
+if [ "$have_type" = 0 ] || [ "$have_dir" = 0 ] || [ "$have_library" = 0 ] ; then
 
     # See if we can find it...
-    grep -q '^[[:blank:]]*global[[:blank:]]*{' $LVMCONF
+    grep -q '^[[:blank:]]*global[[:blank:]]*{' "$LVMCONF"
     have_global=$?
     
     if [ "$have_global" = "1" ] 
@@ -92,7 +91,7 @@ fi
 
 if [ "$have_global" = "1" ]
 then
-    cat $LVMCONF - <<EOF > $TMPFILE
+    cat "$LVMCONF" - <<EOF > "$TMPFILE"
 global {
     # Enable locking for cluster LVM
     locking_type = $locking_type
@@ -132,8 +131,8 @@ else
 	SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ locking_library = \"$LIB\""
     fi
 
-    echo -e $SEDCMD > $SCRIPTFILE
-    sed  <$LVMCONF >$TMPFILE -f $SCRIPTFILE
+    echo -e "$SEDCMD" > "$SCRIPTFILE"
+    sed  <"$LVMCONF" >"$TMPFILE" -f "$SCRIPTFILE"
     if [ $? != 0 ]
     then
 	echo "sed failed, $LVMCONF not updated"
@@ -144,19 +143,19 @@ fi
 # Now we have a suitably editted config file in a temp place,
 # backup the original and copy our new one into place.
 
-cp $LVMCONF $LVMCONF.nocluster
+cp "$LVMCONF" "$LVMCONF.nocluster"
 if [ $? != 0 ]
     then
     echo "failed to backup old config file, $LVMCONF not updated"
     exit 2
 fi
 
-cp $TMPFILE $LVMCONF
+cp "$TMPFILE" "$LVMCONF"
 if [ $? != 0 ]
     then
     echo "failed to copy new config file into place, check $LVMCONF is still OK"
     exit 3
 fi
 
-rm -f $SCRIPTFILE $TMPFILE
+rm -f "$SCRIPTFILE" "$TMPFILE"
 


