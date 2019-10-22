From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Oct 2019 10:08:11 -0400
Subject: master - tests: enable with 6.2.1
Message-ID: <201910221408.x9ME8BJR004578@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4e87e638ea2fc1c0f8ebca01496f4c34dbd80d0
Commit:        b4e87e638ea2fc1c0f8ebca01496f4c34dbd80d0
Parent:        3e01ff2783505f9b64f273fb492ee88e26afb568
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 22 16:06:19 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 22 16:06:19 2019 +0200

tests: enable with 6.2.1

Package vdo-6.2.2.18  goes with  kvdo version 6.2.1
Hopefully will get fixed soon.
Meanwhile to get test coverage...
---
 test/shell/lvcreate-vdo-cache.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-vdo-cache.sh b/test/shell/lvcreate-vdo-cache.sh
index a104a16..b502986 100644
--- a/test/shell/lvcreate-vdo-cache.sh
+++ b/test/shell/lvcreate-vdo-cache.sh
@@ -22,9 +22,9 @@ SKIP_WITH_LVMPOLLD=1
 #
 
 #
-# FIXME: tempororarily disable this test until fixed VDO driver is relase
-#
-aux have_vdo 96 2 0 || skip
+# FIXME: tempororarily disable this test until fixed VDO driver is relased
+#        should really be 6.2.2 - currently goes with vdo-6.2.2.18
+aux have_vdo 6 2 1 || skip
 aux have_cache 1 3 0 || skip
 
 which mkfs.ext4 || skip


