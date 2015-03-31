From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 Mar 2015 13:38:39 +0000 (UTC)
Subject: master - lvm.conf: fix typo as -> is in read_only_volume_list comments
Message-ID: <20150331133839.4E54760ED0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=974a029a8a181b3bc8ee5f10b202408b175d1b4b
Commit:        974a029a8a181b3bc8ee5f10b202408b175d1b4b
Parent:        04826db7c415028cb4a16bdde5553859779380ac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 31 15:38:29 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 31 15:38:29 2015 +0200

lvm.conf: fix typo as -> is in read_only_volume_list comments

---
 conf/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 51e8e85..1863a89 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -997,7 +997,7 @@ activation {
     # auto_activation_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
     # If read_only_volume_list is defined, each LV that is to be activated 
-    # is checked against the list, and if it matches, it as activated
+    # is checked against the list, and if it matches, it is activated
     # in read-only mode.  (This overrides '--permission rw' stored in the
     # metadata.)
     #


