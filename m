From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:59:53 +0000 (UTC)
Subject: master - tests: check for idle only for raid type
Message-ID: <20150527095953.5038060BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=778b66a7199b5fe05d59df55bd23e681759c2bbe
Commit:        778b66a7199b5fe05d59df55bd23e681759c2bbe
Parent:        6e4c04b1becf171d6c337771839cf5a82bd901c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 27 11:59:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:59:10 2015 +0200

tests: check for idle only for raid type

---
 test/lib/check.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 23af3a9..a6a9b38 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -202,6 +202,10 @@ in_sync() {
 		# 6th argument is the sync ratio for RAID
 		idx=6
 		type=${a[3]}
+		if [ ${a[$(($idx + 1))]} != "idle" ]; then
+			echo "$lvm_name ($type$snap) is not in-sync"
+			return 1
+		fi
 	elif [ ${a[2]} = "mirror" ]; then
 		# 4th Arg tells us how far to the sync ratio
 		idx=$((${a[3]} + 4))
@@ -212,7 +216,7 @@ in_sync() {
 
 	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
 
-	if [ ${a[$(($idx + 1))]} != "idle" -o ${b[0]} -eq 0 -o ${b[0]} != ${b[1]} ]; then
+	if [ ${b[0]} -eq 0 -o ${b[0]} != ${b[1]} ]; then
 		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi
@@ -222,7 +226,6 @@ in_sync() {
 	fi
 
 	echo "$lvm_name ($type$snap) is in-sync"
-	return 0
 }
 
 active() {


