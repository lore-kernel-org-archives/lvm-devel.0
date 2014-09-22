From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:26 +0000 (UTC)
Subject: dev-dct-process-latest - tests: update lv_no_exists
Message-ID: <20140922153826.CF27E60EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10a448eb2fdc795d144f13ba4a7d83351eb8c9df
Commit:        10a448eb2fdc795d144f13ba4a7d83351eb8c9df
Parent:        f435bef957cea11a16d15ea10a1d85193bacd736
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 15 13:45:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 15 13:51:19 2014 +0200

tests: update lv_no_exists

On successful exit path remove debug.log file.
---
 test/lib/check.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index cd29ef4..add8fb8 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -259,8 +259,9 @@ lv_exists() {
 lv_not_exists() {
 	local vg=$1
 	if test $# -le 1 ; then
-		lvl $vg &>/dev/null || return
-		die "$vg expected to not exist but it does!"
+		if lvl $vg &>/dev/null ; then
+			die "$vg expected to not exist but it does!"
+		fi
 	else
 		while [ $# -gt 1 ]; do
 			shift
@@ -268,6 +269,7 @@ lv_not_exists() {
 			die "$vg/$1 expected to not exist but it does!"
 		done
 	fi
+	rm -f debug.log
 }
 
 pv_field() {


