From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Jan 2013 15:59:01 +0000 (UTC)
Subject: master - blkdeactivate: prevent trying to unmount the same mountpoint more times
Message-ID: <20130123155901.44F26A32D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2be83f45431313947619ac57e9554c59621c371b
Commit:        2be83f45431313947619ac57e9554c59621c371b
Parent:        f7da1caf8deaf50e0597ec377fb035ea3de1ac36
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 23 16:57:44 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 23 16:57:44 2013 +0100

blkdeactivate: prevent trying to unmount the same mountpoint more times

An addendum to previous commit 1052863a1b35f7488758c78b3a9ebef5c63392bc.
---
 scripts/blkdeactivate.sh.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 849c61d..be00c24 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -39,7 +39,7 @@ LVM="@sbindir@/lvm"
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
 LSBLK_READ="read -r devtype kname name mnt"
-SORT_MNT="/bin/sort -r -k 4"
+SORT_MNT="/bin/sort -r -u -k 4"
 
 # Do not unmount mounted devices by default.
 DO_UMOUNT=0


