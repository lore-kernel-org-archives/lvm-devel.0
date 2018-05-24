From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:54 -0400
Subject: master - gitignore
Message-ID: <201805240934.w4O9Ys3p002246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c35d3242a8897c054c993dc59ad6e1cfff658061
Commit:        c35d3242a8897c054c993dc59ad6e1cfff658061
Parent:        87291a28328e6b786ea6674aa52003e7f4af0ac3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 22 13:45:21 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 23 16:53:18 2018 +0200

gitignore

---
 .gitignore |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/.gitignore b/.gitignore
index 3038524..f51bb67 100644
--- a/.gitignore
+++ b/.gitignore
@@ -79,5 +79,55 @@ test/lib/vgrename
 test/lib/vgs
 test/lib/vgscan
 test/lib/vgsplit
-
+test/api/lvtest.t
+test/api/pe_start.t
+test/api/percent.t
+test/api/python_lvm_unit.py
+test/api/test
+test/api/thin_percent.t
+test/api/vglist.t
+test/api/vgtest.t
+test/lib/aux
+test/lib/check
+test/lib/clvmd
+test/lib/dm-version-expected
+test/lib/dmeventd
+test/lib/dmsetup
+test/lib/dmstats
+test/lib/fail
+test/lib/flavour-ndev-cluster
+test/lib/flavour-ndev-cluster-lvmpolld
+test/lib/flavour-ndev-lvmetad
+test/lib/flavour-ndev-lvmetad-lvmpolld
+test/lib/flavour-ndev-lvmpolld
+test/lib/flavour-ndev-vanilla
+test/lib/flavour-udev-cluster
+test/lib/flavour-udev-cluster-lvmpolld
+test/lib/flavour-udev-lvmetad
+test/lib/flavour-udev-lvmetad-lvmpolld
+test/lib/flavour-udev-lvmlockd-dlm
+test/lib/flavour-udev-lvmlockd-sanlock
+test/lib/flavour-udev-lvmlockd-test
+test/lib/flavour-udev-lvmpolld
+test/lib/flavour-udev-vanilla
+test/lib/fsadm
+test/lib/get
+test/lib/inittest
+test/lib/invalid
+test/lib/lvm
+test/lib/lvm-wrapper
+test/lib/lvmchange
+test/lib/lvmdbusd.profile
+test/lib/lvmetad
+test/lib/lvmpolld
+test/lib/not
+test/lib/paths
+test/lib/paths-common
+test/lib/runner
+test/lib/should
+test/lib/test
+test/lib/thin-performance.profile
+test/lib/utils
+test/lib/version-expected
+test/unit/dmraid_t.c
 test/unit/unit-test


