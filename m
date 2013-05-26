From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 17:12:00 +0000 (UTC)
Subject: dev-mornfall-nix - NIX: Grab specfile from lvm2Nix (at least for now).
Message-ID: <20130526171200.F404261055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66c0f037fe61b9bf23d623f5c10f750af58870a6
Commit:        66c0f037fe61b9bf23d623f5c10f750af58870a6
Parent:        3f70e788087817b6432b552dec123930e6bb9265
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun May 26 18:13:25 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun May 26 18:54:46 2013 +0200

NIX: Grab specfile from lvm2Nix (at least for now).

---
 release.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/release.nix b/release.nix
index 8ca13db..981609f 100644
--- a/release.nix
+++ b/release.nix
@@ -1,4 +1,4 @@
-{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false, rawhide32 ? "" , rawhide64 ? "" , fc19_32 ? "" , fc19_64 ? "" }:
+{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false, rawhide32 ? "" , rawhide64 ? "" , fc19_32 ? "" , fc19_64 ? "", lvm2Nix ? lvm2Src }:
 
 let
   pkgs = import nixpkgs {};
@@ -138,7 +138,7 @@ let
         version=`cat VERSION | cut "-d(" -f1`${versionSuffix}
         version_dm=`cat VERSION_DM | cut "-d-" -f1`${versionSuffix}
         sed -e s,-git,${versionSuffix}, -i VERSION VERSION_DM
-        mv spec/* . && rmdir spec
+        rm -rf spec; cp -R ${lvm2Nix}/spec/* .
         chmod u+w *
         (echo "%define enable_profiling 1";
          echo "%define check_commands \\";


