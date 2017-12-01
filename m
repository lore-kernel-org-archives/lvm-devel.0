From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 13:00:31 -0500
Subject: master - test: allow to succeed in the cluster
Message-ID: <201712011800.vB1I0VkO029582@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b74e7f6a781bf7dc4914d8294fcbc6881a539f2e
Commit:        b74e7f6a781bf7dc4914d8294fcbc6881a539f2e
Parent:        053314f2954dd94f707ef4a6ae9967ecd69fad6e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:59:55 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:59:55 2017 +0100

test: allow to succeed in the cluster

Avoiding "$(get first_extent_sector "$d")" in the loop
allows the test to succeed in the cluster.  Further cluster
analysis needed to get to the core reason.
---
 test/shell/lvconvert-repair-raid.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index c866455..d29b72d 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -25,10 +25,12 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 aux prepare_vg 8 80
 get_devs
 
+offset=$(get first_extent_sector $dev1)
+
 function delay
 {
 	for d in "${DEVICES[@]}"; do
-		aux delay_dev "$d" 0 $1 "$(get first_extent_sector "$d")"
+		aux delay_dev "$d" 0 $1 "$offset"
 	done
 }
 


