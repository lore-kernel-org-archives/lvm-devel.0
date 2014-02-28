From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:45 +0000 (UTC)
Subject: master - NIX: Try harder to set dmesg levels.
Message-ID: <20140228102545.256B560F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b953df0f97eba540c750f9dd8abe9337210da2d
Commit:        2b953df0f97eba540c750f9dd8abe9337210da2d
Parent:        fe4d473c5b93ff4f05b623ad841ce23be1357462
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 3 15:48:34 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Try harder to set dmesg levels.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index e1785c1..318ece7 100644
--- a/release.nix
+++ b/release.nix
@@ -168,7 +168,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "dmesg --console-level debug || true\\";
+         echo "dmesg --console-level debug || dmesg 8 || true\\";
          echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
          echo "make check_full T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"


