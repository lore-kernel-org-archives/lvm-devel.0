From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:10 +0000 (UTC)
Subject: dev-mornfall-activate - WHATS_NEW: ea_start, ea_size -> ba_start, ba_size
Message-ID: <20130604192710.D4BA760FCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be25f7ac83bcf0f910a6213d4c1d195fbdd0d45d
Commit:        be25f7ac83bcf0f910a6213d4c1d195fbdd0d45d
Parent:        732859d21f3b41bdb188f92b60f25d5c94dcee8a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 28 12:43:26 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 28 12:43:26 2013 +0200

WHATS_NEW: ea_start,ea_size -> ba_start,ba_size

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 977519c..40fd569 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -38,7 +38,7 @@ Version 2.02.99 -
   Add --withcomments and --withversions switch to lvm dumpconfig.
   Add --type {current|default|missing|new} and --atversion to lvm dumpconfig.
   Support automatic config validation and add 'config' section to lvm.conf.
-  Add pvs -o ea_start,ea_size to report bootloader area start and size.
+  Add pvs -o ba_start,ba_size to report bootloader area start and size.
   Add --bootloaderareasize to pvcreate and vgconvert to create a bootloader area.
   Add PV header extension: extension version, flags and bootloader areas.
   Initial support for lvconvert of thin external origin.


