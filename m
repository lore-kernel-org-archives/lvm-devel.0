From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:39 +0000 (UTC)
Subject: master - tests: aux works better with installed_testsuite
Message-ID: <20150422092039.33EAE60F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b161de2e5afac32ab99c3d5bb2ffe65be5dce13
Commit:        4b161de2e5afac32ab99c3d5bb2ffe65be5dce13
Parent:        7a64a157e13154a9b6a37a12a8d50a8e63f51478
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 11:04:47 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 11:18:31 2015 +0200

tests: aux works better with installed_testsuite

When test suite is used from installed rpm package
we need to handle things better.

This patch is rather first approach - expecting few more
tweaks needed.
---
 test/lib/aux.sh |   33 +++++++++++++++------------------
 1 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 15a689a..4e6961a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -31,7 +31,9 @@ prepare_clvmd() {
 	fi
 
 	# skip if we don't have our own clvmd...
-	(which clvmd 2>/dev/null | grep -q "$abs_builddir") || skip
+	if test -z "${installed_testsuite+varset}"; then
+		(which clvmd 2>/dev/null | grep -q "$abs_builddir") || skip
+	fi
 	# lvs is executed from clvmd - use our version
 	export LVM_BINARY=$(which lvm)
 
@@ -62,8 +64,9 @@ prepare_dmeventd() {
 	fi
 
 	# skip if we don't have our own dmeventd...
-	(which dmeventd 2>/dev/null | grep "$abs_builddir") || skip
-
+	if test -z "${installed_testsuite+varset}"; then
+		(which dmeventd 2>/dev/null | grep -q "$abs_builddir") || skip
+	fi
 	lvmconf "activation/monitoring = 1"
 
 	local run_valgrind=
@@ -84,8 +87,9 @@ prepare_lvmetad() {
 	test $# -eq 0 && default_opts="-l all"
 	rm -f debug.log strace.log
 	# skip if we don't have our own lvmetad...
-	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
-
+	if test -z "${installed_testsuite+varset}"; then
+		(which lvmetad 2>/dev/null | grep -q "$abs_builddir") || skip
+	fi
 	lvmconf "global/use_lvmetad = 1" \
 		"devices/md_component_detection = 0"
 
@@ -743,28 +747,21 @@ profileconf() {
 	profile_name="$1"
 	shift
 	generate_config "$@"
-	test -d etc/profile || mkdir etc/profile
+	mkdir -p etc/profile
 	mv -f "PROFILE_$profile_name" "etc/profile/$profile_name.profile"
 }
 
 prepare_profiles() {
-	test -d etc/profile || mkdir etc/profile
+	mkdir -p etc/profile
 	for profile_name in $@; do
-		test -L "$abs_top_builddir/test/lib/$profile_name.profile" || skip
-		cp "$abs_top_builddir/test/lib/$profile_name.profile" "etc/profile/$profile_name.profile"
+		test -L "lib/$profile_name.profile" || skip
+		cp "lib/$profile_name.profile" "etc/profile/$profile_name.profile"
 	done
 }
 
 apitest() {
-	local t=$1
-	shift
-	test -x "$abs_top_builddir/test/api/$t.t" || skip
-	"$abs_top_builddir/test/api/$t.t" "$@" && rm -f debug.log strace.log
-}
-
-api() {
-	test -x "$abs_top_builddir/test/api/wrapper" || skip
-	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log strace.log
+	test -x "api/$1.t" || skip
+	"api/$1.t" "${@:2}" && rm -f debug.log strace.log
 }
 
 mirror_recovery_works() {


