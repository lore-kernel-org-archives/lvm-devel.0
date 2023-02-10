From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 21:33:27 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230210213327.76E953858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=615347da20f7ede98c3cc8b1fd0aaaae15603c6e
Commit:        615347da20f7ede98c3cc8b1fd0aaaae15603c6e
Parent:        1416bb383719f5d4dde42a9bfb123e0a7c38a36c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 21:30:57 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 22:31:43 2023 +0100

configure: update

---
 configure | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index e84333ec7..7b160639f 100755
--- a/configure
+++ b/configure
@@ -12933,6 +12933,19 @@ fi
 #       so lvresize can check detected flag here
 #
 DEFAULT_USE_BLKID_WIPING=0
+if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  HAVE_BLKID="yes"
+else
+  HAVE_BLKID="no"
+fi
+
+if test "$HAVE_BLKID" = "yes"
+then :
 
 
 pkg_failed=no
@@ -13024,10 +13037,9 @@ else
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
-	HAVE_BLKID=1
 
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkdid.h defines BLKID_SUBLKS_FSINFO." >&5
-printf %s "checking for blkdid.h defines BLKID_SUBLKS_FSINFO.... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkid.h defines BLKID_SUBLKS_FSINFO." >&5
+printf %s "checking for blkid.h defines BLKID_SUBLKS_FSINFO.... " >&6; }
 if test ${ac_cv_have_blkid_sublks_fsinfo+y}
 then :
   printf %s "(cached) " >&6
@@ -13057,7 +13069,7 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkid_sublks_fsinfo" >&5
 printf "%s\n" "$ac_cv_have_blkid_sublks_fsinfo" >&6; }
 
-		if test $ac_cv_have_blkid_sublks_fsinfo = yes
+	if test $ac_cv_have_blkid_sublks_fsinfo = yes
 then :
 
 printf "%s\n" "#define HAVE_BLKID_SUBLKS_FSINFO 1" >>confdefs.h
@@ -13066,13 +13078,15 @@ fi
 
 fi
 
+fi
+
 if test "$BLKID_WIPING" != "no"
 then :
 
-	if test "$HAVE_BLKID" = 1
+	if test "$HAVE_BLKID" = "yes"
 then :
 
-		BLKID_WIPING=yes
+		BLKID_WIPING="yes"
 		BLKID_PC="blkid"
 		DEFAULT_USE_BLKID_WIPING=1
 

