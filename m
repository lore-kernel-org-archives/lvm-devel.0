From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:45:37 +0000 (UTC)
Subject: master - man: pvs -o ba_start, ba_size -> pv_ba_start, pv_ba_size
Message-ID: <20130723124537.6898361078@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b1834f075daf0fb3f349356a31c1bfed421384a
Commit:        9b1834f075daf0fb3f349356a31c1bfed421384a
Parent:        83fb622598458e6814eb0d5dde23eda18c6ac620
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 23 14:44:30 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 23 14:45:30 2013 +0200

man: pvs -o ba_start,ba_size -> pv_ba_start,pv_ba_size

---
 WHATS_NEW         |    2 +-
 man/pvcreate.8.in |    2 +-
 man/pvs.8.in      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 15419bb..0269839 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -111,7 +111,7 @@ Version 2.02.99 -
   Add --withcomments and --withversions switch to lvm dumpconfig.
   Add --type {current|default|missing|new} and --atversion to lvm dumpconfig.
   Support automatic config validation and add 'config' section to lvm.conf.
-  Add pvs -o ba_start,ba_size to report bootloader area start and size.
+  Add pvs -o pv_ba_start,pv_ba_size to report bootloader area start and size.
   Add --bootloaderareasize to pvcreate and vgconvert to create a bootloader area.
   Add PV header extension: extension version, flags and bootloader areas.
   Initial support for lvconvert of thin external origin.
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index bd979aa..9353c6c 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -174,7 +174,7 @@ The start of the bootloader area is always aligned, see also \fB--dataalignment\
 and \fB--dataalignmentoffset\fP. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
-an existing Physical Volume use \fBpvs -o +ba_start,ba_size\fP.
+an existing Physical Volume use \fBpvs -o +pv_ba_start,pv_ba_size\fP.
 .TP
 .B \-\-setphysicalvolumesize \fIsize
 Overrides the automatically-detected size of the PV.  Use with care.
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 7ec724a..d1f6e8b 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -63,7 +63,7 @@ and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
 Use \fB-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
-pv_mda_size, ba_start, ba_size, pe_start, pv_size, pv_free, pv_used,
+pv_mda_size, pv_ba_start, pv_ba_size, pe_start, pv_size, pv_free, pv_used,
 pv_attr, pv_pe_count, pv_pe_alloc_count, pv_tags, pv_mda_count,
 pv_mda_used_count, pvseg_start, and pvseg_size
 .IP


