From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:49 +0000 (UTC)
Subject: master - NIX: Update URL for lcov RPM.
Message-ID: <20140228102549.5D7E460F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a0cf9cb0a0e2825d404b3e54ff4db0d2a472541
Commit:        8a0cf9cb0a0e2825d404b3e54ff4db0d2a472541
Parent:        7cb3e7d016613ba20e3e86d2e36182cf5f6debac
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Nov 15 22:11:17 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Update URL for lcov RPM.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 24db140..0f85493 100644
--- a/release.nix
+++ b/release.nix
@@ -17,7 +17,7 @@ let
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''
       rpm -Uv ${pkgs.fetchurl {
-       url="ftp://fr2.rpmfind.net/linux/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
+       url="ftp://ftp.isu.edu.tw/pub/Linux/Fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
      '';
      postBuild = ''


