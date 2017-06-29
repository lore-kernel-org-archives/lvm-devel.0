From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:21 -0400
Subject: master - vgimportclone.sh: use well defined tests
Message-ID: <201706292027.v5TKRLBm026619@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef4506069a1a29cd00532e36c24df9a01cd32600
Commit:        ef4506069a1a29cd00532e36c24df9a01cd32600
Parent:        8dc29d7cc7e86295116a4fb401315896b6793fa8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:35:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: use well defined tests

Prefer [ p ] && [ q ] as [ p -a q ] is not well defined.
Prefer [ p ] || [ q ] as [ p -o q ] is not well defined.
---
 scripts/vgimportclone.sh |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index ac52f01..7d3118f 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -95,8 +95,7 @@ function cleanup {
 SCRIPTNAME=$("$BASENAME" "$0")
 
 
-if [ "$UID" != "0" -a "$EUID" != "0" ]
-then
+if [ "$UID" != 0 ] && [ "$EUID" != 0 ]; then
     die 3 "${SCRIPTNAME} must be run as root."
 fi
 
@@ -183,14 +182,13 @@ do
 done
 
 # turn on DEBUG (special case associated with -v use)
-if [ -z "$DEBUG" -a $VERBOSE_COUNT -gt 3 ]; then
+if [ -z "$DEBUG" ] && [ "$VERBOSE_COUNT" -gt 3 ]; then
     DEBUG="-d"
     set -x
 fi
 
 # setup LVM_OPTS
-if [ -n "${DEBUG}" -o -n "${VERBOSE}" ]
-then
+if [ -n "$DEBUG" ] || [ -n "$VERBOSE" ]; then
     LVM_OPTS="${LVM_OPTS} ${DEBUG} ${VERBOSE}"
 fi
 


