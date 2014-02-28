From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:26 +0000 (UTC)
Subject: master - nix: Look a bit harder for udevd.
Message-ID: <20140228102526.32F6760CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=765337dcc1721084d40808c48691d236882b844f
Commit:        765337dcc1721084d40808c48691d236882b844f
Parent:        2df5eb250d9dd8d1e9e75faaf0345c9858a7dbdb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Aug 20 23:04:37 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

nix: Look a bit harder for udevd.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 7b18982..1af5f1e 100644
--- a/release.nix
+++ b/release.nix
@@ -165,7 +165,7 @@ let
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
          echo "dmesg --console-level debug\\";
-         echo "/usr/lib/systemd/systemd-udevd & \\";
+         echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
          echo "LVM_TEST_DEVDIR=/dev make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc


