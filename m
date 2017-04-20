From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 19:22:36 -0400
Subject: master - test: Adjust previous commit
Message-ID: <201704202322.v3KNMaTZ005430@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a004cceed2ce050514fe9b4bd66fc948a2b72bc2
Commit:        a004cceed2ce050514fe9b4bd66fc948a2b72bc2
Parent:        18bf954801e0ea3aff4b85e9511b1bbf03a07c2d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Apr 21 01:21:24 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Apr 21 01:21:24 2017 +0200

test: Adjust previous commit

Change have_single_core to  have_multi_core and go back to || logic in related test scripts.
---
 test/lib/aux.sh                                    |    4 ++--
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    3 +--
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b05c59d..6217c4c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1490,9 +1490,9 @@ have_readline() {
 	echo version | lvm &>/dev/null
 }
 
-have_single_core() {
+have_multi_core() {
 	which nproc &>/dev/null || return 0
-	[ $(nproc) -eq 1 ] && return 1
+	[ $(nproc) -ne 1 ]
 }
 
 dmsetup_wrapped() {
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 879c33c..042cb33 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -19,8 +19,7 @@ aux have_raid 1 10 1 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_single_core && skip
-
+aux have_multi_core || skip
 aux prepare_vg 5
 
 #
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 4c12dd7..4051862 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -19,7 +19,7 @@ aux have_raid 1 10 1 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_single_core && skip
+aux have_multi_core || skip
 
 aux prepare_vg 5
 


