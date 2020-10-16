From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:20 +0000 (GMT)
Subject: stable-2.02 - tests: fix unbound variable
Message-ID: <20201016191220.A7F05396EC6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1db024e169c3c6af08477524e8048d54b678714
Commit:        d1db024e169c3c6af08477524e8048d54b678714
Parent:        6b3d0166ee2057ddaac3e73955e07acb1204be42
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 23 15:36:13 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: fix unbound variable

Test `aux kernel_at_least 5 1` fails even for newer kernel
with `$3: unbound variable` when using `set -u`.
---
 test/lib/aux.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a84d41189..7235e69b8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1548,17 +1548,17 @@ version_at_least() {
 	IFS=".-" read -r major minor revision <<< "$1"
 	shift
 
-	test -z "$1" && return 0
+	test -n "${1:-}" || return 0
 	test -n "$major" || return 1
 	test "$major" -gt "$1" && return 0
 	test "$major" -eq "$1" || return 1
 
-	test -z "$2" && return 0
+	test -n "${2:-}" || return 0
 	test -n "$minor" || return 1
 	test "$minor" -gt "$2" && return 0
 	test "$minor" -eq "$2" || return 1
 
-	test -z "$3" && return 0
+	test -n "${3:-}" || return 0
 	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 #


