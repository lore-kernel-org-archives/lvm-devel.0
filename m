From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Feb 2022 21:57:01 +0000 (GMT)
Subject: main - tests: skip vgchange-pvs-online.sh on rhel5
Message-ID: <20220215215701.3C8403858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6626adb46789e329a53242822dc6e9d233320adb
Commit:        6626adb46789e329a53242822dc6e9d233320adb
Parent:        d59382c772483d3c09b4fcff90c01d81742feac6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 15 15:56:01 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 15 15:56:46 2022 -0600

tests: skip vgchange-pvs-online.sh on rhel5

the /dev/mapper/ paths to test devices don't seem to work there
---
 test/shell/vgchange-pvs-online.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index ced03f4da..9bcf70e4b 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -19,6 +19,9 @@ _clear_online_files() {
 
 aux prepare_devs 4
 
+# skip rhel5 which doesn't seem to have /dev/mapper/LVMTESTpv1
+aux driver_at_least 4 15 || skip
+
 DFDIR="$LVM_SYSTEM_DIR/devices"
 mkdir -p "$DFDIR" || true
 DF="$DFDIR/system.devices"


