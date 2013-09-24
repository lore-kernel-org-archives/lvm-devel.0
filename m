From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Sep 2013 12:06:56 +0000 (UTC)
Subject: master - lvmconf: use_lvmetad=0 on --enable-cluster, reset to default on --disable-cluster
Message-ID: <20130924120656.98A6260E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6553f86818404cd34fa3600dc976ed25fcf6d65a
Commit:        6553f86818404cd34fa3600dc976ed25fcf6d65a
Parent:        f050278a35ec0049fa333ce82abfc2bf6a231c62
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 24 14:03:42 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 24 14:03:42 2013 +0200

lvmconf: use_lvmetad=0 on --enable-cluster, reset to default on --disable-cluster

lvmetad is not yet supported in clustered environment so
disable it automatically if using lvmconf --enable-cluster
and reset it to default value if using lvmconf --disable-cluster.

Also, add a few comments in lvm.conf about locking_type vs. use_lvmetad
if setting it for clustered environment.
---
 WHATS_NEW            |    1 +
 conf/example.conf.in |    8 ++++++++
 man/lvmconf.8.in     |    4 +++-
 scripts/lvmconf.sh   |   19 ++++++++++++++++++-
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac2a84e..1aebdf4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Set use_lvmetad=0 on lvmconf --enable-cluster, reset to default on --disable-cluster.
   Don't install separate command symlink in binary directory for 'lvm devtypes'.
   Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index fb96079..6adcecf 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -432,6 +432,10 @@ global {
     # Type 3 uses built-in clustered locking.
     # Type 4 uses read-only locking which forbids any operations that might 
     # change metadata.
+    # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
+    # supported in clustered environment. If use_lvmetad=1 and locking_type=3
+    # is set at the same time, LVM always issues a warning message about this
+    # and then it automatically disables lvmetad use.
     locking_type = 1
 
     # Set to 0 to fail when a lock request cannot be satisfied immediately.
@@ -571,6 +575,10 @@ global {
     # setting itself.
     # To prevent scanning devices completely, even when using lvmetad,
     # the devices/global_filter must be used.
+    # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
+    # supported in clustered environment. If use_lvmetad=1 and locking_type=3
+    # is set at the same time, LVM always issues a warning message about this
+    # and then it automatically disables lvmetad use.
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device
diff --git a/man/lvmconf.8.in b/man/lvmconf.8.in
index 0722e22..2c822ee 100644
--- a/man/lvmconf.8.in
+++ b/man/lvmconf.8.in
@@ -22,10 +22,12 @@ an lvm configuration file. See \fBlvm.conf\fP(5).
 .SH "OPTIONS"
 .TP
 .BR \-\-disable-cluster
-Set \fBlocking_type\fR to the default non-clustered type.
+Set \fBlocking_type\fR to the default non-clustered type. Also reset
+lvmetad use to its default.
 .TP
 .BR \-\-enable-cluster
 Set \fBlocking_type\fR to the default clustered type on this system.
+Also disable lvmetad use as it is not yet supported in clustered environment.
 .TP
 .BR \-\-file " <" \fIconfigfile >
 Apply the changes to \fIconfigfile\fP instead of the default
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index 5a8e9e8..bfe518e 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -16,6 +16,8 @@
 # Edit an lvm.conf file to adjust various properties
 #
 
+DEFAULT_USE_LVMETAD=0
+
 function usage
 {
     echo "usage: $0 <command>"
@@ -37,10 +39,12 @@ function parse_args
         case $1 in
             --enable-cluster)
                 LOCKING_TYPE=3
+                USE_LVMETAD=0
                 shift
                 ;;
             --disable-cluster)
                 LOCKING_TYPE=1
+                USE_LVMETAD=$DEFAULT_USE_LVMETAD
                 shift
                 ;;
             --lockinglibdir)
@@ -129,6 +133,7 @@ TMPFILE=/etc/lvm/.lvmconf-tmp.tmp
 have_type=1
 have_dir=1
 have_library=1
+have_use_lvmetad=1
 have_global=1
 
 grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' $CONFIGFILE
@@ -140,8 +145,11 @@ have_dir=$?
 grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $CONFIGFILE
 have_library=$?
 
+grep -q '^[[:blank:]]*use_lvmetad[[:blank:]]*=' $CONFIGFILE
+have_use_lvmetad=$?
+
 # Those options are in section "global {" so we must have one if any are present.
-if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" ]
+if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" -o "$have_use_lvmetad" = "0" ]
 then
 
     # See if we can find it...
@@ -174,6 +182,8 @@ global {
     # Enable locking for cluster LVM
     locking_type = $LOCKING_TYPE
     library_dir = "$LOCKINGLIBDIR"
+    # Disable lvmetad in cluster
+    use_lvmetad = 0
 EOF
         if [ $? != 0 ]
         then
@@ -233,6 +243,13 @@ else
         fi
     fi
 
+    if [ "$have_use_lvmetad" = "0" ]
+    then
+        SEDCMD="${SEDCMD}\ns'^[[:blank:]]*use_lvmetad[[:blank:]]*=.*'\ \ \ \ use_lvmetad = $USE_LVMETAD'g"
+    else
+        SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ use_lvmetad = $USE_LVMETAD"
+    fi
+
     echo -e $SEDCMD > $SCRIPTFILE
     sed  <$CONFIGFILE >$TMPFILE -f $SCRIPTFILE
     if [ $? != 0 ]


