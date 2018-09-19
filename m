From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 19 Sep 2018 08:54:55 -0400
Subject: master - tests: fix lvconvert-raid-reshape-linear_to_striped-single-type.sh
Message-ID: <201809191254.w8JCstun010151@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=945d13541e50a25f859e471abea4d86f00ce0964
Commit:        945d13541e50a25f859e471abea4d86f00ce0964
Parent:        41ef146dc3bf9bd2ecbcedb8c3cdbd2535149296
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Sep 19 14:53:38 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Sep 19 14:53:41 2018 +0200

tests: fix lvconvert-raid-reshape-linear_to_striped-single-type.sh

Add errouneously removed VG creation back in.
---
 ...t-raid-reshape-linear_to_striped-single-type.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
index c9c4321..6d49f54 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -20,6 +20,8 @@ aux lvmconf 'activation/raid_region_size = 512'
 which mkfs.ext4 || skip
 aux have_raid 1 14 0 || skip
 
+aux prepare_vg 5
+
 #
 # Test multi step linear -> striped conversion
 #


