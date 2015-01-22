From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 22 Jan 2015 19:02:04 +0000 (UTC)
Subject: master - lvm.conf: update error_when_full description
Message-ID: <20150122190204.B674060FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f5ce1fa430004f853b9aee1ac28fdd3cd5014ba
Commit:        4f5ce1fa430004f853b9aee1ac28fdd3cd5014ba
Parent:        4b099d06b119013bbf27ffb8a0f056fe725ce603
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 22 13:01:02 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 22 13:01:02 2015 -0600

lvm.conf: update error_when_full description

Relate it to the --errorwhenfull option.
---
 conf/example.conf.in |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 21b963b..0ba9ccb 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -938,8 +938,11 @@ activation {
     # enables or disables this automatic setting of the flag while LVs are created.
     # auto_set_activation_skip = 1
 
-    # Control error behavior when provisioned device becomes full.
-    # Set to 1 to instant error when there is missing free space in device.
+    # Control error behavior when provisioned device becomes full.  This
+    # determines the default --errorwhenfull setting of new thin pools.
+    # The command line option --errorwhenfull takes precedence over this
+    # setting.  error_when_full 0 means --errorwhenfull n.
+    #
     # error_when_full = 0
 
     # For RAID or 'mirror' segment types, 'raid_region_size' is the


