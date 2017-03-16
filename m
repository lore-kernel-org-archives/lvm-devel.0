From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Mar 2017 19:15:00 -0400
Subject: master - man: Preserve template variables in pre-generated pages.
Message-ID: <201703162315.v2GNF0wG030387@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=270ed9bc9038b1cd2ff4f4a7177292621c591ede
Commit:        270ed9bc9038b1cd2ff4f4a7177292621c591ede
Parent:        0c74afa1c613537e5aed33ed230755cfe8b0ab03
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 23:08:59 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 23:08:59 2017 +0000

man: Preserve template variables in pre-generated pages.

---
 man/Makefile.in             |   10 ++++++----
 man/lvchange.8_pregen       |    2 +-
 man/lvconvert.8_pregen      |    2 +-
 man/lvcreate.8_pregen       |    2 +-
 man/lvdisplay.8_pregen      |    2 +-
 man/lvextend.8_pregen       |    2 +-
 man/lvm-config.8_pregen     |    2 +-
 man/lvm-dumpconfig.8_pregen |    2 +-
 man/lvm-fullreport.8_pregen |    2 +-
 man/lvm-lvpoll.8_pregen     |    2 +-
 man/lvmconfig.8_pregen      |    2 +-
 man/lvmdiskscan.8_pregen    |    2 +-
 man/lvreduce.8_pregen       |    2 +-
 man/lvremove.8_pregen       |    2 +-
 man/lvrename.8_pregen       |    2 +-
 man/lvresize.8_pregen       |    2 +-
 man/lvs.8_pregen            |    2 +-
 man/lvscan.8_pregen         |    2 +-
 man/pvchange.8_pregen       |    2 +-
 man/pvck.8_pregen           |    2 +-
 man/pvcreate.8_pregen       |    2 +-
 man/pvdisplay.8_pregen      |    2 +-
 man/pvmove.8_pregen         |    2 +-
 man/pvremove.8_pregen       |    2 +-
 man/pvresize.8_pregen       |    2 +-
 man/pvs.8_pregen            |    2 +-
 man/pvscan.8_pregen         |    2 +-
 man/vgcfgbackup.8_pregen    |    6 +++---
 man/vgcfgrestore.8_pregen   |    2 +-
 man/vgchange.8_pregen       |    2 +-
 man/vgck.8_pregen           |    2 +-
 man/vgconvert.8_pregen      |    2 +-
 man/vgcreate.8_pregen       |    2 +-
 man/vgdisplay.8_pregen      |    2 +-
 man/vgexport.8_pregen       |    2 +-
 man/vgextend.8_pregen       |    2 +-
 man/vgimport.8_pregen       |    2 +-
 man/vgimportclone.8_pregen  |    2 +-
 man/vgmerge.8_pregen        |    2 +-
 man/vgmknodes.8_pregen      |    2 +-
 man/vgreduce.8_pregen       |    2 +-
 man/vgremove.8_pregen       |    2 +-
 man/vgrename.8_pregen       |    2 +-
 man/vgs.8_pregen            |    2 +-
 man/vgscan.8_pregen         |    2 +-
 man/vgsplit.8_pregen        |    2 +-
 46 files changed, 53 insertions(+), 51 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index e9c7d3d..b3f287b 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -122,7 +122,7 @@ TESTMAN=test.gen
 
 include $(top_builddir)/make.tmpl
 
-CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8:%.8_gen=%.8) $(MAN8CLUSTER) \
+CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(MANGENERATOR) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
@@ -150,12 +150,14 @@ $(TESTMAN): $(MANGENERATOR)
 
 SEE_ALSO=$(srcdir)/see_also.end
 
