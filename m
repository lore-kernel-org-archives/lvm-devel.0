From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:45:23 +0000 (UTC)
Subject: master - tests: comment in select-tools.sh
Message-ID: <20150213104523.A685060A57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=993c988895c2bdac1867b79ef1de5c14cdd4072d
Commit:        993c988895c2bdac1867b79ef1de5c14cdd4072d
Parent:        e0ce7285794da030a3e87d9b0a81217d6155c3bc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 11:45:13 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 11:45:13 2015 +0100

tests: comment in select-tools.sh

---
 test/shell/select-tools.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index b727fd7..c418716 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -236,9 +236,8 @@ not check pv_field $dev3 pv_tags 305
 not check pv_field $dev4 pv_tags 305
 pvchange -a --deltag 305
 
-# intersection between selection
-# result and supplied VG name/tag
-
+# if PV name or tag is supplied together with the
+# selection, the result is an intersection of both
 pvchange --addtag 306 -S "pv_name=$dev1" $dev2
 not check pv_field $dev1 pv_tags 306
 not check pv_field $dev2 pv_tags 306


