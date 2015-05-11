From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 15:31:46 +0000 (UTC)
Subject: master - nix: now some files are generate so keep them
Message-ID: <20150511153146.DB3A46055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e28ff7e0fcac221edc9289420fbc8ecb5a4a3707
Commit:        e28ff7e0fcac221edc9289420fbc8ecb5a4a3707
Parent:        d748b3455d25192d68e166d89d1c6f67ac226d44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 17:29:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 17:31:09 2015 +0200

nix: now some files are generate so keep them

more tweaks ahead
---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index a1cc98f..b1693af 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -194,7 +194,7 @@ let
        echo "* `date +"%a %b %d %Y"` Petr Rockai <prockai@redhat.com> - $version";
        echo "- AUTOMATED BUILD BY Hydra") >> spec/lvm2.spec
 
-      mv spec/* . && rmdir spec # */ # RPM needs the spec file in the source root
+      cp spec/* . # */ # RPM needs the spec file in the source root
 
       # make a tarball
       mkdir ../LVM2.$version


