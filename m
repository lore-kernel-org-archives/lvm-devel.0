From: Mike Snitzer <msnitzer@fedoraproject.org>
Date: Mon, 21 Oct 2013 22:08:58 +0000 (UTC)
Subject: master - vgimportclone: remove 2>/dev/null from three lvm commands
Message-ID: <20131021220858.1DCFC6096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65456a4a29d8f25ab75af2145b8a6b2a9ff391e5
Commit:        65456a4a29d8f25ab75af2145b8a6b2a9ff391e5
Parent:        7763607f3617188906dae9e9ae218e9099f5e6e9
Author:        Mike Snitzer <snitzer@redhat.com>
AuthorDate:    Mon Oct 21 18:04:14 2013 -0400
Committer:     Mike Snitzer <snitzer@redhat.com>
CommitterDate: Mon Oct 21 18:04:14 2013 -0400

vgimportclone: remove 2>/dev/null from three lvm commands

There is no point eating stderr for these commands.  In fact the
redirect causes confusion and hurts dubugging.

Also reword an error message if the pvs command fails so as not be
certain that a device is not a PV.  Coupled with removing the stderr
redirect this will improve the user experience in the face of errors.
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 96e6775..61aeb72 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Remove 2>/dev/null from three lvm commands executed by vgimportclone.
   Add configure --enable-udev-systemd-background-jobs.
   Add lvm2-pvscan at .service to run pvscan as a service for lvmetad/autoactivation.
   Fix lvconvert swap of poolmetadata volume for active thin pool.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index d6ad75d..7087557 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -204,8 +204,8 @@ for ARG
 do
     if [ -b "$ARG" ]
     then
-        PVS_OUT=`"${LVM}" pvs ${LVM_OPTS} --noheadings -o vg_name "$ARG" 2>/dev/null`
-        checkvalue $? "$ARG is not a PV."
+        PVS_OUT=`"${LVM}" pvs ${LVM_OPTS} --noheadings -o vg_name "$ARG"`
+        checkvalue $? "$ARG could not be verified to be a PV without errors."
         PV_VGNAME=$(echo $PVS_OUT | $GREP -v '[[:space:]]+$')
         [ -z "$PV_VGNAME" ] && die 3 "$ARG is not in a VG."
 
@@ -227,7 +227,7 @@ fi
 ### Get the existing state so we can use it later
 #####################################################################
 
-OLDVGS=`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings 2>/dev/null`
+OLDVGS=`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings`
 checkvalue $? "Current VG names could not be collected without errors"
 
 #####################################################################
@@ -280,7 +280,7 @@ export LVM_SYSTEM_DIR=${TMP_LVM_SYSTEM_DIR}
 ### Rename the VG(s) and change the VG and PV UUIDs.
 #####################################################################
 
-PVINFO=`"${LVM}" pvs ${LVM_OPTS} -o pv_name,vg_name,vg_attr --noheadings --separator : 2>/dev/null`
+PVINFO=`"${LVM}" pvs ${LVM_OPTS} -o pv_name,vg_name,vg_attr --noheadings --separator :`
 checkvalue $? "PV info could not be collected without errors"
 
 # output VG info so each line looks like: name:exported?:disk1,disk2,...


