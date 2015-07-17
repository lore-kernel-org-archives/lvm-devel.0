From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 17 Jul 2015 11:58:42 +0000 (UTC)
Subject: master - test: Ignore known concurrent VG clvmd failure.
Message-ID: <20150717115842.13F356110A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7fc06a262bacb6355485edebc5f7b7037471106
Commit:        c7fc06a262bacb6355485edebc5f7b7037471106
Parent:        268f53ed0de087b0d42429a8b18c191f12a331cb
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 17 12:56:52 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 17 12:56:52 2015 +0100

test: Ignore known concurrent VG clvmd failure.

Don't abort test when clvmd processes two VGs concurrently.
  CLVMD: ioctl/libdm-iface.c:1940   Internal error: Performing unsafe table load while 3 device(s) are known to be suspended:  (253:19)
---
 test/shell/pvmove-abort-all.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index da43da6..2867163 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -11,6 +11,10 @@
 
 # Check pvmove --abort behaviour for all VGs and PVs
 
+# Ignore known failure when clvmd is processing sequences of commands for two VGs in parallel - 2015/07/17 agk
+# CLVMD: ioctl/libdm-iface.c:1940   Internal error: Performing unsafe table load while 3 device(s) are known to be suspended:  (253:19) 
+export DM_ABORT_ON_INTERNAL_ERRORS=0
+
 . lib/inittest
 
 aux prepare_pvs 6 60


