From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:47 +0000 (UTC)
Subject: master - NIX: Skip autoconf, as we include ./configure in git.
Message-ID: <20140228102547.3C89160F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cb3e7d016613ba20e3e86d2e36182cf5f6debac
Commit:        7cb3e7d016613ba20e3e86d2e36182cf5f6debac
Parent:        2b953df0f97eba540c750f9dd8abe9337210da2d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Nov 15 19:11:15 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Skip autoconf, as we include ./configure in git.

---
 release.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/release.nix b/release.nix
index 318ece7..24db140 100644
--- a/release.nix
+++ b/release.nix
@@ -156,6 +156,7 @@ let
                          then ".pre${toString lvm2Src.revCount}"
                          else "";
       src = lvm2Src;
+      autoconfPhase = ":";
       distPhase = ''
         set -x
         make distclean


