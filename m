From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2008 22:14:42 -0000
Subject: LVM2 ./Makefile.in ./configure ./configure.in ...
Message-ID: <20081103221442.20407.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-03 22:14:30

Modified files:
	.              : Makefile.in configure configure.in make.tmpl.in 
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: dmeventd.c 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	lib/activate   : activate.c activate.h dev_manager.c fs.c 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : config.c config.h 
	lib/datastruct : list.c list.h lvm-types.h str_list.c str_list.h 
	lib/device     : dev-cache.c dev-io.c device.h 
	lib/display    : display.c 
	lib/error      : errseg.c 
	lib/filters    : filter-persistent.c filter-regex.c 
	lib/format1    : Makefile.in disk-rep.c disk-rep.h format1.c 
	                 import-export.c import-extents.c lvm1-label.c 
	                 vg_number.c 
	lib/format_pool: Makefile.in disk_rep.c disk_rep.h format_pool.c 
	                 import_export.c 
	lib/format_text: archive.c archiver.c export.c format-text.c 
	                 format-text.h import-export.h import_vsn1.c 
	                 layout.h tags.c text_label.c 
	lib/label      : label.c 
	lib/locking    : Makefile.in file_locking.c locking.c locking.h 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 
	                 metadata-exported.h metadata.c metadata.h 
	                 mirror.c pv_alloc.h pv_manip.c pv_map.c 
	                 pv_map.h segtype.c segtype.h snapshot_manip.c 
	lib/mirror     : Makefile.in mirrored.c 
	lib/report     : report.c 
	lib/snapshot   : Makefile.in snapshot.c 
	lib/zero       : zero.c 
	libdm          : Makefile.in libdm-common.c libdm-deptree.c 
	                 libdm-report.c 
	libdm/datastruct: list.c list.h 
	tools          : Makefile.in lvconvert.c lvcreate.c lvmcmdline.c 
	                 lvresize.c lvscan.c polldaemon.c polldaemon.h 
	                 pvchange.c pvcreate.c pvmove.c pvremove.c 
	                 pvresize.c pvscan.c reporter.c toollib.c 
	                 toollib.h vgchange.c vgconvert.c vgexport.c 
	                 vgimport.c vgmerge.c vgreduce.c vgrename.c 
	                 vgsplit.c 

Log message:
	Right, a simple build (without options) is working again.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/vg_number.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_alloc.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/list.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/list.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/Makefile.in	2008/11/01 02:19:17	1.25
+++ LVM2/Makefile.in	2008/11/03 22:14:26	1.26
@@ -46,7 +46,9 @@
 tools: lib
 po: tools daemons
 
+libdm.device-mapper: include.device-mapper
 tools.device-mapper: libdm.device-mapper
+device-mapper: tools.device-mapper
 
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
--- LVM2/configure	2008/11/01 20:48:50	1.83
+++ LVM2/configure	2008/11/03 22:14:26	1.84
@@ -11798,14 +11798,14 @@
 echo "${ECHO_T}$interface" >&6; }
 
 ################################################################################
-DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
+DM_LIB_VERSION="\"`cat VERSION_DM 2>/dev/null || echo Unknown`\""
 
 cat >>confdefs.h <<_ACEOF
 #define DM_LIB_VERSION $DM_LIB_VERSION
 _ACEOF
 
 
-DM_LIB_PATCHLEVEL=`cat VERSION_LIB | awk -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=`cat VERSION_DM | awk -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
--- LVM2/configure.in	2008/11/01 20:48:09	1.87
+++ LVM2/configure.in	2008/11/03 22:14:26	1.88
@@ -718,10 +718,10 @@
 AC_MSG_RESULT($interface)
 
 ################################################################################
-DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
+DM_LIB_VERSION="\"`cat VERSION_DM 2>/dev/null || echo Unknown`\""
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 
-DM_LIB_PATCHLEVEL=`cat VERSION_LIB | awk -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=`cat VERSION_DM | awk -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
--- LVM2/make.tmpl.in	2008/11/01 02:19:17	1.59
+++ LVM2/make.tmpl.in	2008/11/03 22:14:26	1.60
@@ -51,6 +51,9 @@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 
+interface = @interface@
+interfacedir = $(top_srcdir)/libdm/$(interface)
+
 # setup misc variables
 # define the ownership variables for the binaries and man pages
 OWNER = @OWNER@
@@ -80,7 +83,8 @@
   DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
 endif
 
-LDFLAGS += -L$(top_srcdir)/lib -L$(libdir)
+LDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
+CLDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
 
 #DEFS += -DDEBUG_POOL
 #DEFS += -DBOUNDS_CHECK
@@ -93,8 +97,11 @@
 
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
-LIB_VERSION := $(shell cat $(top_srcdir)/VERSION | \
-		 awk -F '.' '{printf "%s.%s",$$1,$$2}')
+LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
+		     awk -F '.' '{printf "%s.%s",$$1,$$2}')
+
+LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
+		    awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
 INCLUDES += -I$(top_srcdir)/include
 
@@ -123,12 +130,10 @@
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+TARGETS += $(LIB_SHARED) $(LIB_STATIC) $(VERSIONED_SHLIB)
 
 all: $(SUBDIRS) $(TARGETS)
 
