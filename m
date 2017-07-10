From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:38:14 -0400
Subject: master - tests: mixes string and array
Message-ID: <201707101238.v6ACcE1J023841@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec05890026ac9f66797fdd44dad4c8ce02b857b6
Commit:        ec05890026ac9f66797fdd44dad4c8ce02b857b6
Parent:        4e2fd6f6abcb97fe9f8ec2b5843469e2b497df25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:24:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: mixes string and array

Argument mixes string and array. Use * or separate argument
---
 test/shell/select-report.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index 314e207..b879bf5 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -63,7 +63,7 @@ sel() {
 
 	# the number of lines on output must match
 	test "$items_found" -eq $# || {
-		echo "  >>> NUMBER OF ITEMS EXPECTED: $# ($@)"
+		echo "  >>> NUMBER OF ITEMS EXPECTED: $#" "$@"
 		echo "  >>> NUMBER OF ITEMS FOUND: $items_found ($(< $OUT_LOG_FILE))"
 		return 1
 	}


