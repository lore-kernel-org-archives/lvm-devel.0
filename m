From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:43 -0400
Subject: master - tests: check.sh drop unnecessary $
Message-ID: <201706292028.v5TKShZO026843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db338c2b42abb6b5274fba5f93a982241afa8ecf
Commit:        db338c2b42abb6b5274fba5f93a982241afa8ecf
Parent:        c0197040a5c68af8314b5466c8b1f61b381044f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 09:37:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh drop unnecessary $

$/${} is unnecessary on arithmetic variables.
---
 test/lib/check.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 1ec1bab..8555235 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -208,14 +208,14 @@ in_sync() {
 		# 6th argument is the sync ratio for RAID
 		idx=6
 		type=${a[3]}
-		if [ "${a[$(($idx + 1))]}" != "idle" ]; then
+		if [ "${a[$(( idx + 1 ))]}" != "idle" ]; then
 			echo "$lvm_name ($type$snap) is not in-sync"
 			return 1
 		fi
 		;;
 	"mirror")
 		# 4th Arg tells us how far to the sync ratio
-		idx=$((${a[3]} + 4))
+		idx=$(( a[3] + 4 ))
 		type=${a[2]}
 		;;
 	*)
@@ -230,7 +230,7 @@ in_sync() {
 		return 1
 	fi
 
-	if [[ ${a[$(($idx - 1))]} =~ a ]] ; then
+	if [[ ${a[$(( idx - 1 ))]} =~ a ]] ; then
 		[ $ignore_a -eq 0 ] && \
 			die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
 		echo "$lvm_name ($type$snap) is not in-sync"


