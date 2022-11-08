From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Nov 2022 10:10:40 +0000 (GMT)
Subject: main - tests: update test to handle different status
Message-ID: <20221108101040.2914D3858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0fed9b097120648301faa586970a47b8b4d629ff
Commit:        0fed9b097120648301faa586970a47b8b4d629ff
Parent:        8e9410594b3113386a667df400b2c229c745cb6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 4 17:00:48 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 11:10:21 2022 +0100

tests: update test to handle different status

Since now we change deduplication with V4 table line change,
the modification tends to be faster and we can capture for a few ms
also 'status' about opening or closing deduplication index.
Use 'grep -E' to handle both words.
---
 test/shell/lvchange-vdo.sh | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvchange-vdo.sh b/test/shell/lvchange-vdo.sh
index 7cc44d6bc..b11edf35c 100644
--- a/test/shell/lvchange-vdo.sh
+++ b/test/shell/lvchange-vdo.sh
@@ -40,13 +40,14 @@ check grep_dmsetup status $vg-vdopool-vpool " online online "
 
 # dedulication_ARG
 lvchange --deduplication n $vg/vdopool
-check grep_dmsetup status $vg-vdopool-vpool " offline online "
+check grep_dmsetup status $vg-vdopool-vpool -E " offline|closed online "
+
 lvchange --deduplication y $vg/vdopool
-check grep_dmsetup status $vg-vdopool-vpool " online online "
+check grep_dmsetup status $vg-vdopool-vpool -E " online|opening online "
 
 
 lvchange --compression n --deduplication n $vg/vdopool
-check grep_dmsetup status $vg-vdopool-vpool " offline offline "
+check grep_dmsetup status $vg-vdopool-vpool -E " offline|closed offline "
 
 # --vdosettings needs inactive LV
 not lvchange --vdosettings 'ack_threads=8' $vg/vdopool

