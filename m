From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 10:28:20 +0000 (UTC)
Subject: master - WHATS_NEW: previous commit
Message-ID: <20150130102820.4944F60B44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c35503e0f74968224e71d79b4359d32af5bdea93
Commit:        c35503e0f74968224e71d79b4359d32af5bdea93
Parent:        8650404df1884f1e040aad4343c8db0eac71e125
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 30 11:28:10 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 11:28:10 2015 +0100

WHATS_NEW: previous commit

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 62f03ef..474cd24 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Fix lvm2app lvm_lv_get_property return value for fields with info/status ioctl.
   Fix lvm2app regression in lvm_lv_get_attr causing unknown values (2.02.115).
   Set default cache_mode to writehrough when missing in metadata.
   Preserve chunk size with repair and metadata swap of a thin pool.


