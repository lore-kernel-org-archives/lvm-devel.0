From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 26 May 2016 14:13:45 +0000 (UTC)
Subject: master - WHATS_NEW: include recent changes
Message-ID: <20160526141345.8A013607BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b762c37555dec3c2e99df05a721787d2223807b6
Commit:        b762c37555dec3c2e99df05a721787d2223807b6
Parent:        5dc2ed0c71eab9081ef6245150f5efad2a7c77b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 26 09:13:30 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 26 09:13:30 2016 -0500

WHATS_NEW: include recent changes

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eac3477..fa13ac8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.155 - 
 ================================
+  Update vgreduce to use process_each_vg.
+  Update lvconvert to use process_each_lv.
+  Update pvscan to use process_each_vg for autoactivation.
   Add basic support for --type raid0 using md.
   Add support for lvchange --cachemode for cached LV.
   Fix liblvm2app error handling when setting up context.


