From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:39 -0500
Subject: master - tests: skipping test waiting for fixed kernel
Message-ID: <201803061446.w26EkdIg027197@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15b6793528de99a70e988d09502ca33ad1d7c575
Commit:        15b6793528de99a70e988d09502ca33ad1d7c575
Parent:        b05caca77e3df828d69d13ef52f43cc1531d6481
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 6 15:32:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:49 2018 +0100

tests: skipping test waiting for fixed kernel

Once working kernel is released, reenable me...
---
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 38af778..3fac9a4 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -15,6 +15,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# FIXME - skippping until properly kernel is released
+skip
+
 # Test reshaping under io load
 
 which mkfs.ext4 || skip


