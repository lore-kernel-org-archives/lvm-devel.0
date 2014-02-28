From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:40 +0000 (UTC)
Subject: master - NIX: Fix a centos64 failure due to old dmesg.
Message-ID: <20140228102540.EC4EC60F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fea3f44698928d00338981d05604cfefe06fa3f
Commit:        7fea3f44698928d00338981d05604cfefe06fa3f
Parent:        4eaaad0caa339bd548a3b6ece830b682ed7e9033
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 31 01:25:26 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Fix a centos64 failure due to old dmesg.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 1a7183f..74d4ee8 100644
--- a/release.nix
+++ b/release.nix
@@ -168,7 +168,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "dmesg --console-level debug\\";
+         echo "dmesg --console-level debug || true\\";
          echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
          echo "make check_full T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"


