From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 20:18:14 -0400
Subject: master - test: also prevent lvconvert-raid-reshape.sh on single core
Message-ID: <201704210018.v3L0IEYB012185@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d48b816764fcf2b153d9d4f27244be5b96846227
Commit:        d48b816764fcf2b153d9d4f27244be5b96846227
Parent:        a004cceed2ce050514fe9b4bd66fc948a2b72bc2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Apr 21 02:17:55 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Apr 21 02:17:55 2017 +0200

test: also prevent lvconvert-raid-reshape.sh on single core

---
 test/shell/lvconvert-raid-reshape.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index f9ff744..246a3ba 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 which mkfs.ext4 || skip
 aux have_raid 1 10 1 || skip
 
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_multi_core || skip
+
 aux prepare_pvs 65 64
 
 vgcreate -s 1M $vg $(cat DEVICES)


