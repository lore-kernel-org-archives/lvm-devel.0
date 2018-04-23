From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:46:48 -0400
Subject: master - [git] Update .gitignore
Message-ID: <201804231346.w3NDkmTJ031127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb2c4542a6028ef09d30bfdcdaef4e7ddb740ca7
Commit:        cb2c4542a6028ef09d30bfdcdaef4e7ddb740ca7
Parent:        38d77898ae7a824b3a05ee2a1812d7a85cca6373
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed Jan 31 11:35:47 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:11:56 2018 -0500

[git] Update .gitignore

---
 .gitignore |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index a890cee..0ac0a32 100644
--- a/.gitignore
+++ b/.gitignore
@@ -30,3 +30,51 @@ make.tmpl
 /cscope.out
 /tags
 /tmp/
+
+tools/man-generator
+tools/man-generator.c
+
+test/lib/lvchange
+test/lib/lvconvert
+test/lib/lvcreate
+test/lib/lvdisplay
+test/lib/lvextend
+test/lib/lvmconfig
+test/lib/lvmdiskscan
+test/lib/lvmsadc
+test/lib/lvmsar
+test/lib/lvreduce
+test/lib/lvremove
+test/lib/lvrename
+test/lib/lvresize
+test/lib/lvs
+test/lib/lvscan
+test/lib/pvchange
+test/lib/pvck
+test/lib/pvcreate
+test/lib/pvdisplay
+test/lib/pvmove
+test/lib/pvremove
+test/lib/pvresize
+test/lib/pvs
+test/lib/pvscan
+test/lib/vgcfgbackup
+test/lib/vgcfgrestore
+test/lib/vgchange
+test/lib/vgck
+test/lib/vgconvert
+test/lib/vgcreate
+test/lib/vgdisplay
+test/lib/vgexport
+test/lib/vgextend
+test/lib/vgimport
+test/lib/vgimportclone
+test/lib/vgmerge
+test/lib/vgmknodes
+test/lib/vgreduce
+test/lib/vgremove
+test/lib/vgrename
+test/lib/vgs
+test/lib/vgscan
+test/lib/vgsplit
+