-device-mapper: $(SUBDIRS.device-mapper)
-
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
--- LVM2/daemons/clvmd/clvmd.c	2008/06/13 07:44:14	1.48
+++ LVM2/daemons/clvmd/clvmd.c	2008/11/03 22:14:26	1.49
@@ -75,7 +75,7 @@
 
 /* Structure of items on the LVM thread list */
 struct lvm_thread_cmd {
-	struct list list;
+	struct dm_list list;
 
 	struct local_client *client;
 	struct clvm_header *msg;
@@ -90,7 +90,7 @@
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
 static pthread_mutex_t lvm_start_mutex;
-static struct list lvm_cmd_head;
+static struct dm_list lvm_cmd_head;
 static volatile sig_atomic_t quit = 0;
 static volatile sig_atomic_t reread_config = 0;
 static int child_pipe[2];
@@ -352,7 +352,7 @@
 	sigprocmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the LVM thread variables */
-	list_init(&lvm_cmd_head);
+	dm_list_init(&lvm_cmd_head);
 	pthread_mutex_init(&lvm_thread_mutex, NULL);
 	pthread_cond_init(&lvm_thread_cond, NULL);
 	pthread_mutex_init(&lvm_start_mutex, NULL);
@@ -1749,7 +1749,7 @@
  */
 static __attribute__ ((noreturn)) void *lvm_thread_fn(void *arg)
 {
-	struct list *cmdl, *tmp;
+	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
 	int using_gulm = (int)(long)arg;
 
@@ -1775,15 +1775,15 @@
 		DEBUGLOG("LVM thread waiting for work\n");
 
 		pthread_mutex_lock(&lvm_thread_mutex);
-		if (list_empty(&lvm_cmd_head))
+		if (dm_list_empty(&lvm_cmd_head))
 			pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
 
-		list_iterate_safe(cmdl, tmp, &lvm_cmd_head) {
+		dm_list_iterate_safe(cmdl, tmp, &lvm_cmd_head) {
 			struct lvm_thread_cmd *cmd;
 
 			cmd =
-			    list_struct_base(cmdl, struct lvm_thread_cmd, list);
-			list_del(&cmd->list);
+			    dm_list_struct_base(cmdl, struct lvm_thread_cmd, list);
+			dm_list_del(&cmd->list);
 			pthread_mutex_unlock(&lvm_thread_mutex);
 
 			process_work_item(cmd);
@@ -1833,7 +1833,7 @@
 	    ("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
 	     cmd, client, msg, msglen, csid, cmd->xid);
 	pthread_mutex_lock(&lvm_thread_mutex);
-	list_add(&lvm_cmd_head, &cmd->list);
+	dm_list_add(&lvm_cmd_head, &cmd->list);
 	pthread_cond_signal(&lvm_thread_cond);
 	pthread_mutex_unlock(&lvm_thread_mutex);
 
--- LVM2/daemons/dmeventd/dmeventd.c	2008/07/09 13:26:07	1.51
+++ LVM2/daemons/dmeventd/dmeventd.c	2008/11/03 22:14:26	1.52
@@ -58,11 +58,11 @@
 static int _debug = 0;
 
 /* List (un)link macros. */
-#define	LINK(x, head)		list_add(head, &(x)->list)
+#define	LINK(x, head)		dm_list_add(head, &(x)->list)
 #define	LINK_DSO(dso)		LINK(dso, &_dso_registry)
 #define	LINK_THREAD(thread)	LINK(thread, &_thread_registry)
 
-#define	UNLINK(x)		list_del(&(x)->list)
+#define	UNLINK(x)		dm_list_del(&(x)->list)
 #define	UNLINK_DSO(x)		UNLINK(x)
 #define	UNLINK_THREAD(x)	UNLINK(x)
 
@@ -101,7 +101,7 @@
 
 /* Data kept about a DSO. */
 struct dso_data {
-	struct list list;
+	struct dm_list list;
 
 	char *dso_name;		/* DSO name (eg, "evms", "dmraid", "lvm2"). */
 
@@ -143,7 +143,7 @@
 	int (*unregister_device)(const char *device, const char *uuid,
 				 int major, int minor, void **user);
 };
-static LIST_INIT(_dso_registry);
+static DM_LIST_INIT(_dso_registry);
 
 /* Structure to keep parsed register variables from client message. */
 struct message_data {
@@ -168,7 +168,7 @@
  * occurs and the event processing function of the DSO gets called.
  */
 struct thread_status {
-	struct list list;
+	struct dm_list list;
 
 	pthread_t thread;
 
@@ -189,14 +189,14 @@
 	struct dm_task *current_task;
 	time_t next_time;
 	uint32_t timeout;
-	struct list timeout_list;
+	struct dm_list timeout_list;
 	void *dso_private; /* dso per-thread status variable */
 };
-static LIST_INIT(_thread_registry);
-static LIST_INIT(_thread_registry_unused);
+static DM_LIST_INIT(_thread_registry);
+static DM_LIST_INIT(_thread_registry_unused);
 
 static int _timeout_running;
-static LIST_INIT(_timeout_registry);
+static DM_LIST_INIT(_timeout_registry);
 static pthread_mutex_t _timeout_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 
@@ -239,7 +239,7 @@
 	ret->dso_data = dso_data;
 	ret->events = data->events.field;
 	ret->timeout = data->timeout.secs;
-	list_init(&ret->timeout_list);
+	dm_list_init(&ret->timeout_list);
 
 	return ret;
 }
@@ -459,7 +459,7 @@
 {
 	struct thread_status *thread;
 
-	list_iterate_items(thread, &_thread_registry)
+	dm_list_iterate_items(thread, &_thread_registry)
 	    if (!strcmp(data->device_uuid, thread->device.uuid))
 		return thread;
 
@@ -489,13 +489,13 @@
 	pthread_cleanup_push(_exit_timeout, NULL);
 	pthread_mutex_lock(&_timeout_mutex);
 
-	while (!list_empty(&_timeout_registry)) {
+	while (!dm_list_empty(&_timeout_registry)) {
 		struct thread_status *thread;
 
 		timeout.tv_sec = 0;
 		curr_time = time(NULL);
 
-		list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
+		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
 			if (thread->next_time <= curr_time) {
 				thread->next_time = curr_time + thread->timeout;
 				pthread_kill(thread->thread, SIGALRM);
@@ -522,8 +522,8 @@
 
 	thread->next_time = time(NULL) + thread->timeout;
 
-	if (list_empty(&thread->timeout_list)) {
-		list_add(&_timeout_registry, &thread->timeout_list);
+	if (dm_list_empty(&thread->timeout_list)) {
+		dm_list_add(&_timeout_registry, &thread->timeout_list);
 		if (_timeout_running)
 			pthread_cond_signal(&_timeout_cond);
 	}
@@ -543,9 +543,9 @@
 static void _unregister_for_timeout(struct thread_status *thread)
 {
 	pthread_mutex_lock(&_timeout_mutex);
-	if (!list_empty(&thread->timeout_list)) {
-		list_del(&thread->timeout_list);
-		list_init(&thread->timeout_list);
+	if (!dm_list_empty(&thread->timeout_list)) {
+		dm_list_del(&thread->timeout_list);
+		dm_list_init(&thread->timeout_list);
 	}
 	pthread_mutex_unlock(&_timeout_mutex);
 }
@@ -698,7 +698,7 @@
 	}
 	/* we may have been relinked to unused registry since we were
 	   called, so check that */
-	list_iterate_items(thread_iter, &_thread_registry_unused)
+	dm_list_iterate_items(thread_iter, &_thread_registry_unused)
 		if (thread_iter == thread) {
 			thread->status = DM_THREAD_DONE;
 			_unlock_mutex();
@@ -839,7 +839,7 @@
 {
 	struct dso_data *dso_data, *ret = NULL;
 
-	list_iterate_items(dso_data, &_dso_registry)
+	dm_list_iterate_items(dso_data, &_dso_registry)
 	    if (!strcmp(data->dso_name, dso_data->dso_name)) {
 		_lib_get(dso_data);
 		ret = dso_data;
@@ -1110,7 +1110,7 @@
 	_lock_mutex();
 
 	/* Iterate list of threads checking if we want a particular one. */
-	list_iterate_items(thread, &_thread_registry)
+	dm_list_iterate_items(thread, &_thread_registry)
 		if (_want_registered_device(message_data->dso_name,
 					    message_data->device_uuid,
 					    thread)) {
@@ -1133,10 +1133,10 @@
 	thread = hit;
 
 	while (1) {
-		if (list_end(&_thread_registry, &thread->list))
+		if (dm_list_end(&_thread_registry, &thread->list))
 			goto out;
 
-		thread = list_item(thread->list.n, struct thread_status);
+		thread = dm_list_item(thread->list.n, struct thread_status);
 		if (_want_registered_device(message_data->dso_name, NULL, thread)) {
 			hit = thread;
 			break;
@@ -1440,12 +1440,12 @@
 static void _cleanup_unused_threads(void)
 {
 	int ret;
-	struct list *l;
+	struct dm_list *l;
 	struct thread_status *thread;
 
 	_lock_mutex();
-	while ((l = list_first(&_thread_registry_unused))) {
-		thread = list_item(l, struct thread_status);
+	while ((l = dm_list_first(&_thread_registry_unused))) {
+		thread = dm_list_item(l, struct thread_status);
 		if (thread->processing)
 			break;	/* cleanup on the next round */
 
@@ -1470,7 +1470,7 @@
 				break;
 			}
 
-			list_del(l);
+			dm_list_del(l);
 			syslog(LOG_ERR,
 			       "thread can't be on unused list unless !thread->events");
 			thread->status = DM_THREAD_RUNNING;
@@ -1480,7 +1480,7 @@
 		}
 
 		if (thread->status == DM_THREAD_DONE) {
-			list_del(l);
+			dm_list_del(l);
 			pthread_join(thread->thread, NULL);
 			_lib_put(thread->dso_data);
 			_free_thread_status(thread);
@@ -1741,8 +1741,8 @@
 	while (!_exit_now) {
 		_process_request(&fifos);
 		_cleanup_unused_threads();
-		if (!list_empty(&_thread_registry)
-		    || !list_empty(&_thread_registry_unused))
+		if (!dm_list_empty(&_thread_registry)
+		    || !dm_list_empty(&_thread_registry_unused))
 			_thread_registries_empty = 0;
 		else
 			_thread_registries_empty = 1;
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2008/07/09 09:59:42	1.7
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2008/11/03 22:14:26	1.8
@@ -27,6 +27,8 @@
   LIB_SHARED = libdevmapper-event-lvm2mirror.so
 endif
 
+LIB_VERSION = $(LIB_VERSION_LVM)
+
 include $(top_srcdir)/make.tmpl
 
 install: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2008/07/09 09:59:42	1.3
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2008/11/03 22:14:27	1.4
@@ -27,6 +27,8 @@
   LIB_SHARED = libdevmapper-event-lvm2snapshot.so
 endif
 
+LIB_VERSION = $(LIB_VERSION_LVM)
+
 include $(top_srcdir)/make.tmpl
 
 install: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
--- LVM2/lib/activate/activate.c	2008/09/19 07:12:45	1.139
+++ LVM2/lib/activate/activate.c	2008/11/03 22:14:27	1.140
@@ -52,11 +52,11 @@
 }
 
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
-			 struct list *modules)
+			 struct dm_list *modules)
 {
 	unsigned int s;
 	struct lv_segment *seg2, *snap_seg;
-	struct list *snh;
+	struct dm_list *snh;
 
 	if (seg->segtype->ops->modules_needed &&
 	    !seg->segtype->ops->modules_needed(mem, seg, modules)) {
@@ -65,9 +65,9 @@
 	}
 
 	if (lv_is_origin(seg->lv))
-		list_iterate(snh, &seg->lv->snapshot_segs)
+		dm_list_iterate(snh, &seg->lv->snapshot_segs)
 			if (!list_lv_modules(mem,
-					     list_struct_base(snh,
+					     dm_list_struct_base(snh,
 							      struct lv_segment,
 							      origin_list)->cow,
 					     modules))
@@ -100,11 +100,11 @@
 }
 
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
-		    struct list *modules)
+		    struct dm_list *modules)
 {
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments)
 		if (!list_segment_modules(mem, seg, modules))
 			return_0;
 
@@ -264,7 +264,7 @@
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
 		/* If no host tags defined, activate */
-		if (list_empty(&cmd->tags))
+		if (dm_list_empty(&cmd->tags))
 			return 1;
 
 		/* If any host tag matches any LV or VG tag, activate */
@@ -517,7 +517,7 @@
 
 	/* If mirrored LV is temporarily shrinked to 1 area (= linear),
 	 * it should be considered in-sync. */
-	if (list_size(&lv->segments) == 1 && first_seg(lv)->area_count == 1) {
+	if (dm_list_size(&lv->segments) == 1 && first_seg(lv)->area_count == 1) {
 		*percent = 100.0;
 		return 1;
 	}
@@ -639,7 +639,7 @@
 	if (!activation())
 		return 0;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & VISIBLE_LV)
 			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
 	}
@@ -665,7 +665,7 @@
 	if (!activation())
 		return 0;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & VISIBLE_LV)
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 	}
@@ -715,7 +715,7 @@
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
 	int r = 1;
-	struct list *tmp, *snh, *snht;
+	struct dm_list *tmp, *snh, *snht;
 	struct lv_segment *seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
@@ -745,15 +745,15 @@
 	 * TODO: This may change when snapshots of mirrors are allowed.
 	 */
 	if (lv_is_origin(lv)) {
-		list_iterate_safe(snh, snht, &lv->snapshot_segs)
-			if (!monitor_dev_for_events(cmd, list_struct_base(snh,
+		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
+			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
 				    struct lv_segment, origin_list)->cow, monitor))
 				r = 0;
 		return r;
 	}
 
-	list_iterate(tmp, &lv->segments) {
-		seg = list_item(tmp, struct lv_segment);
+	dm_list_iterate(tmp, &lv->segments) {
+		seg = dm_list_item(tmp, struct lv_segment);
 
 		/* Recurse for AREA_LV */
 		for (s = 0; s < seg->area_count; s++) {
--- LVM2/lib/activate/activate.h	2008/04/10 21:34:18	1.61
+++ LVM2/lib/activate/activate.h	2008/11/03 22:14:27	1.62
@@ -45,9 +45,9 @@
 int target_version(const char *target_name, uint32_t *maj,
                    uint32_t *min, uint32_t *patchlevel);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
-			 struct list *modules);
+			 struct dm_list *modules);
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
-		    struct list *modules);
+		    struct dm_list *modules);
 
 void activation_release(void);
 void activation_exit(void);
--- LVM2/lib/activate/dev_manager.c	2008/09/19 07:05:03	1.141
+++ LVM2/lib/activate/dev_manager.c	2008/11/03 22:14:27	1.142
@@ -330,7 +330,7 @@
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	struct list *segh = &lv->segments;
+	struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
 
@@ -358,12 +358,12 @@
 		next = dm_get_next_target(dmt, next, &start, &length, &type,
 					  &params);
 		if (lv) {
-			if (!(segh = list_next(&lv->segments, segh))) {
+			if (!(segh = dm_list_next(&lv->segments, segh))) {
 				log_error("Number of segments in active LV %s "
 					  "does not match metadata", lv->name);
 				goto out;
 			}
-			seg = list_item(segh, struct lv_segment);
+			seg = dm_list_item(segh, struct lv_segment);
 		}
 
 		if (!type || !params || strcmp(type, target_type))
@@ -381,7 +381,7 @@
 
 	} while (next);
 
-	if (lv && (segh = list_next(&lv->segments, segh))) {
+	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
@@ -576,7 +576,7 @@
 	old_origin = snap_seg->origin;
 
 	/* Was this the last active snapshot with this origin? */
-	list_iterate_items(lvl, active_head) {
+	dm_list_iterate_items(lvl, active_head) {
 		active = lvl->lv;
 		if ((snap_seg = find_cow(active)) &&
 		    snap_seg->origin == old_origin) {
@@ -657,7 +657,7 @@
 static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv)
 {
 	struct dm_tree *dtree;
-	struct list *snh, *snht;
+	struct dm_list *snh, *snht;
 	struct lv_segment *seg;
 	uint32_t s;
 
@@ -670,12 +670,12 @@
 		goto_bad;
 
 	/* Add any snapshots of this LV */
-	list_iterate_safe(snh, snht, &lv->snapshot_segs)
-		if (!_add_lv_to_dtree(dm, dtree, list_struct_base(snh, struct lv_segment, origin_list)->cow))
+	dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
+		if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow))
 			goto_bad;
 
 	/* Add any LVs used by segments in this LV */
-	list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
 				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s)))
@@ -699,7 +699,7 @@
 	int segno = -1, i = 0;;
 	uint64_t size = seg->len * seg->lv->vg->extent_size;
 
-	list_iterate_items(seg_i, &seg->lv->segments) {
+	dm_list_iterate_items(seg_i, &seg->lv->segments) {
 		if (seg == seg_i)
 			segno = i;
 		++i;
@@ -862,7 +862,7 @@
 				   const char *layer)
 {
 	uint32_t s;
-	struct list *snh;
+	struct dm_list *snh;
 	struct lv_segment *seg_present;
 
 	/* Ensure required device-mapper targets are loaded */
@@ -915,8 +915,8 @@
 
 	if (lv_is_origin(seg->lv) && !layer)
 		/* Add any snapshots of this LV */
-		list_iterate(snh, &seg->lv->snapshot_segs)
-			if (!_add_new_lv_to_dtree(dm, dtree, list_struct_base(snh, struct lv_segment, origin_list)->cow, NULL))
+		dm_list_iterate(snh, &seg->lv->snapshot_segs)
+			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, NULL))
 				return_0;
 
 	return 1;
@@ -970,7 +970,7 @@
 
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, layer))
 			return_0;
 		/* These aren't real segments in the LVM2 metadata */
--- LVM2/lib/activate/fs.c	2008/01/30 13:59:57	1.42
+++ LVM2/lib/activate/fs.c	2008/11/03 22:14:27	1.43
@@ -243,10 +243,10 @@
 	return 1;
 }
 
-static LIST_INIT(_fs_ops);
+static DM_LIST_INIT(_fs_ops);
 
 struct fs_op_parms {
-	struct list list;
+	struct dm_list list;
 	fs_op_t type;
 	char *dev_dir;
 	char *vg_name;
@@ -286,21 +286,21 @@
 	_store_str(&pos, &fsp->dev, dev);
 	_store_str(&pos, &fsp->old_lv_name, old_lv_name);
 
-	list_add(&_fs_ops, &fsp->list);
+	dm_list_add(&_fs_ops, &fsp->list);
 
 	return 1;
 }
 
 static void _pop_fs_ops(void)
 {
-	struct list *fsph, *fspht;
+	struct dm_list *fsph, *fspht;
 	struct fs_op_parms *fsp;
 
-	list_iterate_safe(fsph, fspht, &_fs_ops) {
-		fsp = list_item(fsph, struct fs_op_parms);
+	dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+		fsp = dm_list_item(fsph, struct fs_op_parms);
 		_do_fs_op(fsp->type, fsp->dev_dir, fsp->vg_name, fsp->lv_name,
 			  fsp->dev, fsp->old_lv_name);
-		list_del(&fsp->list);
+		dm_list_del(&fsp->list);
 		dm_free(fsp);
 	}
 }
--- LVM2/lib/cache/lvmcache.c	2008/09/16 18:05:11	1.60
+++ LVM2/lib/cache/lvmcache.c	2008/11/03 22:14:27	1.61
@@ -30,7 +30,7 @@
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
-static struct list _vginfos;
+static struct dm_list _vginfos;
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
@@ -38,7 +38,7 @@
 
 int lvmcache_init(void)
 {
-	list_init(&_vginfos);
+	dm_list_init(&_vginfos);
 
 	if (!(_vgname_hash = dm_hash_create(128)))
 		return 0;
@@ -117,7 +117,7 @@
 	struct lvmcache_info *info;
 	int cached_vgmetadata_valid = 1;
 
-	list_iterate_items(info, &vginfo->infos)
+	dm_list_iterate_items(info, &vginfo->infos)
 		_update_cache_info_lock_state(info, locked,
 					      &cached_vgmetadata_valid);
 
@@ -151,7 +151,7 @@
 	 */
 
 	if (!vginfo->precommitted)
-		list_iterate_items(info, &vginfo->infos)
+		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
 	_free_cached_vgmetadata(vginfo);
@@ -226,14 +226,14 @@
 		return;
 
 	info->vginfo = vginfo;
-	list_add(&vginfo->infos, &info->list);
+	dm_list_add(&vginfo->infos, &info->list);
 }
 
 static void _vginfo_detach_info(struct lvmcache_info *info)
 {
-	if (!list_empty(&info->list)) {
-		list_del(&info->list);
-		list_init(&info->list);
+	if (!dm_list_empty(&info->list)) {
+		dm_list_del(&info->list);
+		dm_list_init(&info->list);
 	}
 
 	info->vginfo = NULL;
@@ -267,8 +267,8 @@
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct label *label;
-	struct list *devh, *tmp;
-	struct list devs;
+	struct dm_list *devh, *tmp;
+	struct dm_list devs;
 	struct device_list *devl;
 	char vgid_found[ID_LEN + 1] __attribute((aligned(8)));
 
@@ -277,22 +277,22 @@
 
 	/* This function is normally called before reading metadata so
  	 * we check cached labels here. Unfortunately vginfo is volatile. */
-	list_init(&devs);
-	list_iterate_items(info, &vginfo->infos) {
+	dm_list_init(&devs);
+	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(devl = dm_malloc(sizeof(*devl)))) {
 			log_error("device_list element allocation failed");
 			return NULL;
 		}
 		devl->dev = info->dev;
-		list_add(&devs, &devl->list);
+		dm_list_add(&devs, &devl->list);
 	}
 
 	memcpy(vgid_found, vginfo->vgid, sizeof(vgid_found));
 
-	list_iterate_safe(devh, tmp, &devs) {
-		devl = list_item(devh, struct device_list);
+	dm_list_iterate_safe(devh, tmp, &devs) {
+		devl = dm_list_item(devh, struct device_list);
 		label_read(devl->dev, &label, UINT64_C(0));
-		list_del(&devl->list);
+		dm_list_del(&devl->list);
 		dm_free(devl);
 	}
 
@@ -362,7 +362,7 @@
 	struct lvmcache_info *info;
 
 	/* Invalid if any info is invalid */
-	list_iterate_items(info, &vginfo->infos)
+	dm_list_iterate_items(info, &vginfo->infos)
 		if (!_info_is_valid(info))
 			return 0;
 
@@ -374,7 +374,7 @@
 {
 	struct lvmcache_info *info;
 
-	list_iterate_items(info, &vginfo->infos)
+	dm_list_iterate_items(info, &vginfo->infos)
 		if (_info_is_valid(info))
 			return 0;
 
@@ -458,7 +458,7 @@
 	_has_scanned = 1;
 
 	/* Perform any format-specific scanning e.g. text files */
-	list_iterate_items(fmt, &cmd->formats) {
+	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (fmt->ops->scan && !fmt->ops->scan(fmt))
 			goto out;
 	}
@@ -516,9 +516,9 @@
 	return vg;
 }
 
-struct list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
 {
-	struct list *vgids;
+	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
 
 	lvmcache_label_scan(cmd, full_scan);
@@ -528,7 +528,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(vginfo, &_vginfos) {
+	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!str_list_add(cmd->mem, vgids,
 				  dm_pool_strdup(cmd->mem, vginfo->vgid))) {
 			log_error("strlist allocation failed");
@@ -539,9 +539,9 @@
 	return vgids;
 }
 
-struct list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
 {
-	struct list *vgnames;
+	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
 
 	lvmcache_label_scan(cmd, full_scan);
@@ -551,7 +551,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(vginfo, &_vginfos) {
+	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
 			log_error("strlist allocation failed");
@@ -562,10 +562,10 @@
 	return vgnames;
 }
 
-struct list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
+struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid)
 {
-	struct list *pvids;
+	struct dm_list *pvids;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 
@@ -577,7 +577,7 @@
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 		return pvids;
 
-	list_iterate_items(info, &vginfo->infos) {
+	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!str_list_add(cmd->mem, pvids,
 				  dm_pool_strdup(cmd->mem, info->dev->pvid))) {
 			log_error("strlist allocation failed");
@@ -664,7 +664,7 @@
 	    vginfo_from_vgid(vginfo->vgid) == vginfo)
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 
-	list_del(&vginfo->list);
+	dm_list_del(&vginfo->list);
 
 	dm_free(vginfo);
 
@@ -681,7 +681,7 @@
 
 	/* vginfo still referenced? */
 	if (!vginfo || is_orphan_vg(vginfo->vgname) ||
-	    !list_empty(&vginfo->infos))
+	    !dm_list_empty(&vginfo->infos))
 		return 1;
 
 	if (!_free_vginfo(vginfo))
@@ -904,7 +904,7 @@
 			log_error("cache vgname alloc failed for %s", vgname);
 			return 0;
 		}
-		list_init(&vginfo->infos);
+		dm_list_init(&vginfo->infos);
 
 		/*
 		 * If we're scanning and there's an invalidated entry, remove it.
@@ -912,13 +912,13 @@
 		 */
 		while ((primary_vginfo = vginfo_from_vgname(vgname, NULL)) &&
 		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
-			list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
+			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
 				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
 				_drop_vginfo(info2, primary_vginfo);	
 				_vginfo_attach_info(orphan_vginfo, info2);
 				if (info2->mdas.n)
 					sprintf(mdabuf, " with %u mdas",
-						list_size(&info2->mdas));
+						dm_list_size(&info2->mdas));
 				else
 					mdabuf[0] = '\0';
 				log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
@@ -936,9 +936,9 @@
 		}
 		/* Ensure orphans appear last on list_iterate */
 		if (is_orphan_vg(vgname))
-			list_add(&_vginfos, &vginfo->list);
+			dm_list_add(&_vginfos, &vginfo->list);
 		else
-			list_add_h(&_vginfos, &vginfo->list);
+			dm_list_add_h(&_vginfos, &vginfo->list);
 /***
 		}
 ***/
@@ -956,7 +956,7 @@
 
 	if (info) {
 		if (info->mdas.n)
-			sprintf(mdabuf, " with %u mdas", list_size(&info->mdas));
+			sprintf(mdabuf, " with %u mdas", dm_list_size(&info->mdas));
 		else
 			mdabuf[0] = '\0';
 		log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
@@ -1027,7 +1027,7 @@
 	}
 
 	/* If PV without mdas is already in a real VG, don't make it orphan */
-	if (is_orphan_vg(vgname) && info->vginfo && !list_size(&info->mdas) &&
+	if (is_orphan_vg(vgname) && info->vginfo && !dm_list_size(&info->mdas) &&
 	    !is_orphan_vg(info->vginfo->vgname) && memlock())
 		return 1;
 
@@ -1053,7 +1053,7 @@
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
 		if ((info = info_from_pvid(pvid_s, 0)) &&
@@ -1101,7 +1101,7 @@
 
 		label->info = info;
 		info->label = label;
-		list_init(&info->list);
+		dm_list_init(&info->list);
 		info->dev = dev;
 	} else {
 		if (existing->dev != dev) {
@@ -1246,9 +1246,9 @@
 		_lock_hash = NULL;
 	}
 
-	if (!list_empty(&_vginfos))
+	if (!dm_list_empty(&_vginfos))
 		log_error("Internal error: _vginfos list should be empty");
-	list_init(&_vginfos);
+	dm_list_init(&_vginfos);
 
 	if (retain_orphans)
 		init_lvmcache_orphans(cmd);
--- LVM2/lib/cache/lvmcache.h	2008/05/08 18:00:47	1.23
+++ LVM2/lib/cache/lvmcache.h	2008/11/03 22:14:27	1.24
@@ -35,8 +35,8 @@
 
 /* One per VG */
 struct lvmcache_vginfo {
-	struct list list;	/* Join these vginfos together */
-	struct list infos;	/* List head for lvmcache_infos */
+	struct dm_list list;	/* Join these vginfos together */
+	struct dm_list infos;	/* List head for lvmcache_infos */
 	const struct format_type *fmt;
 	char *vgname;		/* "" == orphan */
 	uint32_t status;
@@ -50,9 +50,9 @@
 
 /* One per device */
 struct lvmcache_info {
-	struct list list;	/* Join VG members together */
-	struct list mdas;	/* list head for metadata areas */
-	struct list das;	/* list head for data areas */
+	struct dm_list list;	/* Join VG members together */
+	struct dm_list mdas;	/* list head for metadata areas */
+	struct dm_list das;	/* list head for data areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label;
 	const struct format_type *fmt;
@@ -98,14 +98,14 @@
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
 /* Set full_scan to 1 to reread every filtered device label */
-struct list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan);
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgids */
 /* Set full_scan to 1 to reread every filtered device label */
-struct list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan);
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan);
 
 /* Returns list of struct str_lists containing pool-allocated copy of pvids */
-struct list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
+struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
 
 /* Returns cached volume group metadata. */
--- LVM2/lib/commands/toolcontext.c	2008/09/19 18:26:41	1.63
+++ LVM2/lib/commands/toolcontext.c	2008/11/03 22:14:27	1.64
@@ -410,7 +410,7 @@
 	/* Is there a config file? */
 	if (stat(config_file, &info) == -1) {
 		if (errno == ENOENT) {
-			list_add(&cmd->config_files, &cfl->list);
+			dm_list_add(&cmd->config_files, &cfl->list);
 			goto out;
 		}
 		log_sys_error("stat", config_file);
@@ -425,7 +425,7 @@
 		return 0;
 	}
 
-	list_add(&cmd->config_files, &cfl->list);
+	dm_list_add(&cmd->config_files, &cfl->list);
 
       out:
 	if (*tag)
@@ -461,7 +461,7 @@
 	struct str_list *sl;
 
 	/* Tag list may grow while inside this loop */
-	list_iterate_items(sl, &cmd->tags) {
+	dm_list_iterate_items(sl, &cmd->tags) {
 		if (!_load_config_file(cmd, sl->str))
 			return_0;
 	}
@@ -481,7 +481,7 @@
 		}
 	}
 
-	list_iterate_items(cfl, &cmd->config_files) {
+	dm_list_iterate_items(cfl, &cmd->config_files) {
 		/* Merge all config trees into cmd->cft using merge/tag rules */
 		if (!merge_config_tree(cmd, cmd->cft, cfl->cft))
 			return_0;
@@ -492,10 +492,10 @@
 
 static void _destroy_tags(struct cmd_context *cmd)
 {
-	struct list *slh, *slht;
+	struct dm_list *slh, *slht;
 
-	list_iterate_safe(slh, slht, &cmd->tags) {
-		list_del(slh);
+	dm_list_iterate_safe(slh, slht, &cmd->tags) {
+		dm_list_del(slh);
 	}
 }
 
@@ -503,7 +503,7 @@
 {
 	struct config_tree_list *cfl;
 
-	list_iterate_items(cfl, &cmd->config_files) {
+	dm_list_iterate_items(cfl, &cmd->config_files) {
 		if (config_file_changed(cfl->cft))
 			return 1;
 	}
@@ -520,11 +520,11 @@
 		cmd->cft = NULL;
 	}
 
-	list_iterate_items(cfl, &cmd->config_files) {
+	dm_list_iterate_items(cfl, &cmd->config_files) {
 		destroy_config_tree(cfl->cft);
 	}
 
-	list_init(&cmd->config_files);
+	dm_list_init(&cmd->config_files);
 }
 
 static int _init_dev_cache(struct cmd_context *cmd)
@@ -725,14 +725,14 @@
 	if (!(fmt = init_lvm1_format(cmd)))
 		return 0;
 	fmt->library = NULL;
-	list_add(&cmd->formats, &fmt->list);
+	dm_list_add(&cmd->formats, &fmt->list);
 #endif
 
 #ifdef POOL_INTERNAL
 	if (!(fmt = init_pool_format(cmd)))
 		return 0;
 	fmt->library = NULL;
-	list_add(&cmd->formats, &fmt->list);
+	dm_list_add(&cmd->formats, &fmt->list);
 #endif
 
 #ifdef HAVE_LIBDL
@@ -764,7 +764,7 @@
 			if (!(fmt = init_format_fn(cmd)))
 				return 0;
 			fmt->library = lib;
-			list_add(&cmd->formats, &fmt->list);
+			dm_list_add(&cmd->formats, &fmt->list);
 		}
 	}
 #endif
@@ -772,14 +772,14 @@
 	if (!(fmt = create_text_format(cmd)))
 		return 0;
 	fmt->library = NULL;
-	list_add(&cmd->formats, &fmt->list);
+	dm_list_add(&cmd->formats, &fmt->list);
 
 	cmd->fmt_backup = fmt;
 
 	format = find_config_tree_str(cmd, "global/format",
 				 DEFAULT_FORMAT);
 
-	list_iterate_items(fmt, &cmd->formats) {
+	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (!strcasecmp(fmt->name, format) ||
 		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
 			cmd->default_settings.fmt = fmt;
@@ -795,7 +795,7 @@
 {
 	struct format_type *fmt;
 
-	list_iterate_items(fmt, &cmd->formats)
+	dm_list_iterate_items(fmt, &cmd->formats)
 		if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
 			return_0;
 
@@ -813,35 +813,35 @@
 	if (!(segtype = init_striped_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 
 	if (!(segtype = init_zero_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 
 	if (!(segtype = init_error_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 
 	if (!(segtype = init_free_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 
 #ifdef SNAPSHOT_INTERNAL
 	if (!(segtype = init_snapshot_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 #endif
 
 #ifdef MIRRORED_INTERNAL
 	if (!(segtype = init_mirrored_segtype(cmd)))
 		return 0;
 	segtype->library = NULL;
-	list_add(&cmd->segtypes, &segtype->list);
+	dm_list_add(&cmd->segtypes, &segtype->list);
 #endif
 
 #ifdef HAVE_LIBDL
@@ -874,16 +874,16 @@
 			if (!(segtype = init_segtype_fn(cmd)))
 				return 0;
 			segtype->library = lib;
-			list_add(&cmd->segtypes, &segtype->list);
+			dm_list_add(&cmd->segtypes, &segtype->list);
 
-			list_iterate_items(segtype2, &cmd->segtypes) {
+			dm_list_iterate_items(segtype2, &cmd->segtypes) {
 				if ((segtype == segtype2) ||
 				     strcmp(segtype2->name, segtype->name))
 					continue;
 				log_error("Duplicate segment type %s: "
 					  "unloading shared library %s",
 					  segtype->name, cv->v.str);
-				list_del(&segtype->list);
+				dm_list_del(&segtype->list);
 				segtype->ops->destroy(segtype);
 				dlclose(lib);
 			}
@@ -1008,10 +1008,10 @@
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->hosttags = 0;
-	list_init(&cmd->formats);
-	list_init(&cmd->segtypes);
-	list_init(&cmd->tags);
-	list_init(&cmd->config_files);
+	dm_list_init(&cmd->formats);
+	dm_list_init(&cmd->segtypes);
+	dm_list_init(&cmd->tags);
+	dm_list_init(&cmd->config_files);
 
 	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
 
@@ -1088,15 +1088,15 @@
 	return NULL;
 }
 
-static void _destroy_formats(struct list *formats)
+static void _destroy_formats(struct dm_list *formats)
 {
-	struct list *fmtl, *tmp;
+	struct dm_list *fmtl, *tmp;
 	struct format_type *fmt;
 	void *lib;
 
-	list_iterate_safe(fmtl, tmp, formats) {
-		fmt = list_item(fmtl, struct format_type);
-		list_del(&fmt->list);
+	dm_list_iterate_safe(fmtl, tmp, formats) {
+		fmt = dm_list_item(fmtl, struct format_type);
+		dm_list_del(&fmt->list);
 		lib = fmt->library;
 		fmt->ops->destroy(fmt);
 #ifdef HAVE_LIBDL
@@ -1106,15 +1106,15 @@
 	}
 }
 
-static void _destroy_segtypes(struct list *segtypes)
+static void _destroy_segtypes(struct dm_list *segtypes)
 {
-	struct list *sgtl, *tmp;
+	struct dm_list *sgtl, *tmp;
 	struct segment_type *segtype;
 	void *lib;
 
-	list_iterate_safe(sgtl, tmp, segtypes) {
-		segtype = list_item(sgtl, struct segment_type);
-		list_del(&segtype->list);
+	dm_list_iterate_safe(sgtl, tmp, segtypes) {
+		segtype = dm_list_item(sgtl, struct segment_type);
+		dm_list_del(&segtype->list);
 		lib = segtype->library;
 		segtype->ops->destroy(segtype);
 #ifdef HAVE_LIBDL
--- LVM2/lib/commands/toolcontext.h	2008/09/19 07:12:08	1.26
+++ LVM2/lib/commands/toolcontext.h	2008/11/03 22:14:27	1.27
@@ -57,8 +57,8 @@
 	const struct format_type *fmt;	/* Current format to use by default */
 	struct format_type *fmt_backup;	/* Format to use for backups */
 
-	struct list formats;	/* Available formats */
-	struct list segtypes;	/* Available segment types */
+	struct dm_list formats;	/* Available formats */
+	struct dm_list segtypes;	/* Available segment types */
 	const char *hostname;
 	const char *kernel_vsn;
 
@@ -74,7 +74,7 @@
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
 
-	struct list config_files;
+	struct dm_list config_files;
 	int config_valid;
 	struct config_tree *cft;
 	struct config_tree *cft_override;
@@ -86,7 +86,7 @@
 	const char *stripe_filler;
 
 	/* List of defined tags */
-	struct list tags;
+	struct dm_list tags;
 	int hosttags;
 
 	char sys_dir[PATH_MAX];
--- LVM2/lib/config/config.c	2008/08/07 14:02:32	1.71
+++ LVM2/lib/config/config.c	2008/11/03 22:14:27	1.72
@@ -1165,7 +1165,7 @@
 	}
 }
 
-static int _match_host_tags(struct list *tags, struct config_node *tn)
+static int _match_host_tags(struct dm_list *tags, struct config_node *tn)
 {
 	struct config_value *tv;
 	const char *str;
--- LVM2/lib/config/config.h	2007/08/20 20:55:24	1.25
+++ LVM2/lib/config/config.h	2008/11/03 22:14:27	1.26
@@ -49,7 +49,7 @@
 };
 
 struct config_tree_list {
-	struct list list;
+	struct dm_list list;
 	struct config_tree *cft;
 };
 
--- LVM2/lib/datastruct/list.c	2008/04/10 19:14:26	1.4
+++ LVM2/lib/datastruct/list.c	2008/11/03 22:14:27	1.5
@@ -19,7 +19,7 @@
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
-void list_init(struct list *head)
+void dm_list_init(struct dm_list *head)
 {
 	head->n = head->p = head;
 }
@@ -28,7 +28,7 @@
  * Insert an element before 'head'.
  * If 'head' is the list head, this adds an element to the end of the list.
  */
-void list_add(struct list *head, struct list *elem)
+void dm_list_add(struct dm_list *head, struct dm_list *elem)
 {
 	assert(head->n);
 
@@ -43,7 +43,7 @@
  * Insert an element after 'head'.
  * If 'head' is the list head, this adds an element to the front of the list.
  */
-void list_add_h(struct list *head, struct list *elem)
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem)
 {
 	assert(head->n);
 
@@ -59,7 +59,7 @@
  * Note that this doesn't change the element itself - it may still be safe
  * to follow its pointers.
  */
-void list_del(struct list *elem)
+void dm_list_del(struct dm_list *elem)
 {
 	elem->n->p = elem->p;
 	elem->p->n = elem->n;
@@ -68,16 +68,16 @@
 /*
  * Remove an element from existing list and insert before 'head'.
  */
-void list_move(struct list *head, struct list *elem)
+void dm_list_move(struct dm_list *head, struct dm_list *elem)
 {
-        list_del(elem);
-        list_add(head, elem);
+        dm_list_del(elem);
+        dm_list_add(head, elem);
 }
 
 /*
  * Is the list empty?
  */
-int list_empty(const struct list *head)
+int dm_list_empty(const struct dm_list *head)
 {
 	return head->n == head;
 }
@@ -85,7 +85,7 @@
 /*
  * Is this the first element of the list?
  */
-int list_start(const struct list *head, const struct list *elem)
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem)
 {
 	return elem->p == head;
 }
@@ -93,7 +93,7 @@
 /*
  * Is this the last element of the list?
  */
-int list_end(const struct list *head, const struct list *elem)
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem)
 {
 	return elem->n == head;
 }
@@ -101,44 +101,44 @@
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(const struct list *head)
+struct dm_list *dm_list_first(const struct dm_list *head)
 {
-	return (list_empty(head) ? NULL : head->n);
+	return (dm_list_empty(head) ? NULL : head->n);
 }
 
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(const struct list *head)
+struct dm_list *dm_list_last(const struct dm_list *head)
 {
-	return (list_empty(head) ? NULL : head->p);
+	return (dm_list_empty(head) ? NULL : head->p);
 }
 
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(const struct list *head, const struct list *elem)
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem)
 {
-	return (list_start(head, elem) ? NULL : elem->p);
+	return (dm_list_start(head, elem) ? NULL : elem->p);
 }
 
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(const struct list *head, const struct list *elem)
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem)
 {
-	return (list_end(head, elem) ? NULL : elem->n);
+	return (dm_list_end(head, elem) ? NULL : elem->n);
 }
 
 /*
  * Return the number of elements in a list by walking it.
  */
-unsigned int list_size(const struct list *head)
+unsigned int dm_list_size(const struct dm_list *head)
 {
 	unsigned int s = 0;
-	const struct list *v;
+	const struct dm_list *v;
 
-	list_iterate(v, head)
+	dm_list_iterate(v, head)
 	    s++;
 
 	return s;
--- LVM2/lib/datastruct/list.h	2008/04/10 19:14:26	1.27
+++ LVM2/lib/datastruct/list.h	2008/11/03 22:14:27	1.28
@@ -24,106 +24,106 @@
  * The list head's pointers point to the first and the last element.
  */
 
-struct list {
-	struct list *n, *p;
+struct dm_list {
+	struct dm_list *n, *p;
 };
 
 /*
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
-#define LIST_INIT(name)	struct list name = { &(name), &(name) }
-void list_init(struct list *head);
+#define DM_LIST_INIT(name)	struct dm_list name = { &(name), &(name) }
+void dm_list_init(struct dm_list *head);
 
 /*
  * Insert an element before 'head'.
  * If 'head' is the list head, this adds an element to the end of the list.
  */
-void list_add(struct list *head, struct list *elem);
+void dm_list_add(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Insert an element after 'head'.
  * If 'head' is the list head, this adds an element to the front of the list.
  */
-void list_add_h(struct list *head, struct list *elem);
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Delete an element from its list.
  * Note that this doesn't change the element itself - it may still be safe
  * to follow its pointers.
  */
-void list_del(struct list *elem);
+void dm_list_del(struct dm_list *elem);
 
 /*
  * Remove an element from existing list and insert before 'head'.
  */
-void list_move(struct list *head, struct list *elem);
+void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Is the list empty?
  */
-int list_empty(const struct list *head);
+int dm_list_empty(const struct dm_list *head);
 
 /*
  * Is this the first element of the list?
  */
-int list_start(const struct list *head, const struct list *elem);
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Is this the last element of the list?
  */
-int list_end(const struct list *head, const struct list *elem);
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(const struct list *head);
+struct dm_list *dm_list_first(const struct dm_list *head);
 
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(const struct list *head);
+struct dm_list *dm_list_last(const struct dm_list *head);
 
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(const struct list *head, const struct list *elem);
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(const struct list *head, const struct list *elem);
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem);
 
 /*
- * Given the address v of an instance of 'struct list' called 'head' 
+ * Given the address v of an instance of 'struct dm_list' called 'head' 
  * contained in a structure of type t, return the containing structure.
  */
-#define list_struct_base(v, t, head) \
+#define dm_list_struct_base(v, t, head) \
     ((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->head))
 
 /*
- * Given the address v of an instance of 'struct list list' contained in
+ * Given the address v of an instance of 'struct dm_list list' contained in
  * a structure of type t, return the containing structure.
  */
-#define list_item(v, t) list_struct_base((v), t, list)
+#define dm_list_item(v, t) dm_list_struct_base((v), t, list)
 
 /*
  * Given the address v of one known element e in a known structure of type t,
  * return another element f.
  */
-#define struct_field(v, t, e, f) \
+#define dm_struct_field(v, t, e, f) \
     (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
 
 /*
  * Given the address v of a known element e in a known structure of type t,
  * return the list head 'list'
  */
-#define list_head(v, t, e) struct_field(v, t, e, list)
+#define dm_list_head(v, t, e) dm_struct_field(v, t, e, list)
 
 /*
  * Set v to each element of a list in turn.
  */
-#define list_iterate(v, head) \
+#define dm_list_iterate(v, head) \
 	for (v = (head)->n; v != head; v = v->n)
 
 /*
@@ -133,7 +133,7 @@
  * already-processed elements.
  * If 'start' is 'head' it walks the list backwards.
  */
-#define list_uniterate(v, head, start) \
+#define dm_list_uniterate(v, head, start) \
 	for (v = (start)->p; v != head; v = v->p)
 
 /*
@@ -141,68 +141,68 @@
  * the way.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_safe(v, t, head) \
+#define dm_list_iterate_safe(v, t, head) \
 	for (v = (head)->n, t = v->n; v != head; v = t, t = v->n)
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  */
-#define list_iterate_items_gen(v, head, field) \
-	for (v = list_struct_base((head)->n, typeof(*v), field); \
+#define dm_list_iterate_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = list_struct_base(v->field.n, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.n, typeof(*v), field))
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  */
-#define list_iterate_items(v, head) list_iterate_items_gen(v, (head), list)
+#define dm_list_iterate_items(v, head) dm_list_iterate_items_gen(v, (head), list)
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_items_gen_safe(v, t, head, field) \
-	for (v = list_struct_base((head)->n, typeof(*v), field), \
-	     t = list_struct_base(v->field.n, typeof(*v), field); \
+#define dm_list_iterate_items_gen_safe(v, t, head, field) \
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field), \
+	     t = dm_list_struct_base(v->field.n, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = t, t = list_struct_base(v->field.n, typeof(*v), field))
+	     v = t, t = dm_list_struct_base(v->field.n, typeof(*v), field))
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_items_safe(v, t, head) \
-	list_iterate_items_gen_safe(v, t, (head), list)
+#define dm_list_iterate_items_safe(v, t, head) \
+	dm_list_iterate_items_gen_safe(v, t, (head), list)
 
 /*
  * Walk a list backwards, setting 'v' in turn to the containing structure 
  * of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  */
-#define list_iterate_back_items_gen(v, head, field) \
-	for (v = list_struct_base((head)->p, typeof(*v), field); \
+#define dm_list_iterate_back_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->p, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = list_struct_base(v->field.p, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.p, typeof(*v), field))
 
 /*
  * Walk a list backwards, setting 'v' in turn to the containing structure 
  * of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  */
-#define list_iterate_back_items(v, head) list_iterate_back_items_gen(v, (head), list)
+#define dm_list_iterate_back_items(v, head) dm_list_iterate_back_items_gen(v, (head), list)
 
 /*
  * Return the number of elements in a list by walking it.
  */
-unsigned int list_size(const struct list *head);
+unsigned int dm_list_size(const struct dm_list *head);
 
 #endif
--- LVM2/lib/datastruct/lvm-types.h	2008/08/01 19:51:27	1.14
+++ LVM2/lib/datastruct/lvm-types.h	2008/11/03 22:14:27	1.15
@@ -27,7 +27,7 @@
 #define PRIpid_t PRId32
 
 struct str_list {
-	struct list list;
+	struct dm_list list;
 	const char *str;
 };
 
--- LVM2/lib/datastruct/str_list.c	2008/01/30 13:19:44	1.10
+++ LVM2/lib/datastruct/str_list.c	2008/11/03 22:14:27	1.11
@@ -16,19 +16,19 @@
 #include "lib.h"
 #include "str_list.h"
 
-struct list *str_list_create(struct dm_pool *mem)
+struct dm_list *str_list_create(struct dm_pool *mem)
 {
-	struct list *sl;
+	struct dm_list *sl;
 
-	if (!(sl = dm_pool_alloc(mem, sizeof(struct list))))
+	if (!(sl = dm_pool_alloc(mem, sizeof(struct dm_list))))
 		return_NULL;
 
-	list_init(sl);
+	dm_list_init(sl);
 
 	return sl;
 }
 
-int str_list_add(struct dm_pool *mem, struct list *sll, const char *str)
+int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 {
 	struct str_list *sln;
 
@@ -43,31 +43,31 @@
 		return_0;
 
 	sln->str = str;
-	list_add(sll, &sln->list);
+	dm_list_add(sll, &sln->list);
 
 	return 1;
 }
 
-int str_list_del(struct list *sll, const char *str)
+int str_list_del(struct dm_list *sll, const char *str)
 {
-	struct list *slh, *slht;
+	struct dm_list *slh, *slht;
 
-	list_iterate_safe(slh, slht, sll) {
-		if (!strcmp(str, list_item(slh, struct str_list)->str))
-			 list_del(slh);
+	dm_list_iterate_safe(slh, slht, sll) {
+		if (!strcmp(str, dm_list_item(slh, struct str_list)->str))
+			 dm_list_del(slh);
 	}
 
 	return 1;
 }
 
-int str_list_dup(struct dm_pool *mem, struct list *sllnew,
-		 const struct list *sllold)
+int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
+		 const struct dm_list *sllold)
 {
 	struct str_list *sl;
 
-	list_init(sllnew);
+	dm_list_init(sllnew);
 
-	list_iterate_items(sl, sllold) {
+	dm_list_iterate_items(sl, sllold) {
 		if (!str_list_add(mem, sllnew, dm_pool_strdup(mem, sl->str)))
 			return_0;
 	}
@@ -78,11 +78,11 @@
 /*
  * Is item on list?
  */
-int str_list_match_item(const struct list *sll, const char *str)
+int str_list_match_item(const struct dm_list *sll, const char *str)
 {
 	struct str_list *sl;
 
-	list_iterate_items(sl, sll)
+	dm_list_iterate_items(sl, sll)
 	    if (!strcmp(str, sl->str))
 		return 1;
 
@@ -92,11 +92,11 @@
 /*
  * Is at least one item on both lists?
  */
-int str_list_match_list(const struct list *sll, const struct list *sll2)
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2)
 {
 	struct str_list *sl;
 
-	list_iterate_items(sl, sll)
+	dm_list_iterate_items(sl, sll)
 	    if (str_list_match_item(sll2, sl->str))
 		return 1;
 
@@ -106,14 +106,14 @@
 /*
  * Do both lists contain the same set of items?
  */
-int str_list_lists_equal(const struct list *sll, const struct list *sll2)
+int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2)
 {
 	struct str_list *sl;
 
-	if (list_size(sll) != list_size(sll2))
+	if (dm_list_size(sll) != dm_list_size(sll2))
 		return 0;
 
-	list_iterate_items(sl, sll)
+	dm_list_iterate_items(sl, sll)
 	    if (!str_list_match_item(sll2, sl->str))
 		return 0;
 
--- LVM2/lib/datastruct/str_list.h	2007/08/20 20:55:24	1.8
+++ LVM2/lib/datastruct/str_list.h	2008/11/03 22:14:27	1.9
@@ -16,13 +16,13 @@
 #ifndef _LVM_STR_LIST_H
 #define _LVM_STR_LIST_H
 
-struct list *str_list_create(struct dm_pool *mem);
-int str_list_add(struct dm_pool *mem, struct list *sll, const char *str);
-int str_list_del(struct list *sll, const char *str);
-int str_list_match_item(const struct list *sll, const char *str);
-int str_list_match_list(const struct list *sll, const struct list *sll2);
-int str_list_lists_equal(const struct list *sll, const struct list *sll2);
-int str_list_dup(struct dm_pool *mem, struct list *sllnew,
-		 const struct list *sllold);
+struct dm_list *str_list_create(struct dm_pool *mem);
+int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
+int str_list_del(struct dm_list *sll, const char *str);
+int str_list_match_item(const struct dm_list *sll, const char *str);
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2);
+int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);
+int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
+		 const struct dm_list *sllold);
 
 #endif
--- LVM2/lib/device/dev-cache.c	2008/05/28 22:27:47	1.53
+++ LVM2/lib/device/dev-cache.c	2008/11/03 22:14:27	1.54
@@ -31,7 +31,7 @@
 };
 
 struct dir_list {
-	struct list list;
+	struct dm_list list;
 	char dir[0];
 };
 
@@ -42,8 +42,8 @@
 	struct dm_regex *preferred_names_matcher;
 
 	int has_scanned;
-	struct list dirs;
-	struct list files;
+	struct dm_list dirs;
+	struct dm_list files;
 
 } _cache;
 
@@ -97,15 +97,15 @@
 	}
 
 	dev->flags |= DEV_REGULAR;
-	list_init(&dev->aliases);
-	list_add(&dev->aliases, &alias->list);
+	dm_list_init(&dev->aliases);
+	dm_list_add(&dev->aliases, &alias->list);
 	dev->end = UINT64_C(0);
 	dev->dev = 0;
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
-	list_init(&dev->open_list);
+	dm_list_init(&dev->open_list);
 
 	return dev;
 }
@@ -119,14 +119,14 @@
 		return NULL;
 	}
 	dev->flags = 0;
-	list_init(&dev->aliases);
+	dm_list_init(&dev->aliases);
 	dev->dev = d;
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
 	dev->end = UINT64_C(0);
 	memset(dev->pvid, 0, sizeof(dev->pvid));
-	list_init(&dev->open_list);
+	dm_list_init(&dev->open_list);
 
 	return dev;
 }
@@ -140,8 +140,8 @@
 		return;
 
 	log_debug("%s: New preferred name", sl->str);
-	list_del(&sl->list);
-	list_add_h(&dev->aliases, &sl->list);
+	dm_list_del(&sl->list);
+	dm_list_add_h(&dev->aliases, &sl->list);
 }
 
 /* Return 1 if we prefer path1 else return 0 */
@@ -240,7 +240,7 @@
 		return_0;
 
 	/* Is name already there? */
-	list_iterate_items(strl, &dev->aliases) {
+	dm_list_iterate_items(strl, &dev->aliases) {
 		if (!strcmp(strl->str, path)) {
 			log_debug("%s: Already in device cache", path);
 			return 1;
@@ -250,8 +250,8 @@
 	if (!(sl->str = dm_pool_strdup(_cache.mem, path)))
 		return_0;
 
-	if (!list_empty(&dev->aliases)) {
-		oldpath = list_item(dev->aliases.n, struct str_list)->str;
+	if (!dm_list_empty(&dev->aliases)) {
+		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
 		prefer_old = _compare_paths(path, oldpath);
 		log_debug("%s: Aliased to %s in device cache%s",
 			  path, oldpath, prefer_old ? "" : " (preferred name)");
@@ -260,9 +260,9 @@
 		log_debug("%s: Added to device cache", path);
 
 	if (prefer_old)
-		list_add(&dev->aliases, &sl->list);
+		dm_list_add(&dev->aliases, &sl->list);
 	else
-		list_add_h(&dev->aliases, &sl->list);
+		dm_list_add_h(&dev->aliases, &sl->list);
 
 	return 1;
 }
@@ -443,10 +443,10 @@
 	if (_cache.has_scanned && !dev_scan)
 		return;
 
-	list_iterate_items(dl, &_cache.dirs)
+	dm_list_iterate_items(dl, &_cache.dirs)
 		_insert_dir(dl->dir);
 
-	list_iterate_items(dl, &_cache.files)
+	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
 
 	_cache.has_scanned = 1;
@@ -543,8 +543,8 @@
 		goto bad;
 	}
 
-	list_init(&_cache.dirs);
-	list_init(&_cache.files);
+	dm_list_init(&_cache.dirs);
+	dm_list_init(&_cache.files);
 
 	if (!_init_preferred_names(cmd))
 		goto_bad;
@@ -587,8 +587,8 @@
 
 	_cache.devices = NULL;
 	_cache.has_scanned = 0;
-	list_init(&_cache.dirs);
-	list_init(&_cache.files);
+	dm_list_init(&_cache.dirs);
+	dm_list_init(&_cache.files);
 }
 
 int dev_cache_add_dir(const char *path)
@@ -613,7 +613,7 @@
 	}
 
 	strcpy(dl->dir, path);
-	list_add(&_cache.dirs, &dl->list);
+	dm_list_add(&_cache.dirs, &dl->list);
 	return 1;
 }
 
@@ -639,7 +639,7 @@
 	}
 
 	strcpy(dl->dir, path);
-	list_add(&_cache.files, &dl->list);
+	dm_list_add(&_cache.files, &dl->list);
 	return 1;
 }
 
@@ -656,7 +656,7 @@
 	if ((dev->flags & DEV_REGULAR))
 		return dev_name(dev);
 
-	while ((r = stat(name = list_item(dev->aliases.n,
+	while ((r = stat(name = dm_list_item(dev->aliases.n,
 					  struct str_list)->str, &buf)) ||
 	       (buf.st_rdev != dev->dev)) {
 		if (r < 0) {
@@ -680,8 +680,8 @@
 		/* Leave list alone if there isn't an alternative name */
 		/* so dev_name will always find something to return. */
 		/* Otherwise add the name to the correct device. */
-		if (list_size(&dev->aliases) > 1) {
-			list_del(dev->aliases.n);
+		if (dm_list_size(&dev->aliases) > 1) {
+			dm_list_del(dev->aliases.n);
 			if (!r)
 				_insert(name, 0);
 			continue;
@@ -776,6 +776,6 @@
 
 const char *dev_name(const struct device *dev)
 {
-	return (dev) ? list_item(dev->aliases.n, struct str_list)->str :
+	return (dev) ? dm_list_item(dev->aliases.n, struct str_list)->str :
 	    "unknown device";
 }
--- LVM2/lib/device/dev-io.c	2008/01/30 13:59:58	1.62
+++ LVM2/lib/device/dev-io.c	2008/11/03 22:14:27	1.63
@@ -51,7 +51,7 @@
 #  endif
 #endif
 
-static LIST_INIT(_open_devices);
+static DM_LIST_INIT(_open_devices);
 
 /*-----------------------------------------------------------------
  * The standard io loop that keeps submitting an io until it's
@@ -431,7 +431,7 @@
 	if ((flags & O_CREAT) && !(flags & O_TRUNC))
 		dev->end = lseek(dev->fd, (off_t) 0, SEEK_END);
 
-	list_add(&_open_devices, &dev->open_list);
+	dm_list_add(&_open_devices, &dev->open_list);
 
 	log_debug("Opened %s %s%s%s", dev_name(dev),
 		  dev->flags & DEV_OPENED_RW ? "RW" : "RO",
@@ -480,12 +480,12 @@
 		log_sys_error("close", dev_name(dev));
 	dev->fd = -1;
 	dev->block_size = -1;
-	list_del(&dev->open_list);
+	dm_list_del(&dev->open_list);
 
 	log_debug("Closed %s", dev_name(dev));
 
 	if (dev->flags & DEV_ALLOCED) {
-		dm_free((void *) list_item(dev->aliases.n, struct str_list)->
+		dm_free((void *) dm_list_item(dev->aliases.n, struct str_list)->
 			 str);
 		dm_free(dev->aliases.n);
 		dm_free(dev);
@@ -537,11 +537,11 @@
 
 void dev_close_all(void)
 {
-	struct list *doh, *doht;
+	struct dm_list *doh, *doht;
 	struct device *dev;
 
-	list_iterate_safe(doh, doht, &_open_devices) {
-		dev = list_struct_base(doh, struct device, open_list);
+	dm_list_iterate_safe(doh, doht, &_open_devices) {
+		dev = dm_list_struct_base(doh, struct device, open_list);
 		if (dev->open_count < 1)
 			_close(dev);
 	}
--- LVM2/lib/device/device.h	2008/09/19 05:19:09	1.36
+++ LVM2/lib/device/device.h	2008/11/03 22:14:27	1.37
@@ -33,7 +33,7 @@
  * pointer comparisons are valid.
  */
 struct device {
-	struct list aliases;	/* struct str_list from lvm-types.h */
+	struct dm_list aliases;	/* struct str_list from lvm-types.h */
 	dev_t dev;
 
 	/* private */
@@ -42,14 +42,14 @@
 	int block_size;
 	uint32_t flags;
 	uint64_t end;
-	struct list open_list;
+	struct dm_list open_list;
 
 	char pvid[ID_LEN + 1];
 	char _padding[7];
 };
 
 struct device_list {
-	struct list list;
+	struct dm_list list;
 	struct device *dev;
 };
 
--- LVM2/lib/display/display.c	2008/11/03 18:59:58	1.93
+++ LVM2/lib/display/display.c	2008/11/03 22:14:28	1.94
@@ -266,7 +266,7 @@
 	if (pv->pe_size)
 		log_print("--- Physical Segments ---");
 
-	list_iterate_items(pvseg, &pv->segments) {
+	dm_list_iterate_items(pvseg, &pv->segments) {
 		log_print("Physical extent %u to %u:",
 			  pvseg->pe, pvseg->pe + pvseg->len - 1);
 
@@ -425,7 +425,7 @@
 	if (lv_is_origin(lv)) {
 		log_print("LV snapshot status     source of");
 
-		list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
+		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
@@ -483,7 +483,7 @@
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
 	}
 
-	log_print("Segments               %u", list_size(&lv->segments));
+	log_print("Segments               %u", dm_list_size(&lv->segments));
 
 /********* FIXME Stripes & stripesize for each segment
 	log_print("Stripe size (KByte)    %u", lv->stripesize / 2);
@@ -551,7 +551,7 @@
 
 	log_print("--- Segments ---");
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		log_print("Logical extent %u to %u:",
 			  seg->le, seg->le + seg->len - 1);
 
@@ -586,7 +586,7 @@
 	log_print("Format                %s", vg->fid->fmt->name);
 	if (vg->fid->fmt->features & FMT_MDAS) {
 		log_print("Metadata Areas        %d",
-			  list_size(&vg->fid->metadata_areas));
+			  dm_list_size(&vg->fid->metadata_areas));
 		log_print("Metadata Sequence No  %d", vg->seqno);
 	}
 	access_str = vg->status & (LVM_READ | LVM_WRITE);
@@ -607,7 +607,7 @@
 			  vg->status & SHARED ? "yes" : "no");
 	}
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
 			lv_count++;
 
@@ -663,7 +663,7 @@
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
 			lv_count++;
 
@@ -726,7 +726,7 @@
 {
 	const struct format_type *fmt;
 
-	list_iterate_items(fmt, &cmd->formats) {
+	dm_list_iterate_items(fmt, &cmd->formats) {
 		log_print("%s", fmt->name);
 	}
 }
@@ -735,7 +735,7 @@
 {
 	const struct segment_type *segtype;
 
-	list_iterate_items(segtype, &cmd->segtypes) {
+	dm_list_iterate_items(segtype, &cmd->segtypes) {
 		log_print("%s", segtype->name);
 	}
 }
--- LVM2/lib/error/errseg.c	2008/04/07 10:23:46	1.17
+++ LVM2/lib/error/errseg.c	2008/11/03 22:14:28	1.18
@@ -69,7 +69,7 @@
 
 static int _errseg_modules_needed(struct dm_pool *mem,
 				  const struct lv_segment *seg __attribute((unused)),
-				  struct list *modules)
+				  struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "error")) {
 		log_error("error module string list allocation failed");
--- LVM2/lib/filters/filter-persistent.c	2008/03/12 16:03:21	1.36
+++ LVM2/lib/filters/filter-persistent.c	2008/11/03 22:14:28	1.37
@@ -273,7 +273,7 @@
 		l = pf->real->passes_filter(pf->real, dev) ?
 		    PF_GOOD_DEVICE : PF_BAD_DEVICE;
 
-		list_iterate_items(sl, &dev->aliases)
+		dm_list_iterate_items(sl, &dev->aliases)
 			dm_hash_insert(pf->devices, sl->str, l);
 
 	} else if (l == PF_BAD_DEVICE)
--- LVM2/lib/filters/filter-regex.c	2008/01/30 13:59:58	1.25
+++ LVM2/lib/filters/filter-regex.c	2008/11/03 22:14:28	1.26
@@ -151,7 +151,7 @@
 	struct rfilter *rf = (struct rfilter *) f->private;
 	struct str_list *sl;
 
-	list_iterate_items(sl, &dev->aliases) {
+	dm_list_iterate_items(sl, &dev->aliases) {
 		m = dm_regex_match(rf->engine, sl->str);
 
 		if (m >= 0) {
--- LVM2/lib/format1/Makefile.in	2007/09/21 10:16:44	1.9
+++ LVM2/lib/format1/Makefile.in	2008/11/03 22:14:28	1.10
@@ -26,6 +26,7 @@
 	vg_number.c
 
 LIB_SHARED = liblvm2format1.so
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
--- LVM2/lib/format1/disk-rep.c	2008/11/03 16:26:27	1.77
+++ LVM2/lib/format1/disk-rep.c	2008/11/03 22:14:28	1.78
@@ -261,7 +261,7 @@
 		memcpy(ul->uuid, buffer, NAME_LEN);
 		ul->uuid[NAME_LEN - 1] = '\0';
 
-		list_add(&data->uuids, &ul->list);
+		dm_list_add(&data->uuids, &ul->list);
 
 		pos += NAME_LEN;
 		num_read++;
@@ -296,7 +296,7 @@
 			continue;
 
 		lvs_read++;
-		list_add(&data->lvds, &ll->list);
+		dm_list_add(&data->lvds, &ll->list);
 	}
 
 	return 1;
@@ -336,7 +336,7 @@
 	}
 
 	info->device_size = xlate32(dl->pvd.pv_size) << SECTOR_SHIFT;
-	list_init(&info->mdas);
+	dm_list_init(&info->mdas);
 	info->status &= ~CACHE_INVALID;
 }
 
@@ -352,8 +352,8 @@
 
 	dl->dev = dev;
 	dl->mem = mem;
-	list_init(&dl->uuids);
-	list_init(&dl->lvds);
+	dm_list_init(&dl->uuids);
+	dm_list_init(&dl->lvds);
 
 	if (!_read_pvd(dev, &dl->pvd))
 		goto_bad;
@@ -426,12 +426,12 @@
 	return dl;
 }
 
-static void _add_pv_to_list(struct list *head, struct disk_list *data)
+static void _add_pv_to_list(struct dm_list *head, struct disk_list *data)
 {
 	struct pv_disk *pvd;
 	struct disk_list *diskl;
 
-	list_iterate_items(diskl, head) {
+	dm_list_iterate_items(diskl, head) {
 		pvd = &diskl->pvd;
 		if (!strncmp((char *)data->pvd.pv_uuid, (char *)pvd->pv_uuid,
 			     sizeof(pvd->pv_uuid))) {
@@ -443,11 +443,11 @@
 			}
 			log_very_verbose("Duplicate PV %s - using md %s",
 					 pvd->pv_uuid, dev_name(data->dev));
-			list_del(&diskl->list);
+			dm_list_del(&diskl->list);
 			break;
 		}
 	}
-	list_add(head, &data->list);
+	dm_list_add(head, &data->list);
 }
 
 /*
@@ -457,7 +457,7 @@
  */
 int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 		   struct dev_filter *filter, struct dm_pool *mem,
-		   struct list *head)
+		   struct dm_list *head)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -468,7 +468,7 @@
 	/* Fast path if we already saw this VG and cached the list of PVs */
 	if (vg_name && (vginfo = vginfo_from_vgname(vg_name, NULL)) &&
 	    vginfo->infos.n) {
-		list_iterate_items(info, &vginfo->infos) {
+		dm_list_iterate_items(info, &vginfo->infos) {
 			dev = info->dev;
 			if (dev && !(data = read_disk(fmt, dev, mem, vg_name)))
 				break;
@@ -478,11 +478,11 @@
 		/* Did we find the whole VG? */
 		if (!vg_name || is_orphan_vg(vg_name) ||
 		    (data && *data->pvd.vg_name &&
-		     list_size(head) == data->vgd.pv_cur))
+		     dm_list_size(head) == data->vgd.pv_cur))
 			return 1;
 
 		/* Failed */
-		list_init(head);
+		dm_list_init(head);
 		/* vgcache_del(vg_name); */
 	}
 
@@ -499,7 +499,7 @@
 	}
 	dev_iter_destroy(iter);
 
-	if (list_empty(head))
+	if (dm_list_empty(head))
 		return 0;
 
 	return 1;
@@ -528,7 +528,7 @@
 	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
-	list_iterate_items(ul, &data->uuids) {
+	dm_list_iterate_items(ul, &data->uuids) {
 		if (pos >= end) {
 			log_error("Too many uuids to fit on %s",
 				  dev_name(data->dev));
@@ -576,7 +576,7 @@
 		return 0;
 	}
 
-	list_iterate_items(ll, &data->lvds) {
+	dm_list_iterate_items(ll, &data->lvds) {
 		offset = sizeof(struct lv_disk) * ll->lvd.lv_number;
 		if (offset + sizeof(struct lv_disk) > data->pvd.lv_on_disk.size) {
 			log_error("lv_number %d too large", ll->lvd.lv_number);
@@ -719,11 +719,11 @@
  * little sanity checking, so make sure correct
  * data is passed to here.
  */
-int write_disks(const struct format_type *fmt, struct list *pvs)
+int write_disks(const struct format_type *fmt, struct dm_list *pvs)
 {
 	struct disk_list *dl;
 
-	list_iterate_items(dl, pvs) {
+	dm_list_iterate_items(dl, pvs) {
 		if (!(_write_all_pvd(fmt, dl)))
 			return_0;
 
--- LVM2/lib/format1/disk-rep.h	2008/09/19 06:41:58	1.52
+++ LVM2/lib/format1/disk-rep.h	2008/11/03 22:14:28	1.53
@@ -147,24 +147,24 @@
 } __attribute__ ((packed));
 
 struct uuid_list {
-	struct list list;
+	struct dm_list list;
 	char uuid[NAME_LEN] __attribute((aligned(8)));
 };
 
 struct lvd_list {
-	struct list list;
+	struct dm_list list;
 	struct lv_disk lvd;
 };
 
 struct disk_list {
-	struct list list;
+	struct dm_list list;
 	struct dm_pool *mem;
 	struct device *dev;
 
 	struct pv_disk pvd __attribute((aligned(8)));
 	struct vg_disk vgd __attribute((aligned(8)));
-	struct list uuids __attribute((aligned(8)));
-	struct list lvds __attribute((aligned(8)));
+	struct dm_list uuids __attribute((aligned(8)));
+	struct dm_list lvds __attribute((aligned(8)));
 	struct pe_disk *extents __attribute((aligned(8)));
 };
 
@@ -195,9 +195,9 @@
 
 int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 		   struct dev_filter *filter,
-		   struct dm_pool *mem, struct list *results);
+		   struct dm_pool *mem, struct dm_list *results);
 
-int write_disks(const struct format_type *fmt, struct list *pvds);
+int write_disks(const struct format_type *fmt, struct dm_list *pvds);
 
 /*
  * Functions to translate to between disk and in
@@ -218,33 +218,33 @@
 int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd);
 
 int import_extents(struct cmd_context *cmd, struct volume_group *vg,
-		   struct list *pvds);
+		   struct dm_list *pvds);
 int export_extents(struct disk_list *dl, uint32_t lv_num,
 		   struct logical_volume *lv, struct physical_volume *pv);
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
 	       struct volume_group *vg,
-	       struct list *pvds, struct list *results, uint32_t *count);
+	       struct dm_list *pvds, struct dm_list *results, uint32_t *count);
 
-int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct list *pvds);
+int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds);
 int export_lvs(struct disk_list *dl, struct volume_group *vg,
 	       struct physical_volume *pv, const char *dev_dir);
 
 int import_snapshots(struct dm_pool *mem, struct volume_group *vg,
-		     struct list *pvds);
+		     struct dm_list *pvds);
 
 int export_uuids(struct disk_list *dl, struct volume_group *vg);
 
-void export_numbers(struct list *pvds, struct volume_group *vg);
+void export_numbers(struct dm_list *pvds, struct volume_group *vg);
 
-void export_pv_act(struct list *pvds);
+void export_pv_act(struct dm_list *pvds);
 int munge_pvd(struct device *dev, struct pv_disk *pvd);
 int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd);
 
 /* blech */
 int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
 		       const char *candidate_vg, int *result);
-int export_vg_number(struct format_instance *fid, struct list *pvds,
+int export_vg_number(struct format_instance *fid, struct dm_list *pvds,
 		     const char *vg_name, struct dev_filter *filter);
 
 #endif
--- LVM2/lib/format1/format1.c	2008/09/19 06:41:58	1.108
+++ LVM2/lib/format1/format1.c	2008/11/03 22:14:28	1.109
@@ -23,9 +23,9 @@
 #include "segtype.h"
 
 /* VG consistency checks */
-static int _check_vgs(struct list *pvs)
+static int _check_vgs(struct dm_list *pvs)
 {
-	struct list *pvh, *t;
+	struct dm_list *pvh, *t;
 	struct disk_list *dl = NULL;
 	struct disk_list *first = NULL;
 
@@ -38,7 +38,7 @@
 	 * This means an active VG won't be affected if disks are inserted
 	 * bearing an exported VG with the same name.
 	 */
-	list_iterate_items(dl, pvs) {
+	dm_list_iterate_items(dl, pvs) {
 		if (first_time) {
 			exported = dl->pvd.pv_status & VG_EXPORTED;
 			first_time = 0;
@@ -47,18 +47,18 @@
 
 		if (exported != (dl->pvd.pv_status & VG_EXPORTED)) {
 			/* Remove exported PVs */
-			list_iterate_safe(pvh, t, pvs) {
-				dl = list_item(pvh, struct disk_list);
+			dm_list_iterate_safe(pvh, t, pvs) {
+				dl = dm_list_item(pvh, struct disk_list);
 				if (dl->pvd.pv_status & VG_EXPORTED)
-					list_del(pvh);
+					dm_list_del(pvh);
 			}
 			break;
 		}
 	}
 
 	/* Remove any PVs with VG structs that differ from the first */
-	list_iterate_safe(pvh, t, pvs) {
-		dl = list_item(pvh, struct disk_list);
+	dm_list_iterate_safe(pvh, t, pvs) {
+		dl = dm_list_item(pvh, struct disk_list);
 
 		if (!first)
 			first = dl;
@@ -95,7 +95,7 @@
 				  dl->vgd.vgda, dl->vgd.pe_size,
 				  dl->vgd.pe_total, dl->vgd.pe_allocated,
 				  dl->vgd.pvg_total);
-			list_del(pvh);
+			dm_list_del(pvh);
 			return 0;
 		}
 		pv_count++;
@@ -111,7 +111,7 @@
 }
 
 static struct volume_group *_build_vg(struct format_instance *fid,
-				      struct list *pvs)
+				      struct dm_list *pvs)
 {
 	struct dm_pool *mem = fid->fmt->cmd->mem;
 	struct volume_group *vg = dm_pool_alloc(mem, sizeof(*vg));
@@ -120,7 +120,7 @@
 	if (!vg)
 		goto_bad;
 
-	if (list_empty(pvs))
+	if (dm_list_empty(pvs))
 		goto_bad;
 
 	memset(vg, 0, sizeof(*vg));
@@ -128,14 +128,14 @@
 	vg->cmd = fid->fmt->cmd;
 	vg->fid = fid;
 	vg->seqno = 0;
-	list_init(&vg->pvs);
-	list_init(&vg->lvs);
-	list_init(&vg->tags);
+	dm_list_init(&vg->pvs);
+	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->tags);
 
 	if (!_check_vgs(pvs))
 		goto_bad;
 
-	dl = list_item(pvs->n, struct disk_list);
+	dl = dm_list_item(pvs->n, struct disk_list);
 
 	if (!import_vg(mem, vg, dl))
 		goto_bad;
@@ -164,9 +164,9 @@
 				     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", 1024 * 10);
-	struct list pvs;
+	struct dm_list pvs;
 	struct volume_group *vg = NULL;
-	list_init(&pvs);
+	dm_list_init(&pvs);
 
 	if (!mem)
 		return_NULL;
@@ -199,8 +199,8 @@
 	dl->mem = mem;
 	dl->dev = pv->dev;
 
-	list_init(&dl->uuids);
-	list_init(&dl->lvds);
+	dm_list_init(&dl->uuids);
+	dm_list_init(&dl->lvds);
 
 	if (!export_pv(fid->fmt->cmd, mem, vg, &dl->pvd, pv) ||
 	    !export_vg(&dl->vgd, vg) ||
@@ -215,17 +215,17 @@
 
 static int _flatten_vg(struct format_instance *fid, struct dm_pool *mem,
 		       struct volume_group *vg,
-		       struct list *pvds, const char *dev_dir,
+		       struct dm_list *pvds, const char *dev_dir,
 		       struct dev_filter *filter)
 {
 	struct pv_list *pvl;
 	struct disk_list *data;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(data = _flatten_pv(fid, mem, vg, pvl->pv, dev_dir)))
 			return_0;
 
-		list_add(pvds, &data->list);
+		dm_list_add(pvds, &data->list);
 	}
 
 	export_numbers(pvds, vg);
@@ -241,13 +241,13 @@
 		     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", 1024 * 10);
-	struct list pvds;
+	struct dm_list pvds;
 	int r = 0;
 
 	if (!mem)
 		return_0;
 
-	list_init(&pvds);
+	dm_list_init(&pvds);
 
 	r = (_flatten_vg(fid, mem, vg, &pvds, fid->fmt->cmd->dev_dir,
 			 fid->fmt->cmd->filter) &&
@@ -259,7 +259,7 @@
 }
 
 static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct list *mdas __attribute((unused)))
+		    struct physical_volume *pv, struct dm_list *mdas __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
 	struct disk_list *dl;
@@ -293,7 +293,7 @@
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     int pvmetadatacopies __attribute((unused)),
-		     uint64_t pvmetadatasize __attribute((unused)), struct list *mdas __attribute((unused)),
+		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
 {
 	if (pv->size > MAX_PV_SIZE)
@@ -346,11 +346,11 @@
 }
 
 static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct list *mdas __attribute((unused)), int64_t sector __attribute((unused)))
+		     struct dm_list *mdas __attribute((unused)), int64_t sector __attribute((unused)))
 {
 	struct dm_pool *mem;
 	struct disk_list *dl;
-	struct list pvs;
+	struct dm_list pvs;
 	struct label *label;
 	struct lvmcache_info *info;
 
@@ -361,9 +361,9 @@
 	info->device_size = pv->size << SECTOR_SHIFT;
 	info->fmt = fmt;
 
-	list_init(&info->mdas);
+	dm_list_init(&info->mdas);
 
-	list_init(&pvs);
+	dm_list_init(&pvs);
 
 	/* Ensure any residual PE structure is gone */
 	pv->pe_size = pv->pe_count = 0;
@@ -387,7 +387,7 @@
 	dl->pvd.pv_on_disk.size = PV_SIZE;
 	dl->pvd.pe_on_disk.base = LVM1_PE_ALIGN << SECTOR_SHIFT;
 
-	list_add(&pvs, &dl->list);
+	dm_list_add(&pvs, &dl->list);
 	if (!write_disks(fmt, &pvs))
 		goto_bad;
 
@@ -457,7 +457,7 @@
 		return_NULL;
 
 	fid->fmt = fmt;
-	list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
@@ -467,7 +467,7 @@
 
 	mda->ops = &_metadata_format1_ops;
 	mda->metadata_locn = NULL;
-	list_add(&fid->metadata_areas, &mda->list);
+	dm_list_add(&fid->metadata_areas, &mda->list);
 
 	return fid;
 }
--- LVM2/lib/format1/import-export.c	2008/09/19 06:41:58	1.99
+++ LVM2/lib/format1/import-export.c	2008/11/03 22:14:28	1.100
@@ -116,8 +116,8 @@
 		}
 	}
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
+	dm_list_init(&pv->tags);
+	dm_list_init(&pv->segments);
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
@@ -339,10 +339,10 @@
 	lv->le_count = lvd->lv_allocated_le;
 
 	lv->snapshot = NULL;
-	list_init(&lv->snapshot_segs);
-	list_init(&lv->segments);
-	list_init(&lv->tags);
-	list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
 
 	return 1;
 }
@@ -379,9 +379,9 @@
 		lvd->lv_read_ahead = lv->read_ahead;
 
 	lvd->lv_stripes =
-	    list_item(lv->segments.n, struct lv_segment)->area_count;
+	    dm_list_item(lv->segments.n, struct lv_segment)->area_count;
 	lvd->lv_stripesize =
-	    list_item(lv->segments.n, struct lv_segment)->stripe_size;
+	    dm_list_item(lv->segments.n, struct lv_segment)->stripe_size;
 
 	lvd->lv_size = lv->size;
 	lvd->lv_allocated_le = lv->le_count;
@@ -400,7 +400,7 @@
 	struct lv_segment *seg;
 	uint32_t pe, s;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (!(seg->segtype->flags & SEG_FORMAT1_SUPPORT)) {
 				log_error("Segment type %s in LV %s: "
@@ -430,13 +430,13 @@
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
 	       struct volume_group *vg,
-	       struct list *pvds, struct list *results, uint32_t *count)
+	       struct dm_list *pvds, struct dm_list *results, uint32_t *count)
 {
 	struct disk_list *dl;
 	struct pv_list *pvl;
 
 	*count = 0;
-	list_iterate_items(dl, pvds) {
+	dm_list_iterate_items(dl, pvds) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv))))
 			return_0;
@@ -445,7 +445,7 @@
 			return_0;
 
 		pvl->pv->fmt = fmt;
-		list_add(results, &pvl->list);
+		dm_list_add(results, &pvl->list);
 		(*count)++;
 	}
 
@@ -468,20 +468,20 @@
 	if (!import_lv(mem, lv, lvd))
 		return_NULL;
 
-	list_add(&vg->lvs, &ll->list);
+	dm_list_add(&vg->lvs, &ll->list);
 	vg->lv_count++;
 
 	return lv;
 }
 
-int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct list *pvds)
+int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds)
 {
 	struct disk_list *dl;
 	struct lvd_list *ll;
 	struct lv_disk *lvd;
 
-	list_iterate_items(dl, pvds) {
-		list_iterate_items(ll, &dl->lvds) {
+	dm_list_iterate_items(dl, pvds) {
+		dm_list_iterate_items(ll, &dl->lvds) {
 			lvd = &ll->lvd;
 
 			if (!find_lv(vg, (char *)lvd->lv_name) &&
@@ -518,7 +518,7 @@
 		goto_out;
 	memset(dl->extents, 0, len);
 
-	list_iterate_items(ll, &vg->lvs) {
+	dm_list_iterate_items(ll, &vg->lvs) {
 		if (ll->lv->status & SNAPSHOT)
 			continue;
 
@@ -546,7 +546,7 @@
 			    lvnum_from_lvid(&ll->lv->snapshot->origin->lvid);
 		}
 
-		list_add(&dl->lvds, &lvdl->list);
+		dm_list_add(&dl->lvds, &lvdl->list);
 		dl->pvd.lv_cur++;
 	}
 
@@ -561,7 +561,7 @@
  * FIXME: More inefficient code.
  */
 int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_group *vg,
-		     struct list *pvds)
+		     struct dm_list *pvds)
 {
 	struct logical_volume *lvs[MAX_LV];
 	struct disk_list *dl;
@@ -572,8 +572,8 @@
 
 	/* build an index of lv numbers */
 	memset(lvs, 0, sizeof(lvs));
-	list_iterate_items(dl, pvds) {
-		list_iterate_items(ll, &dl->lvds) {
+	dm_list_iterate_items(dl, pvds) {
+		dm_list_iterate_items(ll, &dl->lvds) {
 			lvd = &ll->lvd;
 
 			lvnum = lvd->lv_number;
@@ -596,8 +596,8 @@
 	/*
 	 * Now iterate through yet again adding the snapshots.
 	 */
-	list_iterate_items(dl, pvds) {
-		list_iterate_items(ll, &dl->lvds) {
+	dm_list_iterate_items(dl, pvds) {
+		dm_list_iterate_items(ll, &dl->lvds) {
 			lvd = &ll->lvd;
 
 			if (!(lvd->lv_access & LV_SNAPSHOT))
@@ -633,14 +633,14 @@
 	struct uuid_list *ul;
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(ul = dm_pool_alloc(dl->mem, sizeof(*ul))))
 			return_0;
 
 		memset(ul->uuid, 0, sizeof(ul->uuid));
 		memcpy(ul->uuid, pvl->pv->id.uuid, ID_LEN);
 
-		list_add(&dl->uuids, &ul->list);
+		dm_list_add(&dl->uuids, &ul->list);
 	}
 	return 1;
 }
@@ -649,32 +649,32 @@
  * This calculates the nasty pv_number field
  * used by LVM1.
  */
-void export_numbers(struct list *pvds, struct volume_group *vg __attribute((unused)))
+void export_numbers(struct dm_list *pvds, struct volume_group *vg __attribute((unused)))
 {
 	struct disk_list *dl;
 	int pv_num = 1;
 
-	list_iterate_items(dl, pvds)
+	dm_list_iterate_items(dl, pvds)
 		dl->pvd.pv_number = pv_num++;
 }
 
 /*
  * Calculate vg_disk->pv_act.
  */
-void export_pv_act(struct list *pvds)
+void export_pv_act(struct dm_list *pvds)
 {
 	struct disk_list *dl;
 	int act = 0;
 
-	list_iterate_items(dl, pvds)
+	dm_list_iterate_items(dl, pvds)
 		if (dl->pvd.pv_status & PV_ACTIVE)
 			act++;
 
-	list_iterate_items(dl, pvds)
+	dm_list_iterate_items(dl, pvds)
 		dl->vgd.pv_act = act;
 }
 
-int export_vg_number(struct format_instance *fid, struct list *pvds,
+int export_vg_number(struct format_instance *fid, struct dm_list *pvds,
 		     const char *vg_name, struct dev_filter *filter)
 {
 	struct disk_list *dl;
@@ -683,7 +683,7 @@
 	if (!get_free_vg_number(fid, filter, vg_name, &vg_num))
 		return_0;
 
-	list_iterate_items(dl, pvds)
+	dm_list_iterate_items(dl, pvds)
 		dl->vgd.vg_number = vg_num;
 
 	return 1;
--- LVM2/lib/format1/import-extents.c	2008/01/30 13:59:59	1.36
+++ LVM2/lib/format1/import-extents.c	2008/11/03 22:14:28	1.37
@@ -55,7 +55,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(ll, &vg->lvs) {
+	dm_list_iterate_items(ll, &vg->lvs) {
 		if (ll->lv->status & SNAPSHOT)
 			continue;
 
@@ -86,7 +86,7 @@
 
 	memset(lvs, 0, sizeof(*lvs) * MAX_LV);
 
-	list_iterate_items(ll, &dl->lvds) {
+	dm_list_iterate_items(ll, &dl->lvds) {
 		if (!(lvm = dm_hash_lookup(maps, strrchr((char *)ll->lvd.lv_name, '/')
 					+ 1))) {
 			log_err("Physical volume (%s) contains an "
@@ -105,7 +105,7 @@
 }
 
 static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
-		      struct list *pvds)
+		      struct dm_list *pvds)
 {
 	struct disk_list *dl;
 	struct physical_volume *pv;
@@ -113,7 +113,7 @@
 	struct pe_disk *e;
 	uint32_t i, lv_num, le;
 
-	list_iterate_items(dl, pvds) {
+	dm_list_iterate_items(dl, pvds) {
 		pv = find_pv(vg, dl->dev);
 		e = dl->extents;
 
@@ -228,7 +228,7 @@
 					    lvm->map[le].pe))
 			return_0;
 
-		list_add(&lvm->lv->segments, &seg->list);
+		dm_list_add(&lvm->lv->segments, &seg->list);
 
 		le += seg->len;
 	}
@@ -307,7 +307,7 @@
 			      lvm->map[first_area_le + st * total_area_len].pe))
 				return_0;
 
-		list_add(&lvm->lv->segments, &seg->list);
+		dm_list_add(&lvm->lv->segments, &seg->list);
 
 		first_area_le += area_len;
 	}
@@ -336,7 +336,7 @@
 }
 
 int import_extents(struct cmd_context *cmd, struct volume_group *vg,
-		   struct list *pvds)
+		   struct dm_list *pvds)
 {
 	int r = 0;
 	struct dm_pool *scratch = dm_pool_create("lvm1 import_extents", 10 * 1024);
--- LVM2/lib/format1/lvm1-label.c	2008/02/06 15:47:27	1.19
+++ LVM2/lib/format1/lvm1-label.c	2008/11/03 22:14:28	1.20
@@ -80,7 +80,7 @@
 	*label = info->label;
 
 	info->device_size = xlate32(pvd->pv_size) << SECTOR_SHIFT;
-	list_init(&info->mdas);
+	dm_list_init(&info->mdas);
 
 	info->status &= ~CACHE_INVALID;
 
--- LVM2/lib/format1/vg_number.c	2008/01/30 13:59:59	1.15
+++ LVM2/lib/format1/vg_number.c	2008/11/03 22:14:28	1.16
@@ -26,12 +26,12 @@
 int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
 		       const char *candidate_vg, int *result)
 {
-	struct list all_pvs;
+	struct dm_list all_pvs;
 	struct disk_list *dl;
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_number", 10 * 1024);
 	int numbers[MAX_VG], i, r = 0;
 
-	list_init(&all_pvs);
+	dm_list_init(&all_pvs);
 
 	if (!mem)
 		return_0;
@@ -41,7 +41,7 @@
 
 	memset(numbers, 0, sizeof(numbers));
 
-	list_iterate_items(dl, &all_pvs) {
+	dm_list_iterate_items(dl, &all_pvs) {
 		if (!*dl->pvd.vg_name || !strcmp((char *)dl->pvd.vg_name, candidate_vg))
 			continue;
 
--- LVM2/lib/format_pool/Makefile.in	2007/09/21 10:16:44	1.5
+++ LVM2/lib/format_pool/Makefile.in	2008/11/03 22:14:28	1.6
@@ -23,6 +23,7 @@
 	pool_label.c
 
 LIB_SHARED = liblvm2formatpool.so
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
--- LVM2/lib/format_pool/disk_rep.c	2008/01/30 13:59:59	1.13
+++ LVM2/lib/format_pool/disk_rep.c	2008/11/03 22:14:28	1.14
@@ -51,11 +51,11 @@
 	return 1;
 }
 
-static void _add_pl_to_list(struct list *head, struct pool_list *data)
+static void _add_pl_to_list(struct dm_list *head, struct pool_list *data)
 {
 	struct pool_list *pl;
 
-	list_iterate_items(pl, head) {
+	dm_list_iterate_items(pl, head) {
 		if (id_equal(&data->pv_uuid, &pl->pv_uuid)) {
 			char uuid[ID_LEN + 7] __attribute((aligned(8)));
 
@@ -69,11 +69,11 @@
 			}
 			log_very_verbose("Duplicate PV %s - using md %s",
 					 uuid, dev_name(data->dev));
-			list_del(&pl->list);
+			dm_list_del(&pl->list);
 			break;
 		}
 	}
-	list_add(head, &data->list);
+	dm_list_add(head, &data->list);
 }
 
 int read_pool_label(struct pool_list *pl, struct labeller *l,
@@ -102,7 +102,7 @@
 		*label = info->label;
 
 	info->device_size = xlate32_be(pd->pl_blocks) << SECTOR_SHIFT;
-	list_init(&info->mdas);
+	dm_list_init(&info->mdas);
 
 	info->status &= ~CACHE_INVALID;
 
@@ -235,7 +235,7 @@
 }
 
 static int _read_vg_pds(const struct format_type *fmt, struct dm_pool *mem,
-			struct lvmcache_vginfo *vginfo, struct list *head,
+			struct lvmcache_vginfo *vginfo, struct dm_list *head,
 			uint32_t *devcount)
 {
 	struct lvmcache_info *info;
@@ -251,7 +251,7 @@
 	if (!(tmpmem = dm_pool_create("pool read_vg", 512)))
 		return_0;
 
-	list_iterate_items(info, &vginfo->infos) {
+	dm_list_iterate_items(info, &vginfo->infos) {
 		if (info->dev &&
 		    !(pl = read_pool_disk(fmt, info->dev, mem, vginfo->vgname)))
 			    break;
@@ -298,7 +298,7 @@
 }
 
 int read_pool_pds(const struct format_type *fmt, const char *vg_name,
-		  struct dm_pool *mem, struct list *pdhead)
+		  struct dm_pool *mem, struct dm_list *pdhead)
 {
 	struct lvmcache_vginfo *vginfo;
 	uint32_t totaldevs;
@@ -316,7 +316,7 @@
 				 * If we found all the devices we were
 				 * expecting, return success
 				 */
-				if (list_size(pdhead) == totaldevs)
+				if (dm_list_size(pdhead) == totaldevs)
 					return 1;
 
 				/*
@@ -328,7 +328,7 @@
 			}
 		}
 		/* Failed */
-		list_init(pdhead);
+		dm_list_init(pdhead);
 
 		full_scan++;
 		if (full_scan > 1) {
--- LVM2/lib/format_pool/disk_rep.h	2007/08/20 20:55:25	1.6
+++ LVM2/lib/format_pool/disk_rep.h	2008/11/03 22:14:28	1.7
@@ -106,7 +106,7 @@
 };
 
 struct pool_list {
-	struct list list;
+	struct dm_list list;
 	struct pool_disk pd;
 	struct physical_volume *pv;
 	struct id pv_uuid;
@@ -137,18 +137,18 @@
 void pool_label_out(struct pool_disk *pl, void *buf);
 void pool_label_in(struct pool_disk *pl, void *buf);
 void get_pool_uuid(char *uuid, uint64_t poolid, uint32_t spid, uint32_t devid);
-int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct list *pls);
+int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls);
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem,
-		    struct list *pls);
+		    struct dm_list *pls);
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct list *pvs, struct dm_pool *mem, struct list *pls);
+		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls);
 int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
 		   struct volume_group *vg, struct physical_volume *pv,
 		   struct pool_list *pl);
-int import_pool_segments(struct list *lvs, struct dm_pool *mem,
+int import_pool_segments(struct dm_list *lvs, struct dm_pool *mem,
 			 struct user_subpool *usp, int sp_count);
 int read_pool_pds(const struct format_type *fmt, const char *vgname,
-		  struct dm_pool *mem, struct list *head);
+		  struct dm_pool *mem, struct dm_list *head);
 struct pool_list *read_pool_disk(const struct format_type *fmt,
 				 struct device *dev, struct dm_pool *mem,
 				 const char *vg_name);
--- LVM2/lib/format_pool/format_pool.c	2008/06/11 13:14:41	1.17
+++ LVM2/lib/format_pool/format_pool.c	2008/11/03 22:14:28	1.18
@@ -25,7 +25,7 @@
 #include "pool_label.h"
 
 /* Must be called after pvs are imported */
-static struct user_subpool *_build_usp(struct list *pls, struct dm_pool *mem,
+static struct user_subpool *_build_usp(struct dm_list *pls, struct dm_pool *mem,
 				       int *sps)
 {
 	struct pool_list *pl;
@@ -36,7 +36,7 @@
 	 * FIXME: Need to do some checks here - I'm tempted to add a
 	 * user_pool structure and build the entire thing to check against.
 	 */
-	list_iterate_items(pl, pls) {
+	dm_list_iterate_items(pl, pls) {
 		*sps = pl->pd.pl_subpools;
 		if (!usp && (!(usp = dm_pool_zalloc(mem, sizeof(*usp) * (*sps))))) {
 			log_error("Unable to allocate %d subpool structures",
@@ -100,7 +100,7 @@
 
 static struct volume_group *_build_vg_from_pds(struct format_instance
 					       *fid, struct dm_pool *mem,
-					       struct list *pds)
+					       struct dm_list *pds)
 {
 	struct dm_pool *smem = fid->fmt->cmd->mem;
 	struct volume_group *vg = NULL;
@@ -122,9 +122,9 @@
 	vg->snapshot_count = 0;
 	vg->seqno = 1;
 	vg->system_id = NULL;
-	list_init(&vg->pvs);
-	list_init(&vg->lvs);
-	list_init(&vg->tags);
+	dm_list_init(&vg->pvs);
+	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->tags);
 
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
@@ -161,10 +161,10 @@
 				     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool vg_read", 1024);
-	struct list pds;
+	struct dm_list pds;
 	struct volume_group *vg = NULL;
 
-	list_init(&pds);
+	dm_list_init(&pds);
 
 	/* We can safely ignore the mda passed in */
 
@@ -193,7 +193,7 @@
 			  uint32_t extent_size __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
-			  struct list *mdas __attribute((unused)),
+			  struct dm_list *mdas __attribute((unused)),
 			  struct physical_volume *pv __attribute((unused)),
 			  struct volume_group *vg __attribute((unused)))
 {
@@ -202,7 +202,7 @@
 
 static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
 			 struct physical_volume *pv,
-			 struct list *mdas __attribute((unused)))
+			 struct dm_list *mdas __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
 	struct pool_list *pl;
@@ -258,7 +258,7 @@
 	}
 
 	fid->fmt = fmt;
-	list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
@@ -270,7 +270,7 @@
 
 	mda->ops = &_metadata_format_pool_ops;
 	mda->metadata_locn = NULL;
-	list_add(&fid->metadata_areas, &mda->list);
+	dm_list_add(&fid->metadata_areas, &mda->list);
 
 	return fid;
 }
--- LVM2/lib/format_pool/import_export.c	2008/09/19 04:27:26	1.24
+++ LVM2/lib/format_pool/import_export.c	2008/11/03 22:14:28	1.25
@@ -28,11 +28,11 @@
 
 /* This file contains only imports at the moment... */
 
-int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct list *pls)
+int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pool_list *pl;
 
-	list_iterate_items(pl, pls) {
+	dm_list_iterate_items(pl, pls) {
 		vg->extent_count +=
 		    ((pl->pd.pl_blocks) / POOL_PE_SIZE);
 
@@ -55,7 +55,7 @@
 	return 1;
 }
 
-int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct list *pls)
+int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pool_list *pl;
 	struct lv_list *lvl = dm_pool_zalloc(mem, sizeof(*lvl));
@@ -80,12 +80,12 @@
 	lv->le_count = 0;
 	lv->read_ahead = vg->cmd->default_settings.read_ahead;
 	lv->snapshot = NULL;
-	list_init(&lv->snapshot_segs);
-	list_init(&lv->segments);
-	list_init(&lv->tags);
-	list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
 
-	list_iterate_items(pl, pls) {
+	dm_list_iterate_items(pl, pls) {
 		lv->size += pl->pd.pl_blocks;
 
 		if (lv->name)
@@ -109,26 +109,26 @@
 			lv->minor = -1;
 		}
 		lv->snapshot = NULL;
-		list_init(&lv->snapshot_segs);
-		list_init(&lv->segments);
-		list_init(&lv->tags);
+		dm_list_init(&lv->snapshot_segs);
+		dm_list_init(&lv->segments);
+		dm_list_init(&lv->tags);
 	}
 
 	lv->le_count = lv->size / POOL_PE_SIZE;
 	lvl->lv = lv;
-	list_add(&vg->lvs, &lvl->list);
+	dm_list_add(&vg->lvs, &lvl->list);
 	vg->lv_count++;
 
 	return 1;
 }
 
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct list *pvs, struct dm_pool *mem, struct list *pls)
+		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pv_list *pvl;
 	struct pool_list *pl;
 
-	list_iterate_items(pl, pls) {
+	dm_list_iterate_items(pl, pls) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
 			log_error("Unable to allocate pv list structure");
 			return 0;
@@ -143,7 +143,7 @@
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
-		list_add(pvs, &pvl->list);
+		dm_list_add(pvs, &pvl->list);
 	}
 
 	return 1;
@@ -175,8 +175,8 @@
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
+	dm_list_init(&pv->tags);
+	dm_list_init(&pv->segments);
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
@@ -232,7 +232,7 @@
 	/* add the subpool type to the segment tag list */
 	str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
 
-	list_add(&lv->segments, &seg->list);
+	dm_list_add(&lv->segments, &seg->list);
 
 	*le_cur += seg->len;
 
@@ -268,7 +268,7 @@
 
 		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0))
 			return_0;
-		list_add(&lv->segments, &seg->list);
+		dm_list_add(&lv->segments, &seg->list);
 
 		*le_cur += seg->len;
 	}
@@ -276,7 +276,7 @@
 	return 1;
 }
 
-int import_pool_segments(struct list *lvs, struct dm_pool *mem,
+int import_pool_segments(struct dm_list *lvs, struct dm_pool *mem,
 			 struct user_subpool *usp, int subpools)
 {
 	struct lv_list *lvl;
@@ -284,7 +284,7 @@
 	uint32_t le_cur = 0;
 	int i;
 
-	list_iterate_items(lvl, lvs) {
+	dm_list_iterate_items(lvl, lvs) {
 		lv = lvl->lv;
 
 		if (lv->status & SNAPSHOT)
--- LVM2/lib/format_text/archive.c	2008/01/30 13:59:59	1.31
+++ LVM2/lib/format_text/archive.c	2008/11/03 22:14:28	1.32
@@ -48,7 +48,7 @@
  * with the least recent at the head.
  */
 struct archive_file {
-	struct list list;
+	struct dm_list list;
 
 	char *path;
 	uint32_t index;
@@ -87,24 +87,24 @@
 	return 1;
 }
 
-static void _insert_archive_file(struct list *head, struct archive_file *b)
+static void _insert_archive_file(struct dm_list *head, struct archive_file *b)
 {
 	struct archive_file *bf = NULL;
 
-	if (list_empty(head)) {
-		list_add(head, &b->list);
+	if (dm_list_empty(head)) {
+		dm_list_add(head, &b->list);
 		return;
 	}
 
 	/* index reduces through list */
-	list_iterate_items(bf, head) {
+	dm_list_iterate_items(bf, head) {
 		if (b->index > bf->index) {
-			list_add(&bf->list, &b->list);
+			dm_list_add(&bf->list, &b->list);
 			return;
 		}
 	}
 
-	list_add_h(&bf->list, &b->list);
+	dm_list_add_h(&bf->list, &b->list);
 }
 
 static char *_join_file_to_dir(struct dm_pool *mem, const char *dir, const char *name)
@@ -122,7 +122,7 @@
 /*
  * Returns a list of archive_files.
  */
-static struct list *_scan_archive(struct dm_pool *mem,
+static struct dm_list *_scan_archive(struct dm_pool *mem,
 				  const char *vgname, const char *dir)
 {
 	int i, count;
@@ -130,12 +130,12 @@
 	char vgname_found[64], *path;
 	struct dirent **dirent;
 	struct archive_file *af;
-	struct list *results;
+	struct dm_list *results;
 
 	if (!(results = dm_pool_alloc(mem, sizeof(*results))))
 		return_NULL;
 
-	list_init(results);
+	dm_list_init(results);
 
 	/* Sort fails beyond 5-digit indexes */
 	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
@@ -186,7 +186,7 @@
 	return results;
 }
 
-static void _remove_expired(struct list *archives, uint32_t archives_size,
+static void _remove_expired(struct dm_list *archives, uint32_t archives_size,
 			    uint32_t retain_days, uint32_t min_archive)
 {
 	struct archive_file *bf;
@@ -202,7 +202,7 @@
 	retain_time = time(NULL) - (time_t) retain_days *SECS_PER_DAY;
 
 	/* Assume list is ordered newest first (by index) */
-	list_iterate_back_items(bf, archives) {
+	dm_list_iterate_back_items(bf, archives) {
 		/* Get the mtime of the file and unlink if too old */
 		if (stat(bf->path, &sb)) {
 			log_sys_error("stat", bf->path);
@@ -231,7 +231,7 @@
 	struct archive_file *last;
 	FILE *fp = NULL;
 	char temp_file[PATH_MAX], archive_name[PATH_MAX];
-	struct list *archives;
+	struct dm_list *archives;
 
 	/*
 	 * Write the vg out to a temporary file.
@@ -263,10 +263,10 @@
 	if (!(archives = _scan_archive(vg->cmd->mem, vg->name, dir)))
 		return_0;
 
-	if (list_empty(archives))
+	if (dm_list_empty(archives))
 		ix = 0;
 	else {
-		last = list_item(list_first(archives), struct archive_file);
+		last = dm_list_item(dm_list_first(archives), struct archive_file);
 		ix = last->index + 1;
 	}
 
@@ -286,7 +286,7 @@
 	if (!renamed)
 		log_error("Archive rename failed for %s", temp_file);
 
-	_remove_expired(archives, list_size(archives) + renamed, retain_days,
+	_remove_expired(archives, dm_list_size(archives) + renamed, retain_days,
 			min_archive);
 
 	return 1;
@@ -331,16 +331,16 @@
 
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
 {
-	struct list *archives;
+	struct dm_list *archives;
 	struct archive_file *af;
 
 	if (!(archives = _scan_archive(cmd->mem, vgname, dir)))
 		return_0;
 
-	if (list_empty(archives))
+	if (dm_list_empty(archives))
 		log_print("No archives found in %s.", dir);
 
-	list_iterate_back_items(af, archives)
+	dm_list_iterate_back_items(af, archives)
 		_display_archive(cmd, af);
 
 	dm_pool_free(cmd->mem, archives);
--- LVM2/lib/format_text/archiver.c	2008/09/19 06:41:58	1.14
+++ LVM2/lib/format_text/archiver.c	2008/11/03 22:14:28	1.15
@@ -261,7 +261,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(mda, &tf->metadata_areas) {
+	dm_list_iterate_items(mda, &tf->metadata_areas) {
 		if (!(vg = mda->ops->vg_read(tf, vg_name, mda)))
 			stack;
 		break;
@@ -291,7 +291,7 @@
 	}
 
 	/* Add any metadata areas on the PVs */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("PV %s missing from cache",
@@ -366,7 +366,7 @@
 	}
 
 	/* Write and commit the metadata area */
-	list_iterate_items(mda, &tf->metadata_areas) {
+	dm_list_iterate_items(mda, &tf->metadata_areas) {
 		if (!(r = mda->ops->vg_write(tf, vg, mda))) {
 			stack;
 			continue;
--- LVM2/lib/format_text/export.c	2008/07/10 11:30:57	1.64
+++ LVM2/lib/format_text/export.c	2008/11/03 22:14:28	1.65
@@ -349,7 +349,7 @@
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
 
-	if (!list_empty(&vg->tags)) {
+	if (!dm_list_empty(&vg->tags)) {
 		if (!print_tags(&vg->tags, buffer, sizeof(buffer)))
 			return_0;
 		outf(f, "tags = %s", buffer);
@@ -395,7 +395,7 @@
 	outf(f, "physical_volumes {");
 	_inc_indent(f);
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
 		if (!(name = _get_pv_name(f, pv)))
@@ -424,7 +424,7 @@
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
 			return_0;
 
-		if (!list_empty(&pv->tags)) {
+		if (!dm_list_empty(&pv->tags)) {
 			if (!print_tags(&pv->tags, buffer, sizeof(buffer)))
 				return_0;
 			outf(f, "tags = %s", buffer);
@@ -463,7 +463,7 @@
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
-	if (!list_empty(&seg->tags)) {
+	if (!dm_list_empty(&seg->tags)) {
 		if (!print_tags(&seg->tags, buffer, sizeof(buffer)))
 			return_0;
 		outf(f, "tags = %s", buffer);
@@ -535,7 +535,7 @@
 	if (!_print_flag_config(f, lv->status, LV_FLAGS))
 		return_0;
 
-	if (!list_empty(&lv->tags)) {
+	if (!dm_list_empty(&lv->tags)) {
 		if (!print_tags(&lv->tags, buffer, sizeof(buffer)))
 			return_0;
 		outf(f, "tags = %s", buffer);
@@ -560,11 +560,11 @@
 		outf(f, "major = %d", lv->major);
 	if (lv->minor >= 0)
 		outf(f, "minor = %d", lv->minor);
-	outf(f, "segment_count = %u", list_size(&lv->segments));
+	outf(f, "segment_count = %u", dm_list_size(&lv->segments));
 	outnl(f);
 
 	seg_count = 1;
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!_print_segment(f, lv->vg, seg_count++, seg))
 			return_0;
 	}
@@ -582,7 +582,7 @@
 	/*
 	 * Don't bother with an lv section if there are no lvs.
 	 */
-	if (list_empty(&vg->lvs))
+	if (dm_list_empty(&vg->lvs))
 		return 1;
 
 	outf(f, "logical_volumes {");
@@ -591,14 +591,14 @@
 	/*
 	 * Write visible LVs first
 	 */
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!(lvl->lv->status & VISIBLE_LV))
 			continue;
 		if (!_print_lv(f, lvl->lv))
 			return_0;
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if ((lvl->lv->status & VISIBLE_LV))
 			continue;
 		if (!_print_lv(f, lvl->lv))
@@ -629,7 +629,7 @@
 	if (!(f->pv_names = dm_hash_create(128)))
 		return_0;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
 		/* FIXME But skip if there's already an LV called pv%d ! */
--- LVM2/lib/format_text/format-text.c	2008/10/17 00:55:46	1.97
+++ LVM2/lib/format_text/format-text.c	2008/11/03 22:14:28	1.98
@@ -50,12 +50,12 @@
 };
 
 struct dir_list {
-	struct list list;
+	struct dm_list list;
 	char dir[0];
 };
 
 struct raw_list {
-	struct list list;
+	struct dm_list list;
 	struct device_area dev_area;
 };
 
@@ -96,7 +96,7 @@
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs)
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (pvl->pv->dev == mdac->area.dev)
 			return 1;
 
@@ -518,7 +518,7 @@
 	int noprecommit = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
 			break;
@@ -626,7 +626,7 @@
 	int noprecommit = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
 			break;
@@ -718,7 +718,7 @@
 	int found = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
 			break;
@@ -981,7 +981,7 @@
 {
 	struct dirent *dirent;
 	struct dir_list *dl;
-	struct list *dir_list;
+	struct dm_list *dir_list;
 	char *tmp;
 	DIR *d;
 	struct volume_group *vg;
@@ -991,7 +991,7 @@
 
 	dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
-	list_iterate_items(dl, dir_list) {
+	dm_list_iterate_items(dl, dir_list) {
 		if (!(d = opendir(dl->dir))) {
 			log_sys_error("opendir", dl->dir);
 			continue;
@@ -1126,7 +1126,7 @@
 static int _scan_raw(const struct format_type *fmt)
 {
 	struct raw_list *rl;
-	struct list *raw_list;
+	struct dm_list *raw_list;
 	const char *vgname;
 	struct volume_group *vg;
 	struct format_instance fid;
@@ -1136,9 +1136,9 @@
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
 	fid.fmt = fmt;
-	list_init(&fid.metadata_areas);
+	dm_list_init(&fid.metadata_areas);
 
-	list_iterate_items(rl, raw_list) {
+	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
 		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
@@ -1161,7 +1161,7 @@
 static int _mda_setup(const struct format_type *fmt,
 		      uint64_t pe_start, uint64_t pe_end,
 		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize, struct list *mdas,
+		      uint64_t pvmetadatasize, struct dm_list *mdas,
 		      struct physical_volume *pv,
 		      struct volume_group *vg __attribute((unused)))
 {
@@ -1289,7 +1289,7 @@
 /* Only for orphans */
 /* Set label_sector to -1 if rewriting existing label into same sector */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct list *mdas, int64_t label_sector)
+		     struct dm_list *mdas, int64_t label_sector)
 {
 	struct label *label;
 	struct lvmcache_info *info;
@@ -1318,8 +1318,8 @@
 		if (info->mdas.n)
 			del_mdas(&info->mdas);
 		else
-			list_init(&info->mdas);
-		list_iterate_items(mda, mdas) {
+			dm_list_init(&info->mdas);
+		dm_list_iterate_items(mda, mdas) {
 			mdac = mda->metadata_locn;
 			log_debug("Creating metadata area on %s at sector %"
 				  PRIu64 " size %" PRIu64 " sectors",
@@ -1331,18 +1331,18 @@
 		}
 		/* FIXME Temporary until mda creation supported by tools */
 	} else if (!info->mdas.n) {
-		list_init(&info->mdas);
+		dm_list_init(&info->mdas);
 	}
 
 	if (info->das.n)
 		del_das(&info->das);
 	else
-		list_init(&info->das);
+		dm_list_init(&info->das);
 
 	/* Set pe_start to first aligned sector after any metadata
 	 * areas that begin before pe_start */
 	pv->pe_start = pe_align(pv);
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
 		    (mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) &&
@@ -1362,7 +1362,7 @@
 	if (!dev_open(pv->dev))
 		return_0;
 
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = mda->metadata_locn;
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
@@ -1385,12 +1385,12 @@
 	return 1;
 }
 
-static int _add_raw(struct list *raw_list, struct device_area *dev_area)
+static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
 {
 	struct raw_list *rl;
 
 	/* Already present? */
-	list_iterate_items(rl, raw_list) {
+	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME Check size/overlap consistency too */
 		if (rl->dev_area.dev == dev_area->dev &&
 		    rl->dev_area.start == dev_area->start)
@@ -1402,7 +1402,7 @@
 		return 0;
 	}
 	memcpy(&rl->dev_area, dev_area, sizeof(*dev_area));
-	list_add(raw_list, &rl->list);
+	dm_list_add(raw_list, &rl->list);
 
 	return 1;
 }
@@ -1444,20 +1444,20 @@
 	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
 
 	/* Currently only support exactly one data area */
-	if (list_size(&info->das) != 1) {
+	if (dm_list_size(&info->das) != 1) {
 		log_error("Must be exactly one data area (found %d) on PV %s",
-			  list_size(&info->das), dev_name(info->dev));
+			  dm_list_size(&info->das), dev_name(info->dev));
 		return 0;
 	}
 
-	list_iterate_items(da, &info->das)
+	dm_list_iterate_items(da, &info->das)
 		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 
 	return 1;
 }
 
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct list *mdas)
+		    struct physical_volume *pv, struct dm_list *mdas)
 {
 	struct label *label;
 	struct device *dev;
@@ -1479,7 +1479,7 @@
 		return 1;
 
 	/* Add copy of mdas to supplied list */
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (!(mda_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda_new)))) {
 			log_error("metadata_area allocation failed");
@@ -1492,7 +1492,7 @@
 		memcpy(mda_new, mda, sizeof(*mda));
 		memcpy(mdac_new, mdac, sizeof(*mdac));
 		mda_new->metadata_locn = mdac_new;
-		list_add(mdas, &mda_new->list);
+		dm_list_add(mdas, &mda_new->list);
 	}
 
 	return 1;
@@ -1503,22 +1503,22 @@
 	return;
 }
 
-static void _free_dirs(struct list *dir_list)
+static void _free_dirs(struct dm_list *dir_list)
 {
-	struct list *dl, *tmp;
+	struct dm_list *dl, *tmp;
 
-	list_iterate_safe(dl, tmp, dir_list) {
-		list_del(dl);
+	dm_list_iterate_safe(dl, tmp, dir_list) {
+		dm_list_del(dl);
 		dm_free(dl);
 	}
 }
 
-static void _free_raws(struct list *raw_list)
+static void _free_raws(struct dm_list *raw_list)
 {
-	struct list *rl, *tmp;
+	struct dm_list *rl, *tmp;
 
-	list_iterate_safe(rl, tmp, raw_list) {
-		list_del(rl);
+	dm_list_iterate_safe(rl, tmp, raw_list) {
+		dm_list_del(rl);
 		dm_free(rl);
 	}
 }
@@ -1567,12 +1567,12 @@
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     int pvmetadatacopies,
-		     uint64_t pvmetadatasize, struct list *mdas,
+		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
 {
 	struct metadata_area *mda, *mda_new, *mda2;
 	struct mda_context *mdac, *mdac_new, *mdac2;
-	struct list *pvmdas;
+	struct dm_list *pvmdas;
 	struct lvmcache_info *info;
 	int found;
 	uint64_t pe_end = 0;
@@ -1588,7 +1588,7 @@
 		/* Iterate through all mdas on this PV */
 		if ((info = info_from_pvid(pv->dev->pvid, 0))) {
 			pvmdas = &info->mdas;
-			list_iterate_items(mda, pvmdas) {
+			dm_list_iterate_items(mda, pvmdas) {
 				mda_count++;
 				mdac =
 				    (struct mda_context *) mda->metadata_locn;
@@ -1601,7 +1601,7 @@
 
 				/* Ensure it isn't already on list */
 				found = 0;
-				list_iterate_items(mda2, mdas) {
+				dm_list_iterate_items(mda2, mdas) {
 					if (mda2->ops !=
 					    &_metadata_text_raw_ops) continue;
 					mdac2 =
@@ -1628,7 +1628,7 @@
 				memcpy(mda_new, mda, sizeof(*mda));
 				memcpy(mdac_new, mdac, sizeof(*mdac));
 				mda_new->metadata_locn = mdac_new;
-				list_add(mdas, &mda_new->list);
+				dm_list_add(mdas, &mda_new->list);
 			}
 		}
 
@@ -1678,7 +1678,7 @@
 	struct mda_context *mdac, *mdac_new;
 	struct dir_list *dl;
 	struct raw_list *rl;
-	struct list *dir_list, *raw_list, *mdas;
+	struct dm_list *dir_list, *raw_list, *mdas;
 	char path[PATH_MAX];
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -1698,18 +1698,18 @@
 	fid->private = (void *) fidtc;
 
 	fid->fmt = fmt;
-	list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas);
 
 	if (!vgname) {
 		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
-		list_add(&fid->metadata_areas, &mda->list);
+		dm_list_add(&fid->metadata_areas, &mda->list);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
-		list_iterate_items(dl, dir_list) {
+		dm_list_iterate_items(dl, dir_list) {
 			if (dm_snprintf(path, PATH_MAX, "%s/%s",
 					 dl->dir, vgname) < 0) {
 				log_error("Name too long %s/%s", dl->dir,
@@ -1722,12 +1722,12 @@
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
-			list_add(&fid->metadata_areas, &mda->list);
+			dm_list_add(&fid->metadata_areas, &mda->list);
 		}
 
 		raw_list = &((struct mda_lists *) fmt->private)->raws;
 
-		list_iterate_items(rl, raw_list) {
+		dm_list_iterate_items(rl, raw_list) {
 			/* FIXME Cache this; rescan below if some missing */
 			if (!_raw_holds_vgname(fid, &rl->dev_area, vgname))
 				continue;
@@ -1742,16 +1742,16 @@
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
-			list_add(&fid->metadata_areas, &mda->list);
+			dm_list_add(&fid->metadata_areas, &mda->list);
 		}
 
 		/* Scan PVs in VG for any further MDAs */
 		lvmcache_label_scan(fmt->cmd, 0);
 		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 			goto_out;
-		list_iterate_items(info, &vginfo->infos) {
+		dm_list_iterate_items(info, &vginfo->infos) {
 			mdas = &info->mdas;
-			list_iterate_items(mda, mdas) {
+			dm_list_iterate_items(mda, mdas) {
 				mdac =
 				    (struct mda_context *) mda->metadata_locn;
 
@@ -1767,7 +1767,7 @@
 				memcpy(mda_new, mda, sizeof(*mda));
 				memcpy(mdac_new, mdac, sizeof(*mdac));
 				mda_new->metadata_locn = mdac_new;
-				list_add(&fid->metadata_areas, &mda_new->list);
+				dm_list_add(&fid->metadata_areas, &mda_new->list);
 			}
 		}
 		/* FIXME Check raw metadata area count - rescan if required */
@@ -1827,18 +1827,18 @@
 	.destroy = _text_destroy
 };
 
-static int _add_dir(const char *dir, struct list *dir_list)
+static int _add_dir(const char *dir, struct dm_list *dir_list)
 {
 	struct dir_list *dl;
 
 	if (dm_create_dir(dir)) {
-		if (!(dl = dm_malloc(sizeof(struct list) + strlen(dir) + 1))) {
+		if (!(dl = dm_malloc(sizeof(struct dm_list) + strlen(dir) + 1))) {
 			log_error("_add_dir allocation failed");
 			return 0;
 		}
 		log_very_verbose("Adding text format metadata dir: %s", dir);
 		strcpy(dl->dir, dir);
-		list_add(dir_list, &dl->list);
+		dm_list_add(dir_list, &dl->list);
 		return 1;
 	}
 
@@ -1846,7 +1846,7 @@
 }
 
 static int _get_config_disk_area(struct cmd_context *cmd,
-				 struct config_node *cn, struct list *raw_list)
+				 struct config_node *cn, struct dm_list *raw_list)
 {
 	struct device_area dev_area;
 	char *id_str;
@@ -1922,8 +1922,8 @@
 		return NULL;
 	}
 
-	list_init(&mda_lists->dirs);
-	list_init(&mda_lists->raws);
+	dm_list_init(&mda_lists->dirs);
+	dm_list_init(&mda_lists->raws);
 	mda_lists->file_ops = &_metadata_text_file_ops;
 	mda_lists->raw_ops = &_metadata_text_raw_ops;
 	fmt->private = (void *) mda_lists;
--- LVM2/lib/format_text/format-text.h	2008/02/06 15:47:27	1.24
+++ LVM2/lib/format_text/format-text.h	2008/11/03 22:14:28	1.25
@@ -51,13 +51,13 @@
 
 int pvhdr_read(struct device *dev, char *buf);
 
-int add_da(struct dm_pool *mem, struct list *das,
+int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size);
-void del_das(struct list *das);
+void del_das(struct dm_list *das);
 
-int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct list *mdas,
+int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size);
-void del_mdas(struct list *mdas);
+void del_mdas(struct dm_list *mdas);
 
 const char *vgname_from_mda(const struct format_type *fmt,
 			    struct device_area *dev_area, struct id *vgid,
--- LVM2/lib/format_text/import-export.h	2008/07/10 11:30:57	1.21
+++ LVM2/lib/format_text/import-export.h	2008/11/03 22:14:28	1.22
@@ -60,8 +60,8 @@
 int print_flags(uint32_t status, int type, char *buffer, size_t size);
 int read_flags(uint32_t *status, int type, struct config_value *cv);
 
-int print_tags(struct list *tags, char *buffer, size_t size);
-int read_tags(struct dm_pool *mem, struct list *tags, struct config_value *cv);
+int print_tags(struct dm_list *tags, char *buffer, size_t size);
+int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
--- LVM2/lib/format_text/import_vsn1.c	2008/09/19 06:41:58	1.54
+++ LVM2/lib/format_text/import_vsn1.c	2008/11/03 22:14:28	1.55
@@ -223,8 +223,8 @@
 		return 0;
 	}
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
+	dm_list_init(&pv->tags);
+	dm_list_init(&pv->segments);
 
 	/* Optional tags */
 	if ((cn = find_config_node(pvn, "tags")) &&
@@ -267,7 +267,7 @@
 		return_0;
 
 	vg->pv_count++;
-	list_add(&vg->pvs, &pvl->list);
+	dm_list_add(&vg->pvs, &pvl->list);
 
 	return 1;
 }
@@ -276,15 +276,15 @@
 {
 	struct lv_segment *comp;
 
-	list_iterate_items(comp, &lv->segments) {
+	dm_list_iterate_items(comp, &lv->segments) {
 		if (comp->le > seg->le) {
-			list_add(&comp->list, &seg->list);
+			dm_list_add(&comp->list, &seg->list);
 			return;
 		}
 	}
 
 	lv->le_count += seg->len;
-	list_add(&lv->segments, &seg->list);
+	dm_list_add(&lv->segments, &seg->list);
 }
 
 static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
@@ -548,10 +548,10 @@
 	}
 
 	lv->snapshot = NULL;
-	list_init(&lv->snapshot_segs);
-	list_init(&lv->segments);
-	list_init(&lv->tags);
-	list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
 
 	/* Optional tags */
 	if ((cn = find_config_node(lvn, "tags")) &&
@@ -563,7 +563,7 @@
 
 	lv->vg = vg;
 	vg->lv_count++;
-	list_add(&vg->lvs, &lvl->list);
+	dm_list_add(&vg->lvs, &lvl->list);
 
 	return 1;
 }
@@ -609,7 +609,7 @@
 	 */
 	if (lv->status & SNAPSHOT) {
 		vg->lv_count--;
-		list_del(&lvl->list);
+		dm_list_del(&lvl->list);
 		return 1;
 	}
 
@@ -758,7 +758,7 @@
 		goto bad;
 	}
 
-	list_init(&vg->pvs);
+	dm_list_init(&vg->pvs);
 	if (!_read_sections(fid, "physical_volumes", _read_pv, mem, vg,
 			    vgn, pv_hash, 0)) {
 		log_error("Couldn't find all physical volumes for volume "
@@ -766,8 +766,8 @@
 		goto bad;
 	}
 
-	list_init(&vg->lvs);
-	list_init(&vg->tags);
+	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->tags);
 
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
--- LVM2/lib/format_text/layout.h	2007/11/05 17:17:55	1.8
+++ LVM2/lib/format_text/layout.h	2008/11/03 22:14:28	1.9
@@ -29,7 +29,7 @@
 
 /* Data areas (holding PEs) */
 struct data_area_list {
-	struct list list;
+	struct dm_list list;
 	struct disk_locn disk_locn;
 };
 
@@ -67,8 +67,8 @@
 } __attribute__ ((packed));
 
 struct mda_lists {
-	struct list dirs;
-	struct list raws;
+	struct dm_list dirs;
+	struct dm_list raws;
 	struct metadata_area_ops *file_ops;
 	struct metadata_area_ops *raw_ops;
 };
--- LVM2/lib/format_text/tags.c	2008/01/30 13:59:59	1.6
+++ LVM2/lib/format_text/tags.c	2008/11/03 22:14:28	1.7
@@ -19,7 +19,7 @@
 #include "str_list.h"
 #include "lvm-string.h"
 
-int print_tags(struct list *tags, char *buffer, size_t size)
+int print_tags(struct dm_list *tags, char *buffer, size_t size)
 {
 	struct str_list *sl;
 	int first = 1;
@@ -27,7 +27,7 @@
 	if (!emit_to_buffer(&buffer, &size, "["))
 		return_0;
 
-	list_iterate_items(sl, tags) {
+	dm_list_iterate_items(sl, tags) {
 		if (!first) {
 			if (!emit_to_buffer(&buffer, &size, ", "))
 				return_0;
@@ -44,7 +44,7 @@
 	return 1;
 }
 
-int read_tags(struct dm_pool *mem, struct list *tags, struct config_value *cv)
+int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv)
 {
 	if (cv->type == CFG_EMPTY_ARRAY)
 		return 1;
--- LVM2/lib/format_text/text_label.c	2008/02/06 15:47:27	1.21
+++ LVM2/lib/format_text/text_label.c	2008/11/03 22:14:28	1.22
@@ -58,7 +58,7 @@
 	pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
 
 	/* List of data areas (holding PEs) */
-	list_iterate_items(da, &info->das) {
+	dm_list_iterate_items(da, &info->das) {
 		pvh_dlocn_xl->offset = xlate64(da->disk_locn.offset);
 		pvh_dlocn_xl->size = xlate64(da->disk_locn.size);
 		pvh_dlocn_xl++;
@@ -70,7 +70,7 @@
 	pvh_dlocn_xl++;
 
 	/* List of metadata area header locations */
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 
 		if (mdac->area.dev != info->dev)
@@ -88,7 +88,7 @@
 	return 1;
 }
 
-int add_da(struct dm_pool *mem, struct list *das,
+int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size)
 {
 	struct data_area_list *dal;
@@ -108,24 +108,24 @@
 	dal->disk_locn.offset = start;
 	dal->disk_locn.size = size;
 
-	list_add(das, &dal->list);
+	dm_list_add(das, &dal->list);
 
 	return 1;
 }
 
-void del_das(struct list *das)
+void del_das(struct dm_list *das)
 {
-	struct list *dah, *tmp;
+	struct dm_list *dah, *tmp;
 	struct data_area_list *da;
 
-	list_iterate_safe(dah, tmp, das) {
-		da = list_item(dah, struct data_area_list);
-		list_del(&da->list);
+	dm_list_iterate_safe(dah, tmp, das) {
+		da = dm_list_item(dah, struct data_area_list);
+		dm_list_del(&da->list);
 		dm_free(da);
 	}
 }
 
-int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct list *mdas,
+int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size)
 {
 /* FIXME List size restricted by pv_header SECTOR_SIZE */
@@ -165,19 +165,19 @@
 	mdac->free_sectors = UINT64_C(0);
 	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
 
-	list_add(mdas, &mdal->list);
+	dm_list_add(mdas, &mdal->list);
 	return 1;
 }
 
-void del_mdas(struct list *mdas)
+void del_mdas(struct dm_list *mdas)
 {
-	struct list *mdah, *tmp;
+	struct dm_list *mdah, *tmp;
 	struct metadata_area *mda;
 
-	list_iterate_safe(mdah, tmp, mdas) {
-		mda = list_item(mdah, struct metadata_area);
+	dm_list_iterate_safe(mdah, tmp, mdas) {
+		mda = dm_list_item(mdah, struct metadata_area);
 		dm_free(mda->metadata_locn);
-		list_del(&mda->list);
+		dm_list_del(&mda->list);
 		dm_free(mda);
 	}
 }
@@ -217,11 +217,11 @@
 
 	if (info->das.n)
 		del_das(&info->das);
-	list_init(&info->das);
+	dm_list_init(&info->das);
 
 	if (info->mdas.n)
 		del_mdas(&info->mdas);
-	list_init(&info->mdas);
+	dm_list_init(&info->mdas);
 
 	/* Data areas holding the PEs */
 	dlocn_xl = pvhdr->disk_areas_xl;
@@ -239,7 +239,7 @@
 		dlocn_xl++;
 	}
 
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
--- LVM2/lib/label/label.c	2008/09/15 17:06:55	1.44
+++ LVM2/lib/label/label.c	2008/11/03 22:14:28	1.45
@@ -30,13 +30,13 @@
  * Internal labeller struct.
  */
 struct labeller_i {
-	struct list list;
+	struct dm_list list;
 
 	struct labeller *l;
 	char name[0];
 };
 
-static struct list _labellers;
+static struct dm_list _labellers;
 
 static struct labeller_i *_alloc_li(const char *name, struct labeller *l)
 {
@@ -63,23 +63,23 @@
 
 int label_init(void)
 {
-	list_init(&_labellers);
+	dm_list_init(&_labellers);
 	return 1;
 }
 
 void label_exit(void)
 {
-	struct list *c, *n;
+	struct dm_list *c, *n;
 	struct labeller_i *li;
 
 	for (c = _labellers.n; c != &_labellers; c = n) {
 		n = c->n;
-		li = list_item(c, struct labeller_i);
+		li = dm_list_item(c, struct labeller_i);
 		li->l->ops->destroy(li->l);
 		_free_li(li);
 	}
 
-	list_init(&_labellers);
+	dm_list_init(&_labellers);
 }
 
 int label_register_handler(const char *name, struct labeller *handler)
@@ -89,7 +89,7 @@
 	if (!(li = _alloc_li(name, handler)))
 		return_0;
 
-	list_add(&_labellers, &li->list);
+	dm_list_add(&_labellers, &li->list);
 	return 1;
 }
 
@@ -97,7 +97,7 @@
 {
 	struct labeller_i *li;
 
-	list_iterate_items(li, &_labellers)
+	dm_list_iterate_items(li, &_labellers)
 		if (!strcmp(li->name, name))
 			return li->l;
 
@@ -153,7 +153,7 @@
 				continue;
 		}
 
-		list_iterate_items(li, &_labellers) {
+		dm_list_iterate_items(li, &_labellers) {
 			if (li->l->ops->can_handle(li->l, (char *) lh,
 						   sector + scan_sector)) {
 				log_very_verbose("%s: %s label detected",
@@ -228,7 +228,7 @@
 			if (xlate64(lh->sector_xl) == sector)
 				wipe = 1;
 		} else {
-			list_iterate_items(li, &_labellers) {
+			dm_list_iterate_items(li, &_labellers) {
 				if (li->l->ops->can_handle(li->l, (char *) lh,
 							   sector)) {
 					wipe = 1;
--- LVM2/lib/locking/Makefile.in	2007/09/21 10:16:44	1.3
+++ LVM2/lib/locking/Makefile.in	2008/11/03 22:14:29	1.4
@@ -19,6 +19,7 @@
 SOURCES = cluster_locking.c
 
 LIB_SHARED = liblvm2clusterlock.so
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
--- LVM2/lib/locking/file_locking.c	2008/05/09 19:26:58	1.39
+++ LVM2/lib/locking/file_locking.c	2008/11/03 22:14:29	1.40
@@ -31,12 +31,12 @@
 #include <signal.h>
 
 struct lock_list {
-	struct list list;
+	struct dm_list list;
 	int lf;
 	char *res;
 };
 
-static struct list _lock_list;
+static struct dm_list _lock_list;
 static char _lock_dir[NAME_LEN];
 
 static sig_t _oldhandler;
@@ -46,15 +46,15 @@
 static int _release_lock(const char *file, int unlock)
 {
 	struct lock_list *ll;
-	struct list *llh, *llt;
+	struct dm_list *llh, *llt;
 
 	struct stat buf1, buf2;
 
-	list_iterate_safe(llh, llt, &_lock_list) {
-		ll = list_item(llh, struct lock_list);
+	dm_list_iterate_safe(llh, llt, &_lock_list) {
+		ll = dm_list_item(llh, struct lock_list);
 
 		if (!file || !strcmp(ll->res, file)) {
-			list_del(llh);
+			dm_list_del(llh);
 			if (unlock) {
 				log_very_verbose("Unlocking %s", ll->res);
 				if (flock(ll->lf, LOCK_NB | LOCK_UN))
@@ -194,7 +194,7 @@
 			break;
 	} while (!(flags & LCK_NONBLOCK));
 
-	list_add(&_lock_list, &ll->list);
+	dm_list_add(&_lock_list, &ll->list);
 	return 1;
 
       err:
@@ -290,7 +290,7 @@
 	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
 		return 0;
 
-	list_init(&_lock_list);
+	dm_list_init(&_lock_list);
 
 	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
 		log_sys_error("sigfillset", "init_file_locking");
--- LVM2/lib/locking/locking.c	2008/10/24 01:16:16	1.51
+++ LVM2/lib/locking/locking.c	2008/11/03 22:14:29	1.52
@@ -401,27 +401,27 @@
 }
 
 /* Unlock list of LVs */
-int resume_lvs(struct cmd_context *cmd, struct list *lvs)
+int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, lvs)
+	dm_list_iterate_items(lvl, lvs)
 		resume_lv(cmd, lvl->lv);
 
 	return 1;
 }
 
 /* Lock a list of LVs */
-int suspend_lvs(struct cmd_context *cmd, struct list *lvs)
+int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 {
-	struct list *lvh;
+	struct dm_list *lvh;
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, lvs) {
+	dm_list_iterate_items(lvl, lvs) {
 		if (!suspend_lv(cmd, lvl->lv)) {
 			log_error("Failed to suspend %s", lvl->lv->name);
-			list_uniterate(lvh, lvs, &lvl->list) {
-				lvl = list_item(lvh, struct lv_list);
+			dm_list_uniterate(lvh, lvs, &lvl->list) {
+				lvl = dm_list_item(lvh, struct lv_list);
 				resume_lv(cmd, lvl->lv);
 			}
 
@@ -433,12 +433,12 @@
 }
 
 /* Lock a list of LVs */
-int activate_lvs(struct cmd_context *cmd, struct list *lvs, unsigned exclusive)
+int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive)
 {
-	struct list *lvh;
+	struct dm_list *lvh;
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, lvs) {
+	dm_list_iterate_items(lvl, lvs) {
 		if (!exclusive) {
 			if (!activate_lv(cmd, lvl->lv)) {
 				log_error("Failed to activate %s", lvl->lv->name);
@@ -446,8 +446,8 @@
 			}
 		} else if (!activate_lv_excl(cmd, lvl->lv)) {
 			log_error("Failed to activate %s", lvl->lv->name);
-			list_uniterate(lvh, lvs, &lvl->list) {
-				lvl = list_item(lvh, struct lv_list);
+			dm_list_uniterate(lvh, lvs, &lvl->list) {
+				lvl = dm_list_item(lvh, struct lv_list);
 				activate_lv(cmd, lvl->lv);
 			}
 			return 0;
--- LVM2/lib/locking/locking.h	2008/09/19 06:41:58	1.42
+++ LVM2/lib/locking/locking.h	2008/11/03 22:14:29	1.43
@@ -130,9 +130,9 @@
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
 
 /* Process list of LVs */
-int suspend_lvs(struct cmd_context *cmd, struct list *lvs);
-int resume_lvs(struct cmd_context *cmd, struct list *lvs);
-int activate_lvs(struct cmd_context *cmd, struct list *lvs, unsigned exclusive);
+int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
+int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
+int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
 
 /* Interrupt handling */
 void sigint_clear(void);
--- LVM2/lib/metadata/lv_alloc.h	2008/01/16 19:00:59	1.21
+++ LVM2/lib/metadata/lv_alloc.h	2008/11/03 22:14:29	1.22
@@ -48,9 +48,9 @@
                                       uint32_t stripes,
                                       uint32_t mirrors, uint32_t log_count,
 				      uint32_t extents,
-                                      struct list *allocatable_pvs,
+                                      struct dm_list *allocatable_pvs,
 				      alloc_policy_t alloc,
-				      struct list *parallel_areas);
+				      struct dm_list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
 		   uint32_t first_area, uint32_t num_areas,
@@ -75,7 +75,7 @@
 
 void alloc_destroy(struct alloc_handle *ah);
 
-struct list *build_parallel_areas_from_lv(struct cmd_context *cmd,
+struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
 					  struct logical_volume *lv);
 
 #endif
--- LVM2/lib/metadata/lv_manip.c	2008/10/23 11:21:04	1.158
+++ LVM2/lib/metadata/lv_manip.c	2008/11/03 22:14:29	1.159
@@ -36,7 +36,7 @@
 {
 	struct seg_list *sl;
 
-	list_iterate_items(sl, &lv->segs_using_this_lv) {
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		if (sl->seg == seg) {
 			sl->count++;
 			return 1;
@@ -53,7 +53,7 @@
 
 	sl->count = 1;
 	sl->seg = seg;
-	list_add(&lv->segs_using_this_lv, &sl->list);
+	dm_list_add(&lv->segs_using_this_lv, &sl->list);
 
 	return 1;
 }
@@ -63,7 +63,7 @@
 {
 	struct seg_list *sl;
 
-	list_iterate_items(sl, &lv->segs_using_this_lv) {
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		if (sl->seg != seg)
 			continue;
 		if (sl->count > 1)
@@ -72,7 +72,7 @@
 			log_very_verbose("%s:%" PRIu32 " is no longer a user "
 					 "of %s", seg->lv->name, seg->le,
 					 lv->name);
-			list_del(&sl->list);
+			dm_list_del(&sl->list);
 		}
 		return 1;
 	}
@@ -91,14 +91,14 @@
 {
 	struct seg_list *sl;
 
-	if (list_size(&lv->segs_using_this_lv) != 1) {
+	if (dm_list_size(&lv->segs_using_this_lv) != 1) {
 		log_error("%s is expected to have only one segment using it, "
 			  "while it has %d", lv->name,
-			  list_size(&lv->segs_using_this_lv));
+			  dm_list_size(&lv->segs_using_this_lv));
 		return NULL;
 	}
 
-	sl = list_item(list_first(&lv->segs_using_this_lv), struct seg_list);
+	sl = dm_list_item(dm_list_first(&lv->segs_using_this_lv), struct seg_list);
 
 	if (sl->count != 1) {
 		log_error("%s is expected to have only one segment using it, "
@@ -114,19 +114,19 @@
  * PVs used by a segment of an LV
  */
 struct seg_pvs {
-	struct list list;
+	struct dm_list list;
 
-	struct list pvs;	/* struct pv_list */
+	struct dm_list pvs;	/* struct pv_list */
 
 	uint32_t le;
 	uint32_t len;
 };
 
-static struct seg_pvs *_find_seg_pvs_by_le(struct list *list, uint32_t le)
+static struct seg_pvs *_find_seg_pvs_by_le(struct dm_list *list, uint32_t le)
 {
 	struct seg_pvs *spvs;
 
-	list_iterate_items(spvs, list)
+	dm_list_iterate_items(spvs, list)
 		if (le >= spvs->le && le < spvs->le + spvs->len)
 			return spvs;
 
@@ -145,7 +145,7 @@
 
 	memset(&lvnum_used, 0, sizeof(lvnum_used));
 
-	list_iterate_items(lvl, &lv->vg->lvs) {
+	dm_list_iterate_items(lvl, &lv->vg->lvs) {
 		lvnum = lvnum_from_lvid(&lvl->lv->lvid);
 		if (lvnum <= MAX_RESTRICTED_LVS)
 			lvnum_used[lvnum] = 1;
@@ -203,7 +203,7 @@
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
 	seg->log_lv = log_lv;
-	list_init(&seg->tags);
+	dm_list_init(&seg->tags);
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
 		return_NULL;
@@ -231,7 +231,7 @@
 		return NULL;
 	}
 
-	list_add(&lv->segments, &seg->list);
+	dm_list_add(&lv->segments, &seg->list);
 	lv->status |= VIRTUAL;
 
 	return seg;
@@ -407,7 +407,7 @@
 	uint32_t count = extents;
 	uint32_t reduction;
 
-	list_iterate_back_items(seg, &lv->segments) {
+	dm_list_iterate_back_items(seg, &lv->segments) {
 		if (!count)
 			break;
 
@@ -416,7 +416,7 @@
 			/* FIXME Check this is safe */
 			if (seg->log_lv && !lv_remove(seg->log_lv))
 				return_0;
-			list_del(&seg->list);
+			dm_list_del(&seg->list);
 			reduction = seg->len;
 		} else
 			reduction = count;
@@ -437,7 +437,7 @@
 		if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
 			return_0;
 
-		list_del(&lvl->list);
+		dm_list_del(&lvl->list);
 
 		if (!(lv->status & SNAPSHOT))
 			lv->vg->lv_count--;
@@ -498,7 +498,7 @@
  * A set of contiguous physical extents allocated
  */
 struct alloced_area {
-	struct list list;
+	struct dm_list list;
 
 	struct physical_volume *pv;
 	uint32_t pe;
@@ -518,10 +518,10 @@
 	uint32_t log_count;		/* Number of parallel 1-extent logs */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
-	struct list *parallel_areas;	/* PVs to avoid */
+	struct dm_list *parallel_areas;	/* PVs to avoid */
 
 	struct alloced_area log_area;	/* Extent used for log */
-	struct list alloced_areas[0];	/* Lists of areas in each stripe */
+	struct dm_list alloced_areas[0];	/* Lists of areas in each stripe */
 };
 
 static uint32_t calc_area_multiple(const struct segment_type *segtype,
@@ -543,7 +543,7 @@
 					uint32_t mirrors,
 					uint32_t stripes,
 					uint32_t log_count,
-					struct list *parallel_areas)
+					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
 	uint32_t s, area_count;
@@ -586,7 +586,7 @@
 	ah->area_multiple = calc_area_multiple(segtype, area_count);
 
 	for (s = 0; s < ah->area_count; s++)
-		list_init(&ah->alloced_areas[s]);
+		dm_list_init(&ah->alloced_areas[s]);
 
 	ah->parallel_areas = parallel_areas;
 
@@ -599,7 +599,7 @@
 		dm_pool_destroy(ah->mem);
 }
 
-static int _log_parallel_areas(struct dm_pool *mem, struct list *parallel_areas)
+static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas)
 {
 	struct seg_pvs *spvs;
 	struct pv_list *pvl;
@@ -613,8 +613,8 @@
 		return 0;
 	}
 
-	list_iterate_items(spvs, parallel_areas) {
-		list_iterate_items(pvl, &spvs->pvs) {
+	dm_list_iterate_items(spvs, parallel_areas) {
+		dm_list_iterate_items(pvl, &spvs->pvs) {
 			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
 				log_error("dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
@@ -670,7 +670,7 @@
 		if (!set_lv_segment_area_pv(seg, s, aa[s].pv, aa[s].pe))
 			return_0;
 
-	list_add(&lv->segments, &seg->list);
+	dm_list_add(&lv->segments, &seg->list);
 
 	extents = aa[0].len * area_multiple;
 	lv->le_count += extents;
@@ -683,7 +683,7 @@
 }
 
 static int _setup_alloced_segments(struct logical_volume *lv,
-				   struct list *alloced_areas,
+				   struct dm_list *alloced_areas,
 				   uint32_t area_count,
 				   uint32_t status,
 				   uint32_t stripe_size,
@@ -693,7 +693,7 @@
 {
 	struct alloced_area *aa;
 
-	list_iterate_items(aa, &alloced_areas[0]) {
+	dm_list_iterate_items(aa, &alloced_areas[0]) {
 		if (!_setup_alloced_segment(lv, status, area_count,
 					    stripe_size, segtype, aa,
 					    region_size, log_lv))
@@ -734,7 +734,7 @@
 		aa[s].pv = areas[s]->map->pv;
 		aa[s].pe = areas[s]->start;
 		aa[s].len = area_len;
-		list_add(&ah->alloced_areas[s], &aa[s].list);
+		dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 	}
 
 	ah->total_area_len += area_len;
@@ -958,7 +958,7 @@
  * Choose sets of parallel areas to use, respecting any constraints.
  */
 static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
-				struct list *pvms, struct pv_area **areas,
+				struct dm_list *pvms, struct pv_area **areas,
 				uint32_t areas_size, unsigned can_split,
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
@@ -973,7 +973,7 @@
 	uint32_t max_parallel;	/* Maximum extents to allocate */
 	uint32_t next_le;
 	struct seg_pvs *spvs;
-	struct list *parallel_pvs;
+	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
 
 	/* Is there enough total space? */
@@ -1015,7 +1015,7 @@
 		 */
 		if (ah->parallel_areas) {
 			next_le = (prev_lvseg ? prev_lvseg->le + prev_lvseg->len : 0) + *allocated / ah->area_multiple;
-			list_iterate_items(spvs, ah->parallel_areas) {
+			dm_list_iterate_items(spvs, ah->parallel_areas) {
 				if (next_le >= spvs->le + spvs->len)
 					continue;
 
@@ -1032,8 +1032,8 @@
 		 * that fits completely and we're allowed more than one
 		 * LV segment, then take the largest remaining instead.
 		 */
-		list_iterate_items(pvm, pvms) {
-			if (list_empty(&pvm->areas))
+		dm_list_iterate_items(pvm, pvms) {
+			if (dm_list_empty(&pvm->areas))
 				continue;	/* Next PV */
 
 			if (alloc != ALLOC_ANYWHERE) {
@@ -1044,14 +1044,14 @@
 
 				/* Avoid PVs used by existing parallel areas */
 				if (parallel_pvs)
-					list_iterate_items(pvl, parallel_pvs)
+					dm_list_iterate_items(pvl, parallel_pvs)
 						if (pvm->pv == pvl->pv)
 							goto next_pv;
 			}
 
 			already_found_one = 0;
 			/* First area in each list is the largest */
-			list_iterate_items(pva, &pvm->areas) {
+			dm_list_iterate_items(pva, &pvm->areas) {
 				if (contiguous) {
 					if (prev_lvseg &&
 					    _check_contiguous(ah->cmd,
@@ -1137,14 +1137,14 @@
 		     struct logical_volume *lv,
 		     uint32_t new_extents,
 		     unsigned can_split,
-		     struct list *allocatable_pvs)
+		     struct dm_list *allocatable_pvs)
 {
 	struct pv_area **areas;
 	uint32_t allocated = lv ? lv->le_count : 0;
 	uint32_t old_allocated;
 	struct lv_segment *prev_lvseg = NULL;
 	int r = 0;
-	struct list *pvms;
+	struct dm_list *pvms;
 	uint32_t areas_size;
 	alloc_policy_t alloc;
 
@@ -1156,8 +1156,8 @@
 	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
 
-	if (lv && !list_empty(&lv->segments))
-		prev_lvseg = list_item(list_last(&lv->segments),
+	if (lv && !dm_list_empty(&lv->segments))
+		prev_lvseg = dm_list_item(dm_list_last(&lv->segments),
 				       struct lv_segment);
 	/*
 	 * Build the sets of available areas on the pv's.
@@ -1168,7 +1168,7 @@
 	if (!_log_parallel_areas(ah->mem, ah->parallel_areas))
 		stack;
 
-	areas_size = list_size(pvms);
+	areas_size = dm_list_size(pvms);
 	if (areas_size && areas_size < (ah->area_count + ah->log_count)) {
 		if (ah->alloc != ALLOC_ANYWHERE) {
 			log_error("Not enough PVs with free space available "
@@ -1238,7 +1238,7 @@
 		return 0;
 	}
 
-	list_add(&lv->segments, &seg->list);
+	dm_list_add(&lv->segments, &seg->list);
 
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents *lv->vg->extent_size;
@@ -1257,9 +1257,9 @@
 				      uint32_t stripes,
 				      uint32_t mirrors, uint32_t log_count,
 				      uint32_t extents,
-				      struct list *allocatable_pvs,
+				      struct dm_list *allocatable_pvs,
 				      alloc_policy_t alloc,
-				      struct list *parallel_areas)
+				      struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
 
@@ -1375,8 +1375,8 @@
 		if (!move_lv_segment_area(newseg, s, seg, s))
 			return_NULL;
 
-	list_add(&seg->list, &newseg->list);
-	list_del(&seg->list);
+	dm_list_add(&seg->list, &newseg->list);
+	dm_list_del(&seg->list);
 
 	return newseg;
 }
@@ -1393,7 +1393,7 @@
 	uint32_t current_le = le;
 	uint32_t s, old_area_count, new_area_count;
 
-	list_iterate_items(aa, &ah->alloced_areas[0]) {
+	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(lv, current_le))) {
 			log_error("Failed to find segment for %s extent %"
 				  PRIu32, lv->name, current_le);
@@ -1452,7 +1452,7 @@
 
 	seg = first_seg(lv);
 
-	if (list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
+	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
 		log_error("Mirror layer must be inserted before adding mirrors");
 		return_0;
 	}
@@ -1498,7 +1498,7 @@
 {
 	struct lv_segment *seg;
 
-	if (list_size(&log_lv->segments)) {
+	if (dm_list_size(&log_lv->segments)) {
 		log_error("Log segments can only be added to an empty LV");
 		return 0;
 	}
@@ -1515,7 +1515,7 @@
 	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe))
 		return_0;
 
-	list_add(&log_lv->segments, &seg->list);
+	dm_list_add(&log_lv->segments, &seg->list);
 	log_lv->le_count += ah->log_area.len;
 	log_lv->size += (uint64_t) log_lv->le_count * log_lv->vg->extent_size;
 
@@ -1568,7 +1568,7 @@
 	      uint32_t mirrors, uint32_t extents,
 	      struct physical_volume *mirrored_pv __attribute((unused)),
 	      uint32_t mirrored_pe __attribute((unused)),
-	      uint32_t status, struct list *allocatable_pvs,
+	      uint32_t status, struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc)
 {
 	int r = 1;
@@ -1687,7 +1687,7 @@
 	struct lv_segment *seg;
 	uint32_t s;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !func(cmd, seg->log_lv, data))
 			return 0;
 		for (s = 0; s < seg->area_count; s++) {
@@ -1775,7 +1775,7 @@
 	struct lv_list *lvl;
 	int high = -1, i;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (sscanf(lvl->lv->name, format, &i) != 1)
 			continue;
 
@@ -1847,10 +1847,10 @@
 	lv->size = UINT64_C(0);
 	lv->le_count = 0;
 	lv->snapshot = NULL;
-	list_init(&lv->snapshot_segs);
-	list_init(&lv->segments);
-	list_init(&lv->tags);
-	list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
 
 	if (lvid)
 		lv->lvid = *lvid;
@@ -1864,7 +1864,7 @@
 	if (!import)
 		vg->lv_count++;
 
-	list_add(&vg->lvs, &ll->list);
+	dm_list_add(&vg->lvs, &ll->list);
 
 	return lv;
 }
@@ -1886,18 +1886,18 @@
 
 	pvl->pv = peg->pv;
 
-	list_add(&spvs->pvs, &pvl->list);
+	dm_list_add(&spvs->pvs, &pvl->list);
 
 	return 1;
 }
 
 /*
- * Construct list of segments of LVs showing which PVs they use.
+ * Construct dm_list of segments of LVs showing which PVs they use.
  */
-struct list *build_parallel_areas_from_lv(struct cmd_context *cmd,
+struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
 					  struct logical_volume *lv)
 {
-	struct list *parallel_areas;
+	struct dm_list *parallel_areas;
 	struct seg_pvs *spvs;
 	uint32_t current_le = 0;
 
@@ -1906,7 +1906,7 @@
 		return NULL;
 	}
 
-	list_init(parallel_areas);
+	dm_list_init(parallel_areas);
 
 	do {
 		if (!(spvs = dm_pool_zalloc(cmd->mem, sizeof(*spvs)))) {
@@ -1914,12 +1914,12 @@
 			return NULL;
 		}
 
-		list_init(&spvs->pvs);
+		dm_list_init(&spvs->pvs);
 
 		spvs->le = current_le;
 		spvs->len = lv->le_count - current_le;
 
-		list_add(parallel_areas, &spvs->list);
+		dm_list_add(parallel_areas, &spvs->list);
 
 		/* Find next segment end */
 		/* FIXME Unnecessary nesting! */
@@ -2054,12 +2054,12 @@
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
 				const force_t force)
 {
-	struct list *snh, *snht;
+	struct dm_list *snh, *snht;
 
         if (lv_is_origin(lv)) {
 		/* remove snapshot LVs first */
-		list_iterate_safe(snh, snht, &lv->snapshot_segs) {
-			if (!lv_remove_with_dependencies(cmd, list_struct_base(snh, struct lv_segment,
+		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
+			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
 									       origin_list)->cow,
 							 force))
 				return 0;
@@ -2078,7 +2078,7 @@
  * is used to find the lowest-level segment boundaries.
  */
 static int _split_parent_area(struct lv_segment *seg, uint32_t s,
-			      struct list *layer_seg_pvs)
+			      struct dm_list *layer_seg_pvs)
 {
 	uint32_t parent_area_len, parent_le, layer_le;
 	uint32_t area_multiple;
@@ -2132,19 +2132,19 @@
 	struct logical_volume *parent_lv;
 	struct lv_segment *seg;
 	uint32_t s;
-	struct list *parallel_areas;
+	struct dm_list *parallel_areas;
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, layer_lv)))
 		return_0;
 
 	/* Loop through all LVs except itself */
-	list_iterate_items(lvl, &layer_lv->vg->lvs) {
+	dm_list_iterate_items(lvl, &layer_lv->vg->lvs) {
 		parent_lv = lvl->lv;
 		if (parent_lv == layer_lv)
 			continue;
 
 		/* Find all segments that point at the layer LV */
-		list_iterate_items(seg, &parent_lv->segments) {
+		dm_list_iterate_items(seg, &parent_lv->segments) {
 			for (s = 0; s < seg->area_count; s++) {
 				if (seg_type(seg, s) != AREA_LV ||
 				    seg_lv(seg, s) != layer_lv)
@@ -2163,7 +2163,7 @@
 int remove_layers_for_segments(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       struct logical_volume *layer_lv,
-			       uint32_t status_mask, struct list *lvs_changed)
+			       uint32_t status_mask, struct dm_list *lvs_changed)
 {
 	struct lv_segment *seg, *lseg;
 	uint32_t s;
@@ -2174,7 +2174,7 @@
 			 layer_lv->name, lv->name);
 
 	/* Find all segments that point at the temporary mirror */
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV ||
 			    seg_lv(seg, s) != layer_lv)
@@ -2230,7 +2230,7 @@
 					return 0;
 				}
 				lvl->lv = lv;
-				list_add(lvs_changed, &lvl->list);
+				dm_list_add(lvs_changed, &lvl->list);
 				lv_changed = 1;
 			}
 		}
@@ -2245,13 +2245,13 @@
 int remove_layers_for_segments_all(struct cmd_context *cmd,
 				   struct logical_volume *layer_lv,
 				   uint32_t status_mask,
-				   struct list *lvs_changed)
+				   struct dm_list *lvs_changed)
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv1;
 
 	/* Loop through all LVs except the temporary mirror */
-	list_iterate_items(lvl, &layer_lv->vg->lvs) {
+	dm_list_iterate_items(lvl, &layer_lv->vg->lvs) {
 		lv1 = lvl->lv;
 		if (lv1 == layer_lv)
 			continue;
@@ -2273,7 +2273,7 @@
 {
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv_to->segments) {
+	dm_list_iterate_items(seg, &lv_to->segments) {
 		if (seg->origin) {
 			log_error("Can't move snapshot segment");
 			return 0;
@@ -2284,13 +2284,13 @@
 	lv_to->segments.n->p = &lv_to->segments;
 	lv_to->segments.p->n = &lv_to->segments;
 
-	list_iterate_items(seg, &lv_to->segments) {
+	dm_list_iterate_items(seg, &lv_to->segments) {
 		seg->lv = lv_to;
 		seg->status &= ~reset_status;
 		seg->status |= set_status;
 	}
 
-	list_init(&lv_from->segments);
+	dm_list_init(&lv_from->segments);
 
 	lv_to->le_count = lv_from->le_count;
 	lv_to->size = lv_from->size;
@@ -2322,7 +2322,7 @@
 	 * Before removal, the layer should be cleaned up,
 	 * i.e. additional segments and areas should have been removed.
 	 */
-	if (list_size(&parent->segments) != 1 ||
+	if (dm_list_size(&parent->segments) != 1 ||
 	    parent_seg->area_count != 1 ||
 	    seg_type(parent_seg, 0) != AREA_LV ||
 	    layer_lv != seg_lv(parent_seg, 0) ||
@@ -2428,7 +2428,7 @@
 		return_NULL;
 
 	/* add the new segment to the layer LV */
-	list_add(&lv_where->segments, &mapseg->list);
+	dm_list_add(&lv_where->segments, &mapseg->list);
 	lv_where->le_count = layer_lv->le_count;
 	lv_where->size = lv_where->le_count * lv_where->vg->extent_size;
 
@@ -2471,7 +2471,7 @@
 		return_0;
 
 	/* add the new segment to the layer LV */
-	list_add(&layer_lv->segments, &mapseg->list);
+	dm_list_add(&layer_lv->segments, &mapseg->list);
 	layer_lv->le_count += seg->area_len;
 	layer_lv->size += seg->area_len * layer_lv->vg->extent_size;
 
@@ -2502,7 +2502,7 @@
 	pe_start = seg_pe(seg, s);
 
 	/* Do these PEs match to any of the PEs in pvl? */
-	list_iterate_items(per, pvl->pe_ranges) {
+	dm_list_iterate_items(per, pvl->pe_ranges) {
 		per_end = per->start + per->count - 1;
 
 		if ((pe_start < per->start) || (pe_start > per_end))
@@ -2535,14 +2535,14 @@
 		return 1;
 
 	/* Split LV segments to match PE ranges */
-	list_iterate_items(seg, &lv_where->segments) {
+	dm_list_iterate_items(seg, &lv_where->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_PV ||
 			    seg_dev(seg, s) != pvl->pv->dev)
 				continue;
 
 			/* Do these PEs match with the condition? */
-			list_iterate_items(per, pvl->pe_ranges) {
+			dm_list_iterate_items(per, pvl->pe_ranges) {
 				pe_start = seg_pe(seg, s);
 				pe_end = pe_start + seg->area_len - 1;
 				per_end = per->start + per->count - 1;
@@ -2589,7 +2589,7 @@
 				    struct logical_volume *layer_lv,
 				    uint32_t status,
 				    struct pv_list *pvl,
-				    struct list *lvs_changed)
+				    struct dm_list *lvs_changed)
 {
 	struct lv_segment *seg;
 	struct lv_list *lvl;
@@ -2604,7 +2604,7 @@
 		return_0;
 
 	/* Work through all segments on the supplied PV */
-	list_iterate_items(seg, &lv_where->segments) {
+	dm_list_iterate_items(seg, &lv_where->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (!_match_seg_area_to_pe_range(seg, s, pvl))
 				continue;
@@ -2616,7 +2616,7 @@
 					return 0;
 				}
 				lvl->lv = lv_where;
-				list_add(lvs_changed, &lvl->list);
+				dm_list_add(lvs_changed, &lvl->list);
 				lv_used = 1;
 			}
 
--- LVM2/lib/metadata/merge.c	2008/02/22 13:22:44	1.35
+++ LVM2/lib/metadata/merge.c	2008/11/03 22:14:29	1.36
@@ -37,17 +37,17 @@
 
 int lv_merge_segments(struct logical_volume *lv)
 {
-	struct list *segh, *t;
+	struct dm_list *segh, *t;
 	struct lv_segment *current, *prev = NULL;
 
 	if (lv->status & LOCKED || lv->status & PVMOVE)
 		return 1;
 
-	list_iterate_safe(segh, t, &lv->segments) {
-		current = list_item(segh, struct lv_segment);
+	dm_list_iterate_safe(segh, t, &lv->segments) {
+		current = dm_list_item(segh, struct lv_segment);
 
 		if (_merge(prev, current))
-			list_del(&current->list);
+			dm_list_del(&current->list);
 		else
 			prev = current;
 	}
@@ -67,7 +67,7 @@
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
 		if (seg->le != le) {
 			log_error("LV %s invalid: segment %u should begin at "
@@ -175,7 +175,7 @@
 				}
  */
 				seg_found = 0;
-				list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv)
+				dm_list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv)
 					if (sl->seg == seg)
 						seg_found++;
 				if (!seg_found) {
@@ -198,7 +198,7 @@
 		le += seg->len;
 	}
 
-	list_iterate_items(sl, &lv->segs_using_this_lv) {
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		seg = sl->seg;
 		seg_found = 0;
 		for (s = 0; s < seg->area_count; s++) {
@@ -226,7 +226,7 @@
 		}
 
 		seg_found = 0;
-		list_iterate_items(seg2, &seg->lv->segments)
+		dm_list_iterate_items(seg2, &seg->lv->segments)
 			if (sl->seg == seg2) {
 				seg_found++;
 				break;
@@ -334,7 +334,7 @@
 	}
 
 	/* Add split off segment to the list _after_ the original one */
-	list_add_h(&seg->list, &split_seg->list);
+	dm_list_add_h(&seg->list, &split_seg->list);
 
 	return 1;
 }
--- LVM2/lib/metadata/metadata-exported.h	2008/09/25 15:57:02	1.54
+++ LVM2/lib/metadata/metadata-exported.h	2008/11/03 22:14:29	1.55
@@ -134,7 +134,7 @@
 struct labeller;
 
 struct format_type {
-	struct list list;
+	struct dm_list list;
 	struct cmd_context *cmd;
 	struct format_handler *ops;
 	struct labeller *labeller;
@@ -147,7 +147,7 @@
 };
 
 struct pv_segment {
-	struct list list;	/* Member of pv->segments: ordered list
+	struct dm_list list;	/* Member of pv->segments: ordered list
 				 * covering entire data area on this PV */
 
 	struct physical_volume *pv;
@@ -177,13 +177,13 @@
 	uint32_t pe_alloc_count;
 	unsigned long pe_align;
 
-	struct list segments;	/* Ordered pv_segments covering complete PV */
-	struct list tags;
+	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
+	struct dm_list tags;
 };
 
 struct format_instance {
 	const struct format_type *fmt;
-	struct list metadata_areas;	/* e.g. metadata locations */
+	struct dm_list metadata_areas;	/* e.g. metadata locations */
 	void *private;
 };
 
@@ -208,12 +208,12 @@
 
 	/* physical volumes */
 	uint32_t pv_count;
-	struct list pvs;
+	struct dm_list pvs;
 
 	/*
 	 * logical volumes
 	 * The following relationship should always hold:
-	 * list_size(lvs) = lv_count + 2 * snapshot_count
+	 * dm_list_size(lvs) = lv_count + 2 * snapshot_count
 	 *
 	 * Snapshots consist of 2 instances of "struct logical_volume":
 	 * - cow (lv_name is visible to the user)
@@ -229,9 +229,9 @@
 	 */
 	uint32_t lv_count;
 	uint32_t snapshot_count;
-	struct list lvs;
+	struct dm_list lvs;
 
-	struct list tags;
+	struct dm_list tags;
 };
 
 /* There will be one area for each stripe */
@@ -250,7 +250,7 @@
 
 struct segment_type;
 struct lv_segment {
-	struct list list;
+	struct dm_list list;
 	struct logical_volume *lv;
 
 	const struct segment_type *segtype;
@@ -265,13 +265,13 @@
 	uint32_t area_len;
 	struct logical_volume *origin;
 	struct logical_volume *cow;
-	struct list origin_list;
+	struct dm_list origin_list;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
 	uint32_t region_size;	/* For mirrors - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
 
-	struct list tags;
+	struct dm_list tags;
 
 	struct lv_segment_area *areas;
 };
@@ -296,29 +296,29 @@
 	uint32_t le_count;
 
 	uint32_t origin_count;
-	struct list snapshot_segs;
+	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
-	struct list segments;
-	struct list tags;
-	struct list segs_using_this_lv;
+	struct dm_list segments;
+	struct dm_list tags;
+	struct dm_list segs_using_this_lv;
 };
 
 struct pe_range {
-	struct list list;
+	struct dm_list list;
 	uint32_t start;		/* PEs */
 	uint32_t count;		/* PEs */
 };
 
 struct pv_list {
-	struct list list;
+	struct dm_list list;
 	struct physical_volume *pv;
-	struct list *mdas;	/* Metadata areas */
-	struct list *pe_ranges;	/* Ranges of PEs e.g. for allocation */
+	struct dm_list *mdas;	/* Metadata areas */
+	struct dm_list *pe_ranges;	/* Ranges of PEs e.g. for allocation */
 };
 
 struct lv_list {
-	struct list list;
+	struct dm_list list;
 	struct logical_volume *lv;
 };
 
@@ -331,17 +331,17 @@
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				struct list *mdas, uint64_t *label_sector,
+				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings);
-struct list *get_pvs(struct cmd_context *cmd);
+struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
-struct list *get_vgs(struct cmd_context *cmd, int full_scan);
-struct list *get_vgids(struct cmd_context *cmd, int full_scan);
+struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan);
+struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
-	     struct list *mdas, int64_t label_sector);
+	     struct dm_list *mdas, int64_t label_sector);
 int is_pv(pv_t *pv);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(const pv_t *pv);
@@ -363,14 +363,14 @@
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
 		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize, struct list *mdas);
+		      uint64_t pvmetadatasize, struct dm_list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
              uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
 /* FIXME: move internal to library */
-uint32_t pv_list_extents_free(const struct list *pvh);
+uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
@@ -415,7 +415,7 @@
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
 	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
-	      uint32_t status, struct list *allocatable_pvs,
+	      uint32_t status, struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
@@ -438,15 +438,15 @@
 				    struct logical_volume *layer_lv,
 				    uint32_t status,
 				    struct pv_list *pv,
-				    struct list *lvs_changed);
+				    struct dm_list *lvs_changed);
 int remove_layers_for_segments(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       struct logical_volume *layer_lv,
-			       uint32_t status_mask, struct list *lvs_changed);
+			       uint32_t status_mask, struct dm_list *lvs_changed);
 int remove_layers_for_segments_all(struct cmd_context *cmd,
 				   struct logical_volume *layer_lv,
 				   uint32_t status_mask,
-				   struct list *lvs_changed);
+				   struct dm_list *lvs_changed);
 int split_parent_segments_for_layer(struct cmd_context *cmd,
 				    struct logical_volume *layer_lv);
 int remove_layer_from_lv(struct logical_volume *lv,
@@ -507,10 +507,10 @@
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
-		   struct list *pvs, alloc_policy_t alloc, uint32_t flags);
+		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
-		      struct list *pvs, uint32_t status_mask);
+		      struct dm_list *pvs, uint32_t status_mask);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
@@ -521,24 +521,24 @@
 				 uint32_t new_mirrors, uint32_t status_mask);
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 			    uint32_t mirrors, uint32_t region_size,
-			    struct list *allocatable_pvs, alloc_policy_t alloc);
+			    struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
-			 struct list *removable_pvs, unsigned remove_log);
+			 struct dm_list *removable_pvs, unsigned remove_log);
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
-		      struct list *allocatable_pvs, alloc_policy_t alloc,
+		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count);
 struct logical_volume *detach_mirror_log(struct lv_segment *seg);
 int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct list *removable_pvs);
+		      struct dm_list *removable_pvs);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
-		   struct list *allocatable_pvs, alloc_policy_t alloc);
+		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct list *removable_pvs, unsigned remove_log);
+			      struct dm_list *removable_pvs, unsigned remove_log);
 int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
@@ -551,7 +551,7 @@
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
 float copy_percent(struct logical_volume *lv_mirr);
-struct list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
+struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
 uint32_t find_free_lvnum(struct logical_volume *lv);
--- LVM2/lib/metadata/metadata.c	2008/10/03 14:22:18	1.194
+++ LVM2/lib/metadata/metadata.c	2008/11/03 22:14:29	1.195
@@ -39,7 +39,7 @@
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					const char *pv_name,
-					struct list *mdas,
+					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings);
 
@@ -50,11 +50,11 @@
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct list *mdas);
+				  uint64_t pvmetadatasize, struct dm_list *mdas);
 
 static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 		     struct physical_volume *pv,
-	     	     struct list *mdas, int64_t label_sector);
+	     	     struct dm_list *mdas, int64_t label_sector);
 
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 			 			const char *pv_name);
@@ -181,7 +181,7 @@
 		return_0;
 
 	pvl->pv = pv;
-	list_add(&vg->pvs, &pvl->list);
+	dm_list_add(&vg->pvs, &pvl->list);
 
 	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
 		log_error("Unable to add %s to %s: new extent count (%"
@@ -234,7 +234,7 @@
 		log_warn("WARNING: Volume group %s is not consistent",
 			 vg_name);
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
 			if (!_copy_pv(pv, pvl->pv))
 				return_0;
@@ -303,7 +303,7 @@
 		return 0;
 	}
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvl->pv->vg_name = dm_pool_strdup(mem, new_name))) {
 			log_error("pv->vg_name allocation failed for '%s'",
 				  pv_dev_name(pvl->pv));
@@ -318,11 +318,11 @@
 			    struct volume_group *vg,
 			    force_t force)
 {
-	struct list *lst;
+	struct dm_list *lst;
 	struct lv_list *lvl;
 
-	while ((lst = list_first(&vg->lvs))) {
-		lvl = list_item(lst, struct lv_list);
+	while ((lst = dm_list_first(&vg->lvs))) {
+		lvl = dm_list_item(lst, struct lv_list);
 		if (!lv_remove_with_dependencies(cmd, lvl->lv, force))
 		    return 0;
 	}
@@ -378,7 +378,7 @@
 	}
 
 	/* init physical volumes */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg_name);
@@ -534,14 +534,14 @@
 	vg->alloc = alloc;
 
 	vg->pv_count = 0;
-	list_init(&vg->pvs);
+	dm_list_init(&vg->pvs);
 
 	vg->lv_count = 0;
-	list_init(&vg->lvs);
+	dm_list_init(&vg->lvs);
 
 	vg->snapshot_count = 0;
 
-	list_init(&vg->tags);
+	dm_list_init(&vg->tags);
 
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
 						       NULL, NULL))) {
@@ -619,7 +619,7 @@
 		return_0;
 
 	/* foreach PV */
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
 		pv->pe_size = new_size;
@@ -632,7 +632,7 @@
 			return_0;
 
 		/* foreach free PV Segment */
-		list_iterate_items(pvseg, &pv->segments) {
+		dm_list_iterate_items(pvseg, &pv->segments) {
 			if (pvseg_is_allocated(pvseg))
 				continue;
 
@@ -648,14 +648,14 @@
 	}
 
 	/* foreach LV */
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
 		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
 				     new_size))
 			return_0;
 
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			if (!_recalc_extents(&seg->le, lv->name,
 					     " segment start", old_size,
 					     new_size))
@@ -721,13 +721,13 @@
 		  struct volume_group *vg_from, struct volume_group *vg_to)
 {
 	struct metadata_area *mda, *mda2;
-	struct list *mdas_from, *mdas_to;
+	struct dm_list *mdas_from, *mdas_to;
 	int common_mda = 0;
 
 	mdas_from = &vg_from->fid->metadata_areas;
 	mdas_to = &vg_to->fid->metadata_areas;
 
-	list_iterate_items_safe(mda, mda2, mdas_from) {
+	dm_list_iterate_items_safe(mda, mda2, mdas_from) {
 		if (!mda->ops->mda_in_vg) {
 			common_mda = 1;
 			continue;
@@ -735,14 +735,14 @@
 
 		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda)) {
 			if (is_orphan_vg(vg_to->name))
-				list_del(&mda->list);
+				dm_list_del(&mda->list);
 			else
-				list_move(mdas_to, &mda->list);
+				dm_list_move(mdas_to, &mda->list);
 		}
 	}
 
-	if (list_empty(mdas_from) ||
-	    (!is_orphan_vg(vg_to->name) && list_empty(mdas_to)))
+	if (dm_list_empty(mdas_from) ||
+	    (!is_orphan_vg(vg_to->name) && dm_list_empty(mdas_to)))
 		return common_mda;
 
 	return 1;
@@ -775,7 +775,7 @@
 		uint32_t existing_extent_count,
 		uint32_t existing_extent_size,
 		int pvmetadatacopies,
-		uint64_t pvmetadatasize, struct list *mdas)
+		uint64_t pvmetadatasize, struct dm_list *mdas)
 {
 	return _pv_create(cmd->fmt, dev, id, size, pe_start,
 			  existing_extent_count,
@@ -811,8 +811,8 @@
 
 	pv->status = ALLOCATABLE_PV;
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
+	dm_list_init(&pv->tags);
+	dm_list_init(&pv->segments);
 
 	return pv;
 }
@@ -825,7 +825,7 @@
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct list *mdas)
+				  uint64_t pvmetadatasize, struct dm_list *mdas)
 {
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
@@ -891,19 +891,19 @@
 {
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs)
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (pvl->pv->dev == dev_cache_get(pv_name, vg->cmd->filter))
 			return pvl;
 
 	return NULL;
 }
 
-struct pv_list *find_pv_in_pv_list(const struct list *pl,
+struct pv_list *find_pv_in_pv_list(const struct dm_list *pl,
 				   const struct physical_volume *pv)
 {
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, pl)
+	dm_list_iterate_items(pvl, pl)
 		if (pvl->pv == pv)
 			return pvl;
 
@@ -914,7 +914,7 @@
 {
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs)
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (pv == pvl->pv)
 			 return 1;
 
@@ -945,7 +945,7 @@
 {
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs)
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (id_equal(&pvl->pv->id, id))
 			return pvl->pv;
 
@@ -964,19 +964,19 @@
 	else
 		ptr = lv_name;
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!strcmp(lvl->lv->name, ptr))
 			return lvl;
 
 	return NULL;
 }
 
-struct lv_list *find_lv_in_lv_list(const struct list *ll,
+struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 				   const struct logical_volume *lv)
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, ll)
+	dm_list_iterate_items(lvl, ll)
 		if (lvl->lv == lv)
 			return lvl;
 
@@ -988,7 +988,7 @@
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!strncmp(lvl->lv->lvid.s, lvid->s, sizeof(*lvid)))
 			return lvl;
 
@@ -1006,7 +1006,7 @@
 {
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs)
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (dev == pvl->pv->dev)
 			return pvl->pv;
 
@@ -1054,7 +1054,7 @@
 {
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments)
 		if (le >= seg->le && le < seg->le + seg->len)
 			return seg;
 
@@ -1065,7 +1065,7 @@
 {
 	struct lv_segment *seg = NULL;
 
-	list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments)
 		break;
 
 	return seg;
@@ -1076,7 +1076,7 @@
 {
 	struct pv_segment *peg;
 
-	list_iterate_items(peg, &pv->segments)
+	dm_list_iterate_items(peg, &pv->segments)
 		if (pe >= peg->pe && pe < peg->pe + peg->len)
 			return peg;
 
@@ -1089,7 +1089,7 @@
 
 	/* FIXME Improve recovery situation? */
 	/* Remove each copy of the metadata */
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (mda->ops->vg_remove &&
 		    !mda->ops->vg_remove(vg->fid, vg, mda))
 			return_0;
@@ -1154,10 +1154,10 @@
 	}
 
 	/* Check no conflicts with LV names */
-	list_iterate_items(lvl1, &vg_to->lvs) {
+	dm_list_iterate_items(lvl1, &vg_to->lvs) {
 		name1 = lvl1->lv->name;
 
-		list_iterate_items(lvl2, &vg_from->lvs) {
+		dm_list_iterate_items(lvl2, &vg_from->lvs) {
 			name2 = lvl2->lv->name;
 
 			if (!strcmp(name1, name2)) {
@@ -1171,7 +1171,7 @@
 	}
 
 	/* Check no PVs are constructed from either VG */
-	list_iterate_items(pvl, &vg_to->pvs) {
+	dm_list_iterate_items(pvl, &vg_to->pvs) {
 		if (pv_uses_vg(pvl->pv, vg_from)) {
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
@@ -1180,7 +1180,7 @@
 		}
 	}
 
-	list_iterate_items(pvl, &vg_from->pvs) {
+	dm_list_iterate_items(pvl, &vg_from->pvs) {
 		if (pv_uses_vg(pvl->pv, vg_to)) {
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
@@ -1228,7 +1228,7 @@
 			return_0;
 	}
 
-	list_iterate_items(lvseg, &lv->segments) {
+	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
@@ -1306,7 +1306,7 @@
 	struct _lv_mark_if_partial_baton baton;
 	struct lv_segment *lvseg;
 
-	list_iterate_items(lvseg, &lv->segments) {
+	dm_list_iterate_items(lvseg, &lv->segments) {
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_PV) {
 				if (seg_pv(lvseg, s)->status & MISSING_PV)
@@ -1339,7 +1339,7 @@
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (!_lv_mark_if_partial(lv))
 			return_0;
@@ -1357,8 +1357,8 @@
 
 	/* FIXME Also check there's no data/metadata overlap */
 
-	list_iterate_items(pvl, &vg->pvs) {
-		list_iterate_items(pvl2, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		dm_list_iterate_items(pvl2, &vg->pvs) {
 			if (pvl == pvl2)
 				break;
 			if (id_equal(&pvl->pv->id,
@@ -1387,17 +1387,17 @@
 		r = 0;
 	}
 
-	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
+	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
 	    vg->lv_count + 2 * vg->snapshot_count) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
-			  list_size(&vg->lvs), vg->lv_count,
+			  dm_list_size(&vg->lvs), vg->lv_count,
 			  vg->snapshot_count, vg->name);
 		r = 0;
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
-		list_iterate_items(lvl2, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		dm_list_iterate_items(lvl2, &vg->lvs) {
 			if (lvl == lvl2)
 				break;
 			if (!strcmp(lvl->lv->name, lvl2->lv->name)) {
@@ -1420,7 +1420,7 @@
 		}
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error("Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -1444,7 +1444,7 @@
  */
 int vg_write(struct volume_group *vg)
 {
-	struct list *mdah;
+	struct dm_list *mdah;
 	struct metadata_area *mda;
 
 	if (!vg_validate(vg))
@@ -1461,7 +1461,7 @@
 		return 0;
 	}
 
-	if (list_empty(&vg->fid->metadata_areas)) {
+	if (dm_list_empty(&vg->fid->metadata_areas)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
 		return 0;
 	}
@@ -1474,13 +1474,13 @@
 	vg->seqno++;
 
 	/* Write to each copy of the metadata area */
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (!mda->ops->vg_write) {
 			log_error("Format does not support writing volume"
 				  "group metadata areas");
 			/* Revert */
-			list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
-				mda = list_item(mdah, struct metadata_area);
+			dm_list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
+				mda = dm_list_item(mdah, struct metadata_area);
 
 				if (mda->ops->vg_revert &&
 				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
@@ -1492,8 +1492,8 @@
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
 			stack;
 			/* Revert */
-			list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
-				mda = list_item(mdah, struct metadata_area);
+			dm_list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
+				mda = dm_list_item(mdah, struct metadata_area);
 
 				if (mda->ops->vg_revert &&
 				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
@@ -1505,12 +1505,12 @@
 	}
 
 	/* Now pre-commit each copy of the new metadata */
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (mda->ops->vg_precommit &&
 		    !mda->ops->vg_precommit(vg->fid, vg, mda)) {
 			stack;
 			/* Revert */
-			list_iterate_items(mda, &vg->fid->metadata_areas) {
+			dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 				if (mda->ops->vg_revert &&
 				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 					stack;
@@ -1537,7 +1537,7 @@
 	}
 
 	/* Commit to each copy of the metadata area */
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;
 		if (mda->ops->vg_commit &&
 		    !mda->ops->vg_commit(vg->fid, vg, mda)) {
@@ -1565,7 +1565,7 @@
 {
 	struct metadata_area *mda;
 
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (mda->ops->vg_revert &&
 		    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 			stack;
@@ -1598,9 +1598,9 @@
 		log_error("vg allocation failed");
 		return NULL;
 	}
-	list_init(&vg->pvs);
-	list_init(&vg->lvs);
-	list_init(&vg->tags);
+	dm_list_init(&vg->pvs);
+	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->tags);
 	vg->cmd = cmd;
 	if (!(vg->name = dm_pool_strdup(cmd->mem, orphan_vgname))) {
 		log_error("vg name allocation failed");
@@ -1616,7 +1616,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(info, &vginfo->infos) {
+	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1))) {
 			continue;
 		}
@@ -1625,19 +1625,19 @@
 			return NULL;
 		}
 		pvl->pv = pv;
-		list_add(&vg->pvs, &pvl->list);
+		dm_list_add(&vg->pvs, &pvl->list);
 		vg->pv_count++;
 	}
 
 	return vg;
 }
 
-static int _update_pv_list(struct list *all_pvs, struct volume_group *vg)
+static int _update_pv_list(struct dm_list *all_pvs, struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
 
-	list_iterate_items(pvl, &vg->pvs) {
-		list_iterate_items(pvl2, all_pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		dm_list_iterate_items(pvl2, all_pvs) {
 			if (pvl->pv->dev == pvl2->pv->dev)
 				goto next_pv;
 		}
@@ -1648,7 +1648,7 @@
 			return 0;
 		}
 		pvl2->pv = pvl->pv;
-		list_add(all_pvs, &pvl2->list);
+		dm_list_add(all_pvs, &pvl2->list);
   next_pv:
 		;
 	}
@@ -1660,7 +1660,7 @@
 {
 	int ret = 0;
 	struct pv_list *pvl;
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->status & MISSING_PV)
 			++ ret;
 	}
@@ -1692,9 +1692,9 @@
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
 	unsigned use_precommitted = precommitted;
-	struct list *pvids;
+	struct dm_list *pvids;
 	struct pv_list *pvl, *pvl2;
-	struct list all_pvs;
+	struct dm_list all_pvs;
 	char uuid[64] __attribute((aligned(8)));
 
 	if (is_orphan_vg(vgname)) {
@@ -1748,7 +1748,7 @@
 		return_NULL;
 
 	/* Ensure contents of all metadata areas match - else do recovery */
-	list_iterate_items(mda, &fid->metadata_areas) {
+	dm_list_iterate_items(mda, &fid->metadata_areas) {
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
 		    (!use_precommitted &&
@@ -1775,8 +1775,8 @@
 		 * orphans in the cache: update the cache state here.
 		 */
 		if (!inconsistent &&
-		    list_size(&correct_vg->pvs) > list_size(pvids)) {
-			list_iterate_items(pvl, &correct_vg->pvs) {
+		    dm_list_size(&correct_vg->pvs) > dm_list_size(pvids)) {
+			dm_list_iterate_items(pvl, &correct_vg->pvs) {
 				if (!pvl->pv->dev) {
 					inconsistent_pvs = 1;
 					break;
@@ -1791,7 +1791,7 @@
 				 */
 				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
 				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname) ||
-				   list_size(&info->mdas)) {
+				   dm_list_size(&info->mdas)) {
 					inconsistent_pvs = 1;
 					break;
 				}
@@ -1808,7 +1808,7 @@
 			}
 		}
 
-		if (list_size(&correct_vg->pvs) != list_size(pvids)
+		if (dm_list_size(&correct_vg->pvs) != dm_list_size(pvids)
 		    + vg_missing_pv_count(correct_vg)) {
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
@@ -1817,7 +1817,7 @@
 				inconsistent = 1;
 			else
 				correct_vg = NULL;
-		} else list_iterate_items(pvl, &correct_vg->pvs) {
+		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
 			if (pvl->pv->status & MISSING_PV)
 				continue;
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
@@ -1829,7 +1829,7 @@
 		}
 	}
 
-	list_init(&all_pvs);
+	dm_list_init(&all_pvs);
 
 	/* Failed to find VG where we expected it - full scan and retry */
 	if (!correct_vg) {
@@ -1851,7 +1851,7 @@
 		}
 
 		/* Ensure contents of all metadata areas match - else recover */
-		list_iterate_items(mda, &fid->metadata_areas) {
+		dm_list_iterate_items(mda, &fid->metadata_areas) {
 			if ((use_precommitted &&
 			     !(vg = mda->ops->vg_read_precommit(fid, vgname,
 								mda))) ||
@@ -1923,8 +1923,8 @@
 			return NULL;
 		}
 
-		list_iterate_items(pvl, &all_pvs) {
-			list_iterate_items(pvl2, &correct_vg->pvs) {
+		dm_list_iterate_items(pvl, &all_pvs) {
+			dm_list_iterate_items(pvl2, &correct_vg->pvs) {
 				if (pvl->pv->dev == pvl2->pv->dev)
 					goto next_pv;
 			}
@@ -1972,7 +1972,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error("Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -1992,7 +1992,7 @@
 					    unsigned precommitted)
 {
 	const char *vgname;
-	struct list *vgnames;
+	struct dm_list *vgnames;
 	struct volume_group *vg;
 	struct lvmcache_vginfo *vginfo;
 	struct str_list *strl;
@@ -2027,7 +2027,7 @@
 		return NULL;
 	}
 
-	list_iterate_items(strl, vgnames) {
+	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
 		if (!vgname || is_orphan_vg(vgname))
 			continue;	// FIXME Unnecessary?
@@ -2093,7 +2093,7 @@
  *   FIXME - liblvm todo - make into function that returns handle
  */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				struct list *mdas, uint64_t *label_sector,
+				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings)
 {
 	return _pv_read(cmd, pv_name, mdas, label_sector, warnings);
@@ -2102,7 +2102,7 @@
 /* FIXME Use label functions instead of PV functions */
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					const char *pv_name,
-					struct list *mdas,
+					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings)
 {
@@ -2130,8 +2130,8 @@
 		return NULL;
 	}
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
+	dm_list_init(&pv->tags);
+	dm_list_init(&pv->segments);
 
 	/* FIXME Move more common code up here */
 	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas))) {
@@ -2150,23 +2150,23 @@
 }
 
 /* May return empty list */
-struct list *get_vgs(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan)
 {
 	return lvmcache_get_vgnames(cmd, full_scan);
 }
 
-struct list *get_vgids(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan)
 {
 	return lvmcache_get_vgids(cmd, full_scan);
 }
 
-static int _get_pvs(struct cmd_context *cmd, struct list **pvslist)
+static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 {
 	struct str_list *strl;
-	struct list * uninitialized_var(results);
+	struct dm_list * uninitialized_var(results);
 	const char *vgname, *vgid;
-	struct list *pvh, *tmp;
-	struct list *vgids;
+	struct dm_list *pvh, *tmp;
+	struct dm_list *vgids;
 	struct volume_group *vg;
 	int consistent = 0;
 	int old_pvmove;
@@ -2179,7 +2179,7 @@
 			return 0;
 		}
 
-		list_init(results);
+		dm_list_init(results);
 	}
 
 	/* Get list of VGs */
@@ -2192,7 +2192,7 @@
 	/* Orphan VG is last on list */
 	old_pvmove = pvmove_mode();
 	init_pvmove(1);
-	list_iterate_items(strl, vgids) {
+	dm_list_iterate_items(strl, vgids) {
 		vgid = strl->str;
 		if (!vgid)
 			continue;	/* FIXME Unnecessary? */
@@ -2211,8 +2211,8 @@
 
 		/* Move PVs onto results list */
 		if (pvslist)
-			list_iterate_safe(pvh, tmp, &vg->pvs)
-				list_add(results, pvh);
+			dm_list_iterate_safe(pvh, tmp, &vg->pvs)
+				dm_list_add(results, pvh);
 	}
 	init_pvmove(old_pvmove);
 
@@ -2224,9 +2224,9 @@
 	return 1;
 }
 
-struct list *get_pvs(struct cmd_context *cmd)
+struct dm_list *get_pvs(struct cmd_context *cmd)
 {
-	struct list *results;
+	struct dm_list *results;
 
 	if (!_get_pvs(cmd, &results))
 		return NULL;
@@ -2242,14 +2242,14 @@
 /* FIXME: liblvm todo - make into function that takes handle */
 int pv_write(struct cmd_context *cmd __attribute((unused)),
 	     struct physical_volume *pv,
-	     struct list *mdas, int64_t label_sector)
+	     struct dm_list *mdas, int64_t label_sector)
 {
 	return _pv_write(cmd, pv, mdas, label_sector);
 }
 
 static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 		     struct physical_volume *pv,
-	     	     struct list *mdas, int64_t label_sector)
+	     	     struct dm_list *mdas, int64_t label_sector)
 {
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
@@ -2354,7 +2354,7 @@
 	 * Next, loop through metadata areas
 	 */
 	info = label->info;
-	list_iterate_items(mda, &info->mdas)
+	dm_list_iterate_items(mda, &info->mdas)
 		mda->ops->pv_analyze_mda(info->fmt, mda);
 
 	return 1;
@@ -2525,8 +2525,8 @@
  */
 pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
-	struct list mdas;
+	struct dm_list mdas;
 	
-	list_init(&mdas);
+	dm_list_init(&mdas);
 	return _pv_read(cmd, pv_name, &mdas, NULL, 1);
 }
--- LVM2/lib/metadata/metadata.h	2008/09/25 15:57:02	1.183
+++ LVM2/lib/metadata/metadata.h	2008/11/03 22:14:29	1.184
@@ -141,7 +141,7 @@
 };
 
 struct metadata_area {
-	struct list list;
+	struct dm_list list;
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
 };
@@ -152,22 +152,22 @@
 #define seg_le(seg, s)		(seg)->areas[(s)].u.lv.le
 
 struct name_list {
-	struct list list;
+	struct dm_list list;
 	char *name;
 };
 
 struct mda_list {
-	struct list list;
+	struct dm_list list;
 	struct device_area mda;
 };
 
 struct peg_list {
-	struct list list;
+	struct dm_list list;
 	struct pv_segment *peg;
 };
 
 struct seg_list {
-	struct list list;
+	struct dm_list list;
 	unsigned count;
 	struct lv_segment *seg;
 };
@@ -185,7 +185,7 @@
 	 * Return PV with given path.
 	 */
 	int (*pv_read) (const struct format_type * fmt, const char *pv_name,
-			struct physical_volume * pv, struct list * mdas);
+			struct physical_volume * pv, struct dm_list * mdas);
 
 	/*
 	 * Tweak an already filled out a pv ready for importing into a
@@ -195,7 +195,7 @@
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size,
 			 int pvmetadatacopies,
-			 uint64_t pvmetadatasize, struct list * mdas,
+			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
 
 	/*
@@ -203,7 +203,7 @@
 	 * pv->vg_name must be a valid orphan VG name
 	 */
 	int (*pv_write) (const struct format_type * fmt,
-			 struct physical_volume * pv, struct list * mdas,
+			 struct physical_volume * pv, struct dm_list * mdas,
 			 int64_t label_sector);
 
 	/*
@@ -265,7 +265,7 @@
 struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
 				      const union lvid *lvid);
 
-struct lv_list *find_lv_in_lv_list(const struct list *ll,
+struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 				   const struct logical_volume *lv);
 
 /* Return the VG that contains a given LV (based on path given in lv_name) */
@@ -280,7 +280,7 @@
 /* FIXME Merge these functions with ones above */
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);
 
-struct pv_list *find_pv_in_pv_list(const struct list *pl,
+struct pv_list *find_pv_in_pv_list(const struct dm_list *pl,
 				   const struct physical_volume *pv);
 
 /* Find LV segment containing given LE */
--- LVM2/lib/metadata/mirror.c	2008/10/17 10:50:14	1.78
+++ LVM2/lib/metadata/mirror.c	2008/11/03 22:14:29	1.79
@@ -239,7 +239,7 @@
  */
 static int _init_mirror_log(struct cmd_context *cmd,
 			    struct logical_volume *log_lv, int in_sync,
-			    struct list *tags, int remove_on_failure)
+			    struct dm_list *tags, int remove_on_failure)
 {
 	struct str_list *sl;
 	struct lvinfo info;
@@ -263,7 +263,7 @@
 	log_lv->status |= VISIBLE_LV;
 
 	/* Temporary tag mirror log for activation */
-	list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tags)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
 			goto activate_lv;
@@ -284,7 +284,7 @@
 	}
 
 	/* Remove the temporary tags */
-	list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tags)
 		if (!str_list_del(&log_lv->tags, sl->str))
 			log_error("Failed to remove tag %s from mirror log.",
 				  sl->str);
@@ -323,7 +323,7 @@
 revert_new_lv:
 	log_lv->status = orig_status;
 
-	list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tags)
 		if (!str_list_del(&log_lv->tags, sl->str))
 			log_error("Failed to remove tag %s from mirror log.",
 				  sl->str);
@@ -355,7 +355,7 @@
 
 	/* Inherit tags - maybe needed for activation */
 	if (!str_list_match_list(&mirror_lv->tags, &lv->tags)) {
-		list_iterate_items(sl, &mirror_lv->tags)
+		dm_list_iterate_items(sl, &mirror_lv->tags)
 			if (!str_list_add(cmd->mem, &lv->tags, sl->str)) {
 				log_error("Aborting. Unable to tag.");
 				return 0;
@@ -381,9 +381,9 @@
 }
 
 static int _merge_mirror_images(struct logical_volume *lv,
-				const struct list *mimages)
+				const struct dm_list *mimages)
 {
-	uint32_t addition = list_size(mimages);
+	uint32_t addition = dm_list_size(mimages);
 	struct logical_volume **img_lvs;
 	struct lv_list *lvl;
 	int i = 0;
@@ -394,7 +394,7 @@
 	if (!(img_lvs = alloca(sizeof(*img_lvs) * addition)))
 		return_0;
 
-	list_iterate_items(lvl, mimages)
+	dm_list_iterate_items(lvl, mimages)
 		img_lvs[i++] = lvl->lv;
 
 	return lv_add_mirror_lvs(lv, img_lvs, addition,
@@ -420,7 +420,7 @@
 
 /* Check if mirror image LV is removable with regard to given removable_pvs */
 static int _is_mirror_image_removable(struct logical_volume *mimage_lv,
-				      struct list *removable_pvs)
+				      struct dm_list *removable_pvs)
 {
 	struct physical_volume *pv;
 	struct lv_segment *seg;
@@ -428,7 +428,7 @@
 	struct pv_list *pvl;
 	uint32_t s;
 
-	list_iterate_items(seg, &mimage_lv->segments) {
+	dm_list_iterate_items(seg, &mimage_lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_PV) {
 				/* FIXME Recurse for AREA_LV? */
@@ -440,7 +440,7 @@
 			pv = seg_pv(seg, s);
 
 			pv_found = 0;
-			list_iterate_items(pvl, removable_pvs) {
+			dm_list_iterate_items(pvl, removable_pvs) {
 				if (pv->dev->dev == pvl->pv->dev->dev) {
 					pv_found = 1;
 					break;
@@ -481,7 +481,7 @@
  */
 static int _remove_mirror_images(struct logical_volume *lv,
 				 uint32_t num_removed,
-				 struct list *removable_pvs,
+				 struct dm_list *removable_pvs,
 				 unsigned remove_log, unsigned collapse,
 				 uint32_t *removed)
 {
@@ -494,7 +494,7 @@
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;
-	struct list tmp_orphan_lvs;
+	struct dm_list tmp_orphan_lvs;
 
 	if (removed)
 		*removed = 0;
@@ -529,7 +529,7 @@
 		new_area_count = old_area_count - num_removed;
 
 	/* Remove mimage LVs from the segment */
-	list_init(&tmp_orphan_lvs);
+	dm_list_init(&tmp_orphan_lvs);
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		seg_lv(mirrored_seg, m)->status |= VISIBLE_LV;
@@ -538,7 +538,7 @@
 			return 0;
 		}
 		lvl->lv = seg_lv(mirrored_seg, m);
-		list_add(&tmp_orphan_lvs, &lvl->list);
+		dm_list_add(&tmp_orphan_lvs, &lvl->list);
 		release_lv_segment_area(mirrored_seg, m, mirrored_seg->area_len);
 	}
 	mirrored_seg->area_count = new_area_count;
@@ -615,7 +615,7 @@
 
 	/* Save or delete the 'orphan' LVs */
 	if (!collapse) {
-		list_iterate_items(lvl, &tmp_orphan_lvs)
+		dm_list_iterate_items(lvl, &tmp_orphan_lvs)
 			if (!_delete_lv(lv, lvl->lv))
 				return_0;
 	}
@@ -651,7 +651,7 @@
  * Remove the number of mirror images from the LV
  */
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
-			 struct list *removable_pvs, unsigned remove_log)
+			 struct dm_list *removable_pvs, unsigned remove_log)
 {
 	uint32_t num_removed, removed_once, r;
 	uint32_t existing_mirrors = lv_mirror_count(lv);
@@ -844,7 +844,7 @@
 }
 
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct list *removable_pvs, unsigned remove_log)
+			      struct dm_list *removable_pvs, unsigned remove_log)
 {
 	int r;
 	int in_sync;
@@ -961,7 +961,7 @@
 	uint32_t s;
 
 	/* Check the segment params are compatible */
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg)) {
 			log_error("Segment is not mirrored: %s:%" PRIu32,
 				  lv->name, seg->le);
@@ -975,7 +975,7 @@
 	}
 
 	/* Convert the segments */
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!new_mirrors && seg->extents_copied == seg->area_len) {
 			if (!move_lv_segment_area(seg, 0, seg, 1))
 				return_0;
@@ -998,7 +998,7 @@
 {
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv_mirr->segments) {
+	dm_list_iterate_items(seg, &lv_mirr->segments) {
 		if (!seg_is_mirrored(seg))
 			continue;
 		if (seg_type(seg, 0) != AREA_PV)
@@ -1014,7 +1014,7 @@
 	struct lv_segment *seg;
 	uint32_t s;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
@@ -1034,14 +1034,14 @@
 	struct lv_segment *seg;
 
 	/* Loop through all LVs */
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
 		if (!(lv->status & lv_type))
 			continue;
 
 		/* Check segment origins point to pvname */
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			if (seg_type(seg, 0) != AREA_PV)
 				continue;
 			if (seg_dev(seg, 0) != dev)
@@ -1066,10 +1066,10 @@
 	return find_pvmove_lv(vg, pv->dev, lv_type);
 }
 
-struct list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
+struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv)
 {
-	struct list *lvs;
+	struct dm_list *lvs;
 	struct logical_volume *lv1;
 	struct lv_list *lvl, *lvl1;
 	struct lv_segment *seg;
@@ -1080,16 +1080,16 @@
 		return NULL;
 	}
 
-	list_init(lvs);
+	dm_list_init(lvs);
 
 	/* Loop through all LVs except the one supplied */
-	list_iterate_items(lvl1, &vg->lvs) {
+	dm_list_iterate_items(lvl1, &vg->lvs) {
 		lv1 = lvl1->lv;
 		if (lv1 == lv)
 			continue;
 
 		/* Find whether any segment points at the supplied LV */
-		list_iterate_items(seg, &lv1->segments) {
+		dm_list_iterate_items(seg, &lv1->segments) {
 			for (s = 0; s < seg->area_count; s++) {
 				if (seg_type(seg, s) != AREA_LV ||
 				    seg_lv(seg, s) != lv)
@@ -1099,7 +1099,7 @@
 					return NULL;
 				}
 				lvl->lv = lv1;
-				list_add(lvs, &lvl->list);
+				dm_list_add(lvs, &lvl->list);
 				goto next_lv;
 			}
 		}
@@ -1115,7 +1115,7 @@
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv_mirr->segments) {
+	dm_list_iterate_items(seg, &lv_mirr->segments) {
 		denominator += seg->area_len;
 
 		if (seg_is_mirrored(seg) && seg->area_count > 1)
@@ -1135,8 +1135,8 @@
 	struct lv_list *lvl;
 	struct lv_segment *seg;
 
-	list_iterate_items(lvl, &vg->lvs) {
-		list_iterate_items(seg, &lvl->lv->segments) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		dm_list_iterate_items(seg, &lvl->lv->segments) {
 			if (seg->segtype !=
 			    get_segtype_from_string(vg->cmd, "mirror"))
 				continue;
@@ -1154,11 +1154,11 @@
  */
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 			    uint32_t mirrors, uint32_t region_size,
-			    struct list *allocatable_pvs, alloc_policy_t alloc)
+			    struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
-	struct list *parallel_areas;
+	struct dm_list *parallel_areas;
 	uint32_t adjusted_region_size;
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
@@ -1193,14 +1193,14 @@
  */
 int remove_mirror_log(struct cmd_context *cmd,
 		      struct logical_volume *lv,
-		      struct list *removable_pvs)
+		      struct dm_list *removable_pvs)
 {
 	float sync_percent;
 	struct lvinfo info;
 	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
-	if (list_size(&lv->segments) != 1) {
+	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
 	}
@@ -1340,11 +1340,11 @@
 
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
-		   struct list *allocatable_pvs, alloc_policy_t alloc)
+		   struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
-	struct list *parallel_areas;
+	struct dm_list *parallel_areas;
 	float sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
@@ -1356,7 +1356,7 @@
 		return 0;
 	}
 
-	if (list_size(&lv->segments) != 1) {
+	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
 	}
@@ -1418,12 +1418,12 @@
  */
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
-		      struct list *allocatable_pvs, alloc_policy_t alloc,
+		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
-	struct list *parallel_areas;
+	struct dm_list *parallel_areas;
 	struct logical_volume **img_lvs;
 	struct logical_volume *log_lv = NULL;
 
@@ -1465,7 +1465,7 @@
 	/*
 	 * insert a mirror layer
 	 */
-	if (list_size(&lv->segments) != 1 ||
+	if (dm_list_size(&lv->segments) != 1 ||
 	    seg_type(first_seg(lv), 0) != AREA_LV)
 		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
 			goto out_remove_log;
@@ -1514,7 +1514,7 @@
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
-		   struct list *pvs, alloc_policy_t alloc, uint32_t flags)
+		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags)
 {
 	if (!mirrors && !log_count) {
 		log_error("No conversion is requested");
@@ -1565,7 +1565,7 @@
  */
 int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
 		      struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t log_count, struct list *pvs,
+		      uint32_t mirrors, uint32_t log_count, struct dm_list *pvs,
 		      uint32_t status_mask)
 {
 	uint32_t new_mirrors;
--- LVM2/lib/metadata/pv_alloc.h	2007/08/20 20:55:26	1.6
+++ LVM2/lib/metadata/pv_alloc.h	2008/11/03 22:14:29	1.7
@@ -15,7 +15,7 @@
 #ifndef _LVM_PV_ALLOC_H
 
 int alloc_pv_segment_whole_pv(struct dm_pool *mem, struct physical_volume *pv);
-int peg_dup(struct dm_pool *mem, struct list *peg_new, struct list *peg_old);
+int peg_dup(struct dm_pool *mem, struct dm_list *peg_new, struct dm_list *peg_old);
 struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv, uint32_t pe,
 				       uint32_t area_len,
 				       struct lv_segment *seg,
--- LVM2/lib/metadata/pv_manip.c	2008/03/26 16:48:10	1.21
+++ LVM2/lib/metadata/pv_manip.c	2008/11/03 22:14:29	1.22
@@ -40,7 +40,7 @@
 	peg->lvseg = lvseg;
 	peg->lv_area = lv_area;
 
-	list_init(&peg->list);
+	dm_list_init(&peg->list);
 
 	return peg;
 }
@@ -56,23 +56,23 @@
 	if (!(peg = _alloc_pv_segment(mem, pv, 0, pv->pe_count, NULL, 0)))
 		return_0;
 
-	list_add(&pv->segments, &peg->list);
+	dm_list_add(&pv->segments, &peg->list);
 
 	return 1;
 }
 
-int peg_dup(struct dm_pool *mem, struct list *peg_new, struct list *peg_old)
+int peg_dup(struct dm_pool *mem, struct dm_list *peg_new, struct dm_list *peg_old)
 {
 	struct pv_segment *peg, *pego;
 
-	list_init(peg_new);
+	dm_list_init(peg_new);
 
-	list_iterate_items(pego, peg_old) {
+	dm_list_iterate_items(pego, peg_old) {
 		if (!(peg = _alloc_pv_segment(mem, pego->pv, pego->pe,
 					      pego->len, pego->lvseg,
 					      pego->lv_area)))
 			return_0;
-		list_add(peg_new, &peg->list);
+		dm_list_add(peg_new, &peg->list);
 	}
 
 	return 1;
@@ -94,7 +94,7 @@
 
 	peg->len = peg->len - peg_new->len;
 
-	list_add_h(&peg->list, &peg_new->list);
+	dm_list_add_h(&peg->list, &peg_new->list);
 
 	if (peg->lvseg) {
 		peg->pv->pe_alloc_count -= peg_new->len;
@@ -199,7 +199,7 @@
 {
 	peg1->len += peg2->len;
 
-	list_del(&peg2->list);
+	dm_list_del(&peg2->list);
 }
 
 /*
@@ -223,16 +223,16 @@
 /*
  * Returns: number of free PEs in a struct pv_list
  */
-uint32_t pv_list_extents_free(const struct list *pvh)
+uint32_t pv_list_extents_free(const struct dm_list *pvh)
 {
 	struct pv_list *pvl;
 	struct pe_range *per;
 	uint32_t extents = 0;
 	struct pv_segment *pvseg;
 
-	list_iterate_items(pvl, pvh) {
-		list_iterate_items(per, pvl->pe_ranges) {
-			list_iterate_items(pvseg, &pvl->pv->segments) {
+	dm_list_iterate_items(pvl, pvh) {
+		dm_list_iterate_items(per, pvl->pe_ranges) {
+			dm_list_iterate_items(pvseg, &pvl->pv->segments) {
 				if (!pvseg_is_allocated(pvseg))
 					extents += _overlap_pe(pvseg, per);
 			}
@@ -255,14 +255,14 @@
 	uint32_t pv_count = 0, free_count = 0, extent_count = 0;
 	int ret = 1;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		segno = 0;
 		start_pe = 0;
 		alloced = 0;
 		pv_count++;
 
-		list_iterate_items(peg, &pv->segments) {
+		dm_list_iterate_items(peg, &pv->segments) {
 			s = peg->lv_area;
 
 			/* FIXME Remove this next line eventually */
@@ -347,7 +347,7 @@
 	}
 
 	/* Check PEs to be removed are not already allocated */
-	list_iterate_items(peg, &pv->segments) {
+	dm_list_iterate_items(peg, &pv->segments) {
  		if (peg->pe + peg->len <= new_pe_count)
 			continue;
 
@@ -362,9 +362,9 @@
 	if (!pv_split_segment(pv, new_pe_count))
 		return_0;
 
-	list_iterate_items_safe(peg, pegt, &pv->segments) {
+	dm_list_iterate_items_safe(peg, pegt, &pv->segments) {
  		if (peg->pe + peg->len > new_pe_count)
-			list_del(&peg->list);
+			dm_list_del(&peg->list);
 	}
 
 	pv->pe_count = new_pe_count;
@@ -392,7 +392,7 @@
 				old_pe_count,
 				new_pe_count - old_pe_count,
 				NULL, 0);
-	list_add(&pv->segments, &peg->list);
+	dm_list_add(&pv->segments, &peg->list);
 
 	pv->pe_count = new_pe_count;
 
--- LVM2/lib/metadata/pv_map.c	2008/01/30 14:00:00	1.31
+++ LVM2/lib/metadata/pv_map.c	2008/11/03 22:14:29	1.32
@@ -22,16 +22,16 @@
  *
  * FIXME Cope with overlap.
  */
-static void _insert_area(struct list *head, struct pv_area *a)
+static void _insert_area(struct dm_list *head, struct pv_area *a)
 {
 	struct pv_area *pva;
 
-	list_iterate_items(pva, head) {
+	dm_list_iterate_items(pva, head) {
 		if (a->count > pva->count)
 			break;
 	}
 
-	list_add(&pva->list, &a->list);
+	dm_list_add(&pva->list, &a->list);
 	a->map->pe_count += a->count;
 }
 
@@ -67,7 +67,7 @@
 	pe = start;
 
 	/* Walk through complete ordered list of device segments */
-	list_iterate_items(peg, &pvm->pv->segments) {
+	dm_list_iterate_items(peg, &pvm->pv->segments) {
 		/* pe holds the next extent we want to check */
 
 		/* Beyond the range we're interested in? */
@@ -97,7 +97,7 @@
 }
 
 static int _create_all_areas_for_pv(struct dm_pool *mem, struct pv_map *pvm,
-				    struct list *pe_ranges)
+				    struct dm_list *pe_ranges)
 {
 	struct pe_range *aa;
 
@@ -110,7 +110,7 @@
 		return 1;
 	}
 
-	list_iterate_items(aa, pe_ranges) {
+	dm_list_iterate_items(aa, pe_ranges) {
 		if (!_create_alloc_areas_for_pv(mem, pvm, aa->start,
 						aa->count))
 			return_0;
@@ -119,18 +119,18 @@
 	return 1;
 }
 
-static int _create_maps(struct dm_pool *mem, struct list *pvs, struct list *pvms)
+static int _create_maps(struct dm_pool *mem, struct dm_list *pvs, struct dm_list *pvms)
 {
 	struct pv_map *pvm, *pvm2;
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, pvs) {
+	dm_list_iterate_items(pvl, pvs) {
 		if (!(pvl->pv->status & ALLOCATABLE_PV))
 			continue;
 
 		pvm = NULL;
 
-		list_iterate_items(pvm2, pvms)
+		dm_list_iterate_items(pvm2, pvms)
 			if (pvm2->pv->dev == pvl->pv->dev) {
 				pvm = pvm2;
 				break;
@@ -141,8 +141,8 @@
 				return_0;
 
 			pvm->pv = pvl->pv;
-			list_init(&pvm->areas);
-			list_add(pvms, &pvm->list);
+			dm_list_init(&pvm->areas);
+			dm_list_add(pvms, &pvm->list);
 		}
 
 		if (!_create_all_areas_for_pv(mem, pvm, pvl->pe_ranges))
@@ -155,17 +155,17 @@
 /*
  * Create list of PV areas available for this particular allocation
  */
-struct list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
-			    struct list *allocatable_pvs)
+struct dm_list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
+			    struct dm_list *allocatable_pvs)
 {
-	struct list *pvms;
+	struct dm_list *pvms;
 
 	if (!(pvms = dm_pool_zalloc(mem, sizeof(*pvms)))) {
 		log_error("create_pv_maps alloc failed");
 		return NULL;
 	}
 
-	list_init(pvms);
+	dm_list_init(pvms);
 
 	if (!_create_maps(mem, allocatable_pvs, pvms)) {
 		log_error("Couldn't create physical volume maps in %s",
@@ -179,7 +179,7 @@
 
 void consume_pv_area(struct pv_area *pva, uint32_t to_go)
 {
-	list_del(&pva->list);
+	dm_list_del(&pva->list);
 	pva->map->pe_count -= pva->count;
 
 	assert(to_go <= pva->count);
@@ -192,12 +192,12 @@
 	}
 }
 
-uint32_t pv_maps_size(struct list *pvms)
+uint32_t pv_maps_size(struct dm_list *pvms)
 {
 	struct pv_map *pvm;
 	uint32_t pe_count = 0;
 
-	list_iterate_items(pvm, pvms)
+	dm_list_iterate_items(pvm, pvms)
 		pe_count += pvm->pe_count;
 
 	return pe_count;
--- LVM2/lib/metadata/pv_map.h	2007/08/20 20:55:26	1.9
+++ LVM2/lib/metadata/pv_map.h	2008/11/03 22:14:29	1.10
@@ -31,25 +31,25 @@
 	uint32_t start;
 	uint32_t count;
 
-	struct list list;		/* pv_map.areas */
+	struct dm_list list;		/* pv_map.areas */
 };
 
 struct pv_map {
 	struct physical_volume *pv;
-	struct list areas;		/* struct pv_areas */
+	struct dm_list areas;		/* struct pv_areas */
 	uint32_t pe_count;		/* Total number of PEs */
 
-	struct list list;
+	struct dm_list list;
 };
 
 /*
  * Find intersection between available_pvs and free space in VG
  */
-struct list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
-			    struct list *allocatable_pvs);
+struct dm_list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
+			    struct dm_list *allocatable_pvs);
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
 
-uint32_t pv_maps_size(struct list *pvms);
+uint32_t pv_maps_size(struct dm_list *pvms);
 
 #endif
--- LVM2/lib/metadata/segtype.c	2008/01/30 14:00:00	1.3
+++ LVM2/lib/metadata/segtype.c	2008/11/03 22:14:29	1.4
@@ -22,7 +22,7 @@
 {
 	struct segment_type *segtype;
 
-	list_iterate_items(segtype, &cmd->segtypes) {
+	dm_list_iterate_items(segtype, &cmd->segtypes) {
 		if (!strcmp(segtype->name, str))
 			return segtype;
 	}
--- LVM2/lib/metadata/segtype.h	2008/07/15 00:25:51	1.21
+++ LVM2/lib/metadata/segtype.h	2008/11/03 22:14:29	1.22
@@ -47,7 +47,7 @@
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
-	struct list list;
+	struct dm_list list;
 	struct cmd_context *cmd;
 	uint32_t flags;
 	struct segtype_handler *ops;
@@ -82,7 +82,7 @@
 			       unsigned *attributes);
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
-			       struct list *modules);
+			       struct dm_list *modules);
 	void (*destroy) (const struct segment_type * segtype);
 	int (*target_monitored) (struct lv_segment *seg, int *pending);
 	int (*target_monitor_events) (struct lv_segment *seg, int events);
--- LVM2/lib/metadata/snapshot_manip.c	2008/01/30 14:00:00	1.31
+++ LVM2/lib/metadata/snapshot_manip.c	2008/11/03 22:14:29	1.32
@@ -90,14 +90,14 @@
 
 	cow->status &= ~VISIBLE_LV;
 
-	list_add(&origin->snapshot_segs, &seg->origin_list);
+	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 
 	return 1;
 }
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
-	list_del(&cow->snapshot->origin_list);
+	dm_list_del(&cow->snapshot->origin_list);
 	cow->snapshot->origin->origin_count--;
 
 	if (!lv_remove(cow->snapshot->lv)) {
--- LVM2/lib/mirror/Makefile.in	2007/09/21 10:16:44	1.4
+++ LVM2/lib/mirror/Makefile.in	2008/11/03 22:14:29	1.5
@@ -19,6 +19,7 @@
 SOURCES = mirrored.c
 
 LIB_SHARED = liblvm2mirror.so
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
--- LVM2/lib/mirror/mirrored.c	2008/10/31 22:41:51	1.58
+++ LVM2/lib/mirror/mirrored.c	2008/11/03 22:14:29	1.59
@@ -512,7 +512,7 @@
 
 static int _mirrored_modules_needed(struct dm_pool *mem,
 				    const struct lv_segment *seg,
-				    struct list *modules)
+				    struct dm_list *modules)
 {
 	if (seg->log_lv &&
 	    !list_segment_modules(mem, first_seg(seg->log_lv), modules))
--- LVM2/lib/report/report.c	2008/09/19 06:41:59	1.88
+++ LVM2/lib/report/report.c	2008/11/03 22:14:29	1.89
@@ -173,7 +173,7 @@
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute((unused)))
 {
-	const struct list *tags = (const struct list *) data;
+	const struct dm_list *tags = (const struct dm_list *) data;
 	struct str_list *sl;
 
 	if (!dm_pool_begin_object(mem, 256)) {
@@ -181,7 +181,7 @@
 		return 0;
 	}
 
-	list_iterate_items(sl, tags) {
+	dm_list_iterate_items(sl, tags) {
 		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
 		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
 			log_error("dm_pool_grow_object failed");
@@ -204,7 +204,7 @@
 			 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct list *modules;
+	struct dm_list *modules;
 
 	if (!(modules = str_list_create(mem))) {
 		log_error("modules str_list allocation failed");
@@ -492,7 +492,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg) || !seg->log_lv)
 			continue;
 		return dm_report_field_string(rh, field,
@@ -545,7 +545,7 @@
 	const char *name;
 	struct lv_segment *seg;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (!(seg->status & PVMOVE))
 			continue;
 		name = dev_name(seg_dev(seg, 0));
@@ -842,7 +842,7 @@
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
 	info = info_from_pvid(pvid, 0);
-	count = info ? list_size(&info->mdas) : 0;
+	count = info ? dm_list_size(&info->mdas) : 0;
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -854,7 +854,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = list_size(&vg->fid->metadata_areas);
+	count = dm_list_size(&vg->fid->metadata_areas);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -870,7 +870,7 @@
 
 	info = info_from_pvid(pvid, 0);
 
-	list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->mdas) {
 		if (!mda->ops->mda_free_sectors)
 			continue;
 		mda_free = mda->ops->mda_free_sectors(mda);
@@ -892,7 +892,7 @@
 	uint64_t freespace = UINT64_MAX, mda_free;
 	struct metadata_area *mda;
 
-	list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (!mda->ops->mda_free_sectors)
 			continue;
 		mda_free = mda->ops->mda_free_sectors(mda);
@@ -914,7 +914,7 @@
         struct lv_list *lvl;
 	uint32_t count = 0;
 
-        list_iterate_items(lvl, &vg->lvs)
+        dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
 			count++;
 
@@ -928,7 +928,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint32_t count;
 
-	count = list_size(&lv->segments);
+	count = dm_list_size(&lv->segments);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
--- LVM2/lib/snapshot/Makefile.in	2007/09/21 10:16:44	1.4
+++ LVM2/lib/snapshot/Makefile.in	2008/11/03 22:14:29	1.5
@@ -19,6 +19,7 @@
 SOURCES = snapshot.c
 
 LIB_SHARED = liblvm2snapshot.so
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
--- LVM2/lib/snapshot/snapshot.c	2008/10/31 22:41:51	1.32
+++ LVM2/lib/snapshot/snapshot.c	2008/11/03 22:14:29	1.33
@@ -254,7 +254,7 @@
 
 static int _snap_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute((unused)),
-				struct list *modules)
+				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "snapshot")) {
 		log_error("snapshot string list allocation failed");
--- LVM2/lib/zero/zero.c	2008/04/07 10:23:47	1.17
+++ LVM2/lib/zero/zero.c	2008/11/03 22:14:29	1.18
@@ -67,7 +67,7 @@
 
 static int _zero_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute((unused)),
-				struct list *modules)
+				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "zero")) {
 		log_error("zero module string list allocation failed");
--- LVM2/libdm/Makefile.in	2008/11/03 18:59:59	1.40
+++ LVM2/libdm/Makefile.in	2008/11/03 22:14:29	1.41
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
-interface = @interface@
 
 SOURCES =\
 	datastruct/bitset.c \
@@ -42,7 +41,8 @@
 else
   LIB_SHARED = $(interface)/libdevmapper.so
 endif
-VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
+VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
+LIB_VERSION = $(LIB_VERSION_DM)
 
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
@@ -72,15 +72,15 @@
 		$(includedir)/libdevmapper.h
 
 install_dynamic: install_ at interface@
-	$(LN_S) -f libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION) \
+	$(LN_S) -f libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM) \
 		$(libdir)/libdevmapper.$(LIB_SUFFIX)
 
 install_static: install_ at interface@_static
-	$(LN_S) -f libdevmapper.a.$(LIB_VERSION) $(libdir)/libdevmapper.a
+	$(LN_S) -f libdevmapper.a.$(LIB_VERSION_DM) $(libdir)/libdevmapper.a
 
 install_ioctl: ioctl/libdevmapper.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
+		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 
 install_pkgconfig:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.pc \
@@ -88,11 +88,13 @@
 
 install_ioctl_static: ioctl/libdevmapper.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.a.$(LIB_VERSION)
+		$(libdir)/libdevmapper.a.$(LIB_VERSION_DM)
 
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): $(interface)/%.$(LIB_SUFFIX)
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_DM): $(interface)/%.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
+	rm -f libdevmapper.so
+	$(LN_S) $< libdevmapper.so
 
 .PHONY: distclean_lib distclean
 
--- LVM2/libdm/libdm-common.c	2008/11/03 18:59:59	1.61
+++ LVM2/libdm/libdm-common.c	2008/11/03 22:14:29	1.62
@@ -506,10 +506,10 @@
 	return 1;
 }
 
-static LIST_INIT(_node_ops);
+static DM_LIST_INIT(_node_ops);
 
 struct node_op_parms {
-	struct list list;
+	struct dm_list list;
 	node_op_t type;
 	char *dev_name;
 	uint32_t major;
@@ -536,7 +536,7 @@
 			  uint32_t read_ahead_flags)
 {
 	struct node_op_parms *nop;
-	struct list *noph, *nopht;
+	struct dm_list *noph, *nopht;
 	size_t len = strlen(dev_name) + strlen(old_name) + 2;
 	char *pos;
 
@@ -544,10 +544,10 @@
 	 * Ignore any outstanding operations on the node if deleting it
 	 */
 	if (type == NODE_DEL) {
-		list_iterate_safe(noph, nopht, &_node_ops) {
-			nop = list_item(noph, struct node_op_parms);
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
 			if (!strcmp(dev_name, nop->dev_name)) {
-				list_del(&nop->list);
+				dm_list_del(&nop->list);
 				dm_free(nop);
 			}
 		}
@@ -571,22 +571,22 @@
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
 
-	list_add(&_node_ops, &nop->list);
+	dm_list_add(&_node_ops, &nop->list);
 
 	return 1;
 }
 
 static void _pop_node_ops(void)
 {
-	struct list *noph, *nopht;
+	struct dm_list *noph, *nopht;
 	struct node_op_parms *nop;
 
-	list_iterate_safe(noph, nopht, &_node_ops) {
-		nop = list_item(noph, struct node_op_parms);
+	dm_list_iterate_safe(noph, nopht, &_node_ops) {
+		nop = dm_list_item(noph, struct node_op_parms);
 		_do_node_op(nop->type, nop->dev_name, nop->major, nop->minor,
 			    nop->uid, nop->gid, nop->mode, nop->old_name,
 			    nop->read_ahead, nop->read_ahead_flags);
-		list_del(&nop->list);
+		dm_list_del(&nop->list);
 		dm_free(nop);
 	}
 }
--- LVM2/libdm/libdm-deptree.c	2008/11/03 18:59:59	1.45
+++ LVM2/libdm/libdm-deptree.c	2008/11/03 22:14:29	1.46
@@ -55,7 +55,7 @@
 
 /* Some segment types have a list of areas of other devices attached */
 struct seg_area {
-	struct list list;
+	struct dm_list list;
 
 	struct dm_tree_node *dev_node;
 
@@ -64,14 +64,14 @@
 
 /* Per-segment properties */
 struct load_segment {
-	struct list list;
+	struct dm_list list;
 
 	unsigned type;
 
 	uint64_t size;
 
 	unsigned area_count;		/* Linear + Striped + Mirrored */
-	struct list areas;		/* Linear + Striped + Mirrored */
+	struct dm_list areas;		/* Linear + Striped + Mirrored */
 
 	uint32_t stripe_size;		/* Striped */
 
@@ -99,14 +99,14 @@
 
 	unsigned segment_count;
 	unsigned size_changed;
-	struct list segs;
+	struct dm_list segs;
 
 	const char *new_name;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
 struct dm_tree_link {
-	struct list list;
+	struct dm_list list;
 	struct dm_tree_node *node;
 };
 
@@ -117,8 +117,8 @@
         const char *uuid;
         struct dm_info info;
 
-        struct list uses;       	/* Nodes this node uses */
-        struct list used_by;    	/* Nodes that use this node */
+        struct dm_list uses;       	/* Nodes this node uses */
+        struct dm_list used_by;    	/* Nodes that use this node */
 
 	int activation_priority;	/* 0 gets activated first */
 
@@ -163,8 +163,8 @@
 
 	memset(dtree, 0, sizeof(*dtree));
 	dtree->root.dtree = dtree;
-	list_init(&dtree->root.uses);
-	list_init(&dtree->root.used_by);
+	dm_list_init(&dtree->root.uses);
+	dm_list_init(&dtree->root.used_by);
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
 
@@ -208,14 +208,14 @@
 {
 	struct dm_tree_link *dlink;
 
-	list_iterate_items(dlink, &parent->uses)
+	dm_list_iterate_items(dlink, &parent->uses)
 		if (dlink->node == child)
 			return 1;
 
 	return 0;
 }
 
-static int _link(struct list *list, struct dm_tree_node *node)
+static int _link(struct dm_list *list, struct dm_tree_node *node)
 {
 	struct dm_tree_link *dlink;
 
@@ -225,7 +225,7 @@
 	}
 
 	dlink->node = node;
-	list_add(list, &dlink->list);
+	dm_list_add(list, &dlink->list);
 
 	return 1;
 }
@@ -245,13 +245,13 @@
 	return 1;
 }
 
-static void _unlink(struct list *list, struct dm_tree_node *node)
+static void _unlink(struct dm_list *list, struct dm_tree_node *node)
 {
 	struct dm_tree_link *dlink;
 
-	list_iterate_items(dlink, list)
+	dm_list_iterate_items(dlink, list)
 		if (dlink->node == node) {
-			list_del(&dlink->list);
+			dm_list_del(&dlink->list);
 			break;
 		}
 }
@@ -326,9 +326,9 @@
 	node->context = context;
 	node->activation_priority = 0;
 
-	list_init(&node->uses);
-	list_init(&node->used_by);
-	list_init(&node->props.segs);
+	dm_list_init(&node->uses);
+	dm_list_init(&node->used_by);
+	dm_list_init(&node->props.segs);
 
 	dev = MKDEV(info->major, info->minor);
 
@@ -662,13 +662,13 @@
 	if (inverted) {
 		if (_nodes_are_linked(&node->dtree->root, node))
 			return 0;
-		return list_size(&node->used_by);
+		return dm_list_size(&node->used_by);
 	}
 
 	if (_nodes_are_linked(node, &node->dtree->root))
 		return 0;
 
-	return list_size(&node->uses);
+	return dm_list_size(&node->uses);
 }
 
 /*
@@ -706,7 +706,7 @@
 			       const char *uuid_prefix,
 			       size_t uuid_prefix_len)
 {
-	struct list *list;
+	struct dm_list *list;
 	struct dm_tree_link *dlink;
 	const struct dm_info *dinfo;
 	const char *uuid;
@@ -721,7 +721,7 @@
 		list = &node->uses;
 	}
 
-	list_iterate_items(dlink, list) {
+	dm_list_iterate_items(dlink, list) {
 		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
 			stack;
 			continue;
@@ -776,8 +776,8 @@
 					   struct dm_tree_node *parent,
 					   uint32_t inverted)
 {
-	struct list **dlink = (struct list **) handle;
-	struct list *use_list;
+	struct dm_list **dlink = (struct dm_list **) handle;
+	struct dm_list *use_list;
 
 	if (inverted)
 		use_list = &parent->used_by;
@@ -785,11 +785,11 @@
 		use_list = &parent->uses;
 
 	if (!*dlink)
-		*dlink = list_first(use_list);
+		*dlink = dm_list_first(use_list);
 	else
-		*dlink = list_next(use_list, *dlink);
+		*dlink = dm_list_next(use_list, *dlink);
 
-	return (*dlink) ? list_item(*dlink, struct dm_tree_link)->node : NULL;
+	return (*dlink) ? dm_list_item(*dlink, struct dm_tree_link)->node : NULL;
 }
 
 /*
@@ -1248,7 +1248,7 @@
 	int tw;
 	const char *prefix = "";
 
-	list_iterate_items(area, &seg->areas) {
+	dm_list_iterate_items(area, &seg->areas) {
 		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
 			return_0;
 
@@ -1483,7 +1483,7 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	list_iterate_items(seg, &dnode->props.segs)
+	dm_list_iterate_items(seg, &dnode->props.segs)
 		if (!_emit_segment(dmt, seg, &seg_start))
 			goto_out;
 
@@ -1616,14 +1616,14 @@
 	seg->type = type;
 	seg->size = size;
 	seg->area_count = 0;
-	list_init(&seg->areas);
+	dm_list_init(&seg->areas);
 	seg->stripe_size = 0;
 	seg->persistent = 0;
 	seg->chunk_size = 0;
 	seg->cow = NULL;
 	seg->origin = NULL;
 
-	list_add(&dnode->props.segs, &seg->list);
+	dm_list_add(&dnode->props.segs, &seg->list);
 	dnode->props.segment_count++;
 
 	return seg;
@@ -1747,7 +1747,7 @@
 		return 0;
 	}
 
-	seg = list_item(list_last(&node->props.segs), struct load_segment);
+	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 
 	if (log_uuid) {
 		if (!(seg->uuid = dm_pool_strdup(node->dtree->mem, log_uuid))) {
@@ -1797,7 +1797,7 @@
 	area->dev_node = dev_node;
 	area->offset = offset;
 
-	list_add(&seg->areas, &area->list);
+	dm_list_add(&seg->areas, &area->list);
 	seg->area_count++;
 
 	return 1;
@@ -1845,7 +1845,7 @@
 		return 0;
 	}
 
-	seg = list_item(list_last(&node->props.segs), struct load_segment);
+	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 
 	if (!_add_area(node, seg, dev_node, offset))
 		return_0;
--- LVM2/libdm/libdm-report.c	2008/11/03 18:59:59	1.25
+++ LVM2/libdm/libdm-report.c	2008/11/03 22:14:29	1.26
@@ -35,10 +35,10 @@
 	uint32_t keys_count;
 
 	/* Ordered list of fields needed for this report */
-	struct list field_props;
+	struct dm_list field_props;
 
 	/* Rows of report data */
-	struct list rows;
+	struct dm_list rows;
 
 	/* Array of field definitions */
 	const struct dm_report_field_type *fields;
@@ -57,7 +57,7 @@
 #define FLD_DESCENDING	0x00000800
 
 struct field_properties {
-	struct list list;
+	struct dm_list list;
 	uint32_t field_num;
 	uint32_t sort_posn;
 	int32_t width;
@@ -69,7 +69,7 @@
  * Report data field
  */
 struct dm_report_field {
-	struct list list;
+	struct dm_list list;
 	struct field_properties *props;
 
 	const char *report_string;	/* Formatted ready for display */
@@ -77,9 +77,9 @@
 };
 
 struct row {
-	struct list list;
+	struct dm_list list;
 	struct dm_report *rh;
-	struct list fields;			  /* Fields in display order */
+	struct dm_list fields;			  /* Fields in display order */
 	struct dm_report_field *(*sort_fields)[]; /* Fields in sort order */
 };
 
@@ -317,13 +317,13 @@
 	fp->flags |= flags;
 
 	/*
-	 * Place hidden fields at the front so list_end() will
+	 * Place hidden fields at the front so dm_list_end() will
 	 * tell us when we've reached the last visible field.
 	 */
 	if (fp->flags & FLD_HIDDEN)
-		list_add_h(&rh->field_props, &fp->list);
+		dm_list_add_h(&rh->field_props, &fp->list);
 	else
-		list_add(&rh->field_props, &fp->list);
+		dm_list_add(&rh->field_props, &fp->list);
 
 	return fp;
 }
@@ -372,7 +372,7 @@
 {
 	struct field_properties *fp, *found = NULL;
 
-	list_iterate_items(fp, &rh->field_props) {
+	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->field_num == field_num) {
 			found = fp;
 			break;
@@ -521,8 +521,8 @@
 	if (output_flags & DM_REPORT_OUTPUT_BUFFERED)
 		rh->flags |= RH_SORT_REQUIRED;
 
-	list_init(&rh->field_props);
-	list_init(&rh->rows);
+	dm_list_init(&rh->field_props);
+	dm_list_init(&rh->rows);
 
 	if ((type = _find_type(rh, rh->report_types)) && type->prefix)
 		rh->field_prefix = type->prefix;
@@ -621,11 +621,11 @@
 		return 0;
 	}
 
-	list_init(&row->fields);
-	list_add(&rh->rows, &row->list);
+	dm_list_init(&row->fields);
+	dm_list_add(&rh->rows, &row->list);
 
 	/* For each field to be displayed, call its report_fn */
-	list_iterate_items(fp, &rh->field_props) {
+	dm_list_iterate_items(fp, &rh->field_props) {
 		if (!(field = dm_pool_zalloc(rh->mem, sizeof(*field)))) {
 			log_error("dm_report_object: "
 				  "struct dm_report_field allocation failed");
@@ -653,7 +653,7 @@
 		    (field->props->flags & FLD_SORT_KEY)) {
 			(*row->sort_fields)[field->props->sort_posn] = field;
 		}
-		list_add(&row->fields, &field->list);
+		dm_list_add(&row->fields, &field->list);
 	}
 
 	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
@@ -686,7 +686,7 @@
 	}
 
 	/* First heading line */
-	list_iterate_items(fp, &rh->field_props) {
+	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN)
 			continue;
 
@@ -706,7 +706,7 @@
 			goto bad;
 		}
 
-		if (!list_end(&rh->field_props, &fp->list))
+		if (!dm_list_end(&rh->field_props, &fp->list))
 			if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
 				log_error("dm_report: Failed to generate report headings for printing");
 				goto bad;
@@ -778,19 +778,19 @@
 	struct row *row;
 
 	if (!(rows = dm_pool_alloc(rh->mem, sizeof(**rows) *
-				list_size(&rh->rows)))) {
+				dm_list_size(&rh->rows)))) {
 		log_error("dm_report: sort array allocation failed");
 		return 0;
 	}
 
-	list_iterate_items(row, &rh->rows)
+	dm_list_iterate_items(row, &rh->rows)
 		(*rows)[count++] = row;
 
 	qsort(rows, count, sizeof(**rows), _row_compare);
 
-	list_init(&rh->rows);
+	dm_list_init(&rh->rows);
 	while (count--)
-		list_add_h(&rh->rows, &(*rows)[count]->list);
+		dm_list_add_h(&rh->rows, &(*rows)[count]->list);
 
 	return 1;
 }
@@ -891,11 +891,11 @@
 		return 0;
 	}
 
-	list_iterate_items(fp, &rh->field_props) {
+	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN) {
-			list_iterate_items(row, &rh->rows) {
-				field = list_item(list_first(&row->fields), struct dm_report_field);
-				list_del(&field->list);
+			dm_list_iterate_items(row, &rh->rows) {
+				field = dm_list_item(dm_list_first(&row->fields), struct dm_report_field);
+				dm_list_del(&field->list);
 			}
 			continue;
 		}
@@ -911,14 +911,14 @@
 			}
 		}
 
-		list_iterate_items(row, &rh->rows) {
-			if ((field = list_item(list_first(&row->fields), struct dm_report_field))) {
+		dm_list_iterate_items(row, &rh->rows) {
+			if ((field = dm_list_item(dm_list_first(&row->fields), struct dm_report_field))) {
 				if (!_output_field(rh, field))
 					goto bad;
-				list_del(&field->list);
+				dm_list_del(&field->list);
 			}
 
-			if (!list_end(&rh->rows, &row->list))
+			if (!dm_list_end(&rh->rows, &row->list))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
 					log_error("dm_report: Unable to extend output line");
 					goto bad;
@@ -941,7 +941,7 @@
 
 static int _output_as_columns(struct dm_report *rh)
 {
-	struct list *fh, *rowh, *ftmp, *rtmp;
+	struct dm_list *fh, *rowh, *ftmp, *rtmp;
 	struct row *row = NULL;
 	struct dm_report_field *field;
 
@@ -950,34 +950,34 @@
 		_report_headings(rh);
 
 	/* Print and clear buffer */
-	list_iterate_safe(rowh, rtmp, &rh->rows) {
+	dm_list_iterate_safe(rowh, rtmp, &rh->rows) {
 		if (!dm_pool_begin_object(rh->mem, 512)) {
 			log_error("dm_report: Unable to allocate output line");
 			return 0;
 		}
-		row = list_item(rowh, struct row);
-		list_iterate_safe(fh, ftmp, &row->fields) {
-			field = list_item(fh, struct dm_report_field);
+		row = dm_list_item(rowh, struct row);
+		dm_list_iterate_safe(fh, ftmp, &row->fields) {
+			field = dm_list_item(fh, struct dm_report_field);
 			if (field->props->flags & FLD_HIDDEN)
 				continue;
 
 			if (!_output_field(rh, field))
 				goto bad;
 
-			if (!list_end(&row->fields, fh))
+			if (!dm_list_end(&row->fields, fh))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
 					log_error("dm_report: Unable to extend output line");
 					goto bad;
 				}
 
-			list_del(&field->list);
+			dm_list_del(&field->list);
 		}
 		if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
 			log_error("dm_report: Unable to terminate output line");
 			goto bad;
 		}
 		log_print("%s", (char *) dm_pool_end_object(rh->mem));
-		list_del(&row->list);
+		dm_list_del(&row->list);
 	}
 
 	if (row)
@@ -992,7 +992,7 @@
 
 int dm_report_output(struct dm_report *rh)
 {
-	if (list_empty(&rh->rows))
+	if (dm_list_empty(&rh->rows))
 		return 1;
 
 	if ((rh->flags & RH_SORT_REQUIRED))
--- LVM2/libdm/datastruct/list.c	2008/04/10 19:14:26	1.4
+++ LVM2/libdm/datastruct/list.c	2008/11/03 22:14:30	1.5
@@ -19,7 +19,7 @@
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
-void list_init(struct list *head)
+void dm_list_init(struct dm_list *head)
 {
 	head->n = head->p = head;
 }
@@ -28,7 +28,7 @@
  * Insert an element before 'head'.
  * If 'head' is the list head, this adds an element to the end of the list.
  */
-void list_add(struct list *head, struct list *elem)
+void dm_list_add(struct dm_list *head, struct dm_list *elem)
 {
 	assert(head->n);
 
@@ -43,7 +43,7 @@
  * Insert an element after 'head'.
  * If 'head' is the list head, this adds an element to the front of the list.
  */
-void list_add_h(struct list *head, struct list *elem)
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem)
 {
 	assert(head->n);
 
@@ -59,7 +59,7 @@
  * Note that this doesn't change the element itself - it may still be safe
  * to follow its pointers.
  */
-void list_del(struct list *elem)
+void dm_list_del(struct dm_list *elem)
 {
 	elem->n->p = elem->p;
 	elem->p->n = elem->n;
@@ -68,16 +68,16 @@
 /*
  * Remove an element from existing list and insert before 'head'.
  */
-void list_move(struct list *head, struct list *elem)
+void dm_list_move(struct dm_list *head, struct dm_list *elem)
 {
-        list_del(elem);
-        list_add(head, elem);
+        dm_list_del(elem);
+        dm_list_add(head, elem);
 }
 
 /*
  * Is the list empty?
  */
-int list_empty(const struct list *head)
+int dm_list_empty(const struct dm_list *head)
 {
 	return head->n == head;
 }
@@ -85,7 +85,7 @@
 /*
  * Is this the first element of the list?
  */
-int list_start(const struct list *head, const struct list *elem)
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem)
 {
 	return elem->p == head;
 }
@@ -93,7 +93,7 @@
 /*
  * Is this the last element of the list?
  */
-int list_end(const struct list *head, const struct list *elem)
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem)
 {
 	return elem->n == head;
 }
@@ -101,44 +101,44 @@
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(const struct list *head)
+struct dm_list *dm_list_first(const struct dm_list *head)
 {
-	return (list_empty(head) ? NULL : head->n);
+	return (dm_list_empty(head) ? NULL : head->n);
 }
 
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(const struct list *head)
+struct dm_list *dm_list_last(const struct dm_list *head)
 {
-	return (list_empty(head) ? NULL : head->p);
+	return (dm_list_empty(head) ? NULL : head->p);
 }
 
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(const struct list *head, const struct list *elem)
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem)
 {
-	return (list_start(head, elem) ? NULL : elem->p);
+	return (dm_list_start(head, elem) ? NULL : elem->p);
 }
 
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(const struct list *head, const struct list *elem)
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem)
 {
-	return (list_end(head, elem) ? NULL : elem->n);
+	return (dm_list_end(head, elem) ? NULL : elem->n);
 }
 
 /*
  * Return the number of elements in a list by walking it.
  */
-unsigned int list_size(const struct list *head)
+unsigned int dm_list_size(const struct dm_list *head)
 {
 	unsigned int s = 0;
-	const struct list *v;
+	const struct dm_list *v;
 
-	list_iterate(v, head)
+	dm_list_iterate(v, head)
 	    s++;
 
 	return s;
--- LVM2/libdm/datastruct/list.h	2008/04/10 19:14:26	1.27
+++ LVM2/libdm/datastruct/list.h	2008/11/03 22:14:30	1.28
@@ -24,106 +24,106 @@
  * The list head's pointers point to the first and the last element.
  */
 
-struct list {
-	struct list *n, *p;
+struct dm_list {
+	struct dm_list *n, *p;
 };
 
 /*
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
-#define LIST_INIT(name)	struct list name = { &(name), &(name) }
-void list_init(struct list *head);
+#define DM_LIST_INIT(name)	struct dm_list name = { &(name), &(name) }
+void dm_list_init(struct dm_list *head);
 
 /*
  * Insert an element before 'head'.
  * If 'head' is the list head, this adds an element to the end of the list.
  */
-void list_add(struct list *head, struct list *elem);
+void dm_list_add(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Insert an element after 'head'.
  * If 'head' is the list head, this adds an element to the front of the list.
  */
-void list_add_h(struct list *head, struct list *elem);
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Delete an element from its list.
  * Note that this doesn't change the element itself - it may still be safe
  * to follow its pointers.
  */
-void list_del(struct list *elem);
+void dm_list_del(struct dm_list *elem);
 
 /*
  * Remove an element from existing list and insert before 'head'.
  */
-void list_move(struct list *head, struct list *elem);
+void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
  * Is the list empty?
  */
-int list_empty(const struct list *head);
+int dm_list_empty(const struct dm_list *head);
 
 /*
  * Is this the first element of the list?
  */
-int list_start(const struct list *head, const struct list *elem);
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Is this the last element of the list?
  */
-int list_end(const struct list *head, const struct list *elem);
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(const struct list *head);
+struct dm_list *dm_list_first(const struct dm_list *head);
 
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(const struct list *head);
+struct dm_list *dm_list_last(const struct dm_list *head);
 
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(const struct list *head, const struct list *elem);
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem);
 
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(const struct list *head, const struct list *elem);
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem);
 
 /*
- * Given the address v of an instance of 'struct list' called 'head' 
+ * Given the address v of an instance of 'struct dm_list' called 'head' 
  * contained in a structure of type t, return the containing structure.
  */
-#define list_struct_base(v, t, head) \
+#define dm_list_struct_base(v, t, head) \
     ((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->head))
 
 /*
- * Given the address v of an instance of 'struct list list' contained in
+ * Given the address v of an instance of 'struct dm_list list' contained in
  * a structure of type t, return the containing structure.
  */
-#define list_item(v, t) list_struct_base((v), t, list)
+#define dm_list_item(v, t) dm_list_struct_base((v), t, list)
 
 /*
  * Given the address v of one known element e in a known structure of type t,
  * return another element f.
  */
-#define struct_field(v, t, e, f) \
+#define dm_struct_field(v, t, e, f) \
     (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
 
 /*
  * Given the address v of a known element e in a known structure of type t,
  * return the list head 'list'
  */
-#define list_head(v, t, e) struct_field(v, t, e, list)
+#define dm_list_head(v, t, e) dm_struct_field(v, t, e, list)
 
 /*
  * Set v to each element of a list in turn.
  */
-#define list_iterate(v, head) \
+#define dm_list_iterate(v, head) \
 	for (v = (head)->n; v != head; v = v->n)
 
 /*
@@ -133,7 +133,7 @@
  * already-processed elements.
  * If 'start' is 'head' it walks the list backwards.
  */
-#define list_uniterate(v, head, start) \
+#define dm_list_uniterate(v, head, start) \
 	for (v = (start)->p; v != head; v = v->p)
 
 /*
@@ -141,68 +141,68 @@
  * the way.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_safe(v, t, head) \
+#define dm_list_iterate_safe(v, t, head) \
 	for (v = (head)->n, t = v->n; v != head; v = t, t = v->n)
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  */
-#define list_iterate_items_gen(v, head, field) \
-	for (v = list_struct_base((head)->n, typeof(*v), field); \
+#define dm_list_iterate_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = list_struct_base(v->field.n, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.n, typeof(*v), field))
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  */
-#define list_iterate_items(v, head) list_iterate_items_gen(v, (head), list)
+#define dm_list_iterate_items(v, head) dm_list_iterate_items_gen(v, (head), list)
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_items_gen_safe(v, t, head, field) \
-	for (v = list_struct_base((head)->n, typeof(*v), field), \
-	     t = list_struct_base(v->field.n, typeof(*v), field); \
+#define dm_list_iterate_items_gen_safe(v, t, head, field) \
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field), \
+	     t = dm_list_struct_base(v->field.n, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = t, t = list_struct_base(v->field.n, typeof(*v), field))
+	     v = t, t = dm_list_struct_base(v->field.n, typeof(*v), field))
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  * t must be defined as a temporary variable of the same type as v.
  */
-#define list_iterate_items_safe(v, t, head) \
-	list_iterate_items_gen_safe(v, t, (head), list)
+#define dm_list_iterate_items_safe(v, t, head) \
+	dm_list_iterate_items_gen_safe(v, t, (head), list)
 
 /*
  * Walk a list backwards, setting 'v' in turn to the containing structure 
  * of each item.
  * The containing structure should be the same type as 'v'.
- * The 'struct list' variable within the containing structure is 'field'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
  */
-#define list_iterate_back_items_gen(v, head, field) \
-	for (v = list_struct_base((head)->p, typeof(*v), field); \
+#define dm_list_iterate_back_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->p, typeof(*v), field); \
 	     &v->field != (head); \
-	     v = list_struct_base(v->field.p, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.p, typeof(*v), field))
 
 /*
  * Walk a list backwards, setting 'v' in turn to the containing structure 
  * of each item.
  * The containing structure should be the same type as 'v'.
- * The list should be 'struct list list' within the containing structure.
+ * The list should be 'struct dm_list list' within the containing structure.
  */
-#define list_iterate_back_items(v, head) list_iterate_back_items_gen(v, (head), list)
+#define dm_list_iterate_back_items(v, head) dm_list_iterate_back_items_gen(v, (head), list)
 
 /*
  * Return the number of elements in a list by walking it.
  */
-unsigned int list_size(const struct list *head);
+unsigned int dm_list_size(const struct dm_list *head);
 
 #endif
--- LVM2/tools/Makefile.in	2008/11/01 02:19:19	1.86
+++ LVM2/tools/Makefile.in	2008/11/03 22:14:30	1.87
@@ -80,7 +80,7 @@
 CLEAN_TARGETS = liblvm2cmd.so liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
-		lvmcmdlib.o lvm-static.o
+		lvmcmdlib.o lvm-static.o dmsetup.o
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.so
@@ -99,9 +99,9 @@
 
 device-mapper: dmsetup
 
-dmsetup: dmsetup.o $(interfacedir)/libdevmapper.$(LIB_SUFFIX)
+dmsetup: dmsetup.o $(top_srcdir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
-	      -L$(interfacedir) -L$(DESTDIR)/lib -ldevmapper $(LIBS)
+	      -L$(top_srcdir)/libdm -L$(DESTDIR)/lib -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) -static \
--- LVM2/tools/lvconvert.c	2008/06/26 23:05:11	1.66
+++ LVM2/tools/lvconvert.c	2008/11/03 22:14:30	1.67
@@ -39,7 +39,7 @@
 
 	int pv_count;
 	char **pvs;
-	struct list *pvh;
+	struct dm_list *pvh;
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -257,7 +257,7 @@
 static int _update_lvconvert_mirror(struct cmd_context *cmd __attribute((unused)),
 				    struct volume_group *vg __attribute((unused)),
 				    struct logical_volume *lv __attribute((unused)),
-				    struct list *lvs_changed __attribute((unused)),
+				    struct dm_list *lvs_changed __attribute((unused)),
 				    unsigned flags __attribute((unused)))
 {
 	/* lvconvert mirror doesn't require periodical metadata update */
@@ -267,7 +267,7 @@
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct volume_group *vg,
 				    struct logical_volume *lv,
-				    struct list *lvs_changed __attribute((unused)))
+				    struct dm_list *lvs_changed __attribute((unused)))
 {
 	if (!collapse_mirrored_lv(lv)) {
 		log_error("Failed to remove temporary sync layer.");
@@ -477,7 +477,7 @@
 		/* FIXME Share code with lvcreate */
 
 		/* FIXME Why is this restriction here?  Fix it! */
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			if (seg_is_striped(seg) && seg->area_count > 1) {
 				log_error("Mirrors of striped volumes are not yet supported.");
 				return 0;
@@ -501,7 +501,7 @@
 	 * Converting from mirror to mirror with different leg count,
 	 * or different log type.
 	 */
-	if (list_size(&lv->segments) != 1) {
+	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Logical volume %s has multiple "
 			  "mirror segments.", lv->name);
 		return 0;
--- LVM2/tools/lvcreate.c	2008/09/24 16:32:51	1.177
+++ LVM2/tools/lvcreate.c	2008/11/03 22:14:30	1.178
@@ -518,7 +518,7 @@
 	uint32_t status = 0;
 	uint64_t tmp_size;
 	struct logical_volume *lv, *org = NULL;
-	struct list *pvh;
+	struct dm_list *pvh;
 	const char *tag = NULL;
 	int origin_active = 0;
 	char lv_name_buf[128];
@@ -690,10 +690,10 @@
 		return 0;
 	}
 
-	if (lp->stripes > list_size(pvh) && lp->alloc != ALLOC_ANYWHERE) {
+	if (lp->stripes > dm_list_size(pvh) && lp->alloc != ALLOC_ANYWHERE) {
 		log_error("Number of stripes (%u) must not exceed "
 			  "number of physical volumes (%d)", lp->stripes,
-			  list_size(pvh));
+			  dm_list_size(pvh));
 		return 0;
 	}
 
--- LVM2/tools/lvmcmdline.c	2008/09/19 07:11:54	1.71
+++ LVM2/tools/lvmcmdline.c	2008/11/03 22:14:30	1.72
@@ -120,7 +120,7 @@
 
 	format = a->value;
 
-	list_iterate_items(fmt, &cmd->formats) {
+	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (!strcasecmp(fmt->name, format) ||
 		    !strcasecmp(fmt->name + 3, format) ||
 		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
--- LVM2/tools/lvresize.c	2008/09/18 18:51:58	1.98
+++ LVM2/tools/lvresize.c	2008/11/03 22:14:30	1.99
@@ -267,7 +267,7 @@
 	struct lv_segment *seg;
 	uint32_t seg_extents;
 	uint32_t sz, str;
-	struct list *pvh = NULL;
+	struct dm_list *pvh = NULL;
 	char size_buf[SIZE_BUF];
 	char lv_path[PATH_MAX];
 
@@ -381,7 +381,7 @@
 	seg_size = lp->extents - lv->le_count;
 
 	/* Use segment type of last segment */
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		lp->segtype = seg->segtype;
 	}
 
@@ -394,7 +394,7 @@
 	/* If extending, find stripes, stripesize & size of last segment */
 	if ((lp->extents > lv->le_count) &&
 	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			if (!seg_is_striped(seg))
 				continue;
 
@@ -434,7 +434,7 @@
 
 	/* If extending, find mirrors of last segment */
 	if ((lp->extents > lv->le_count)) {
-		list_iterate_back_items(seg, &lv->segments) {
+		dm_list_iterate_back_items(seg, &lv->segments) {
 			if (seg_is_mirrored(seg))
 				seg_mirrors = lv_mirror_count(seg->lv);
 			else
@@ -461,7 +461,7 @@
 			log_error("Ignoring stripes, stripesize and mirrors "
 				  "arguments when reducing");
 
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			seg_extents = seg->len;
 
 			if (seg_is_striped(seg)) {
--- LVM2/tools/lvscan.c	2008/01/30 14:00:02	1.35
+++ LVM2/tools/lvscan.c	2008/11/03 22:14:30	1.36
@@ -32,7 +32,7 @@
 
 	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
 	if (lv_is_origin(lv)) {
-		list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
+		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
--- LVM2/tools/polldaemon.c	2008/01/30 14:00:02	1.10
+++ LVM2/tools/polldaemon.c	2008/11/03 22:14:30	1.11
@@ -68,7 +68,7 @@
 				const char *name, struct daemon_parms *parms,
 				int *finished)
 {
-	struct list *lvs_changed;
+	struct dm_list *lvs_changed;
 	float segment_percent = 0.0, overall_percent = 0.0;
 	uint32_t event_nr = 0;
 
@@ -196,7 +196,7 @@
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_mirr = lvl->lv;
 		if (!(lv_mirr->status & parms->lv_type))
 			continue;
--- LVM2/tools/polldaemon.h	2008/04/09 12:56:34	1.6
+++ LVM2/tools/polldaemon.h	2008/11/03 22:14:30	1.7
@@ -29,11 +29,11 @@
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
 				struct logical_volume *lv_mirr,
-				struct list *lvs_changed, unsigned flags);
+				struct dm_list *lvs_changed, unsigned flags);
 	int (*finish_copy) (struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
-			    struct list *lvs_changed);
+			    struct dm_list *lvs_changed);
 };
 
 struct daemon_parms {
--- LVM2/tools/pvchange.c	2008/07/31 12:40:52	1.62
+++ LVM2/tools/pvchange.c	2008/11/03 22:14:30	1.63
@@ -226,8 +226,8 @@
 	char *pv_name;
 
 	struct pv_list *pvl;
-	struct list *pvslist;
-	struct list mdas;
+	struct dm_list *pvslist;
+	struct dm_list mdas;
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
 	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
@@ -250,7 +250,7 @@
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
-			list_init(&mdas);
+			dm_list_init(&mdas);
 			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
 				log_error("Failed to read physical volume %s",
 					  pv_name);
@@ -263,7 +263,7 @@
 			 * means checking every VG by scanning every
 			 * PV on the system.
 			 */
-			if (is_orphan(pv) && !list_size(&mdas)) {
+			if (is_orphan(pv) && !dm_list_size(&mdas)) {
 				if (!scan_vgs_for_pvs(cmd)) {
 					log_error("Rescan for PVs without "
 						  "metadata areas failed.");
@@ -287,7 +287,7 @@
 			return ECMD_FAILED;
 		}
 
-		list_iterate_items(pvl, pvslist) {
+		dm_list_iterate_items(pvl, pvslist) {
 			total++;
 			done += _pvchange_single(cmd, pvl->pv, NULL);
 		}
--- LVM2/tools/pvcreate.c	2008/09/19 06:42:00	1.75
+++ LVM2/tools/pvcreate.c	2008/11/03 22:14:30	1.76
@@ -148,7 +148,7 @@
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
 	void *pv;
 	struct device *dev;
-	struct list mdas;
+	struct dm_list mdas;
 
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&
@@ -176,7 +176,7 @@
 		goto error;
 	}
 
-	list_init(&mdas);
+	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
 			     pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
--- LVM2/tools/pvmove.c	2008/04/10 17:09:32	1.53
+++ LVM2/tools/pvmove.c	2008/11/03 22:14:30	1.54
@@ -102,12 +102,12 @@
 }
 
 /* Create list of PVs for allocation of replacement extents */
-static struct list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
+static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 					 char **argv, struct volume_group *vg,
 					 struct physical_volume *pv,
 					 alloc_policy_t alloc)
 {
-	struct list *allocatable_pvs, *pvht, *pvh;
+	struct dm_list *allocatable_pvs, *pvht, *pvh;
 	struct pv_list *pvl;
 
 	if (argc)
@@ -118,21 +118,21 @@
 	if (!allocatable_pvs)
 		return_NULL;
 
-	list_iterate_safe(pvh, pvht, allocatable_pvs) {
-		pvl = list_item(pvh, struct pv_list);
+	dm_list_iterate_safe(pvh, pvht, allocatable_pvs) {
+		pvl = dm_list_item(pvh, struct pv_list);
 
 		/* Don't allocate onto the PV we're clearing! */
 		if ((alloc != ALLOC_ANYWHERE) && (pvl->pv->dev == pv_dev(pv))) {
-			list_del(&pvl->list);
+			dm_list_del(&pvl->list);
 			continue;
 		}
 
 		/* Remove PV if full */
 		if ((pvl->pv->pe_count == pvl->pv->pe_alloc_count))
-			list_del(&pvl->list);
+			dm_list_del(&pvl->list);
 	}
 
-	if (list_empty(allocatable_pvs)) {
+	if (dm_list_empty(allocatable_pvs)) {
 		log_error("No extents available for allocation");
 		return NULL;
 	}
@@ -146,16 +146,16 @@
  */
 static int _insert_pvmove_mirrors(struct cmd_context *cmd,
 				  struct logical_volume *lv_mirr,
-				  struct list *source_pvl,
+				  struct dm_list *source_pvl,
 				  struct logical_volume *lv,
-				  struct list *lvs_changed)
+				  struct dm_list *lvs_changed)
 
 {
 	struct pv_list *pvl;
 	uint32_t prev_le_count;
 
 	/* Only 1 PV may feature in source_pvl */
-	pvl = list_item(source_pvl->n, struct pv_list);
+	pvl = dm_list_item(source_pvl->n, struct pv_list);
 
 	prev_le_count = lv_mirr->le_count;
 	if (!insert_layer_for_segments_on_pv(cmd, lv, lv_mirr, PVMOVE,
@@ -177,11 +177,11 @@
 /* Create new LV with mirror segments for the required copies */
 static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						struct volume_group *vg,
-						struct list *source_pvl,
+						struct dm_list *source_pvl,
 						const char *lv_name,
-						struct list *allocatable_pvs,
+						struct dm_list *allocatable_pvs,
 						alloc_policy_t alloc,
-						struct list **lvs_changed)
+						struct dm_list **lvs_changed)
 {
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_list *lvl;
@@ -203,10 +203,10 @@
 		return NULL;
 	}
 
-	list_init(*lvs_changed);
+	dm_list_init(*lvs_changed);
 
 	/* Find segments to be moved and set up mirrors */
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if ((lv == lv_mirr))
 			continue;
@@ -276,7 +276,7 @@
 
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
-			    struct list *lvs_changed, unsigned flags)
+			    struct dm_list *lvs_changed, unsigned flags)
 {
 	unsigned exclusive = _pvmove_is_exclusive(cmd, vg);
 	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
@@ -347,10 +347,10 @@
 	const char *lv_name = NULL;
 	char *pv_name_arg;
 	struct volume_group *vg;
-	struct list *source_pvl;
-	struct list *allocatable_pvs;
+	struct dm_list *source_pvl;
+	struct dm_list *allocatable_pvs;
 	alloc_policy_t alloc;
-	struct list *lvs_changed;
+	struct dm_list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
 	unsigned first_time = 1;
@@ -474,14 +474,14 @@
 
 static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv_mirr,
-			  struct list *lvs_changed)
+			  struct dm_list *lvs_changed)
 {
 	int r = 1;
-	struct list lvs_completed;
+	struct dm_list lvs_completed;
 	struct lv_list *lvl;
 
 	/* Update metadata to remove mirror segments and break dependencies */
-	list_init(&lvs_completed);
+	dm_list_init(&lvs_completed);
 	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
@@ -489,7 +489,7 @@
 		return 0;
 	}
 
-	list_iterate_items(lvl, &lvs_completed)
+	dm_list_iterate_items(lvl, &lvs_completed)
 		/* FIXME Assumes only one pvmove at a time! */
 		lvl->lv->status &= ~LOCKED;
 
--- LVM2/tools/pvremove.c	2008/07/31 12:38:31	1.24
+++ LVM2/tools/pvremove.c	2008/11/03 22:14:30	1.25
@@ -25,9 +25,9 @@
 static int pvremove_check(struct cmd_context *cmd, const char *name)
 {
 	struct physical_volume *pv;
-	struct list mdas;
+	struct dm_list mdas;
 
-	list_init(&mdas);
+	dm_list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -47,7 +47,7 @@
 	 * means checking every VG by scanning every
 	 * PV on the system.
 	 */
-	if (is_orphan(pv) && !list_size(&mdas)) {
+	if (is_orphan(pv) && !dm_list_size(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd)) {
 			log_error("Rescan for PVs without metadata areas "
 				  "failed.");
--- LVM2/tools/pvresize.c	2008/09/12 15:26:45	1.22
+++ LVM2/tools/pvresize.c	2008/11/03 22:14:30	1.23
@@ -32,13 +32,13 @@
 	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
-	struct list mdas;
+	struct dm_list mdas;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name;
 	struct lvmcache_info *info;
 	int mda_count = 0;
 
-	list_init(&mdas);
+	dm_list_init(&mdas);
 
 	if (is_orphan_vg(pv_vg_name(pv))) {
 		vg_name = VG_ORPHANS;
@@ -53,7 +53,7 @@
 			return 0;
 		}
 
-		mda_count = list_size(&mdas);
+		mda_count = dm_list_size(&mdas);
 	} else {
 		vg_name = pv_vg_name(pv);
 
@@ -90,7 +90,7 @@
 			return 0;
 		}
 
-		mda_count = list_size(&info->mdas);
+		mda_count = dm_list_size(&info->mdas);
 
 		if (!archive(vg))
 			return 0;
--- LVM2/tools/pvscan.c	2008/04/08 12:49:21	1.46
+++ LVM2/tools/pvscan.c	2008/11/03 22:14:30	1.47
@@ -103,7 +103,7 @@
 	int new_pvs_found = 0;
 	int pvs_found = 0;
 
-	struct list *pvslist;
+	struct dm_list *pvslist;
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
@@ -139,13 +139,13 @@
 	}
 
 	/* eliminate exported/new if required */
-	list_iterate_items(pvl, pvslist) {
+	dm_list_iterate_items(pvl, pvslist) {
 		pv = pvl->pv;
 
 		if ((arg_count(cmd, exported_ARG)
 		     && !(pv_status(pv) & EXPORTED_VG))
 		    || (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
-			list_del(&pvl->list);
+			dm_list_del(&pvl->list);
 			continue;
 		}
 
@@ -171,7 +171,7 @@
 
 	/* find maximum pv name length */
 	pv_max_name_len = vg_max_name_len = 0;
-	list_iterate_items(pvl, pvslist) {
+	dm_list_iterate_items(pvl, pvslist) {
 		pv = pvl->pv;
 		len = strlen(pv_dev_name(pv));
 		if (pv_max_name_len < len)
@@ -183,7 +183,7 @@
 	pv_max_name_len += 2;
 	vg_max_name_len += 2;
 
-	list_iterate_items(pvl, pvslist)
+	dm_list_iterate_items(pvl, pvslist)
 	    _pvscan_display_single(cmd, pvl->pv, NULL);
 
 	if (!pvs_found) {
--- LVM2/tools/reporter.c	2008/06/25 16:52:27	1.40
+++ LVM2/tools/reporter.c	2008/11/03 22:14:30	1.41
@@ -88,9 +88,9 @@
 
         _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
-	list_init(&_free_logical_volume.tags);
-	list_init(&_free_logical_volume.segments);
-	list_init(&_free_logical_volume.segs_using_this_lv);
+	dm_list_init(&_free_logical_volume.tags);
+	dm_list_init(&_free_logical_volume.segments);
+	dm_list_init(&_free_logical_volume.segs_using_this_lv);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg))
--- LVM2/tools/toollib.c	2008/06/11 15:02:52	1.136
+++ LVM2/tools/toollib.c	2008/11/03 22:14:30	1.137
@@ -140,8 +140,8 @@
  */
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct volume_group *vg,
-			  const struct list *arg_lvnames,
-			  const struct list *tags,
+			  const struct dm_list *arg_lvnames,
+			  const struct dm_list *tags,
 			  void *handle,
 			  process_single_lv_fn_t process_single)
 {
@@ -158,10 +158,10 @@
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
-	if (tags && !list_empty(tags))
+	if (tags && !dm_list_empty(tags))
 		tags_supplied = 1;
 
-	if (arg_lvnames && !list_empty(arg_lvnames))
+	if (arg_lvnames && !dm_list_empty(arg_lvnames))
 		lvargs_supplied = 1;
 
 	/* Process all LVs in this VG if no restrictions given */
@@ -174,7 +174,7 @@
 		process_all = 1;
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
@@ -207,7 +207,7 @@
 			return ret_max;
 	}
 
-	if (lvargs_supplied && lvargs_matched != list_size(arg_lvnames)) {
+	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
 		log_error("One or more specified logical volume(s) not found.");
 		if (ret_max < ECMD_FAILED)
 			ret_max = ECMD_FAILED;
@@ -227,25 +227,25 @@
 	int ret = 0;
 	int consistent;
 
-	struct list *tags_arg;
-	struct list *vgnames;	/* VGs to process */
+	struct dm_list *tags_arg;
+	struct dm_list *vgnames;	/* VGs to process */
 	struct str_list *sll, *strl;
 	struct volume_group *vg;
-	struct list tags, lvnames;
-	struct list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
+	struct dm_list tags, lvnames;
+	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
 	size_t vglv_sz;
 
 	const char *vgname;
 
-	list_init(&tags);
-	list_init(&arg_lvnames);
+	dm_list_init(&tags);
+	dm_list_init(&arg_lvnames);
 
 	if (argc) {
-		struct list arg_vgnames;
+		struct dm_list arg_vgnames;
 
 		log_verbose("Using logical volume(s) on command line");
-		list_init(&arg_vgnames);
+		dm_list_init(&arg_vgnames);
 
 		for (; opt < argc; opt++) {
 			const char *lv_name = argv[opt];
@@ -327,15 +327,15 @@
 		vgnames = &arg_vgnames;
 	}
 
-	if (!argc || !list_empty(&tags)) {
+	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgs(cmd, 0)) || list_empty(vgnames)) {
+		if (!(vgnames = get_vgs(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
 	}
 
-	list_iterate_items(strl, vgnames) {
+	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
 		if (is_orphan_vg(vgname))
 			continue;	/* FIXME Unnecessary? */
@@ -377,15 +377,15 @@
 		}
 
 		tags_arg = &tags;
-		list_init(&lvnames);	/* LVs to be processed in this VG */
-		list_iterate_items(sll, &arg_lvnames) {
+		dm_list_init(&lvnames);	/* LVs to be processed in this VG */
+		dm_list_iterate_items(sll, &arg_lvnames) {
 			const char *vg_name = sll->str;
 			const char *lv_name = strchr(vg_name, '/');
 
 			if ((!lv_name && !strcmp(vg_name, vgname))) {
 				/* Process all LVs in this VG */
 				tags_arg = NULL;
-				list_init(&lvnames);
+				dm_list_init(&lvnames);
 				break;
 			} else if (!strncmp(vg_name, vgname, strlen(vgname)) &&
 				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
@@ -434,7 +434,7 @@
 		}
 	}
 
-	list_iterate_items(pvseg, &pv->segments) {
+	dm_list_iterate_items(pvseg, &pv->segments) {
 		ret = process_single(cmd, vg, pvseg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
@@ -459,7 +459,7 @@
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
-	list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments) {
 		ret = process_single(cmd, seg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
@@ -472,7 +472,7 @@
 
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
-			   struct list *tags, struct list *arg_vgnames,
+			   struct dm_list *tags, struct dm_list *arg_vgnames,
 			   uint32_t lock_type, int consistent, void *handle,
 			   int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
@@ -500,7 +500,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!list_empty(tags)) {
+	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */
 		if (!str_list_match_item(arg_vgnames, vg_name) &&
 		    !str_list_match_list(tags, &vg->tags)) {
@@ -530,13 +530,13 @@
 	int ret_max = ECMD_PROCESSED;
 
 	struct str_list *sl;
-	struct list *vgnames, *vgids;
-	struct list arg_vgnames, tags;
+	struct dm_list *vgnames, *vgids;
+	struct dm_list arg_vgnames, tags;
 
 	const char *vg_name, *vgid;
 
-	list_init(&tags);
-	list_init(&arg_vgnames);
+	dm_list_init(&tags);
+	dm_list_init(&arg_vgnames);
 
 	if (argc) {
 		log_verbose("Using volume group(s) on command line");
@@ -574,13 +574,13 @@
 		vgnames = &arg_vgnames;
 	}
 
-	if (!argc || !list_empty(&tags)) {
+	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
-		if (!(vgids = get_vgids(cmd, 0)) || list_empty(vgids)) {
+		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
-		list_iterate_items(sl, vgids) {
+		dm_list_iterate_items(sl, vgids) {
 			vgid = sl->str;
 			if (!vgid || !(vg_name = vgname_from_vgid(cmd->mem, vgid)) ||
 			    is_orphan_vg(vg_name))
@@ -593,7 +593,7 @@
 				return ret_max;
 		}
 	} else {
-		list_iterate_items(sl, vgnames) {
+		dm_list_iterate_items(sl, vgnames) {
 			vg_name = sl->str;
 			if (is_orphan_vg(vg_name))
 				continue;	/* FIXME Unnecessary? */
@@ -610,15 +610,15 @@
 }
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct list *tags, void *handle,
+			  const struct dm_list *tags, void *handle,
 			  process_single_pv_fn_t process_single)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	struct pv_list *pvl;
 
-	list_iterate_items(pvl, &vg->pvs) {
-		if (tags && !list_empty(tags) &&
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (tags && !dm_list_empty(tags) &&
 		    !str_list_match_list(tags, &pvl->pv->tags)) {
 			continue;
 		}
@@ -658,8 +658,8 @@
 	while ((dev = dev_iter_get(iter))) {
 		if (!(pv = pv_read(cmd, dev_name(dev), NULL, NULL, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
-			list_init(&pv_dummy.tags);
-			list_init(&pv_dummy.segments);
+			dm_list_init(&pv_dummy.tags);
+			dm_list_init(&pv_dummy.segments);
 			pv_dummy.dev = dev;
 			pv_dummy.fmt = NULL;
 			pv = &pv_dummy;
@@ -689,14 +689,14 @@
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	struct list *pvslist, *vgnames;
-	struct list tags;
+	struct dm_list *pvslist, *vgnames;
+	struct dm_list tags;
 	struct str_list *sll;
 	char *tagname;
 	int consistent = 1;
 	int scanned = 0;
 
-	list_init(&tags);
+	dm_list_init(&tags);
 
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
@@ -769,9 +769,9 @@
 			if (sigint_caught())
 				return ret_max;
 		}
-		if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
-			   !list_empty(vgnames)) {
-			list_iterate_items(sll, vgnames) {
+		if (!dm_list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
+			   !dm_list_empty(vgnames)) {
+			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
 					log_error("Can't lock %s: skipping", sll->str);
 					continue;
@@ -825,7 +825,7 @@
 			if (!(pvslist = get_pvs(cmd)))
 				return ECMD_FAILED;
 
-			list_iterate_items(pvl, pvslist) {
+			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single(cmd, NULL, pvl->pv,
 						     handle);
 				if (ret > ret_max)
@@ -927,7 +927,7 @@
  * Process physical extent range specifiers
  */
 static int _add_pe_range(struct dm_pool *mem, const char *pvname,
-			 struct list *pe_ranges, uint32_t start, uint32_t count)
+			 struct dm_list *pe_ranges, uint32_t start, uint32_t count)
 {
 	struct pe_range *per;
 
@@ -935,7 +935,7 @@
 		  " on %s", start, count, pvname);
 
 	/* Ensure no overlap with existing areas */
-	list_iterate_items(per, pe_ranges) {
+	dm_list_iterate_items(per, pe_ranges) {
 		if (((start < per->start) && (start + count - 1 >= per->start))
 		    || ((start >= per->start) &&
 			(per->start + per->count - 1) >= start)) {
@@ -955,7 +955,7 @@
 
 	per->start = start;
 	per->count = count;
-	list_add(pe_ranges, &per->list);
+	dm_list_add(pe_ranges, &per->list);
 
 	return 1;
 }
@@ -972,7 +972,7 @@
 	return 0;
 }
 
-static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,
+static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 		      const char *pvname, uint32_t size)
 {
 	char *endptr;
@@ -1039,11 +1039,11 @@
 }
 
 static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
-			     char *colon, int allocatable_only, struct list *r)
+			     char *colon, int allocatable_only, struct dm_list *r)
 {
 	const char *pvname;
 	struct pv_list *new_pvl = NULL, *pvl2;
-	struct list *pe_ranges;
+	struct dm_list *pe_ranges;
 
 	pvname = pv_dev_name(pvl->pv);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
@@ -1057,7 +1057,7 @@
 		return 1;
 	}
 
-	list_iterate_items(pvl2, r)
+	dm_list_iterate_items(pvl2, r)
 		if (pvl->pv->dev == pvl2->pv->dev) {
 			new_pvl = pvl2;
 			break;
@@ -1075,9 +1075,9 @@
 			log_error("Allocation of pe_ranges list failed");
 			return 0;
 		}
-		list_init(pe_ranges);
+		dm_list_init(pe_ranges);
 		new_pvl->pe_ranges = pe_ranges;
-		list_add(r, &new_pvl->list);
+		dm_list_add(r, &new_pvl->list);
 	}
 
 	/* Determine selected physical extents */
@@ -1088,12 +1088,12 @@
 	return 1;
 }
 
-struct list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
+struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
 			    char **argv, int allocatable_only)
 {
-	struct list *r;
+	struct dm_list *r;
 	struct pv_list *pvl;
-	struct list tags, arg_pvnames;
+	struct dm_list tags, arg_pvnames;
 	const char *pvname = NULL;
 	char *colon, *tagname;
 	int i;
@@ -1103,10 +1103,10 @@
 		log_error("Allocation of list failed");
 		return NULL;
 	}
-	list_init(r);
+	dm_list_init(r);
 
-	list_init(&tags);
-	list_init(&arg_pvnames);
+	dm_list_init(&tags);
+	dm_list_init(&arg_pvnames);
 
 	for (i = 0; i < argc; i++) {
 		if (*argv[i] == '@') {
@@ -1115,7 +1115,7 @@
 				log_error("Skipping invalid tag %s", tagname);
 				continue;
 			}
-			list_iterate_items(pvl, &vg->pvs) {
+			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (str_list_match_item(&pvl->pv->tags,
 							tagname)) {
 					if (!_create_pv_entry(mem, pvl, NULL,
@@ -1147,15 +1147,15 @@
 			return_NULL;
 	}
 
-	if (list_empty(r))
+	if (dm_list_empty(r))
 		log_error("No specified PVs have space available");
 
-	return list_empty(r) ? NULL : r;
+	return dm_list_empty(r) ? NULL : r;
 }
 
-struct list *clone_pv_list(struct dm_pool *mem, struct list *pvsl)
+struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 {
-	struct list *r;
+	struct dm_list *r;
 	struct pv_list *pvl, *new_pvl;
 
 	/* Build up list of PVs */
@@ -1163,16 +1163,16 @@
 		log_error("Allocation of list failed");
 		return NULL;
 	}
-	list_init(r);
+	dm_list_init(r);
 
-	list_iterate_items(pvl, pvsl) {
+	dm_list_iterate_items(pvl, pvsl) {
 		if (!(new_pvl = dm_pool_zalloc(mem, sizeof(*new_pvl)))) {
 			log_error("Unable to allocate physical volume list.");
 			return NULL;
 		}
 
 		memcpy(new_pvl, pvl, sizeof(*new_pvl));
-		list_add(r, &new_pvl->list);
+		dm_list_add(r, &new_pvl->list);
 	}
 
 	return r;
--- LVM2/tools/toollib.h	2008/03/25 15:24:59	1.57
+++ LVM2/tools/toollib.h	2008/11/03 22:14:30	1.58
@@ -66,7 +66,7 @@
 				  void *handle);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct list *tags, void *handle,
+			  const struct dm_list *tags, void *handle,
 			  process_single_pv_fn_t process_single);
 
 typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
@@ -75,8 +75,8 @@
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct volume_group *vg,
-			  const struct list *arg_lvnames,
-			  const struct list *tags,
+			  const struct dm_list *arg_lvnames,
+			  const struct dm_list *tags,
 			  void *handle,
 			  process_single_lv_fn_t process_single);
 
@@ -89,10 +89,10 @@
  * Builds a list of pv's from the names in argv.  Used in
  * lvcreate/extend.
  */
-struct list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
+struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
 			    char **argv, int allocatable_only);
 
-struct list *clone_pv_list(struct dm_pool *mem, struct list *pvs);
+struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvs);
 
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
--- LVM2/tools/vgchange.c	2008/06/12 11:49:46	1.65
+++ LVM2/tools/vgchange.c	2008/11/03 22:14:30	1.66
@@ -24,7 +24,7 @@
 	int lv_active;
 	int count = 0;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
 		if (!lv_info(cmd, lv, &info, 0, 0))
@@ -59,7 +59,7 @@
 	const char *pvname;
 	int count = 0;
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
 		/* Only request activation of snapshot origin devices */
@@ -260,7 +260,7 @@
 	}
 
 	if (clustered) {
-		list_iterate_items(lvl, &vg->lvs) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
 			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
 				log_error("Volume group %s contains snapshots "
 					  "that are not yet supported.",
@@ -496,7 +496,7 @@
 		return ECMD_FAILED;
 	}
 
-	list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
 	}
 
--- LVM2/tools/vgconvert.c	2008/08/29 13:41:21	1.30
+++ LVM2/tools/vgconvert.c	2008/11/03 22:14:30	1.31
@@ -23,7 +23,7 @@
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 	uint64_t size = 0;
-	struct list mdas;
+	struct dm_list mdas;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
 	uint64_t pe_end = 0, pe_start = 0;
@@ -93,7 +93,7 @@
 	/* If converting to restricted lvid, check if lvid is compatible */
 	if (!(vg->fid->fmt->features & FMT_RESTRICTED_LVIDS) &&
 	    cmd->fmt->features & FMT_RESTRICTED_LVIDS)
-		list_iterate_items(lvl, &vg->lvs)
+		dm_list_iterate_items(lvl, &vg->lvs)
 			if (!lvid_in_restricted_range(&lvl->lv->lvid)) {
 				log_error("Logical volume %s lvid format is"
 					  " incompatible with requested"
@@ -103,7 +103,7 @@
 
 	/* Attempt to change any LVIDs that are too big */
 	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
-		list_iterate_items(lvl, &vg->lvs) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
 			lv = lvl->lv;
 			if (lv->status & SNAPSHOT)
 				continue;
@@ -124,14 +124,14 @@
 	if (active)
 		return ECMD_FAILED;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
 
 		pe_start = pv_pe_start(existing_pv);
 		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
 		    + pe_start - 1;
 
-		list_init(&mdas);
+		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
 				     &existing_pv->id, size,
 				     pe_start, pv_pe_count(existing_pv),
--- LVM2/tools/vgexport.c	2008/01/30 14:00:02	1.18
+++ LVM2/tools/vgexport.c	2008/11/03 22:14:30	1.19
@@ -48,7 +48,7 @@
 
 	vg->status |= EXPORTED_VG;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		pv->status |= EXPORTED_VG;
 	}
--- LVM2/tools/vgimport.c	2008/01/30 14:00:02	1.17
+++ LVM2/tools/vgimport.c	2008/11/03 22:14:30	1.18
@@ -44,7 +44,7 @@
 
 	vg->status &= ~EXPORTED_VG;
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		pv->status &= ~EXPORTED_VG;
 	}
--- LVM2/tools/vgmerge.c	2008/06/06 19:32:35	1.49
+++ LVM2/tools/vgmerge.c	2008/11/03 22:14:30	1.50
@@ -52,23 +52,23 @@
 	drop_cached_metadata(vg_from);
 
 	/* Merge volume groups */
-	while (!list_empty(&vg_from->pvs)) {
-		struct list *pvh = vg_from->pvs.n;
+	while (!dm_list_empty(&vg_from->pvs)) {
+		struct dm_list *pvh = vg_from->pvs.n;
 		struct physical_volume *pv;
 
-		list_move(&vg_to->pvs, pvh);
+		dm_list_move(&vg_to->pvs, pvh);
 
-		pv = list_item(pvh, struct pv_list)->pv;
+		pv = dm_list_item(pvh, struct pv_list)->pv;
 		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
 	}
 	vg_to->pv_count += vg_from->pv_count;
 
 	/* Fix up LVIDs */
-	list_iterate_items(lvl1, &vg_to->lvs) {
+	dm_list_iterate_items(lvl1, &vg_to->lvs) {
 		union lvid *lvid1 = &lvl1->lv->lvid;
 		char uuid[64] __attribute((aligned(8)));
 
-		list_iterate_items(lvl2, &vg_from->lvs) {
+		dm_list_iterate_items(lvl2, &vg_from->lvs) {
 			union lvid *lvid2 = &lvl2->lv->lvid;
 
 			if (id_equal(&lvid1->id[1], &lvid2->id[1])) {
@@ -88,16 +88,16 @@
 		}
 	}
 
-	while (!list_empty(&vg_from->lvs)) {
-		struct list *lvh = vg_from->lvs.n;
+	while (!dm_list_empty(&vg_from->lvs)) {
+		struct dm_list *lvh = vg_from->lvs.n;
 
-		list_move(&vg_to->lvs, lvh);
+		dm_list_move(&vg_to->lvs, lvh);
 	}
 
-	while (!list_empty(&vg_from->fid->metadata_areas)) {
-		struct list *mdah = vg_from->fid->metadata_areas.n;
+	while (!dm_list_empty(&vg_from->fid->metadata_areas)) {
+		struct dm_list *mdah = vg_from->fid->metadata_areas.n;
 
-		list_move(&vg_to->fid->metadata_areas, mdah);
+		dm_list_move(&vg_to->fid->metadata_areas, mdah);
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
--- LVM2/tools/vgreduce.c	2008/09/19 15:44:03	1.84
+++ LVM2/tools/vgreduce.c	2008/11/03 22:14:30	1.85
@@ -41,16 +41,16 @@
 	vg->extent_count -= pvl->pv->pe_count;
 	vg->pv_count--;
 
-	list_del(&pvl->list);
+	dm_list_del(&pvl->list);
 
 	return 1;
 }
 
 static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
-		      int *list_unsafe, struct list *lvs_changed)
+		      int *list_unsafe, struct dm_list *lvs_changed)
 {
 	struct lv_segment *snap_seg;
-	struct list *snh, *snht;
+	struct dm_list *snh, *snht;
 	struct logical_volume *cow;
 	struct lv_list *lvl;
 	struct lvinfo info;
@@ -77,8 +77,8 @@
 	}
 
 	/* Remove snapshot dependencies */
-	list_iterate_safe(snh, snht, &lv->snapshot_segs) {
-		snap_seg = list_struct_base(snh, struct lv_segment,
+	dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
+		snap_seg = dm_list_struct_base(snh, struct lv_segment,
 					    origin_list);
 		cow = snap_seg->cow;
 
@@ -120,7 +120,7 @@
 			return 0;
 		}
 		lvl->lv = lv;
-		list_add(lvs_changed, &lvl->list);
+		dm_list_add(lvs_changed, &lvl->list);
 	} else {
 		/* Remove LV immediately. */
 		log_verbose("Removing LV %s from VG %s", lv->name, lv->vg->name);
@@ -137,7 +137,7 @@
 	struct lv_list *lvl;
 	int r = 1;
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lvl->lv->status & PARTIAL_LV) {
 			log_warn("WARNING: Partial LV %s needs to be repaired "
 				 "or removed. ", lvl->lv->name);
@@ -151,7 +151,7 @@
 		log_warn("Proceeding to remove empty missing PVs.");
 	}
 
-	list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
 			continue;
 		if (r && !_remove_pv(vg, pvl, 0))
@@ -163,8 +163,8 @@
 
 static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 {
-	struct list *pvh, *pvht;
-	struct list *lvh, *lvht;
+	struct dm_list *pvh, *pvht;
+	struct dm_list *lvh, *lvht;
 	struct pv_list *pvl;
 	struct lv_list *lvl, *lvl2, *lvlt;
 	struct logical_volume *lv;
@@ -173,18 +173,18 @@
 	unsigned s;
 	uint32_t mimages, remove_log;
 	int list_unsafe, only_mirror_images_found;
-	LIST_INIT(lvs_changed);
+	DM_LIST_INIT(lvs_changed);
 	only_mirror_images_found = 1;
 
 	/* Deactivate & remove necessary LVs */
       restart_loop:
 	list_unsafe = 0;	/* Set if we delete a different list-member */
 
-	list_iterate_safe(lvh, lvht, &vg->lvs) {
-		lv = list_item(lvh, struct lv_list)->lv;
+	dm_list_iterate_safe(lvh, lvht, &vg->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
 
 		/* Are any segments of this LV on missing PVs? */
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			for (s = 0; s < seg->area_count; s++) {
 				if (seg_type(seg, s) != AREA_PV)
 					continue;
@@ -222,8 +222,8 @@
 	 * up *after* the PVs are removed. All this should be gradually
 	 * superseded by lvconvert --repair.
 	 */
-	list_iterate_safe(pvh, pvht, &vg->pvs) {
-		pvl = list_item(pvh, struct pv_list);
+	dm_list_iterate_safe(pvh, pvht, &vg->pvs) {
+		pvl = dm_list_item(pvh, struct pv_list);
 		if (pvl->pv->dev)
 			continue;
 		if (!_remove_pv(vg, pvl, 0))
@@ -232,7 +232,7 @@
 
 	/* FIXME Recovery.  For now people must clean up by hand. */
 
-	if (!list_empty(&lvs_changed)) {
+	if (!dm_list_empty(&lvs_changed)) {
 		if (!vg_write(vg)) {
 			log_error("Failed to write out a consistent VG for %s",
 				  vg->name);
@@ -264,7 +264,7 @@
 
   lvs_changed_altered:
 		/* Remove lost mirror images from mirrors */
-		list_iterate_items(lvl, &vg->lvs) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
   mirrored_seg_altered:
 			mirrored_seg = first_seg(lvl->lv);
 			if (!seg_is_mirrored(mirrored_seg))
@@ -274,11 +274,11 @@
 			remove_log = 0;
 
 			for (s = 0; s < mirrored_seg->area_count; s++) {
-				list_iterate_items_safe(lvl2, lvlt, &lvs_changed) {
+				dm_list_iterate_items_safe(lvl2, lvlt, &lvs_changed) {
 					if (seg_type(mirrored_seg, s) != AREA_LV ||
 					    lvl2->lv != seg_lv(mirrored_seg, s))
 						continue;
-					list_del(&lvl2->list);
+					dm_list_del(&lvl2->list);
 					if (!shift_mirror_images(mirrored_seg, s))
 						return_0;
 					mimages--;	/* FIXME Assumes uniqueness */
@@ -286,7 +286,7 @@
 			}
 
 			if (mirrored_seg->log_lv) {
-				list_iterate_items(seg, &mirrored_seg->log_lv->segments) {
+				dm_list_iterate_items(seg, &mirrored_seg->log_lv->segments) {
 					/* FIXME: The second test shouldn't be required */
 					if ((seg->segtype ==
 					     get_segtype_from_string(vg->cmd, "error"))) {
@@ -343,7 +343,7 @@
 
 		/* Deactivate error LVs */
 		if (!test_mode()) {
-			list_iterate_items_safe(lvl, lvlt, &lvs_changed) {
+			dm_list_iterate_items_safe(lvl, lvlt, &lvs_changed) {
 				log_verbose("Deactivating (if active) logical volume %s",
 					    lvl->lv->name);
 
@@ -356,13 +356,13 @@
 					 * Don't try to lv_remove it.
 					 * Continue work on others.
 					 */
-					list_del(&lvl->list);
+					dm_list_del(&lvl->list);
 				}
 			}
 		}
 
 		/* Remove remaining LVs */
-		list_iterate_items(lvl, &lvs_changed) {
+		dm_list_iterate_items(lvl, &lvs_changed) {
 			log_verbose("Removing LV %s from VG %s", lvl->lv->name,
 				    lvl->lv->vg->name);
 				/* Skip LVs already removed by mirror code */
@@ -411,7 +411,7 @@
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
 	if (pvl)
-		list_del(&pvl->list);
+		dm_list_del(&pvl->list);
 
 	pv->vg_name = vg->fid->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
--- LVM2/tools/vgrename.c	2008/06/06 16:13:35	1.54
+++ LVM2/tools/vgrename.c	2008/11/03 22:14:30	1.55
@@ -23,7 +23,7 @@
 	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
-	struct list *vgids;
+	struct dm_list *vgids;
 	struct str_list *sl;
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
@@ -41,12 +41,12 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
 	/* Avoid duplicates */
-	if (!(vgids = get_vgids(cmd, 0)) || list_empty(vgids)) {
+	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");
 		return 0;
 	}
 
-	list_iterate_items(sl, vgids) {
+	dm_list_iterate_items(sl, vgids) {
 		vgid = sl->str;
 		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)) ||
 		    is_orphan_vg(vg_name))
--- LVM2/tools/vgsplit.c	2008/04/23 14:33:06	1.67
+++ LVM2/tools/vgsplit.c	2008/11/03 22:14:30	1.68
@@ -28,7 +28,7 @@
 		return 0;
 	}
 
-	list_move(&vg_to->pvs, &pvl->list);
+	dm_list_move(&vg_to->pvs, &pvl->list);
 
 	vg_from->pv_count--;
 	vg_to->pv_count++;
@@ -60,7 +60,7 @@
 		return 0;
 	}
 
-	list_iterate_items(lvseg, &lvl->lv->segments) {
+	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
 		if (lvseg->log_lv)
 			if (!_move_pvs_used_by_lv(vg_from, vg_to,
 						     lvseg->log_lv->name))
@@ -86,7 +86,7 @@
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv == lvl->lv)
 			 return 1;
 
@@ -95,11 +95,11 @@
 
 static int _move_one_lv(struct volume_group *vg_from,
 			 struct volume_group *vg_to,
-			 struct list *lvh)
+			 struct dm_list *lvh)
 {
-	struct logical_volume *lv = list_item(lvh, struct lv_list)->lv;
+	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 
-	list_move(&vg_to->lvs, lvh);
+	dm_list_move(&vg_to->lvs, lvh);
 	
 	if (lv_is_active(lv)) {
 		log_error("Logical volume \"%s\" must be inactive", lv->name);
@@ -118,15 +118,15 @@
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 {
-	struct list *lvh, *lvht;
+	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
 	struct lv_segment *seg;
 	struct physical_volume *pv;
 	struct volume_group *vg_with;
 	unsigned s;
 
-	list_iterate_safe(lvh, lvht, &vg_from->lvs) {
-		lv = list_item(lvh, struct lv_list)->lv;
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
 
 		if ((lv->status & SNAPSHOT))
 			continue;
@@ -137,7 +137,7 @@
 		/* Ensure all the PVs used by this LV remain in the same */
 		/* VG as each other */
 		vg_with = NULL;
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			for (s = 0; s < seg->area_count; s++) {
 				/* FIXME Check AREA_LV too */
 				if (seg_type(seg, s) != AREA_PV)
@@ -189,19 +189,19 @@
 static int _move_snapshots(struct volume_group *vg_from,
 			   struct volume_group *vg_to)
 {
-	struct list *lvh, *lvht;
+	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
 	struct lv_segment *seg;
 	int cow_from = 0;
 	int origin_from = 0;
 
-	list_iterate_safe(lvh, lvht, &vg_from->lvs) {
-		lv = list_item(lvh, struct lv_list)->lv;
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
 
 		if (!(lv->status & SNAPSHOT))
 			continue;
 
-		list_iterate_items(seg, &lv->segments) {
+		dm_list_iterate_items(seg, &lv->segments) {
 			cow_from = _lv_is_in_vg(vg_from, seg->cow);
 			origin_from = _lv_is_in_vg(vg_from, seg->origin);
 
@@ -233,13 +233,13 @@
 static int _move_mirrors(struct volume_group *vg_from,
 			 struct volume_group *vg_to)
 {
-	struct list *lvh, *lvht;
+	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
 	struct lv_segment *seg;
 	unsigned s, seg_in, log_in;
 
-	list_iterate_safe(lvh, lvht, &vg_from->lvs) {
-		lv = list_item(lvh, struct lv_list)->lv;
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
 
 		if (!(lv->status & MIRRORED))
 			continue;


