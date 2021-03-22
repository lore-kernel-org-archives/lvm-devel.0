From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:50 +0000 (GMT)
Subject: main - tests: remove local changes
Message-ID: <20210322215350.A56013857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=77432ee13742d09af5e8b1f8813d65bda3556a1d
Commit:        77432ee13742d09af5e8b1f8813d65bda3556a1d
Parent:        daca6e2c225889a8ee4bfe4f4724d92481df2558
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 10:15:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:36:37 2021 +0100

tests: remove local changes

Use aux for preparing profile.
Avoid playing with LVM_BINARY localy - we already
preset this variable in lib/utils.
---
 test/api/dbustest.sh | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index f7d2e91a8..d922d903f 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -28,18 +28,7 @@ aux extend_filter_LVMTEST
 
 # We need the lvmdbusd.profile for the daemon to utilize JSON
 # output
-mkdir -p "$TESTDIR/etc/profile"
-cp -v "$TESTOLDPWD/lib/lvmdbusd.profile" "$TESTDIR/etc/profile/"
-
-# Need to set this up so that the lvmdbusd service knows which
-# binary to be running, which should be the one we just built
-LVM_BINARY=$(which lvm 2>/dev/null)
-export LVM_BINARY
-
-# skip if we don't have our own lvmetad...
-if test -z "${installed_testsuite+varset}"; then
-	(echo "$LVM_BINARY" | grep -q "$abs_builddir") || skip
-fi
+aux prepare_profiles "lvmdbusd"
 
 aux prepare_lvmdbusd
 


