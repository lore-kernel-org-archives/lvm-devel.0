From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:36 -0400
Subject: master - tests: check.sh simplify in_sync
Message-ID: <201707111522.v6BFMaHV015609@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41e11e0f210bf1c423e39a836dfcb7c4fa3c8032
Commit:        41e11e0f210bf1c423e39a836dfcb7c4fa3c8032
Parent:        5ab2676bac452e9875a970d0ece53983a6c16643
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 13:29:54 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

tests: check.sh simplify in_sync

Avoid calling sed.
---
 test/lib/check.sh |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index a61eb81..1829857 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -194,15 +194,13 @@ linear() {
 in_sync() {
 	local a
 	local b
+	local c
 	local idx
 	local type
 	local snap=""
 	local lvm_name="$1/$2"
-	local ignore_a=$3
-	local dm_name
-
-	dm_name=$(echo "$lvm_name" | sed s:-:--: | sed s:/:-:)
-	[ -z "$ignore_a" ] && ignore_a=0
+	local ignore_a=${3:-0}
+	local dm_name="$1-$2"
 
 	a=( $(dmsetup status "$dm_name") )  || \
 		die "Unable to get sync status of $1"
@@ -233,9 +231,10 @@ in_sync() {
 		;;
 	esac
 
-	b=( $(echo "${a[$idx]}" | sed s:/:' ':) )
+	b=${a[$idx]%%/*} # split ratio   x/y
+	c=${a[$idx]##*/}
 
-	if [ "${b[0]}" -eq 0 ] || [ "${b[0]}" != "${b[1]}" ]; then
+	if [ "$b" -eq 0 ] || [ "$b" != "$c" ]; then
 		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi


