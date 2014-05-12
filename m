From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:54 +0000 (UTC)
Subject: master - tests: replance hostname call
Message-ID: <20140512142554.E0FBF6106E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f057e3c6640f25676b0c5d0fe93912ac91244bf
Commit:        6f057e3c6640f25676b0c5d0fe93912ac91244bf
Parent:        c07fb7678ecb7ecf54e9acc4c2f3ef6138cec90f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 12 10:39:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:40 2014 +0200

tests: replance hostname call

---
 test/shell/lvchange-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 0b4c15d..c6fd813 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -98,7 +98,7 @@ not lvchange --resync --addtag foo $vg/$lv1
 #
 # Play with tags and activation
 #
-TAG=$(hostname)
+TAG=$(uname -n)
 aux lvmconf 'activation/volume_list = [ "$vg/$lv2", "@mytag", "$vg2" ]'
 
 lvchange -ay $vg/$lv1


