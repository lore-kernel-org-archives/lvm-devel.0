From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 19:22:48 -0400
Subject: master - tests: aux.sh better loop logic
Message-ID: <201707112322.v6BNMmrs010818@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2baac408fc8421b0f65d1cc9ec18470f330c36a1
Commit:        2baac408fc8421b0f65d1cc9ec18470f330c36a1
Parent:        b97f75b1331b112412073ffd54812375867d9de7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 01:14:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 01:21:44 2017 +0200

tests: aux.sh better loop logic

Instead of using pipe for read and haveing no chance
to modify shell vars inside such loop  use  <( )
and keep using bash arrays.
---
 test/lib/aux.sh |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fda826f..9f60430 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -504,20 +504,18 @@ kill_tagged_processes() {
 	local wait
 
 	# read uses all vars within pipe subshell
-	rm -f PIDS
-	print_procs_by_tag_ "$@" | while read -r pid wait; do
+	local pids=()
+	while read -r pid wait; do
 		if test -n "$pid" ; then
 			echo "## killing tagged process: $pid ${wait:0:120}..."
 			kill -TERM "$pid" 2>/dev/null || true
 		fi
-		echo "$pid" >> PIDS
-	done
-
-	test -s PIDS || return 0
+		pids+=( "$pid" )
+	done < <(print_procs_by_tag_ "$@")
 
 	# wait if process exited and eventually -KILL
 	wait=0
-	for pid in $(< PIDS) ; do
+	for pid in "${pids[@]}" ; do
 		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .2
 			wait=$(( wait + 1 ))


