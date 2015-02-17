From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 17 Feb 2015 14:43:16 +0000 (UTC)
Subject: master - NIX: Fix a typo that broke evaluation of fc19+.
Message-ID: <20150217144316.240766112A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=973afcbb2064ad5ca264d9262ed5fd0a7bdac50e
Commit:        973afcbb2064ad5ca264d9262ed5fd0a7bdac50e
Parent:        a009c0fb407ec3a16e0432cb29434b9e9e79d81b
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 17 14:41:51 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Feb 17 15:32:04 2015 +0100

NIX: Fix a typo that broke evaluation of fc19+.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index c5f044f..da1fa08 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -326,7 +326,7 @@ let
                    "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
       fedora18u = fedora18;
 
-      fedora19 = centos70 + [ "kernel-modules-extra" ];
+      fedora19 = centos70 ++ [ "kernel-modules-extra" ];
       fedora19u = fedora19;
 
       fedora20 = fedora19;


