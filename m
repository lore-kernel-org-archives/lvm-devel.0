From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:06 -0400
Subject: master - vgimportclone.sh: cannot trap signal 9
Message-ID: <201706292027.v5TKR6Sk026566@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d745593e8929bd2ebf928e897a4b7d549ea46cf1
Commit:        d745593e8929bd2ebf928e897a4b7d549ea46cf1
Parent:        275eeb4631657fcb43d27d6cd309f690869c4e2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:06:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: cannot trap signal 9

---
 scripts/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 23181ea..f621f99 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -117,7 +117,7 @@ if [ -n "${LVM_SYSTEM_DIR}" ]; then
     export ORIG_LVM_SYS_DIR="${LVM_SYSTEM_DIR}"
 fi
 
-trap  cleanup 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
+trap  cleanup 0 1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 17 18
 
 #####################################################################
 ### Get and check arguments


