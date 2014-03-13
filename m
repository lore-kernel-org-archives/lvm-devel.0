From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Mar 2014 12:20:41 +0000 (UTC)
Subject: master - man: install lvm2-activation-generator man page only on make install_systemd_generators
Message-ID: <20140313122041.89DE760F8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2189d66a2758e4be67a32a7d9d24a9df55c31c4c
Commit:        2189d66a2758e4be67a32a7d9d24a9df55c31c4c
Parent:        031666ef66bf7b17ded4afcaa9bb97587fca0749
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 13 13:17:58 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 13 13:20:28 2014 +0100

man: install lvm2-activation-generator man page only on make install_systemd_generators

---
 man/Makefile.in |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 12a0560..ce3b1ee 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -48,8 +48,7 @@ MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 lvm2-activation-generator.8 \
-	$(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8


