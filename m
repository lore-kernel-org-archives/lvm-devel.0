From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Oct 2014 19:08:02 +0000 (UTC)
Subject: master - NIX: Give the VMs 2G of RAM (for tmpfs) until the new runner is merged.
Message-ID: <20141014190802.B9E61611BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4461c624bc59ddca60f4bbf1eb447d64c8d4aeb2
Commit:        4461c624bc59ddca60f4bbf1eb447d64c8d4aeb2
Parent:        5e6e2d6b1b984b83929dd23e75c0512e564d184f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 14 19:06:26 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 14 21:07:00 2014 +0200

NIX: Give the VMs 2G of RAM (for tmpfs) until the new runner is merged.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 228047f..6ef339b 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -13,7 +13,7 @@ let
      fullName = "LVM2";
      src = jobs.tarball;
      diskImage = diskFun { extraPackages = extras; };
-     memSize = 768;
+     memSize = 2048;
 
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''


