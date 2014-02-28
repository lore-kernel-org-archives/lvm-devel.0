From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:43 +0000 (UTC)
Subject: master - NIX: Give the VMs more RAM (768M instead of 512M).
Message-ID: <20140228102543.0A5AF60F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe4d473c5b93ff4f05b623ad841ce23be1357462
Commit:        fe4d473c5b93ff4f05b623ad841ce23be1357462
Parent:        7fea3f44698928d00338981d05604cfefe06fa3f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 31 10:01:13 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Give the VMs more RAM (768M instead of 512M).

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 74d4ee8..e1785c1 100644
--- a/release.nix
+++ b/release.nix
@@ -13,7 +13,7 @@ let
      fullName = "LVM2";
      src = jobs.tarball;
      diskImage = diskFun { extraPackages = extras; };
-     memSize = 512;
+     memSize = 768;
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''
       rpm -Uv ${pkgs.fetchurl {


