From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:55 -0400
Subject: master - tests: use exclusive activation
Message-ID: <201706161513.v5GFDtEK011250@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd866a67f44ad44512388cf2e073511d88b9c19c
Commit:        dd866a67f44ad44512388cf2e073511d88b9c19c
Parent:        fbb3bffb221f3c0275bafef4f2cc7ea299214ef4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 14 13:59:11 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:02 2017 +0200

tests: use exclusive activation

Conversion needs exlusively active LV for clustered testing.
---
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
index 3870c35..cf926a1 100644
--- a/test/shell/lvconvert-raid-takeover-alloc-failure.sh
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -48,7 +48,7 @@ function check_no_sub_lvs
 # Check takover upconversion fails allocation errors nicely without leaving image pair remnants behind
 
 # 6-way striped: neither conversion to raid5 nor raid6 possible
-lvcreate --yes --stripes 6 --size 4M --name $lv1 $vg
+lvcreate -aey --yes --stripes 6 --size 4M --name $lv1 $vg
 not lvconvert --yes --type raid4 $vg/$lv1
 check lv_field $vg/$lv1 segtype "striped"
 check_no_sub_lvs $vg $lv1 0 5
@@ -69,7 +69,7 @@ check_sub_lvs $vg $lv1 0 5
 lvremove -y $vg
 
 # 5-way striped: conversion to raid5 possible but not to raid6
-lvcreate --yes --stripes 5 --size 4M --name $lv1 $vg
+lvcreate -aey --stripes 5 --size 4M --name $lv1 $vg
 not lvconvert --yes --type raid6 $vg/$lv1
 check lv_field $vg/$lv1 segtype "striped"
 check_no_sub_lvs $vg $lv1 0 5
@@ -83,7 +83,7 @@ check_sub_lvs $vg $lv1 0 5
 lvremove -y $vg
 
 # 4-way striped: conversion to raid5 and raid6 possible
-lvcreate --yes --stripes 4 --size 4M --name $lv1 $vg
+lvcreate -aey --stripes 4 --size 4M --name $lv1 $vg
 lvconvert --yes --type raid5 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 stripes 5
@@ -92,7 +92,8 @@ check_sub_lvs $vg $lv1 0 4
 check_no_sub_lvs $vg $lv1 5 5
 
 lvremove -y $vg
-lvcreate --yes --stripes 4 --size 4M --name $lv1 $vg
+
+lvcreate -aey --stripes 4 --size 4M --name $lv1 $vg
 lvconvert --yes --type raid6 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid6_n_6"
 check lv_field $vg/$lv1 stripes 6


