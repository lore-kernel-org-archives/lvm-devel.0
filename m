From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:10 +0000 (UTC)
Subject: master - NIX: Retire the CentOS 6.3 builds.
Message-ID: <20140228102610.3B98960F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31e8fa883d345d897d50abdcc880345116cfacd2
Commit:        31e8fa883d345d897d50abdcc880345116cfacd2
Parent:        55964cedcb1c58b5e258eb22ab99134d44c38678
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 8 16:35:39 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Retire the CentOS 6.3 builds.

---
 release.nix |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/release.nix b/release.nix
index a59ebb8..5e4b3cf 100644
--- a/release.nix
+++ b/release.nix
@@ -95,15 +95,15 @@ let
       fedora18ux86_64 = update "18" "x86_64" fc18_64_updates pkgs.vmTools.rpmDistros.fedora18x86_64;
       fedora18ui386 = update "18" "i386" fc18_32_updates pkgs.vmTools.rpmDistros.fedora18i386;
 
-      centos63x86_64 = centos {
-        version="6.3"; arch="x86_64";
-        sha="4d3cddf382e81c20b167a8d13c7c92067040a1947dbb3c29cfafa01a74a26a2b";
-      };
+      #centos63x86_64 = centos {
+      #  version="6.3"; arch="x86_64";
+      #  sha="4d3cddf382e81c20b167a8d13c7c92067040a1947dbb3c29cfafa01a74a26a2b";
+      #};
 
-      centos63i386 = centos {
-        version="6.3"; arch="i386";
-        sha="5cee0e0c4d7e2dcb997f123ce9107dedbc424d80dd7f2b2471b3b348f3e1754c";
-      };
+      #centos63i386 = centos {
+      #  version="6.3"; arch="i386";
+      #  sha="5cee0e0c4d7e2dcb997f123ce9107dedbc424d80dd7f2b2471b3b348f3e1754c";
+      #};
 
       centos64x86_64 = centos {
         version="6.4"; arch="x86_64";
@@ -213,8 +213,8 @@ let
     fc19u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora19u"; };
     fc19u_i386   = mkRPM { arch = "i386"; image = "fedora19u"; };
 
-    centos63_i386 = mkRPM { arch = "i386"  ; image = "centos63"; };
-    centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };
+    #centos63_i386 = mkRPM { arch = "i386"  ; image = "centos63"; };
+    #centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };
     centos64_i386 = mkRPM { arch = "i386"  ; image = "centos64"; };
     centos64_x86_64 = mkRPM { arch = "x86_64" ; image = "centos64"; };
 


