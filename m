From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 17:33:44 -0400
Subject: master - tests: require also no 'a' for in-sync
Message-ID: <201706232133.v5NLXiQl022602@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f48d1bf1474f4485d42a180c542618a416f00006
Commit:        f48d1bf1474f4485d42a180c542618a416f00006
Parent:        653bdedb83fecf2b4fe2f4c84664c72ffd911e41
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 21:14:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 23:32:44 2017 +0200

tests: require also no 'a' for in-sync

Raid easily reports  'idle' with 'a', so in this case
we will not report in-sync.
---
 test/lib/check.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 5eec936..f2e5ff4 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -228,8 +228,12 @@ in_sync() {
 		return 1
 	fi
 
-	[[ ${a[$(($idx - 1))]} =~ a ]] && [ $ignore_a -eq 0 ] && \
-		die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
+	if [[ ${a[$(($idx - 1))]} =~ a ]] ; then
+		[ $ignore_a -eq 0 ] && \
+			die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
+		echo "$lvm_name ($type$snap) is not in-sync"
+		return 1
+	fi
 
 	echo "$lvm_name ($type$snap) is in-sync \"${a[@]}\""
 }


