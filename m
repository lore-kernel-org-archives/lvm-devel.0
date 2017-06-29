From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:13 -0400
Subject: master - tests: utils.sh no mixed string array
Message-ID: <201706292029.v5TKTDib026929@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00957450ebc08f82382eccef78ce405eeb4461fa
Commit:        00957450ebc08f82382eccef78ce405eeb4461fa
Parent:        c396053955c6481cfc753f498af9a61202ce2d91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:14:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: utils.sh no mixed string array

Argument mixes string and array. Use * or separate argument.
---
 test/lib/utils.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index c15eef3..fa072ba 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -223,7 +223,7 @@ skip() {
 	if test "$#" -eq 0; then
 		stacktrace
 	else
-		echo "TEST SKIPPED: $@"
+		echo "TEST SKIPPED:" "$@"
 	fi
 	touch SKIP_THIS_TEST
 	exit 200


