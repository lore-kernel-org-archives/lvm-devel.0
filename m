From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 09:16:16 +0000 (UTC)
Subject: master - nix: add pkgconfig
Message-ID: <20150514091616.D49A660DA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64b40c5554599c48138820eca414c79ca3468a68
Commit:        64b40c5554599c48138820eca414c79ca3468a68
Parent:        a42c1c5728d28b8903725694afb3735dac62f11a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 11:15:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 11:15:56 2015 +0200

nix: add pkgconfig

Install for better config
---
 nix/default.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 5c2e3d3..3879fc1 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -357,6 +357,7 @@ let
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
                  "device-mapper-persistent-data" # thin and cache
+                 "pkgconfig" # better support for config
                  "kernel"
                ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "procps" "nc" ];


