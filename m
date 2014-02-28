From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:24 +0000 (UTC)
Subject: master - nix: Set kernel console log level to debug.
Message-ID: <20140228102524.1F3A760CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2df5eb250d9dd8d1e9e75faaf0345c9858a7dbdb
Commit:        2df5eb250d9dd8d1e9e75faaf0345c9858a7dbdb
Parent:        4fc075e04062dfcf4ea3e11c6b5527cf5624089e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Aug 20 17:34:12 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

nix: Set kernel console log level to debug.

---
 release.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/release.nix b/release.nix
index bf72944..7b18982 100644
--- a/release.nix
+++ b/release.nix
@@ -164,6 +164,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
+         echo "dmesg --console-level debug\\";
          echo "/usr/lib/systemd/systemd-udevd & \\";
          echo "LVM_TEST_DEVDIR=/dev make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"


