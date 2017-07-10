From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:19 -0400
Subject: master - tests: aux.sh move corosyn
Message-ID: <201707101233.v6ACXJDT022786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fc0166ca90efe902805f7abb951edeb0f7a91b2
Commit:        4fc0166ca90efe902805f7abb951edeb0f7a91b2
Parent:        408e3b84f6b5d04fca1533cc7aab80d19e561d1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 12:42:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh move corosyn

---
 test/lib/aux.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2e0cc10..747255b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -21,9 +21,10 @@ expect_failure() {
         echo "TEST EXPECT FAILURE"
 }
 
-COROSYNC_CONF="/etc/corosync/corosync.conf"
-COROSYNC_NODE=$(hostname)
 create_corosync_conf() {
+	COROSYNC_CONF="/etc/corosync/corosync.conf"
+	COROSYNC_NODE=$(hostname)
+
 	if test -a "$COROSYNC_CONF"; then
 		if ! grep "created by lvm test suite" "$COROSYNC_CONF"; then
 			rm "$COROSYNC_CONF"


