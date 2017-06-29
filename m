From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:32 -0400
Subject: master - tests: get.sh double quote
Message-ID: <201706292029.v5TKTWb4026973@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=834b82b0cd8dfb4867b7eb65e9608e96cf2ba08e
Commit:        834b82b0cd8dfb4867b7eb65e9608e96cf2ba08e
Parent:        d7b381522352c684c5c55657125963533fe98132
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:27:56 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: get.sh double quote

---
 test/lib/get.sh |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 0a8c943..0608bc9 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -82,18 +82,18 @@ lv_tree_devices_() {
 			do lv_tree_devices_ "$1" "$i"; done
 		;;
 	thin)
-		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv pool_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ "$lv" pool_lv)"
 		;;
 	thin-pool)
-		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv data_lv)"
-		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv metadata_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ "$lv" data_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ "$lv" metadata_lv)"
 		;;
 	cache)
-		lv_tree_devices_ "$1" "$(lv_devices $lv)"
+		lv_tree_devices_ "$1" "$(lv_devices "$lv")"
 		;;
 	cache-pool)
-		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv data_lv)"
-		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv metadata_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ "$lv" data_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ "$lv" metadata_lv)"
 		;;
 	esac
 }


