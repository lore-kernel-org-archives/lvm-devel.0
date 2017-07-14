From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Jul 2017 18:15:59 -0400
Subject: master - tests: use get_devs
Message-ID: <201707142215.v6EMFx4C010282@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c64e2a85cb1c76413cf2eee49873bfb9ee24393f
Commit:        c64e2a85cb1c76413cf2eee49873bfb9ee24393f
Parent:        413209f3f8f35963dda8b0fbbbaaa785e44958e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 15 00:13:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 15 00:13:33 2017 +0200

tests: use get_devs

---
 test/shell/lvconvert-repair-raid.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 93b7db2..c866455 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -23,11 +23,11 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 	    'activation/raid_fault_policy = "allocate"'
 
 aux prepare_vg 8 80
+get_devs
 
 function delay
 {
-	for d in $(< DEVICES)
-	do
+	for d in "${DEVICES[@]}"; do
 		aux delay_dev "$d" 0 $1 "$(get first_extent_sector "$d")"
 	done
 }


