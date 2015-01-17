From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 17 Jan 2015 11:30:51 +0000 (UTC)
Subject: master - vgimportclone: Say safe to ignore lvmetad message.
Message-ID: <20150117113051.4B43C60E52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f90f632f565f9796603e6fef081ab9ecd0f9e49
Commit:        8f90f632f565f9796603e6fef081ab9ecd0f9e49
Parent:        e5ffacc43440d5aef5ec84d4c9df62faca103fe6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 17 11:29:38 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 17 11:29:38 2015 +0000

vgimportclone: Say safe to ignore lvmetad message.

---
 scripts/vgimportclone.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 719cd8d..9d319bd 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -369,6 +369,7 @@ then
     if [ "$use_lvmetad" = "1" ]
     then
       echo "Notifying lvmetad about changes since it was disabled temporarily."
+      echo "(This resolves any WARNING message about restarting lvmetad that appears above.)"
       LVM_OPTS="${LVM_OPTS} --cache"
     fi
 


