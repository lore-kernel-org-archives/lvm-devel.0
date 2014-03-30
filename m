From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:08 +0000 (UTC)
Subject: master - tests: workaround clvmd .cache consistency
Message-ID: <20140330214608.75CA5602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1216aa7826428dfa5f83af4bd29c7741de7a1a23
Commit:        1216aa7826428dfa5f83af4bd29c7741de7a1a23
Parent:        2c8f0c9800e658c14d57f1726055876dab869d08
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 23:13:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:45:00 2014 +0200

tests: workaround clvmd .cache consistency

May need futher fixes, but it's needed only on non-udev systems
(systems which still needs .cache - just like test suite)
---
 test/shell/stray-device-node.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 8e67caa..cd6525f 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -17,5 +17,9 @@ cp -r "$dev1" "$DM_DEV_DIR/stray"
 vgcreate $vg $(cat DEVICES)
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 aux disable_dev "$dev1"
+# FIXME:
+# for the .cache use case we need to run pvscan
+# to keep clvmd in sync.
+pvscan
 vgreduce --removemissing --force $vg
 aux enable_dev "$dev1"


