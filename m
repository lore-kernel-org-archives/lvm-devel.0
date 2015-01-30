From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 14:41:51 +0000 (UTC)
Subject: master - cleanup: conf: auxiliary_device_status_source -> external_device_info_source
Message-ID: <20150130144151.A1B1460F35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8aab3a7fdb22655493ace8bac75e655b5b0cffe
Commit:        e8aab3a7fdb22655493ace8bac75e655b5b0cffe
Parent:        434031719e37524606d198b2d78795962970a1b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 30 15:39:59 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 15:41:42 2015 +0100

cleanup: conf: auxiliary_device_status_source -> external_device_info_source

auxiliary_device_status_source was name used during development
of this feature, renamed later.
---
 conf/example.conf.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index d9f10bf..f7b9da0 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -181,8 +181,8 @@ devices {
     # By default, LVM2 will not ignore devices used as components of
     # firmware RAID devices. Set to 1 to enable this detection.
     # N.B. LVM2 itself is not detecting firmware RAID - an
-    # auxiliary_device_status_source other than "native" must
-    # be used for this detection to be successful.
+    # external_device_info_source other than "none" must
+    # be used for this detection to execute.
     # 1 enables; 0 disables
     fw_raid_component_detection = 0
 


