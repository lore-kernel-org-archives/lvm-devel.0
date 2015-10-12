From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Oct 2015 09:13:39 +0000 (UTC)
Subject: master - vgimportclone: fix vgimportclone with -n to not add number unnecessarily to base VG name
Message-ID: <20151012091339.A0BCC606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38df48d108e3b040501edfd9e0517bfcb31373de
Commit:        38df48d108e3b040501edfd9e0517bfcb31373de
Parent:        21a8ac0cd3a392feaa049ab509c4727eee548d6b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 12 11:11:34 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 12 11:11:34 2015 +0200

vgimportclone: fix vgimportclone with -n to not add number unnecessarily to base VG name

$ vgcreate vgA /dev/sda
  Volume group "vgA" successfully created

$ dd if=/dev/sda of=/dev/sdb bs=1M
$ dd if=/dev/sda of=/dev/sdc bs=1M

(the new VG name is prefix of existing VG name)
$ vgimportclone -n vg /dev/sdb

(the new VG name is suffix of existing VG name)
$ vgimportclone -n gA /dev/sdc

Before this patch:
------------------
(we end up with "vg1" and "gA1" names with the "1" suffix which is not needed)
$ vgs -o vg_name
  VG
  gA1
  vg1
  vgA

With this patch applied:
------------------------
(we end up with "vg" and "gA" names as they're unique already and no extra suffix is added)
$ # vgs -o vg_name
  VG
  gA
  vg
  vgA

Of course, if the name supplied is not unique, the number is added correctly:
$ dd if=/dev/sda of=/dev/sdb bs=1M
$ vgimportclone -n vgA /dev/sdb
$ vgs -o vg_name
  VG
  vgA
  vgA1
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9af759e..5fa6e7f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Fix vgimportclone with -n to not add number unnecessarily to base VG name.
   Cleanup vgimportclone script and remove dependency on awk, grep, cut and tr.
   Add vg_missing_pv_count report field to report number of missing PVs in a VG.
   Properly identify internal LV holding sanlock locks within lv_role field.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index d14a170..52f3884 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -48,7 +48,7 @@ function getvgname {
     NAME="${BNAME}"
     I=0
 
-    while [[ "${VGLIST}" =~ "${NAME}" ]]
+    while [[ "${VGLIST}" =~ ":${NAME}:" ]]
     do
         I=$(($I+1))
         NAME="${BNAME}$I"
@@ -215,10 +215,12 @@ then
 fi
 
 #####################################################################
-### Get the existing state so we can use it later
+### Get the existing state so we can use it later.
+### The list of VG names is saved in this format:
+###     :vgname1:vgname2:...:vgnameN:
 #####################################################################
 
-OLDVGS=`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings`
+OLDVGS=":`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings --rows --separator :`:"
 checkvalue $? "Current VG names could not be collected without errors"
 
 #####################################################################


