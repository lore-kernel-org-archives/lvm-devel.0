From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 20 Jan 2015 19:13:11 +0000 (UTC)
Subject: master - vgimportclone: remove arg check that uses pvs
Message-ID: <20150120191311.693A06063C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a164d603d386c5daed06b46316ef3c001807dff9
Commit:        a164d603d386c5daed06b46316ef3c001807dff9
Parent:        404c834e14657645d70d19b825d328bff5b165b7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 20 13:08:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 20 13:08:22 2015 -0600

vgimportclone: remove arg check that uses pvs

The arg check using pvs is unnecessary.  If the arg is not a PV,
the command will just fail later.  Using the pvs command at this
point in the command is a problem when lvmetad is running, because
the pvs command does not report duplicate PVs when using lvmetad.
(Alternatively, use_lvmetad could be disabled by adding a --config
override to this pvs command.)
---
 scripts/vgimportclone.sh |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 9d319bd..388d14c 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -204,11 +204,6 @@ for ARG
 do
     if [ -b "$ARG" ]
     then
-        PVS_OUT=`"${LVM}" pvs ${LVM_OPTS} --noheadings -o vg_name "$ARG"`
-        checkvalue $? "$ARG could not be verified to be a PV without errors."
-        PV_VGNAME=$(echo $PVS_OUT | $GREP -v '[[:space:]]+$')
-        [ -z "$PV_VGNAME" ] && die 3 "$ARG is not in a VG."
-
         ln -s "$ARG" ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}
         DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
         DEVNO=$((${DEVNO}+1))


