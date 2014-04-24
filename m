From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 24 Apr 2014 19:35:51 +0000 (UTC)
Subject: master - NIX: Fix failure mode for "make check".
Message-ID: <20140424193551.B87E760308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=448af9ff0ba04bfaeb45c15819f577fef089fd95
Commit:        448af9ff0ba04bfaeb45c15819f577fef089fd95
Parent:        9676ee9ba9414c64bf9b519479f69be99e9a1dc7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Apr 24 21:03:58 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Apr 24 21:35:31 2014 +0200

NIX: Fix failure mode for "make check".

---
 nix/default.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 81e9d30..faf179a 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -204,6 +204,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
+         echo "mkdir -p \$out/nix-support \\";
          echo "make check QUIET=1 T=${T} || touch \$out/nix-support/failed \\"
 	 echo "pwd > /tmp/build-location \\"
 	 echo "touch rpm-no-clean") >> source.inc


