From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:38 -0500
Subject: master - tests: use LVM_SYSTEM_DIR for etc
Message-ID: <201703101836.v2AIabFM032467@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c717011f8eb8df047bf82065a1136f86595cfe72
Commit:        c717011f8eb8df047bf82065a1136f86595cfe72
Parent:        a9b78d26b13fb759d3dbf2834c3ce365aaba44b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 2 23:01:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

tests: use LVM_SYSTEM_DIR for etc

Instead of hardcoding etc/ dir  use $LVM_SYSTEM_DIR.
---
 test/lib/aux.sh |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b0e6556..bc10b44 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1213,22 +1213,24 @@ EOF
 lvmconf() {
 	unset profile_name
 	generate_config "$@"
-	mv -f CONFIG etc/lvm.conf
+	mv -f CONFIG "$LVM_SYSTEM_DIR/lvm.conf"
 }
 
 profileconf() {
+	local pdir="$LVM_SYSTEM_DIR/profile"
 	profile_name="$1"
 	shift
 	generate_config "$@"
-	mkdir -p etc/profile
-	mv -f "PROFILE_$profile_name" "etc/profile/$profile_name.profile"
+	mkdir -p $pdir
+	mv -f "PROFILE_$profile_name" "$pdir/$profile_name.profile"
 }
 
 prepare_profiles() {
-	mkdir -p etc/profile
+	local pdir="$LVM_SYSTEM_DIR/profile"
+	mkdir -p $pdir
 	for profile_name in $@; do
 		test -L "lib/$profile_name.profile" || skip
-		cp "lib/$profile_name.profile" "etc/profile/$profile_name.profile"
+		cp "lib/$profile_name.profile" "$pdir/$profile_name.profile"
 	done
 }
 


