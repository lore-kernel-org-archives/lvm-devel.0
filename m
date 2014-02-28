From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:15 +0000 (UTC)
Subject: master - NIX: The mergeUsr attribute was renamed to unifiedSystemDir.
Message-ID: <20140228102515.B98E460CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0d3a7d5695ddcbb451e9615471e6b05a2f73047
Commit:        a0d3a7d5695ddcbb451e9615471e6b05a2f73047
Parent:        cad28a49ab48a08f781594cde0bb73b85f2694a0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 23 00:26:33 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: The mergeUsr attribute was renamed to unifiedSystemDir.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 6fd0735..d8b9ed1 100644
--- a/release.nix
+++ b/release.nix
@@ -60,7 +60,7 @@ let
         urlPrefix = fedora_url version arch;
         archs = ["noarch" arch] ++ (if eqStrings arch "i386" then ["i586" "i686"] else []);
         packages = pkgs.vmTools.commonFedoraPackages;
-        mergeUsr = true;
+        unifiedSystemDir = true;
       };
       rawhide = version: arch: repodata: import (pkgs.runCommand "rawhide-${version}-${arch}.nix" {} ''
         sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')


