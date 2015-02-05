From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:03 +0000 (UTC)
Subject: master - NIX: Drop -h from rpm invocations as it messes up logs.
Message-ID: <20150205134203.314206036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3ac180ab37a5cfe39ac739d48b9176c0e4f6003
Commit:        e3ac180ab37a5cfe39ac739d48b9176c0e4f6003
Parent:        6380869f27bfd4f271cb1c8ba3d023e1c94f77fd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 12:50:57 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Drop -h from rpm invocations as it messes up logs.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index b6a4f98..8de3eba 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -17,7 +17,7 @@ let
          export PATH=/usr/bin:/bin:/usr/sbin:/sbin
 
          # we always run in a fresh image, so need to install everything again
-         ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uvh # */
+         ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uv # */
          rpm -Uv ${pkgs.fetchurl {
             url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
             sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}


