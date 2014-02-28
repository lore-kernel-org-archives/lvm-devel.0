From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:28 +0000 (UTC)
Subject: master - NIX: Use the new "check_full" target for comprehensive testing.
Message-ID: <20140228102528.5767B60CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39d00da752c42a8a72d124313a373eaaee94ab28
Commit:        39d00da752c42a8a72d124313a373eaaee94ab28
Parent:        765337dcc1721084d40808c48691d236882b844f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 23 10:14:41 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Use the new "check_full" target for comprehensive testing.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 1af5f1e..4fddf5e 100644
--- a/release.nix
+++ b/release.nix
@@ -166,7 +166,7 @@ let
          echo "dmsetup targets\\";
          echo "dmesg --console-level debug\\";
          echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
-         echo "LVM_TEST_DEVDIR=/dev make check T=${T} || touch \$out/nix-support/failed \\"
+         echo "make check_full T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \


