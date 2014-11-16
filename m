From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 16 Nov 2014 23:45:20 +0000 (UTC)
Subject: master - tests: reduce number of sync waiting
Message-ID: <20141116234520.626C260EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a1c609ac49852b50d45a4dd292a61b7cbb9c25f
Commit:        3a1c609ac49852b50d45a4dd292a61b7cbb9c25f
Parent:        776934aa0811727405434698ab25b2c1e7722fa6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 17 00:34:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 17 00:34:44 2014 +0100

tests: reduce number of sync waiting

Lets assume faster systems, if we have too big raid arrays,
reduce them.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1c168f0..8da834c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -753,7 +753,7 @@ udev_wait() {
 # wait_for_sync <VG/LV>
 wait_for_sync() {
 	local i
-	for i in {1..3000} ; do
+	for i in {1..100} ; do
 		check in_sync $1 $2 && return
 		sleep .2
 	done


