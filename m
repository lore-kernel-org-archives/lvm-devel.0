From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 May 2015 15:53:29 +0000 (UTC)
Subject: master - lvm.conf: add more information to the comment header
Message-ID: <20150514155329.14A5E60D23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f10dfd6c79e05de89a9ef09bd92239ec1681b13
Commit:        3f10dfd6c79e05de89a9ef09bd92239ec1681b13
Parent:        8081ee1440d4a88247504c8f985161098637c520
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 14 10:52:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 14 10:52:24 2015 -0500

lvm.conf: add more information to the comment header

---
 conf/example.conf.base |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.base b/conf/example.conf.base
index e4f4761..5c49899 100644
--- a/conf/example.conf.base
+++ b/conf/example.conf.base
@@ -4,6 +4,17 @@
 #
 # Refer to 'man lvm.conf' for further information including the file layout.
 #
+# Refer to 'man lvm.conf' for information about how settings configured in
+# this file are combined with built-in values and command line options to
+# arrive at the final values used by LVM.
+#
+# Refer to 'man lvmconfig' for information about displaying the built-in
+# and configured values used by LVM.
+#
+# If a default value is set in this file (not commented out), then a
+# new version of LVM using this file will continue using that value,
+# even if the new version of LVM changes the built-in default value.
+#
 # To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
 # the environment variable LVM_SYSTEM_DIR before running the tools.
 #


