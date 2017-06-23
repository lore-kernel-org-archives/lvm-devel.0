From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:34 -0400
Subject: master - tests: request 1.12 for reshaping raid
Message-ID: <201706231649.v5NGnYbF019933@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=535f7209d2c0fa996928f82b3668560ad489e742
Commit:        535f7209d2c0fa996928f82b3668560ad489e742
Parent:        d0c97b44016024676e9f1dd24a4db4a7182f9918
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:52:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

tests: request 1.12 for reshaping raid

We will need  1.12 as the kernel needs some mandatory md fixes,
otherwise random freezes may appear.
---
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    2 +-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 test/shell/lvconvert-raid-reshape.sh               |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index cef35cd..0b589b4 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 1 || skip
+aux have_raid 1 12 0 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index d926827..d34ca5e 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 1 || skip
+aux have_raid 1 12 0 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 246a3ba..e4ade3f 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 1 || skip
+aux have_raid 1 12 0 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20


