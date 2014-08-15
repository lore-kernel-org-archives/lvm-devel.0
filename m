From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:37 +0000 (UTC)
Subject: master - man: add some more reserved names
Message-ID: <20140815130737.D91FD60319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba7796e0550dcc8fcc114bc8eadc6815c34c3f4f
Commit:        ba7796e0550dcc8fcc114bc8eadc6815c34c3f4f
Parent:        630fcab420ce791612bbeed3e30db4c5371803e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 14 11:10:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

man: add some more reserved names

---
 man/lvm.8.in |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 76d1237..069194c 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -339,14 +339,15 @@ Path for the lvmetad pid file.
 .B LVM_LVMETAD_SOCKET
 Path for the lvmetad socket file.
 .SH VALID NAMES
-The following characters are valid for VG and LV names:
+The valid characters for VG and LV names are:
 .B a-z A-Z 0-9 + _ . -
 .LP
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
-the strings '_mlog', '_mimage', '_rimage', '_tdata', '_tmeta'.
+the strings '_cdata', '_cmeta', '_mlog', '_mimage', '_pmspare',
+'_rimage', '_rlog', '_tdata', '_tmeta'.
 A directory bearing the name of each Volume Group is created under /dev when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic link leading to a device node.
 Links or nodes in /dev/mapper are intended only for internal use and the precise format and escaping might change between releases and distributions.


