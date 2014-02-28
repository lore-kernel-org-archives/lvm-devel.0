From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:19 +0000 (UTC)
Subject: master - NIX: Run tests with /dev and (on recent Fedora) with udevd running.
Message-ID: <20140228102519.DFBC160CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4757ef824ce37c110810f245397d3d2500133310
Commit:        4757ef824ce37c110810f245397d3d2500133310
Parent:        9c927f7b275aee128ddd9049a46f44b68edfe130
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 5 21:16:54 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Run tests with /dev and (on recent Fedora) with udevd running.

---
 release.nix |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index bd12fbb..fa5ccbd 100644
--- a/release.nix
+++ b/release.nix
@@ -164,7 +164,8 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "make check T=${T} || touch \$out/nix-support/failed \\"
+         echo "/usr/lib/systemd/systemd-udevd --daemon || true \\";
+         echo "LVM_TEST_DEVDIR=/dev make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \


