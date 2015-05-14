From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 09:47:05 +0000 (UTC)
Subject: master - nix: drop util-linux
Message-ID: <20150514094705.7FFB960243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=679f1a9e29da5a1425ef7de857bd798bd211448c
Commit:        679f1a9e29da5a1425ef7de857bd798bd211448c
Parent:        4f375d03dd2fba5b32eb8547fdb0f95f30e0bc8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 11:45:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 11:45:37 2015 +0200

nix: drop util-linux

Doesn't appear on centos???
---
 nix/default.nix |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 8a5521a..a5dbc34 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -355,7 +355,6 @@ let
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "e2fsprogs-libs" "e2fsprogs-devel"
-                 "util-linux"
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
                  "device-mapper-persistent-data" # thin and cache


