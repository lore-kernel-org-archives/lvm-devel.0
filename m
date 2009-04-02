From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:34 -0400
Subject: [RFC PATCH 7/7] introduce metadata cache feature
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F3A6.50708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add backup/metadata_cache parameter to enable the metadata cache
feature. Another new parameter, metadata_cache_dir will be added
in the future version to indicate metadata cache directory.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 doc/example.conf |    6 ++++++
 1 file changed, 6 insertions(+)

Index: LVM2.02.46-cvs-20090324/doc/example.conf
===================================================================
--- LVM2.02.46-cvs-20090324.orig/doc/example.conf
+++ LVM2.02.46-cvs-20090324/doc/example.conf
@@ -187,6 +187,12 @@ backup {
 
     # What is the minimum time you wish to keep an archive file for ?
     retain_days = 30
+
+    # Use metadata cache to get lvm structures in the system instead of
+    # scanning all devices every time. If any errors are detected, lvm
+    # commands fall back to not use metadata cache.
+    # 1 enables; 0 disables.
+    # metadata_cache = 0
 }
 
 # Settings for the running LVM2 in shell (readline) mode.





