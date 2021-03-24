From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 11:41:52 +0000 (GMT)
Subject: main - tests: skip stray testing on real dev dir
Message-ID: <20210324114152.3C9C83857C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afd43a75f20fbecb047924468c84212f7aefcf0b
Commit:        afd43a75f20fbecb047924468c84212f7aefcf0b
Parent:        a126dde069ada9380ba2f7ab7e520ba4ce3e2a90
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 11:57:46 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 12:23:07 2021 +0100

tests: skip stray testing on real dev dir

Do not modify /dev dir maintained by udev.
---
 test/shell/stray-device-node.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 7ed229388..003afb7e8 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -18,6 +18,9 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 3
 get_devs
 
+# Avoid manipulation with real /dev dir
+test "$DM_DEV_DIR" = "/dev" && skip "Skipping stray test on real /dev dir"
+
 cp -r "$dev1" "$DM_DEV_DIR/stray"
 
 vgcreate $SHARED "$vg" "${DEVICES[@]}"
@@ -29,3 +32,5 @@ aux disable_dev "$dev1"
 pvscan
 vgreduce --removemissing --force $vg
 aux enable_dev "$dev1"
+
+rm -f "$DM_DEV_DIR/stray"


