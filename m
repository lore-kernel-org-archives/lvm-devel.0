From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:00 +0000 (UTC)
Subject: master - NIX: Avoid a spurious failure when all tests pass.
Message-ID: <20150205134300.4B3B260E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=734a183c5658c1f305a375da02bb24cccad566df
Commit:        734a183c5658c1f305a375da02bb24cccad566df
Parent:        bd0806e1f53f4b978cf298885e1d98365011ec3e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 11:01:48 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

NIX: Avoid a spurious failure when all tests pass.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 445b0a7..734fb3b 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -22,7 +22,7 @@ let
          cp $i/test-results'/'*.txt $out/test-results/ || true
        done
        mkdir -p $out/nix-support
-       grep '\<failed\>' $out/test-results/list && touch $out/nix-support/failed
+       grep '\<failed\>' $out/test-results/list && touch $out/nix-support/failed || true
      '';
 
      buildInputs = map (x: runTest (args // { flavour = x; }))


