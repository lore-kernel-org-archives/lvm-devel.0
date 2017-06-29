From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:42 -0400
Subject: master - lvmconf_lockingtype2: preferable syntax
Message-ID: <201706292026.v5TKQg7f026498@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef8691a2d22e6a7afabdcdde93676b562a5fcfa1
Commit:        ef8691a2d22e6a7afabdcdde93676b562a5fcfa1
Parent:        030912ec03f4ad1874351dbfb2048fa73477d914
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 21:09:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmconf_lockingtype2: preferable syntax

Prefer [ p ] || [ q ] as [ p -o q ] is not well defined.
---
 scripts/lvmconf_lockingtype2.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/scripts/lvmconf_lockingtype2.sh b/scripts/lvmconf_lockingtype2.sh
index 395ef07..225b41d 100644
--- a/scripts/lvmconf_lockingtype2.sh
+++ b/scripts/lvmconf_lockingtype2.sh
@@ -110,8 +110,10 @@ function validate_args
         
     fi
 
-    if [ "$LOCKING_TYPE" = "1" ] && [ -n "$LOCKINGLIBDIR" -o -n "$LOCKINGLIB" ]; then
-	echo "Superfluous locking lib parameter, ignoring"
+    if [ "$LOCKING_TYPE" = "1" ] ; then
+	if [ -n "$LOCKINGLIBDIR" ] || [ -n "$LOCKINGLIB" ]; then
+	    echo "Superfluous locking lib parameter, ignoring"
+	fi
     fi
 }
 
@@ -143,9 +145,7 @@ grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $CONFIGFILE
 have_library=$?
 
 # Those options are in section "global {" so we must have one if any are present.
-if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" ]
-then
-
+if [ "$have_type" = "0" ] || [ "$have_dir" = "0" ] || [ "$have_library" = "0" ]; then
     # See if we can find it...
     grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
     have_global=$?


