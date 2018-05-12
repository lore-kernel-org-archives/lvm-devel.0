From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:27:12 -0400
Subject: master - build: lcov reporting for unit tests
Message-ID: <201805121627.w4CGRCna008763@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35ffc3f8eb7a326c29c1aa6349ac383d81f2cdc0
Commit:        35ffc3f8eb7a326c29c1aa6349ac383d81f2cdc0
Parent:        67c02877a1f2991e1f5de0205e20841b94df5413
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 00:47:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

build: lcov reporting for unit tests

List also lcov for processed unit tests.
---
 Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index c2d5122..e2f5a84 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -171,6 +171,7 @@ install_tmpfiles_configuration:
 
 LCOV_TRACES = libdm.info lib.info liblvm.info tools.info \
 	libdaemon/client.info libdaemon/server.info \
+	test/unit.info \
 	daemons/clvmd.info \
 	daemons/dmeventd.info \
 	daemons/lvmetad.info \


