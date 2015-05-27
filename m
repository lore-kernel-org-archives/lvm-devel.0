From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:11:52 +0000 (UTC)
Subject: master - tests: better check for array in sync
Message-ID: <20150527091152.386196118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0a4955eb1e9fe070d10f451d9d296ceb665fbaa
Commit:        f0a4955eb1e9fe070d10f451d9d296ceb665fbaa
Parent:        c254743ef31f1d36f85329cad1a5c3b55fca2bb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 26 13:11:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:10:43 2015 +0200

tests: better check for array in sync

Update check for raid array being in sync - getting somewhat complex.
It's another way to fight with problems in:
https://bugzilla.redhat.com/show_bug.cgi?id=1210637
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 5244290..23af3a9 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -212,7 +212,7 @@ in_sync() {
 
 	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
 
-	if [ ${b[0]} != ${b[1]} ]; then
+	if [ ${a[$(($idx + 1))]} != "idle" -o ${b[0]} -eq 0 -o ${b[0]} != ${b[1]} ]; then
 		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi


