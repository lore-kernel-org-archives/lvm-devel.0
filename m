From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:17 +0000 (GMT)
Subject: stable-2.02 - tests: aux collects stack trace when stuck is assumed
Message-ID: <20201016191117.D66ED396E83D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c563af047643b18b6ebc369a77ecf094dd2a5f11
Commit:        c563af047643b18b6ebc369a77ecf094dd2a5f11
Parent:        57585ebacd54d7d0f4e80cf11e062e652d019539
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 17:05:02 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: aux collects stack trace when stuck is assumed

Automatically collect traces in this case.
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3c39151ae..b5f81dc74 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1517,6 +1517,7 @@ wait_for_sync() {
 	done
 
 	echo "Sync is taking too long - assume stuck"
+	echo t >/proc/sysrq-trigger 2>/dev/null
 	return 1
 }
 


