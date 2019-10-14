From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:21:35 -0400
Subject: master - tests: disable caching of VDO
Message-ID: <201910141321.x9EDLZcR018706@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6691aa04be8bbe8768c6a7a520b36498066b9e8
Commit:        e6691aa04be8bbe8768c6a7a520b36498066b9e8
Parent:        76a9a86fd359681a598a6509eb90940c3a10f1f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 9 15:27:44 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:13:47 2019 +0200

tests: disable caching of VDO

Disable until vdo gets fixed, then require fixed version.
Otherwise test kills kernel
---
 test/shell/lvcreate-vdo-cache.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-vdo-cache.sh b/test/shell/lvcreate-vdo-cache.sh
index c3d3ed0..a104a16 100644
--- a/test/shell/lvcreate-vdo-cache.sh
+++ b/test/shell/lvcreate-vdo-cache.sh
@@ -20,7 +20,11 @@ SKIP_WITH_LVMPOLLD=1
 #
 # Main
 #
-aux have_vdo 6 2 0 || skip
+
+#
+# FIXME: tempororarily disable this test until fixed VDO driver is relase
+#
+aux have_vdo 96 2 0 || skip
 aux have_cache 1 3 0 || skip
 
 which mkfs.ext4 || skip


