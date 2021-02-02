From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Feb 2021 20:23:59 +0000 (GMT)
Subject: main - test: check read_only_volume_list tagging works
Message-ID: <20210202202359.539EC383E833@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae2af1d5eda8fa4e082e67429758f731ca6fcef6
Commit:        ae2af1d5eda8fa4e082e67429758f731ca6fcef6
Parent:        51c83f14837c8647c3522abb23707da3ece2085c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 2 19:53:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 2 21:23:39 2021 +0100

test: check read_only_volume_list tagging works

---
 test/shell/tags.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index fd1b33229..5b636a877 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -52,6 +52,11 @@ check lv_field @firstlvtag1 tags "firstlvtag1"
 not check lv_field @secondlvtag1 tags "firstlvtag1"
 check lv_field $vg1/$lv2 tags "secondlvtag1"
 not check lv_field $vg1/$lv1 tags "secondlvtag1"
+
+# LV is not zeroed when tag matches read only volume list
+lvcreate -l1 $vg1 --addtag "RO" --config "activation/read_only_volume_list = [ \"@RO\" ]" 2>&1 | tee out
+grep "not zeroed" out
+
 vgremove -f $vg1
 
 # lvchange with --addtag and --deltag