+.PRECIOUS: %.8_gen
+
 %.8_gen: $(srcdir)/%.8_des $(srcdir)/%.8_end $(MANGENERATOR) $(TESTMAN)
 	( \
 	    if [ ! -s $(TESTMAN) ] ; then \
-		echo "Copying pre-generated $@" ; \
+		echo "Copying pre-generated template $@" ; \
 	    else \
-		echo "Generating $@" ; \
+		echo "Generating template $@" ; \
 	    fi \
 	)
 	( \
@@ -222,7 +224,7 @@ install_all_man: install install_systemd_generators
 pregenerated_man: all
 	for i in $(srcdir)/*.8_des; do \
 		CMD=`basename $$i .8_des`; \
-		cat $${CMD}.8 > $(srcdir)/$$CMD.8_pregen ; \
+		cat $${CMD}.8_gen > $(srcdir)/$$CMD.8_pregen ; \
 	done
 
 generate: pregenerated_man
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index f0e2c92..5d63f47 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -1,4 +1,4 @@
-.TH LVCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvchange \- Change the attributes of logical volume(s)
 .
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index da29009..97c01bc 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1,4 +1,4 @@
-.TH LVCONVERT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvconvert \- Change logical volume layout
 .
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 9b64c53..ce1c154 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1,4 +1,4 @@
-.TH LVCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvcreate \- Create a logical volume
 .
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 5670db4..ff15df0 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -1,4 +1,4 @@
-.TH LVDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvdisplay \- Display information about a logical volume
 .
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index d23b719..b81cad3 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -1,4 +1,4 @@
-.TH LVEXTEND 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVEXTEND 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvextend \- Add space to a logical volume
 .
diff --git a/man/lvm-config.8_pregen b/man/lvm-config.8_pregen
index 3eb34a5..6c02ed8 100644
--- a/man/lvm-config.8_pregen
+++ b/man/lvm-config.8_pregen
@@ -1,4 +1,4 @@
-.TH LVM CONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVM CONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvm config \- Display and manipulate configuration information
 .
diff --git a/man/lvm-dumpconfig.8_pregen b/man/lvm-dumpconfig.8_pregen
index 1b47fd5..34c329c 100644
--- a/man/lvm-dumpconfig.8_pregen
+++ b/man/lvm-dumpconfig.8_pregen
@@ -1,4 +1,4 @@
-.TH LVM DUMPCONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVM DUMPCONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvm dumpconfig \- Display and manipulate configuration information
 .
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index c62b449..25d780e 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -1,4 +1,4 @@
-.TH LVM FULLREPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVM FULLREPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvm fullreport \- Display full report
 .
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 5f2b225..fde6d93 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -1,4 +1,4 @@
-.TH LVM LVPOLL 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVM LVPOLL 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvm lvpoll \- Continue already initiated poll operation on a logical volume
 .
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index cfa03fe..3ed8137 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -1,4 +1,4 @@
-.TH LVMCONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVMCONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvmconfig \- Display and manipulate configuration information
 .
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 67e923b..b8c5025 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -1,4 +1,4 @@
-.TH LVMDISKSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVMDISKSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvmdiskscan \- List devices that may be used as physical volumes
 .
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 931b754..98c0414 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -1,4 +1,4 @@
-.TH LVREDUCE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVREDUCE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvreduce \- Reduce the size of a logical volume
 .
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index a502397..83d733e 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -1,4 +1,4 @@
-.TH LVREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvremove \- Remove logical volume(s) from the system
 .
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 3eafe3d..67a9b84 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -1,4 +1,4 @@
-.TH LVRENAME 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVRENAME 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvrename \- Rename a logical volume
 .
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index ca8c2bf..0f04b40 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -1,4 +1,4 @@
-.TH LVRESIZE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVRESIZE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvresize \- Resize a logical volume
 .
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index bd7bd3e..76c25a5 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -1,4 +1,4 @@
-.TH LVS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvs \- Display information about logical volumes
 .
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index f386352..f01631b 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -1,4 +1,4 @@
-.TH LVSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH LVSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 lvscan \- List all logical volumes in all volume groups
 .
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index ccfce11..db9cc95 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -1,4 +1,4 @@
-.TH PVCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvchange \- Change attributes of physical volume(s)
 .
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 194e41a..ff08c45 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -1,4 +1,4 @@
-.TH PVCK 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVCK 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvck \- Check the consistency of physical volume(s)
 .
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index deb9cd1..3a37bfa 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -1,4 +1,4 @@
-.TH PVCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvcreate \- Initialize physical volume(s) for use by LVM
 .
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 4e2b85e..2be292a 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -1,4 +1,4 @@
-.TH PVDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvdisplay \- Display various attributes of physical volume(s)
 .
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 814773d..e7bc556 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -1,4 +1,4 @@
-.TH PVMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvmove \- Move extents from one physical volume to another
 .
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 0a9dd4c..0cc9302 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -1,4 +1,4 @@
-.TH PVREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvremove \- Remove LVM label(s) from physical volume(s)
 .
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index c5acfe3..76f3453 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -1,4 +1,4 @@
-.TH PVRESIZE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVRESIZE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvresize \- Resize physical volume(s)
 .
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 3e8b909..905ccce 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -1,4 +1,4 @@
-.TH PVS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvs \- Display information about physical volumes
 .
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index ae2a6a4..d7c35dd 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -1,4 +1,4 @@
-.TH PVSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH PVSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 pvscan \- List all physical volumes
 .
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index a0a4b07..f4b6f38 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCFGBACKUP 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCFGBACKUP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgcfgbackup \- Backup volume group configuration(s)
 .
@@ -16,7 +16,7 @@ See \fBvgcfgrestore\fP for information on using the back up
 files.
 
 In a default installation, each VG is backed up into a separate file
-bearing the name of the VG in the directory \fI/etc/lvm/backup\fP.
+bearing the name of the VG in the directory \fI#DEFAULT_BACKUP_DIR#\fP.
 
 To use an alternative back up file, use \fB\-f\fP. In this case, when
 backing up multiple VGs, the file name is treated as a template, with %s
@@ -25,7 +25,7 @@ replaced by the VG name.
 NB. This DOES NOT back up the data content of LVs.
 
 It may also be useful to regularly back up the files in
-\fI/etc/lvm\fP.
+\fI#DEFAULT_SYS_DIR#\fP.
 .SH USAGE
 \fBvgcfgbackup\fP
 .br
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 74b6e05..07cc1ed 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCFGRESTORE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCFGRESTORE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgcfgrestore \- Restore volume group configuration
 .
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 9e4b818..cd5cc30 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgchange \- Change volume group attributes
 .
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 01adbfc..9612367 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCK 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCK 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgck \- Check the consistency of volume group(s)
 .
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 795b436..b322b8f 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCONVERT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgconvert \- Change volume group metadata format
 .
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 8279e33..6bd4b02 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -1,4 +1,4 @@
-.TH VGCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgcreate \- Create a volume group
 .
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index cddac7a..6fe90a5 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -1,4 +1,4 @@
-.TH VGDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgdisplay \- Display volume group information
 .
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 6138c0f..b714404 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -1,4 +1,4 @@
-.TH VGEXPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGEXPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgexport \- Unregister volume group(s) from the system
 .
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 6d8d6f8..5b65c99 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -1,4 +1,4 @@
-.TH VGEXTEND 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGEXTEND 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgextend \- Add physical volumes to a volume group
 .
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index c31d9f4..84359e5 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -1,4 +1,4 @@
-.TH VGIMPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGIMPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgimport \- Register exported volume group with system
 .
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index f68a384..24afbf6 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -1,4 +1,4 @@
-.TH VGIMPORTCLONE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgimportclone \- Import a VG from cloned PVs
 .
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 52c7f56..23c4285 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -1,4 +1,4 @@
-.TH VGMERGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGMERGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgmerge \- Merge volume groups
 .
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 501d6e1..6cb68f3 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -1,4 +1,4 @@
-.TH VGMKNODES 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGMKNODES 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgmknodes \- Create the special files for volume group devices in /dev
 .
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index e4f1575..bf4e354 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -1,4 +1,4 @@
-.TH VGREDUCE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGREDUCE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgreduce \- Remove physical volume(s) from a volume group
 .
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index e9b2db9..c175188 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -1,4 +1,4 @@
-.TH VGREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgremove \- Remove volume group(s)
 .
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 1e35c4f..4e8d609 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -1,4 +1,4 @@
-.TH VGRENAME 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGRENAME 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgrename \- Rename a volume group
 .
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index aa6e2f9..4313624 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -1,4 +1,4 @@
-.TH VGS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgs \- Display information about volume groups
 .
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 1e1547a..1e13df2 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -1,4 +1,4 @@
-.TH VGSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgscan \- Search for all volume groups
 .
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index a013c12..bb9e784 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -1,4 +1,4 @@
-.TH VGSPLIT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
+.TH VGSPLIT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
 vgsplit \- Move physical volumes into a new or existing volume group
 .


