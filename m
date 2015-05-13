From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:20:00 +0000 (UTC)
Subject: master - configure: set optimize flags when CFLAGS is unset
Message-ID: <20150513222000.48F4A600E7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fa66d103652df217059e2629da816adb9599e7c
Commit:        3fa66d103652df217059e2629da816adb9599e7c
Parent:        f207a6d353c895c6078f8345340228a2a790a659
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 21:30:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:33 2015 +0200

configure: set optimize flags when CFLAGS is unset

If we are given CFLAGS - preserve user's request and avoid placing
just -O2 there.
---
 configure    |    6 +++---
 configure.in |    4 +---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index 9485c2b..c4d714b 100755
--- a/configure
+++ b/configure
@@ -3033,10 +3033,11 @@ test -n "$target_alias" &&
     NONENONEs,x,x, &&
   program_prefix=${target_alias}-
 
+if test -z "$CFLAGS"; then :
+  COPTIMISE_FLAG="-O2"
+fi
 case "$host_os" in
 	linux*)
-		CFLAGS="$CFLAGS"
-		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -3056,7 +3057,6 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
diff --git a/configure.in b/configure.in
index 5933763..161f832 100644
--- a/configure.in
+++ b/configure.in
@@ -26,10 +26,9 @@ AC_CONFIG_AUX_DIR(autoconf)
 dnl -- Get system type
 AC_CANONICAL_TARGET([])
 
+AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
 case "$host_os" in
 	linux*)
-		CFLAGS="$CFLAGS"
-		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -49,7 +48,6 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"


