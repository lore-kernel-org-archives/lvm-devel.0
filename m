From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:23 +0000 (GMT)
Subject: master - tests: aux collects stack trace when stuck is assumed
Message-ID: <20200910215623.B1C873985431@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f2e9e35467a2a92837a9859b150cf091411583b
Commit:        3f2e9e35467a2a92837a9859b150cf091411583b
Parent:        49d2b27a687da0bffcfc2517576bcf364aac90c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 17:05:02 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:55:03 2020 +0200

tests: aux collects stack trace when stuck is assumed

Automatically collect traces in this case.
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d5509a763..1418bb473 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1480,6 +1480,7 @@ wait_for_sync() {
 	done
 
 	echo "Sync is taking too long - assume stuck"
+	echo t >/proc/sysrq-trigger 2>/dev/null
 	return 1
 }
 


