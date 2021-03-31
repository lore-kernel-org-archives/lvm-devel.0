From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:33 +0000 (GMT)
Subject: dev-next - tests: remove incorrect check
Message-ID: <20210331214833.2C9F13857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1858d209d7b6f0e0db232567c886cfcf374dba1
Commit:        f1858d209d7b6f0e0db232567c886cfcf374dba1
Parent:        09621725d0ea2a27e462f44139a54096ccadeb19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 18:17:09 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:36:37 2021 +0100

tests: remove incorrect check

We would need to be check same status value - otherwise
we can hit race in validating 2 different states.
---
 test/shell/lvcreate-raid-nosync.sh | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 05ab848a1..c7c2d1535 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -38,12 +38,9 @@ _sync() {
 _check_raid_in_loop() {
 	local vg=$1
 	local lv=$2
-	local A=$3
-	local B=$(echo $A | tr A a)
+	local health=$3
 	for i in {1..10} ; do
-		check raid_leg_status $vg $lv ${A} && return 0
-		# Only when there is initial 'a..a' we will wait for a while
-		check raid_leg_status $vg $lv ${B} || break
+		check raid_leg_status $vg $lv ${health} && return 0
 		sleep .05
 	done
 	die "Cannot get $A status for $vg/$lv";


