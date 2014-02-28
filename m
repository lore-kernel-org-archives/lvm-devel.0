From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 22:58:08 +0000 (UTC)
Subject: master - NIX: Cope with existence of multiple primary.xml files.
Message-ID: <20140228225808.59A6460F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=301ac8a07cb1c043cea61eb58ea2bae42a2cbcc2
Commit:        301ac8a07cb1c043cea61eb58ea2bae42a2cbcc2
Parent:        daa897fe90d59c823af6c4b29c5b75fec5ad0be9
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 23:56:04 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 23:56:04 2014 +0100

NIX: Cope with existence of multiple primary.xml files.

This can happen temporarily while a mirror is syncing (parsing repomd.xml
would be a better fix, but slightly tricky since it's xml).
---
 nix/default.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 75c7277..140ae7f 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -75,11 +75,11 @@ let
         unifiedSystemDir = true;
       };
       rawhide = version: arch: repodata: import (pkgs.runCommand "rawhide-${version}-${arch}.nix" {} ''
-        sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
+        sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:' | head -n 1)
         echo '{fedora}: fedora { version = "${version}"; sha = "'$sha'"; arch = "${arch}"; }' > $out
       '') { inherit fedora; };
       update = version: arch: repodata: orig: orig // (import (pkgs.runCommand "updates-fedora.nix" {} ''
-          sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
+          sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:' | head -n 1)
           echo fedora ${version} updates sha: $sha
           (echo 'fetchurl: orig: { packagesLists = [ orig.packagesList ('
            echo "fetchurl { "


