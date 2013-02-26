From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:51:10 +0000 (UTC)
Subject: master - WHATS_NEW: add lines for embedding area support
Message-ID: <20130226145110.38B98A0C32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3776468fa07a0bc173dd01152a4f6010c4d174d
Commit:        b3776468fa07a0bc173dd01152a4f6010c4d174d
Parent:        28a5f6bc3833ad2f84e6d00745fc103d508708a6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 26 15:50:43 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 15:50:43 2013 +0100

WHATS_NEW: add lines for embedding area support

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dc4fc8f..3a837aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.99 - 
 ===================================
+  Add pvs -o ea_start,ea_size to report embedding area start and size.
+  Add --embeddingareasize to pvcreate and vgconvert to create an embedding area.
+  Add PV header extension: extension version, flags and embedding areas.
   Initial support for lvconvert of thin external origin.
   Add _lv_remove_segs_using_this_lv() for removal of dependent lvs.
   Improve activation code for better support of stacked devices.


