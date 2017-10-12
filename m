From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 12 Oct 2017 04:55:32 -0400
Subject: master - test: "Disable" lvconvert-raid-reshape
Message-ID: <201710120855.v9C8tW8p003328@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae55b1b20a4539be2f9702f5dbf882cf50267a62
Commit:        ae55b1b20a4539be2f9702f5dbf882cf50267a62
Parent:        71261ae3747f3810a1cf279098e149bc0f8dd833
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 12 10:53:22 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 12 10:55:02 2017 +0200

test: "Disable" lvconvert-raid-reshape

...when running from ramdisk. This causes test failure, so it is kept on
eyes.
---
 test/shell/lvconvert-raid-reshape.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index c93d79b..b07e1ce 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -15,6 +15,11 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+if [[ "$TESTDIR" == /dev/shm/* ]]; then
+	echo "Disabled. This tests is permanently causing /dev/shm exhaustion. RHBZ#1501145"
+	false
+fi
+
 which mkfs.ext4 || skip
 aux have_raid 1 12 0 || skip
 


