From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 13:02:04 +0000 (UTC)
Subject: master - nix: socat for f18, nc for f17
Message-ID: <20150514130204.CE00D6107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4931d0132c45d3da5cce12ccf76ac2a8774cef39
Commit:        4931d0132c45d3da5cce12ccf76ac2a8774cef39
Parent:        64a999097747316dcfea8c8b7b91778aed56b585
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 15:01:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 15:01:01 2015 +0200

nix: socat for f18, nc for f17

Use common f17_f18 and add extras for f17 and f18
---
 nix/default.nix |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index a5dbc34..cd2fd33 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -369,10 +369,11 @@ let
                    "socat" # used by test suite lvmpolld
                    "procps-ng" ];
 
-      fedora17 = fedora18 ++ [ "libudev-devel" ];
+      fedora17_18 = [ "dlm-devel" "corosynclib-devel" "libblkid" "libblkid-devel"
+                      "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
+      fedora17 = fedora17_18 ++ [ "libudev-devel" "nc" ];
 
-      fedora18 = [ "dlm-devel" "corosynclib-devel" "nc" "libblkid" "libblkid-devel"
-                   "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
+      fedora18 = fedora17_18 ++ [ "socat" ];
       fedora18u = fedora18;
 
       fedora19 = centos70 ++ [ "kernel-modules-extra" ];


