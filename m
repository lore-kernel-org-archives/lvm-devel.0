From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:31 +0000 (UTC)
Subject: master - man: _corig is reserved
Message-ID: <20141110210631.F3D8260FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5c2665a213332904836ad90e2f90dd72b6db4c5
Commit:        c5c2665a213332904836ad90e2f90dd72b6db4c5
Parent:        3e230a8ad80c0c2f48c04979405fe2897f7ef769
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 13:16:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

man: _corig is reserved

---
 WHATS_NEW             |    1 +
 lib/misc/lvm-string.c |    1 +
 man/lvm.8.in          |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 616d1b0..0b5d892 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add _corig as reserved suffix.
   Reduce vg write and vg commits when creating spare volumes.
   When remove_layer_from_lv() removes layer, restore subLV names.
   Cache-pool in use becomes invisible LV.
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 84c8708..ae4adbe 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -121,6 +121,7 @@ static const char *_lvname_has_reserved_string(const char *lvname)
 	static const char _strings[][12] = {
 		"_cdata",
 		"_cmeta",
+		"_corig",
 		"_mimage",
 		"_mlog",
 		"_pmspare",
diff --git a/man/lvm.8.in b/man/lvm.8.in
index c6f72a3..7b95e2b 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -346,7 +346,7 @@ VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 An LV cannot be called '.', '..', 'snapshot' or 'pvmove'. The LV name may also not contain any of the following 
-strings: '_cdata', '_cmeta', '_mlog', '_mimage', '_pmspare', '_rimage', '_rlog', '_tdata' or '_tmeta'.
+strings: '_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare', '_rimage', '_rlog', '_tdata' or '_tmeta'.
 A directory bearing the name of each Volume Group is created under /dev when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic link leading to a device node.
 Links or nodes in /dev/mapper are intended only for internal use and the precise format and escaping might change between releases and distributions.


