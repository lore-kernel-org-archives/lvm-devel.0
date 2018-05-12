From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:12 -0400
Subject: master - tests: fix check sysfs
Message-ID: <201805122139.w4CLdCg7005434@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca87674ea4f6fd12b9049ea2a6498a5cf191893e
Commit:        ca87674ea4f6fd12b9049ea2a6498a5cf191893e
Parent:        edede1d20f413a5baee5474e40cffd135c133bef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 23:01:52 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 23:01:52 2018 +0200

tests: fix check sysfs

Commit 810f856c2490eb1d5db858f26a26621c4a3477e0 missed to move
assign of P after setting maj & min.
---
 test/lib/check.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index c796104..8637619 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -422,10 +422,11 @@ sysfs() {
 	# read maj min and also convert hex to decimal
 	local maj
 	local min
-	local P="/sys/dev/block/$maj:$min/$2"
+	local P
 	local val
 	maj=$(($(stat -L --printf=0x%t "$1")))
 	min=$(($(stat -L --printf=0x%T "$1")))
+	P="/sys/dev/block/$maj:$min/$2"
 	val=$(< "$P") || return 0 # no sysfs ?
 	test "$val" -eq "$3" || \
 		die "$1: $P = $val differs from expected value $3!"


