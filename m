From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:17 +0000 (UTC)
Subject: master - NIX: Fix chrooted builds, passing down package lists explicitly.
Message-ID: <20140228102517.CA2B360CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c927f7b275aee128ddd9049a46f44b68edfe130
Commit:        9c927f7b275aee128ddd9049a46f44b68edfe130
Parent:        a0d3a7d5695ddcbb451e9615471e6b05a2f73047
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 23 11:02:22 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Fix chrooted builds, passing down package lists explicitly.

---
 release.nix |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/release.nix b/release.nix
index d8b9ed1..bd12fbb 100644
--- a/release.nix
+++ b/release.nix
@@ -68,14 +68,14 @@ let
       '') { inherit fedora; };
       update = version: arch: repodata: orig: orig // (import (pkgs.runCommand "updates-fedora.nix" {} ''
           sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
-          (echo 'fetchurl: { packagesLists = [ "${orig.packagesList}" ('
+          (echo 'fetchurl: orig: { packagesLists = [ orig.packagesList ('
            echo "fetchurl { "
            echo "  url = \"${fedora_update_url version arch}/repodata/$sha-primary.xml.gz\";"
            echo "  sha256 = \"$sha\";"
-           echo '} ) ]; urlPrefixes = [ "${orig.urlPrefix}" "${fedora_update_url version arch}" ]; }'
+           echo '} ) ]; urlPrefixes = [ orig.urlPrefix "${fedora_update_url version arch}" ]; }'
           ) > $out
           echo built $out 1>&2
-        '')) pkgs.fetchurl;
+        '')) pkgs.fetchurl orig;
     in {
       rawhidex86_64 = rawhide "rawhide" "x86_64" rawhide64;
       rawhidei386 = rawhide "rawhide" "i386" rawhide32;


