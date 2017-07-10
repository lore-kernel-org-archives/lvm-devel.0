From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:46 -0400
Subject: master - tests: cleaner written eval
Message-ID: <201707101228.v6ACSkpM022107@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c0a92ee8dc4eca67f53b72f190e7c038ae984d4
Commit:        9c0a92ee8dc4eca67f53b72f190e7c038ae984d4
Parent:        ec05890026ac9f66797fdd44dad4c8ce02b857b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:24:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: cleaner written eval

Although code work this coding style is better.
This \c will be a regular 'c' in this context.
---
 test/shell/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index fed7eb4..35c3443 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -80,7 +80,7 @@ fscheck_reiserfs()
 check_missing()
 {
 	local t
-	eval t=$\check_$1
+	eval "t=\$check_$1"
 	test -z "$t" && return 0
 	test "$t" = skip && return 1
 	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing."


