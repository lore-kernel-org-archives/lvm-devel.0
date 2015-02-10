From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 10 Feb 2015 16:27:53 +0000 (UTC)
Subject: master - NIX: Drop Fedora 16 builds.
Message-ID: <20150210162753.180C460B43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=801e47e089ae8e1a09164556536d49af555df734
Commit:        801e47e089ae8e1a09164556536d49af555df734
Parent:        79dc8f5ddd89fd54897347167163c5176b6f7511
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 10 17:26:32 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Feb 10 17:27:10 2015 +0100

NIX: Drop Fedora 16 builds.

---
 nix/default.nix |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 919e9c9..08193c8 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -348,8 +348,6 @@ let
     fc18_i386   = { arch = "i386"  ; image = "fedora18"; };
     fc17_x86_64 = { arch = "x86_64"; image = "fedora17"; };
     fc17_i386   = { arch = "i386"  ; image = "fedora17"; };
-    fc16_x86_64 = { arch = "x86_64"; image = "fedora16"; };
-    fc16_i386   = { arch = "i386"  ; image = "fedora16"; };
 
     fc18u_x86_64 = { arch = "x86_64"; image = "fedora18u"; };
     fc18u_i386   = { arch = "i386"; image = "fedora18u"; };


