From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sat, 26 Apr 2014 12:26:45 +0000 (UTC)
Subject: master - NIX: Use VM images with the correct root module list.
Message-ID: <20140426122645.E7B926116B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75d399800ab60264d1201ad3fa1f9283542459f6
Commit:        75d399800ab60264d1201ad3fa1f9283542459f6
Parent:        3bce3ad52a6c1fafd55573c465486faed3bb0a77
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Apr 26 13:45:23 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sat Apr 26 13:46:25 2014 +0200

NIX: Use VM images with the correct root module list.

---
 nix/default.nix |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index faf179a..228047f 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -147,10 +147,10 @@ let
         [ "loop" "dm_mod" "dm_snapshot" "dm_mirror" "dm_zero" "dm_raid" "dm_thin_pool" ]; };
     release = import "${nixpkgs}/pkgs/build-support/release/default.nix" {
       pkgs = pkgs // { vmTools = tools; }; };
-    imgs = pkgs.vmTools.diskImageFuns //
+    imgs = tools.diskImageFuns //
             mapAttrs (n: a: b: pkgs.vmTools.makeImageFromRPMDist (a // b)) extra_distros;
-    rpmdistros = pkgs.vmTools.rpmDistros // extra_distros;
-    rpmbuild = pkgs.vmTools.buildRPM;
+    rpmdistros = tools.rpmDistros // extra_distros;
+    rpmbuild = tools.buildRPM;
   };
 
   extra_rpms = rec {


