From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:47 -0400
Subject: master - tests: check.sh better if
Message-ID: <201706292028.v5TKSlWm026858@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51237cb5047a93382f8d239e9aa9d3899154300f
Commit:        51237cb5047a93382f8d239e9aa9d3899154300f
Parent:        db338c2b42abb6b5274fba5f93a982241afa8ecf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 09:40:01 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh better if

Prefer [ p ] || [ q ] as [ p -o q ] is not well defined.
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 8555235..64019da 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -225,7 +225,7 @@ in_sync() {
 
 	b=( $(echo "${a[$idx]}" | sed s:/:' ':) )
 
-	if [ "${b[0]}" -eq 0 -o "${b[0]}" != "${b[1]}" ]; then
+	if [ "${b[0]}" -eq 0 ] || [ "${b[0]}" != "${b[1]}" ]; then
 		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi


