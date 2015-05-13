From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:19:56 +0000 (UTC)
Subject: master - nix: fix socat package name
Message-ID: <20150513221956.2381C6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e38b8439a48c5d3e7a9624336e1a4ae73049717
Commit:        5e38b8439a48c5d3e7a9624336e1a4ae73049717
Parent:        a8fc483ca4914ddc67b7831150f1ee4c3c429ec1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 21:22:08 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:32 2015 +0200

nix: fix socat package name

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 6b0001e..b3acc0e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -357,7 +357,7 @@ let
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
                  "device-mapper-persistent-data" # thin and cache
-                 "sockat # used by test suite lvmpolld
+                 "socat" # used by test suite lvmpolld
                  "kernel"
                ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "procps" ];


