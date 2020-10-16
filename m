From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:28 +0000 (GMT)
Subject: stable-2.02 - tests: check in_sync prints also dm status
Message-ID: <20201016191128.225EC396EC6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ebc8875d3f09cd446d1001361dc81af4cb8ded3
Commit:        4ebc8875d3f09cd446d1001361dc81af4cb8ded3
Parent:        0881ba9e9f32144d5a538b9920367c494513d23a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 19:04:56 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: check in_sync prints also dm status

It's more useful to see how the progress of status checking is moving.
---
 test/lib/check.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 8637619f4..4deb78a74 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -216,7 +216,7 @@ in_sync() {
 		idx=6
 		type=${a[3]}
 		if [ "${a[$(( idx + 1 ))]}" != "idle" ]; then
-			echo "$lvm_name ($type$snap) is not in-sync"
+			echo "$lvm_name ($type$snap) is not in-sync    " "${a[@]}"
 			return 1
 		fi
 		;;
@@ -234,19 +234,19 @@ in_sync() {
 	c=${a[$idx]##*/}
 
 	if [ "$b" -eq 0 ] || [ "$b" != "$c" ]; then
-		echo "$lvm_name ($type$snap) is not in-sync"
+		echo "$lvm_name ($type$snap) is not in-sync    " "${a[@]}"
 		return 1
 	fi
 
 	if [[ ${a[$(( idx - 1 ))]} =~ a ]] ; then
 		[ "$ignore_a" = 0 ] && \
 			die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
-		echo "$lvm_name ($type$snap) is not in-sync"
+		echo "$lvm_name ($type$snap) is not in-sync    " "${a[@]}"
 		[ "$ignore_a" = 1 ] && return 0
 		return 1
 	fi
 
-	echo "$lvm_name ($type$snap) is in-sync" "${a[@]}"
+	echo "$lvm_name ($type$snap) is in-sync    " "${a[@]}"
 }
 
 active() {


