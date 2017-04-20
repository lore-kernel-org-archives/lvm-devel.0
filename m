From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 20 Apr 2017 15:06:15 -0400
Subject: master - test: Skip some reshape tests that hang on single core machines
Message-ID: <201704201906.v3KJ6Ff6008047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7fb0cb861104e99c11e8b4e031d981dab7891a1
Commit:        c7fb0cb861104e99c11e8b4e031d981dab7891a1
Parent:        83cdba75bde734027984af9642f161c5693a5458
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 20 20:05:07 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 20 20:05:07 2017 +0100

test: Skip some reshape tests that hang on single core machines

Skip hanging raid reshape tests until https://bugzilla.redhat.com/1443999
is fixed
---
 test/lib/aux.sh                                    |    5 +++++
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    4 ++++
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    4 ++++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5303adc..b05c59d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1490,6 +1490,11 @@ have_readline() {
 	echo version | lvm &>/dev/null
 }
 
+have_single_core() {
+	which nproc &>/dev/null || return 0
+	[ $(nproc) -eq 1 ] && return 1
+}
+
 dmsetup_wrapped() {
 	udev_wait
 	dmsetup "$@"
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 29a293e..13769ec 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 which mkfs.ext4 || skip
 aux have_raid 1 10 1 || skip
 
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_single_core || skip
+
 aux prepare_vg 5
 
 #
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 357763e..8f53a42 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 which mkfs.ext4 || skip
 aux have_raid 1 10 1 || skip
 
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_single_core || skip
+
 aux prepare_vg 5
 
 #


