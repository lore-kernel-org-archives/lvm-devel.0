From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 15:41:56 +0000 (GMT)
Subject: main - tests: improve check raid_leg_status
Message-ID: <20210324154156.D454B384B13C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1f5ca6751eeda5925638447b561b05bdf8a250c
Commit:        c1f5ca6751eeda5925638447b561b05bdf8a250c
Parent:        0783c661b9eb407b0b436559b6950deefc906b4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 16:05:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:38:12 2021 +0100

tests: improve  check raid_leg_status

Enhance function to wait until raid status gets consisten
(shifts from 0/xxxxx to something else)

If it would took too long fail the check.
---
 test/lib/check.sh | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 4deb78a74..5b119430d 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -436,10 +436,19 @@ sysfs() {
 raid_leg_status() {
 	local st
 	local val
-	st=$(dmsetup status "$1-$2")
-	val=$(echo "$st" | cut -d ' ' -f 6)
-	test "$val" = "$3" || \
-		die "$1-$2 status $val != $3  ($st)"
+
+	# Ignore inconsisten raid status 0/xxxxx idle
+	for i in {100..0} ; do
+		st=( $(dmsetup status $1-$2) ) || die "Unable to get status of $vg/$lv1"
+		b=( $(echo "${st[6]}" | sed s:/:' ':) )
+		[ "${b[0]}" = "0" ] || {
+			test "${st[5]}" = "$3" || break
+			return 0
+		}
+		sleep .1
+	done
+
+	die "$1-$2 status ${st[5]} != $3  ($st)"
 }
 
 grep_dmsetup() {


