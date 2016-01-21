From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Jan 2016 13:47:57 +0000 (UTC)
Subject: master - vgimportclone: fix VG name variable reference in error message after failed PV uuid change
Message-ID: <20160121134757.12FF660D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55056c2d16a6cb6e0ce5b7179d62d4dc28cd790d
Commit:        55056c2d16a6cb6e0ce5b7179d62d4dc28cd790d
Parent:        22810155a65e1f2984e04a7f3984eec01d07b7b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 21 14:47:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jan 21 14:47:48 2016 +0100

vgimportclone: fix VG name variable reference in error message after failed PV uuid change

---
 scripts/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 86efeb4..d5b62a8 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -291,7 +291,7 @@ while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
     fi
 
     "$LVM" pvchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' --select "vg_name=${VGNAME}"
-    checkvalue $? "Unable to change all PV uuids in VG ${VG_NAME}"
+    checkvalue $? "Unable to change all PV uuids in VG ${VGNAME}"
 
     NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
 


