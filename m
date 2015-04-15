From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 15 Apr 2015 14:45:37 +0000 (UTC)
Subject: master - NIX: Also install device-mapper-persistent-data on CentOS 7 & FC 19+.
Message-ID: <20150415144538.060DF60CDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ce52430de8c8920e191aca8fd27be4dc8e2c96a
Commit:        9ce52430de8c8920e191aca8fd27be4dc8e2c96a
Parent:        191f3cf52a0ada3aba9ac340cbab464fb05efe89
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 16:44:15 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Apr 15 16:44:15 2015 +0200

NIX: Also install device-mapper-persistent-data on CentOS 7 & FC 19+.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index b8e0061..5d2a260 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -362,7 +362,7 @@ let
       centos65 = centos64;
       centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
-                   "procps-ng" "valgrind-devel" ];
+                   "device-mapper-persistent-data" "procps-ng" "valgrind-devel" ];
 
       fedora17 = fedora18 ++ [ "libudev-devel" ];
 


