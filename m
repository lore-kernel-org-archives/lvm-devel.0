From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:22 +0000 (UTC)
Subject: master - nix: Run udevd in foreground.
Message-ID: <20140228102522.0985560CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fc075e04062dfcf4ea3e11c6b5527cf5624089e
Commit:        4fc075e04062dfcf4ea3e11c6b5527cf5624089e
Parent:        4757ef824ce37c110810f245397d3d2500133310
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Aug 20 17:33:38 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

nix: Run udevd in foreground.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index fa5ccbd..bf72944 100644
--- a/release.nix
+++ b/release.nix
@@ -164,7 +164,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "/usr/lib/systemd/systemd-udevd --daemon || true \\";
+         echo "/usr/lib/systemd/systemd-udevd & \\";
          echo "LVM_TEST_DEVDIR=/dev make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc


