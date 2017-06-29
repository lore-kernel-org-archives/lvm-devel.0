From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:17 -0400
Subject: master - tests: aux.sh fix pid handling
Message-ID: <201706292028.v5TKSHCr026786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=491fcd2a921bea6d63bbb243bfd972fda3bb6c67
Commit:        491fcd2a921bea6d63bbb243bfd972fda3bb6c67
Parent:        96fcf82dddd7bcc7b5c09de09d49d70a04ae8b12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 21:00:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh fix pid handling

Modification of pids is local (to subshell caused by pipeline).
pids was modified in a subshell. That change might be lost.
---
 test/lib/aux.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f39d400..4e2b246 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -500,17 +500,20 @@ kill_tagged_processes() {
 	local wait
 
 	# read uses all vars within pipe subshell
+	rm -f PIDS
 	print_procs_by_tag_ "$@" | while read -r pid wait; do
 		if test -n "$pid" ; then
 			echo "Killing tagged process: $pid ${wait:0:120}..."
 			kill -TERM "$pid" 2>/dev/null || true
 		fi
-		pids="$pids $pid"
+		echo "$pid" >> PIDS
 	done
 
+	test -f PIDS || return 0
+
 	# wait if process exited and eventually -KILL
 	wait=0
-	for pid in $pids ; do
+	for pid in $(< PIDS) ; do
 		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .2
 			wait=$(( wait + 1 ))


