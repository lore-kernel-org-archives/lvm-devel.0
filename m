From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 22 Oct 2014 07:03:52 +0000 (UTC)
Subject: master - NIX: Fix 32b builds (2G of RAM is 1M too much for 32b QEMU).
Message-ID: <20141022070352.94D68602B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c8e7821c31245e3f7c1d56a67eb7f38d4b37001
Commit:        2c8e7821c31245e3f7c1d56a67eb7f38d4b37001
Parent:        4988d799a26032bfde4888d55080f5d42f5d55c1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 22 09:02:17 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 22 09:03:26 2014 +0200

NIX: Fix 32b builds (2G of RAM is 1M too much for 32b QEMU).

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 6ef339b..abd3d01 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -13,7 +13,7 @@ let
      fullName = "LVM2";
      src = jobs.tarball;
      diskImage = diskFun { extraPackages = extras; };
-     memSize = 2048;
+     memSize = 2047;
 
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''


