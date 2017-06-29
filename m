From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:57 -0400
Subject: master - lvmconf: fix test for setting external locking type
Message-ID: <201706292025.v5TKPvwl025743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de04e36fda20dbf1bcfb155e6b2faf584cde791d
Commit:        de04e36fda20dbf1bcfb155e6b2faf584cde791d
Parent:        daa372f78d316ded212ffd703a9740ff80632d38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 17:22:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmconf: fix test for setting external locking type

Fix test for check of set locking lib dir.
---
 scripts/lvmconf.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index caf7fae..3aab4a0 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -134,7 +134,7 @@ function parse_args
         esac
     done
 
-    if [ "$LOCKINGLIBDIR" -o "$LOCKINGLIB" ]; then
+    if [ -n "$LOCKINGLIBDIR" ] || [ -n "$LOCKINGLIB" ]; then
         LOCKING_TYPE=2
         USE_LVMETAD=0
     fi


