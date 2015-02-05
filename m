From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:59 +0000 (UTC)
Subject: master - NIX: Request {fedora, centos}-release packages explicitly.
Message-ID: <20150205134359.6A5D260B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43d6b44a9fac5809bf73a88a7a6a106e302b4fe4
Commit:        43d6b44a9fac5809bf73a88a7a6a106e302b4fe4
Parent:        b9a017d94cb5ad432c51df861242f42cc4f01ba3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Feb 5 14:21:31 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 14:21:31 2015 +0100

NIX: Request {fedora,centos}-release packages explicitly.

---
 nix/default.nix |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index f9f025f..0a45bab 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -207,8 +207,7 @@ let
         };
         urlPrefix = centos_url version arch;
         archs = ["noarch" arch] ++ (if eqStrings arch "i386" then ["i586" "i686"] else []);
-        packages = filter (n: !(eqStrings n "fedora-release")) pkgs.vmTools.commonFedoraPackages ++
-                     [ "centos-release" ];
+        packages = [ "centos-release" ] ++ pkgs.vmTools.commonFedoraPackages;
       };
       fedora = { version, sha, arch }: rec {
         name = "fedora-${version}-${arch}";
@@ -219,7 +218,7 @@ let
         };
         urlPrefix = fedora_url version arch;
         archs = ["noarch" arch] ++ (if eqStrings arch "i386" then ["i586" "i686"] else []);
-        packages = pkgs.vmTools.commonFedoraPackages;
+        packages = [ "fedora-release" ] ++ pkgs.vmTools.commonFedoraPackages;
         unifiedSystemDir = true;
       };
       rawhide = version: arch: repodata: import (pkgs.runCommand "rawhide-${version}-${arch}.nix" {} ''


