From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 27 Jun 2019 05:14:54 -0400
Subject: master - test: Fix unbound variable
Message-ID: <201906270914.x5R9Ese3012638@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09f29570f2dac1a84f5ee24107df6461194b269a
Commit:        09f29570f2dac1a84f5ee24107df6461194b269a
Parent:        9ba45d824adc91b5767fd7a26c3ba83f7b23b250
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jun 27 10:41:21 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jun 27 10:41:21 2019 +0200

test: Fix unbound variable

Test `aux kernel_at_least 5 1` fails even for newer kernel
with `$3: unbound variable` when using `set -u`.
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 09ef9ed..0cc26a4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1387,17 +1387,17 @@ version_at_least() {
 	IFS=".-" read -r major minor revision <<< "$1"
 	shift
 
-	test -z "$1" && return 0
+	test -z "${1:-}" && return 0
 	test -n "$major" || return 1
 	test "$major" -gt "$1" && return 0
 	test "$major" -eq "$1" || return 1
 
-	test -z "$2" && return 0
+	test -n "$2" || return 0
 	test -n "$minor" || return 1
 	test "$minor" -gt "$2" && return 0
 	test "$minor" -eq "$2" || return 1
 
-	test -z "$3" && return 0
+	test -n "$3" || return 0
 	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 #


