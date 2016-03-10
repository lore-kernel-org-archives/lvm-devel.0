From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:09 +0000 (UTC)
Subject: master - makefiles: avoid using vpath for rules files
Message-ID: <20160310174009.40E1360804@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86a23b2145e4abde3086a22ceb15438515b0053d
Commit:        86a23b2145e4abde3086a22ceb15438515b0053d
Parent:        70cbd8f1a5cc6abb418a90529bc12a2813806f13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 9 17:52:29 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:53 2016 +0100

makefiles: avoid using vpath for rules files

Fixing vpath usage as it has been checking for existance of
generated file also in the $(scrdir) e.g.:

No need to remake target '10-dm.rules.in'; using VPATH name '...'

If the $(srcdir) had been also $(builddir) and contained already
generated rules file, it's been used instead generating new
one.

(See: http://make.mad-scientist.net/papers/how-not-to-use-vpath/)
---
 WHATS_NEW        |    1 +
 udev/Makefile.in |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eab40b1..d348cbc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.146 - 
 =================================
+  Fix makefile vpath in /udev when generating udev rules files.
   Another attempt to improve VG name parsing for lvconvert (2.02.144).
   Use new cache status info and skip flushing for failed cache.
   Support --uncache with missing PVs.
diff --git a/udev/Makefile.in b/udev/Makefile.in
index d23eb7d..cb968df 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -16,7 +16,6 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 include $(top_builddir)/make.tmpl
-vpath %.rules $(srcdir)
 
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules
@@ -52,7 +51,7 @@ else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif
 
-%.rules: %.rules.in
+%.rules: $(srcdir)/%.rules.in
 	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules


