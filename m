From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:48 +0000 (GMT)
Subject: dev-next - tests: set known locking dir
Message-ID: <20210331214848.1A6F03858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7575c7ae5c012c4a20bd4c2563640880f522789c
Commit:        7575c7ae5c012c4a20bd4c2563640880f522789c
Parent:        f370cda716f14d0ba1ba97fa3dd5887d5165b140
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 01:15:29 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 01:15:29 2021 +0100

tests: set known locking dir

Tests running in the system may use locking dir of the system.
---
 test/shell/lock-blocking.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 06f1a7ab0..9defaf2c7 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# Make sure the placement of locking dir is known
+aux lvmconf "global/locking_dir = \"$TESTDIR/var/lock/lvm\""
+
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 vgcreate $SHARED $vg "$dev1" "$dev2"


