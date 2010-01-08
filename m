From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Jan 2010 15:53:07 +0100
Subject: [PATCH 2/4] Enable udev_sync and udev_rules in lvm.conf used for tests
Message-ID: <4B4746D3.9010307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I *always* forget to set these.
And it seems I'm not the only one :)

Peter


diff --git a/test/lvm-utils.sh b/test/lvm-utils.sh
index 5ad8872..6b7f231 100644
--- a/test/lvm-utils.sh
+++ b/test/lvm-utils.sh
@@ -202,6 +202,10 @@ init_root_dir_()
   global {
     library_dir = "$G_root_/lib"
   }
+  activation {
+    udev_sync = 1
+    udev_rules = 1
+  }
 EOF
 }
 
diff --git a/test/test-utils.sh b/test/test-utils.sh
index 119a549..27b6fe7 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -203,6 +203,10 @@ prepare_lvmconf() {
     library_dir = "$G_root_/lib"
     locking_dir = "$G_root_/var/lock/lvm"
   }
+  activation {
+    udev_sync = 1
+    udev_rules = 1
+  }
 EOF
 }
 


