From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 15:46:30 -0400
Subject: master - test: Fix skip some reshape tests that hang on single core machines
Message-ID: <201704201946.v3KJkUO3013113@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18bf954801e0ea3aff4b85e9511b1bbf03a07c2d
Commit:        18bf954801e0ea3aff4b85e9511b1bbf03a07c2d
Parent:        0c2fd133d7b690889ed4153853151db5b38eb060
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 20 21:45:56 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 20 21:45:56 2017 +0200

test: Fix skip some reshape tests that hang on single core machines

Fix commit c7fb0cb861104e99c11e8b4e031d981dab7891a1.
---
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    2 +-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 13769ec..879c33c 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -19,7 +19,7 @@ aux have_raid 1 10 1 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_single_core || skip
+aux have_single_core && skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 8f53a42..4c12dd7 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -19,7 +19,7 @@ aux have_raid 1 10 1 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_single_core || skip
+aux have_single_core && skip
 
 aux prepare_vg 5
 


