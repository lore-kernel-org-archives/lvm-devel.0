From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:12 -0400
Subject: master - vgimportclone.sh: add -r to read
Message-ID: <201706292027.v5TKRC4P026588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16a38dede95cbcd7bfd80bb2124ce205a20c5a2f
Commit:        16a38dede95cbcd7bfd80bb2124ce205a20c5a2f
Parent:        588b12e71d7f050ca14e6f9332e7a0ec6b66a4b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:26:23 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: add -r to read

read without -r will mangle backslashes.
---
 scripts/vgimportclone.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 26e4c1f..48ac6ce 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -259,7 +259,7 @@ NOVGDEVLIST=$("$LVM" pvs -a -o pv_name --select vg_name="" --noheadings)
 checkvalue $? "Failed to collect information for PV check"
 if [ -n "${NOVGDEVLIST}" ]; then
     FOLLOWLIST=""
-    while read PVNAME; do
+    while read -r PVNAME; do
         FOLLOW=$("$READLINK" "$PVNAME")
         FOLLOWLIST="$FOLLOWLIST $FOLLOW"
     done <<< "$(echo "$NOVGDEVLIST")"
@@ -272,7 +272,7 @@ fi
 VGLIST=$("$LVM" vgs -o vg_name,vg_exported,vg_missing_pv_count --noheadings --binary)
 checkvalue $? "Failed to collect VG information"
 
-while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
+while read -r VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
     if [ "$VGMISSINGPVCOUNT" -gt 0 ]; then
         echo "Volume Group ${VGNAME} has unknown PV(s), skipping."
         echo "- Were all associated PV(s) supplied as arguments?"


