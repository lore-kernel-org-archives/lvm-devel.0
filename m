From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Feb 2016 10:48:20 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160215104820.9412B60B27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=228b8245e4fbae92968feeb8ded57697b567ceed
Commit:        228b8245e4fbae92968feeb8ded57697b567ceed
Parent:        672deaebc55464015065c2101a3de03e02190e01
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 15 10:35:16 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 15 10:35:16 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++----
 WHATS_NEW_DM |    4 ++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 2cb3303..6ac1ce6 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.142(2)-git (2016-01-25)
+2.02.142(2)-git (2016-02-15)
diff --git a/VERSION_DM b/VERSION_DM
index 17b06bb..73eb926 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.116-git (2016-01-25)
+1.02.116-git (2016-02-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8c3a204..9207fca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,12 +1,13 @@
-Version 2.02.142 - 
-====================================
+Version 2.02.142 - 15th February 2016
+=====================================
   Fix memory pool corruption in pvmove (2.02.141).
   Support control of spare metadata creation when repairing thin-pool.
   Fix config type of 'log/verbose' from bool to int (2.02.99).
-  Fix thinp watermark calc for data LV for faster dmeventd responce (2.02.133).
+  Fix inverted data LV thinp watermark calc for dmeventd response (2.02.133).
   Use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in.
   Do not check for suspended devices if scanning for lvmetad update.
-  Fix part. table filter with external_device_info_source="udev" and blkid<2.20.
+  Clear cached bootloader areas when PV format changed.
+  Fix partn table filter with external_device_info_source="udev" and blkid<2.20.
 
 Version 2.02.141 - 25th January 2016
 ====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 693667b..9e30e66 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.116 - 
-====================================
+Version 1.02.116 - 15th February 2016
+=====================================
   Use fully aligned allocations for dm_pool_strdup/strndup() (1.02.64).
   Fix thin-pool table parameter feature order to match kernel output.
 


