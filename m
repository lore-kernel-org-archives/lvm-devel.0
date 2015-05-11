From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 15:31:48 +0000 (UTC)
Subject: master - tests: split flavours
Message-ID: <20150511153148.F30C96055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5420edd56ecc3547758109cc87d0530d1e2e56d7
Commit:        5420edd56ecc3547758109cc87d0530d1e2e56d7
Parent:        e28ff7e0fcac221edc9289420fbc8ecb5a4a3707
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 17:30:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 17:31:09 2015 +0200

tests: split flavours

Remove duplicate flavour-udev-lvmetad-lvmpolld
and put them 1-per-line.
---
 test/Makefile.in |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 051a38e..91805c2 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -150,11 +150,19 @@ endif
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
-LIB_FLAVOURS = lib/flavour-ndev-vanilla lib/flavour-ndev-cluster lib/flavour-ndev-lvmetad \
-               lib/flavour-udev-vanilla lib/flavour-udev-cluster lib/flavour-udev-lvmetad \
-	       lib/flavour-udev-lvmpolld lib/flavour-ndev-lvmpolld lib/flavour-ndev-cluster-lvmpolld \
-	       lib/flavour-ndev-lvmetad-lvmpolld lib/flavour-udev-lvmpolld lib/flavour-udev-cluster-lvmpolld \
-	       lib/flavour-udev-lvmetad-lvmpolld
+LIB_FLAVOURS = \
+ lib/flavour-ndev-cluster-lvmpolld\
+ lib/flavour-ndev-cluster\
+ lib/flavour-ndev-lvmetad-lvmpolld\
+ lib/flavour-ndev-lvmetad\
+ lib/flavour-ndev-lvmpolld\
+ lib/flavour-ndev-vanilla\
+ lib/flavour-udev-cluster-lvmpolld\
+ lib/flavour-udev-cluster\
+ lib/flavour-udev-lvmetad-lvmpolld\
+ lib/flavour-udev-lvmetad\
+ lib/flavour-udev-lvmpolld\
+ lib/flavour-udev-vanilla
 
 LIB_LOCAL = lib/paths lib/runner
 LIB_EXEC  = lib/not lib/invalid lib/fail lib/should


