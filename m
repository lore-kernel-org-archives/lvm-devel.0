From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 24 Jul 2019 10:30:52 -0400
Subject: master - tests: Fix unbound variable
Message-ID: <201907241430.x6OEUqJl002423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd19fa9ff36ce8a17452f83e6264bbf6c34f83ae
Commit:        dd19fa9ff36ce8a17452f83e6264bbf6c34f83ae
Parent:        aa58f9bd9b28e8b734a6d723234f9ed1de28265b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 23 15:36:13 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jul 24 16:30:15 2019 +0200

tests: Fix unbound variable

Test `aux kernel_at_least 5 1` fails even for newer kernel
with `$3: unbound variable` when using `set -u`.
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0cc26a4..e3f624c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1387,17 +1387,17 @@ version_at_least() {
 	IFS=".-" read -r major minor revision <<< "$1"
 	shift
 
-	test -z "${1:-}" && return 0
+	test -n "${1:-}" || return 0
 	test -n "$major" || return 1
 	test "$major" -gt "$1" && return 0
 	test "$major" -eq "$1" || return 1
 
-	test -n "$2" || return 0
+	test -n "${2:-}" || return 0
 	test -n "$minor" || return 1
 	test "$minor" -gt "$2" && return 0
 	test "$minor" -eq "$2" || return 1
 
-	test -n "$3" || return 0
+	test -n "${3:-}" || return 0
 	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 #


