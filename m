From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Oct 2015 10:55:50 +0000 (UTC)
Subject: master - vgimportclone: make sure there's no prefix in VG name list
Message-ID: <20151012105550.25F5260F68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75420282e17e44d5c7b56126a5c7fd170f0ef417
Commit:        75420282e17e44d5c7b56126a5c7fd170f0ef417
Parent:        38df48d108e3b040501edfd9e0517bfcb31373de
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 12 12:51:13 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 12 12:54:59 2015 +0200

vgimportclone: make sure there's no prefix in VG name list

Make sure log/prefix is set to "" when getting the list of VG names.
We need this for the format to be correct so it's properly searched
through later on.
---
 scripts/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 52f3884..0ac987a 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -220,7 +220,7 @@ fi
 ###     :vgname1:vgname2:...:vgnameN:
 #####################################################################
 
-OLDVGS=":`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings --rows --separator :`:"
+OLDVGS=":`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings --rows --separator : --config 'log{prefix=""}'`:"
 checkvalue $? "Current VG names could not be collected without errors"
 
 #####################################################################


