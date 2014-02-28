From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:28 +0000 (UTC)
Subject: master - NIX: Change the URL for the lcov RPM to a more canonic location.
Message-ID: <20140228102628.EA0AF60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b43db580474ae96627c6b3784c136b56f30dde3
Commit:        6b43db580474ae96627c6b3784c136b56f30dde3
Parent:        ea5ec4ad51e3270b6b4337822d248d5bdbe12ddc
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 27 23:43:57 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Change the URL for the lcov RPM to a more canonic location.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 9a688dd..75c7277 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -17,7 +17,7 @@ let
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''
       rpm -Uv ${pkgs.fetchurl {
-       url="ftp://ftp.isu.edu.tw/pub/Linux/Fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
+       url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
       dmesg -n 1 # avoid spilling dmesg into the main log, we capture it in harness
      '';


