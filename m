From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:19 +0000 (UTC)
Subject: master - nix: install also mdadm
Message-ID: <20150422092019.DC1896011F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16ee4642c732bbe80009d4b1471c8a84f4279099
Commit:        16ee4642c732bbe80009d4b1471c8a84f4279099
Parent:        2e035162a13d9ed6036b1bd8cdacbfa7ba1fd748
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 09:00:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 09:09:26 2015 +0200

nix: install also mdadm

Some tests are checking functinality of lvm2 with mdadm.
---
 nix/default.nix |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 5d2a260..a1cc98f 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -116,9 +116,9 @@ let
                else
                    counter=0
                fi
-               if test $counter -eq 10 || test $(cat hb.current | wc -c) -eq $(cat hb.last | wc -c); then
+               if test $counter -eq 10 || test $(wc -c <hb.current) -eq $(wc -c <hb.last); then
                    echo
-                   echo "VM got stuck; heartbeat: $(cat hb.current | wc -c) $(cat hb.last | wc -c), counter = $counter."
+                   echo "VM got stuck; heartbeat: $(wc -c <hb.current) $(wc -c <hb.last), counter = $counter."
                    echo "last journal entry: $(tail -n 1 j.current), previously $(tail -n 1 j.last)"
                    kill -- -$(cat pid)
                fi
@@ -355,6 +355,7 @@ let
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov
+                 "mdadm" # for tests with lvm2 and mdadm
                  "kernel"
                ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" "procps" ];


