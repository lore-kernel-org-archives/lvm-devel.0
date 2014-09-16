From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:01 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - test: test there is no leak of LV on error path
Message-ID: <20140916153501.A45016117C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f435bef957cea11a16d15ea10a1d85193bacd736
Commit:        f435bef957cea11a16d15ea10a1d85193bacd736
Parent:        75a5de1462c30f364c7d478a4f74f355ce559ae9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 15 13:44:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 15 13:51:19 2014 +0200

test: test there is no leak of LV on error path

---
 test/shell/thin-volume-list.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index b53e772..31f4034 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -38,6 +38,11 @@ aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
 # Pool is not active - so it cannot create thin volume
 not lvcreate -V10 -T $vg/pool
 
+# Cannot create even new pool
+# check there are not left devices (RHBZ #1140128)
+not lvcreate -L10 -T $vg/new_pool
+check lv_not_exists $vg/new_pool
+
 aux lvmconf "activation/volume_list = [ \"$vg\" ]"
 
 lvcreate -V10 -T $vg/pool


