From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:22 -0400
Subject: master - vgimportclone.sh: drop extra $
Message-ID: <201706292027.v5TKRMVB026624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8dc29d7cc7e86295116a4fb401315896b6793fa8
Commit:        8dc29d7cc7e86295116a4fb401315896b6793fa8
Parent:        16a38dede95cbcd7bfd80bb2124ce205a20c5a2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:31:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: drop extra $

$/${} is unnecessary on arithmetic variables.
---
 scripts/vgimportclone.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 48ac6ce..ac52f01 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -50,7 +50,7 @@ function getvgname {
 
     while [[ "${VGLIST}" =~ ":${NAME}:" ]]
     do
-        I=$(($I+1))
+        I=$(( I + 1 ))
         NAME="${BNAME}$I"
     done
     echo "${NAME}"
@@ -201,7 +201,7 @@ do
     then
         ln -s "$ARG" "${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
         DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
-        DEVNO=$((${DEVNO}+1))
+        DEVNO=$(( DEVNO + 1 ))
     else
         die 3 "$ARG is not a block device."
     fi


