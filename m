From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:35:59 +0000 (GMT)
Subject: main - vdo: man page updates
Message-ID: <20210913103559.12FCE3858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=812653d59806439379d80bb8124f6962ae42d46a
Commit:        812653d59806439379d80bb8124f6962ae42d46a
Parent:        9db4ddabc1cf912dee30e0e6293767f01c976a4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 01:15:01 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

vdo: man page updates

---
 man/lvm_import_vdo.8_main | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/man/lvm_import_vdo.8_main b/man/lvm_import_vdo.8_main
index d970eeb40..c812c5e01 100644
--- a/man/lvm_import_vdo.8_main
+++ b/man/lvm_import_vdo.8_main
@@ -45,6 +45,9 @@ Specifies the name of converted VDO LV. When the name is not specified,
 some automatic name is selected. In case the converted VDO volume is
 already using LV a backend device, the name of this LV is used for VDO LV.
 In this case also the of volume group must stay same.
+Automatic name may change between releases and currently selects
+"vdolv" as LV name and VG name is selected from sequence
+"vdovg", "vdovg1", ...
 .
 .TP
 .BR -v | --verbose


