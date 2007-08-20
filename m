From: agk@sourceware.org <agk@sourceware.org>
Date: Mon, 20 Aug 2007 20:56:32 -0000
Subject: LVM2 ./COPYING.LIB ./Makefile.in ./WHATS_NEW l ...
Message-ID: <20070820205552.20490.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-20 20:55:30

Modified files:
	.              : COPYING.LIB Makefile.in WHATS_NEW 
	lib            : Makefile.in 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h fs.c fs.h targets.h 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : errors.h toolcontext.c toolcontext.h 
	lib/config     : config.c config.h defaults.h 
	lib/datastruct : btree.c btree.h list.c list.h lvm-types.h 
	                 str_list.c str_list.h 
	lib/device     : dev-cache.c dev-cache.h dev-io.c dev-md.c 
	                 device.c device.h 
	lib/display    : display.c display.h 
	lib/error      : errseg.c 
	lib/filters    : filter-composite.c filter-composite.h 
	                 filter-md.c filter-persistent.c 
	                 filter-persistent.h filter-regex.c 
	                 filter-regex.h filter-sysfs.c filter-sysfs.h 
	                 filter.c filter.h 
	lib/format1    : disk-rep.c disk-rep.h format1.c format1.h 
	                 import-export.c import-extents.c layout.c 
	                 lvm1-label.c lvm1-label.h vg_number.c 
	lib/format_pool: disk_rep.c disk_rep.h format_pool.c 
	                 format_pool.h import_export.c pool_label.c 
	                 pool_label.h sptype_names.h 
	lib/format_text: archive.c archiver.c archiver.h export.c 
	                 flags.c format-text.c format-text.h 
	                 import-export.h import.c import_vsn1.c layout.h 
	                 tags.c text_export.h text_import.h text_label.c 
	lib/label      : label.c label.h 
	lib/locking    : cluster_locking.c external_locking.c 
	                 file_locking.c locking.c locking.h 
	                 locking_types.h no_locking.c 
	lib/log        : log.c log.h 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 
	                 metadata-exported.h metadata.c metadata.h 
	                 mirror.c pv_alloc.h pv_manip.c pv_map.c 
	                 pv_map.h segtype.c segtype.h snapshot_manip.c 
	lib/mirror     : mirrored.c 
	lib/misc       : crc.c crc.h intl.h lib.h lvm-exec.c lvm-exec.h 
	                 lvm-file.c lvm-file.h lvm-string.c lvm-string.h 
	                 lvm-wrappers.c lvm-wrappers.h sharedlib.c 
	                 sharedlib.h timestamp.c timestamp.h util.c 
	                 util.h 
	lib/mm         : memlock.c memlock.h xlate.h 
	lib/report     : columns.h report.c report.h 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/uuid       : uuid.c uuid.h 
	lib/zero       : zero.c 
	man            : Makefile.in 
	scripts        : lvm_dump.sh 
	tools          : Makefile.in args.h cmdnames.h commands.h 
	                 dumpconfig.c formats.c lvchange.c lvconvert.c 
	                 lvcreate.c lvdisplay.c lvextend.c lvm-static.c 
	                 lvm.c lvm2cmd-static.c lvm2cmd.c lvm2cmd.h 
	                 lvm2cmdline.h lvmchange.c lvmcmdlib.c 
	                 lvmcmdline.c lvmdiskscan.c lvreduce.c 
	                 lvremove.c lvrename.c lvresize.c lvscan.c 
	                 polldaemon.c polldaemon.h pvchange.c pvck.c 
	                 pvcreate.c pvdisplay.c pvmove.c pvremove.c 
	                 pvresize.c pvscan.c reporter.c segtypes.c 
	                 stub.h toollib.c toollib.h tools.h 
	                 vgcfgbackup.c vgcfgrestore.c vgchange.c vgck.c 
	                 vgconvert.c vgcreate.c vgdisplay.c vgexport.c 
	                 vgextend.c vgimport.c vgmerge.c vgmknodes.c 
	                 vgreduce.c vgremove.c vgrename.c vgscan.c 
	                 vgsplit.c 
	tools/fsadm    : fsadm.c 

Log message:
	Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/COPYING.LIB.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.685&r2=1.686
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/targets.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/errors.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-composite.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-composite.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-md.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/layout.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/vg_number.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/sptype_names.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_import.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_alloc.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/intl.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/sharedlib.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/sharedlib.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/timestamp.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/timestamp.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/xlate.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/cmdnames.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/formats.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvdisplay.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvextend.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd-static.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmchange.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvreduce.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/segtypes.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/stub.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmknodes.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/fsadm.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/COPYING.LIB	2001/12/31 16:12:40	1.1
+++ LVM2/COPYING.LIB	2007/08/20 20:55:23	1.2
@@ -1,14 +1,14 @@
+		  GNU LESSER GENERAL PUBLIC LICENSE
+		       Version 2.1, February 1999
 
-		  GNU LIBRARY GENERAL PUBLIC LICENSE
-		       Version 2, June 1991
-
- Copyright (C) 1991 Free Software Foundation, Inc.
- 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
+ Copyright (C) 1991, 1999 Free Software Foundation, Inc.
+ 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
-[This is the first released version of the library GPL.  It is
- numbered 2 because it goes with version 2 of the ordinary GPL.]
+[This is the first released version of the Lesser GPL.  It also counts
+ as the successor of the GNU Library Public License, version 2, hence
+ the version number 2.1.]
 
 			    Preamble
 
@@ -17,97 +17,109 @@
 Licenses are intended to guarantee your freedom to share and change
 free software--to make sure the software is free for all its users.
 
-  This license, the Library General Public License, applies to some
-specially designated Free Software Foundation software, and to any
-other libraries whose authors decide to use it.  You can use it for
-your libraries, too.
-
-  When we speak of free software, we are referring to freedom, not
-price.  Our General Public Licenses are designed to make sure that you
-have the freedom to distribute copies of free software (and charge for
-this service if you wish), that you receive source code or can get it
-if you want it, that you can change the software or use pieces of it
-in new free programs; and that you know you can do these things.
+  This license, the Lesser General Public License, applies to some
+specially designated software packages--typically libraries--of the
+Free Software Foundation and other authors who decide to use it.  You
+can use it too, but we suggest you first think carefully about whether
+this license or the ordinary General Public License is the better
+strategy to use in any particular case, based on the explanations below.
+
+  When we speak of free software, we are referring to freedom of use,
+not price.  Our General Public Licenses are designed to make sure that
+you have the freedom to distribute copies of free software (and charge
+for this service if you wish); that you receive source code or can get
+it if you want it; that you can change the software and use pieces of
+it in new free programs; and that you are informed that you can do
+these things.
 
   To protect your rights, we need to make restrictions that forbid
-anyone to deny you these rights or to ask you to surrender the rights.
-These restrictions translate to certain responsibilities for you if
-you distribute copies of the library, or if you modify it.
+distributors to deny you these rights or to ask you to surrender these
+rights.  These restrictions translate to certain responsibilities for
+you if you distribute copies of the library or if you modify it.
 
   For example, if you distribute copies of the library, whether gratis
 or for a fee, you must give the recipients all the rights that we gave
 you.  You must make sure that they, too, receive or can get the source
-code.  If you link a program with the library, you must provide
-complete object files to the recipients so that they can relink them
-with the library, after making changes to the library and recompiling
+code.  If you link other code with the library, you must provide
+complete object files to the recipients, so that they can relink them
+with the library after making changes to the library and recompiling
 it.  And you must show them these terms so they know their rights.
 
-  Our method of protecting your rights has two steps: (1) copyright
-the library, and (2) offer you this license which gives you legal
+  We protect your rights with a two-step method: (1) we copyright the
+library, and (2) we offer you this license, which gives you legal
 permission to copy, distribute and/or modify the library.
 
-  Also, for each distributor's protection, we want to make certain
-that everyone understands that there is no warranty for this free
-library.  If the library is modified by someone else and passed on, we
-want its recipients to know that what they have is not the original
-version, so that any problems introduced by others will not reflect on
-the original authors' reputations.
+  To protect each distributor, we want to make it very clear that
+there is no warranty for the free library.  Also, if the library is
+modified by someone else and passed on, the recipients should know
+that what they have is not the original version, so that the original
+author's reputation will not be affected by problems that might be
+introduced by others.
 
-  Finally, any free program is threatened constantly by software
-patents.  We wish to avoid the danger that companies distributing free
-software will individually obtain patent licenses, thus in effect
-transforming the program into proprietary software.  To prevent this,
-we have made it clear that any patent must be licensed for everyone's
-free use or not licensed at all.
-
-  Most GNU software, including some libraries, is covered by the ordinary
-GNU General Public License, which was designed for utility programs.  This
-license, the GNU Library General Public License, applies to certain
-designated libraries.  This license is quite different from the ordinary
-one; be sure to read it in full, and don't assume that anything in it is
-the same as in the ordinary license.
-
-  The reason we have a separate public license for some libraries is that
-they blur the distinction we usually make between modifying or adding to a
-program and simply using it.  Linking a program with a library, without
-changing the library, is in some sense simply using the library, and is
-analogous to running a utility program or application program.  However, in
-a textual and legal sense, the linked executable is a combined work, a
-derivative of the original library, and the ordinary General Public License
-treats it as such.
-
-  Because of this blurred distinction, using the ordinary General
-Public License for libraries did not effectively promote software
-sharing, because most developers did not use the libraries.  We
-concluded that weaker conditions might promote sharing better.
-
-  However, unrestricted linking of non-free programs would deprive the
-users of those programs of all benefit from the free status of the
-libraries themselves.  This Library General Public License is intended to
-permit developers of non-free programs to use free libraries, while
-preserving your freedom as a user of such programs to change the free
-libraries that are incorporated in them.  (We have not seen how to achieve
-this as regards changes in header files, but we have achieved it as regards
-changes in the actual functions of the Library.)  The hope is that this
-will lead to faster development of free libraries.
+  Finally, software patents pose a constant threat to the existence of
+any free program.  We wish to make sure that a company cannot
+effectively restrict the users of a free program by obtaining a
+restrictive license from a patent holder.  Therefore, we insist that
+any patent license obtained for a version of the library must be
+consistent with the full freedom of use specified in this license.
+
+  Most GNU software, including some libraries, is covered by the
+ordinary GNU General Public License.  This license, the GNU Lesser
+General Public License, applies to certain designated libraries, and
+is quite different from the ordinary General Public License.  We use
+this license for certain libraries in order to permit linking those
+libraries into non-free programs.
+
+  When a program is linked with a library, whether statically or using
+a shared library, the combination of the two is legally speaking a
+combined work, a derivative of the original library.  The ordinary
+General Public License therefore permits such linking only if the
+entire combination fits its criteria of freedom.  The Lesser General
+Public License permits more lax criteria for linking other code with
+the library.
+
+  We call this license the "Lesser" General Public License because it
+does Less to protect the user's freedom than the ordinary General
+Public License.  It also provides other free software developers Less
+of an advantage over competing non-free programs.  These disadvantages
+are the reason we use the ordinary General Public License for many
+libraries.  However, the Lesser license provides advantages in certain
+special circumstances.
+
+  For example, on rare occasions, there may be a special need to
+encourage the widest possible use of a certain library, so that it becomes
+a de-facto standard.  To achieve this, non-free programs must be
+allowed to use the library.  A more frequent case is that a free
+library does the same job as widely used non-free libraries.  In this
+case, there is little to gain by limiting the free library to free
+software only, so we use the Lesser General Public License.
+
+  In other cases, permission to use a particular library in non-free
+programs enables a greater number of people to use a large body of
+free software.  For example, permission to use the GNU C Library in
+non-free programs enables many more people to use the whole GNU
+operating system, as well as its variant, the GNU/Linux operating
+system.
+
+  Although the Lesser General Public License is Less protective of the
+users' freedom, it does ensure that the user of a program that is
+linked with the Library has the freedom and the wherewithal to run
+that program using a modified version of the Library.
 
   The precise terms and conditions for copying, distribution and
 modification follow.  Pay close attention to the difference between a
 "work based on the library" and a "work that uses the library".  The
-former contains code derived from the library, while the latter only
-works together with the library.
-
-  Note that it is possible for a library to be covered by the ordinary
-General Public License rather than by this special one.
+former contains code derived from the library, whereas the latter must
+be combined with the library in order to run.
 
-		  GNU LIBRARY GENERAL PUBLIC LICENSE
+		  GNU LESSER GENERAL PUBLIC LICENSE
    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
-  0. This License Agreement applies to any software library which
-contains a notice placed by the copyright holder or other authorized
-party saying it may be distributed under the terms of this Library
-General Public License (also called "this License").  Each licensee is
-addressed as "you".
+  0. This License Agreement applies to any software library or other
+program which contains a notice placed by the copyright holder or
+other authorized party saying it may be distributed under the terms of
+this Lesser General Public License (also called "this License").
+Each licensee is addressed as "you".
 
   A "library" means a collection of software functions and/or data
 prepared so as to be conveniently linked with application programs
@@ -256,7 +268,7 @@
 Any executables containing that work also fall under Section 6,
 whether or not they are linked directly with the Library itself.
 
-  6. As an exception to the Sections above, you may also compile or
+  6. As an exception to the Sections above, you may also combine or
 link a "work that uses the Library" with the Library to produce a
 work containing portions of the Library, and distribute that work
 under terms of your choice, provided that the terms permit
@@ -283,23 +295,31 @@
     Library will not necessarily be able to recompile the application
     to use the modified definitions.)
 
-    b) Accompany the work with a written offer, valid for at
+    b) Use a suitable shared library mechanism for linking with the
+    Library.  A suitable mechanism is one that (1) uses at run time a
+    copy of the library already present on the user's computer system,
+    rather than copying library functions into the executable, and (2)
+    will operate properly with a modified version of the library, if
+    the user installs one, as long as the modified version is
+    interface-compatible with the version that the work was made with.
+
+    c) Accompany the work with a written offer, valid for at
     least three years, to give the same user the materials
     specified in Subsection 6a, above, for a charge no more
     than the cost of performing this distribution.
 
-    c) If distribution of the work is made by offering access to copy
+    d) If distribution of the work is made by offering access to copy
     from a designated place, offer equivalent access to copy the above
     specified materials from the same place.
 
-    d) Verify that the user has already received a copy of these
+    e) Verify that the user has already received a copy of these
     materials or that you have already sent this user a copy.
 
   For an executable, the required form of the "work that uses the
 Library" must include any data and utility programs needed for
 reproducing the executable from it.  However, as a special exception,
-the source code distributed need not include anything that is normally
-distributed (in either source or binary form) with the major
+the materials to be distributed need not include anything that is
+normally distributed (in either source or binary form) with the major
 components (compiler, kernel, and so on) of the operating system on
 which the executable runs, unless that component itself accompanies
 the executable.
@@ -348,7 +368,7 @@
 original licensor to copy, distribute, link with or modify the Library
 subject to these terms and conditions.  You may not impose any further
 restrictions on the recipients' exercise of the rights granted herein.
-You are not responsible for enforcing compliance by third parties to
+You are not responsible for enforcing compliance by third parties with
 this License.
 
   11. If, as a consequence of a court judgment or allegation of patent
@@ -391,7 +411,7 @@
 written in the body of this License.
 
   13. The Free Software Foundation may publish revised and/or new
-versions of the Library General Public License from time to time.
+versions of the Lesser General Public License from time to time.
 Such new versions will be similar in spirit to the present version,
 but may differ in detail to address new problems or concerns.
 
@@ -437,7 +457,7 @@
 
 		     END OF TERMS AND CONDITIONS
 
-     Appendix: How to Apply These Terms to Your New Libraries
+           How to Apply These Terms to Your New Libraries
 
   If you develop a new library, and you want it to be of the greatest
 possible use to the public, we recommend making it free software that
@@ -454,19 +474,18 @@
     Copyright (C) <year>  <name of author>
 
     This library is free software; you can redistribute it and/or
-    modify it under the terms of the GNU Library General Public
+    modify it under the terms of the GNU Lesser General Public
     License as published by the Free Software Foundation; either
-    version 2 of the License, or (at your option) any later version.
+    version 2.1 of the License, or (at your option) any later version.
 
     This library is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-    Library General Public License for more details.
+    Lesser General Public License for more details.
 
-    You should have received a copy of the GNU Library General Public
-    License along with this library; if not, write to the Free
-    Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
-    MA 02111-1307, USA
+    You should have received a copy of the GNU Lesser General Public
+    License along with this library; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 
 Also add information on how to contact you by electronic and paper mail.
 
@@ -481,3 +500,5 @@
   Ty Coon, President of Vice
 
 That's all there is to it!
+
+
--- LVM2/Makefile.in	2006/11/20 20:03:26	1.17
+++ LVM2/Makefile.in	2007/08/20 20:55:24	1.18
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
--- LVM2/WHATS_NEW	2007/08/20 17:05:49	1.685
+++ LVM2/WHATS_NEW	2007/08/20 20:55:24	1.686
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.
   Move guts of lvremove into library.
   Allow clvmd debug to be turned on in a running daemon using clvmd -d
   Update to use autoconf 2.61, while still supporting 2.57.
--- LVM2/lib/Makefile.in	2007/07/20 15:48:39	1.82
+++ LVM2/lib/Makefile.in	2007/08/20 20:55:24	1.83
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
--- LVM2/lib/activate/activate.c	2007/08/07 09:06:05	1.126
+++ LVM2/lib/activate/activate.c	2007/08/20 20:55:24	1.127
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/activate.h	2007/08/07 09:06:05	1.57
+++ LVM2/lib/activate/activate.h	2007/08/20 20:55:24	1.58
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/dev_manager.c	2007/08/06 14:57:48	1.126
+++ LVM2/lib/activate/dev_manager.c	2007/08/20 20:55:24	1.127
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/dev_manager.h	2006/08/08 21:20:00	1.26
+++ LVM2/lib/activate/dev_manager.h	2007/08/20 20:55:24	1.27
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/fs.c	2007/05/15 14:42:01	1.39
+++ LVM2/lib/activate/fs.c	2007/08/20 20:55:24	1.40
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/fs.h	2007/05/15 14:42:01	1.11
+++ LVM2/lib/activate/fs.h	2007/08/20 20:55:24	1.12
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/activate/targets.h	2006/05/09 21:23:50	1.7
+++ LVM2/lib/activate/targets.h	2007/08/20 20:55:24	1.8
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/cache/lvmcache.c	2007/04/23 18:21:01	1.30
+++ LVM2/lib/cache/lvmcache.c	2007/08/20 20:55:24	1.31
@@ -1,17 +1,16 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- *
  */
 
 #include "lib.h"
--- LVM2/lib/cache/lvmcache.h	2006/04/21 19:12:41	1.14
+++ LVM2/lib/cache/lvmcache.h	2007/08/20 20:55:24	1.15
@@ -1,17 +1,16 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- *
  */
 
 #ifndef _LVM_CACHE_H
--- LVM2/lib/commands/errors.h	2004/03/30 19:35:37	1.4
+++ LVM2/lib/commands/errors.h	2007/08/20 20:55:24	1.5
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/commands/toolcontext.c	2007/07/28 12:26:21	1.53
+++ LVM2/lib/commands/toolcontext.c	2007/08/20 20:55:24	1.54
@@ -1,17 +1,16 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- *
  */
 
 #include "lib.h"
--- LVM2/lib/commands/toolcontext.h	2007/01/23 15:58:06	1.19
+++ LVM2/lib/commands/toolcontext.h	2007/08/20 20:55:24	1.20
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/config/config.c	2007/07/24 17:48:07	1.63
+++ LVM2/lib/config/config.c	2007/08/20 20:55:24	1.64
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/config/config.h	2007/04/27 20:41:50	1.24
+++ LVM2/lib/config/config.h	2007/08/20 20:55:24	1.25
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/config/defaults.h	2007/02/28 18:27:12	1.31
+++ LVM2/lib/config/defaults.h	2007/08/20 20:55:24	1.32
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/btree.c	2007/08/07 09:06:05	1.10
+++ LVM2/lib/datastruct/btree.c	2007/08/20 20:55:24	1.11
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/btree.h	2007/08/07 09:06:05	1.5
+++ LVM2/lib/datastruct/btree.h	2007/08/20 20:55:24	1.6
@@ -1,14 +1,14 @@
 /*
- * Copyright (C) 2001-2004, 2007 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/list.c	2007/08/07 09:06:05	1.2
+++ LVM2/lib/datastruct/list.c	2007/08/20 20:55:24	1.3
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/list.h	2007/08/07 09:06:05	1.24
+++ LVM2/lib/datastruct/list.h	2007/08/20 20:55:24	1.25
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/lvm-types.h	2007/04/26 16:40:46	1.12
+++ LVM2/lib/datastruct/lvm-types.h	2007/08/20 20:55:24	1.13
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/str_list.c	2007/08/07 09:06:05	1.7
+++ LVM2/lib/datastruct/str_list.c	2007/08/20 20:55:24	1.8
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/datastruct/str_list.h	2007/08/07 09:06:05	1.7
+++ LVM2/lib/datastruct/str_list.h	2007/08/20 20:55:24	1.8
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/device/dev-cache.c	2007/07/23 10:45:49	1.49
+++ LVM2/lib/device/dev-cache.c	2007/08/20 20:55:25	1.50
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/device/dev-cache.h	2007/04/26 16:44:58	1.10
+++ LVM2/lib/device/dev-cache.h	2007/08/20 20:55:25	1.11
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/device/dev-io.c	2007/04/19 02:10:41	1.57
+++ LVM2/lib/device/dev-io.c	2007/08/20 20:55:25	1.58
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/device/dev-md.c	2007/01/26 17:15:16	1.4
+++ LVM2/lib/device/dev-md.c	2007/08/20 20:55:25	1.5
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2004 Luca Berra
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/device/device.c	2007/01/15 21:55:11	1.23
+++ LVM2/lib/device/device.c	2007/08/20 20:55:25	1.24
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/device/device.h	2007/04/19 02:10:41	1.33
+++ LVM2/lib/device/device.h	2007/08/20 20:55:25	1.34
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/display/display.c	2007/08/20 17:04:52	1.77
+++ LVM2/lib/display/display.c	2007/08/20 20:55:25	1.78
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/display/display.h	2007/08/20 17:04:52	1.20
+++ LVM2/lib/display/display.h	2007/08/20 20:55:25	1.21
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/error/errseg.c	2007/07/18 15:38:58	1.13
+++ LVM2/lib/error/errseg.c	2007/08/20 20:55:25	1.14
@@ -1,13 +1,13 @@
 /*
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-composite.c	2006/04/19 15:33:06	1.12
+++ LVM2/lib/filters/filter-composite.c	2007/08/20 20:55:25	1.13
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-composite.h	2004/03/30 19:35:38	1.3
+++ LVM2/lib/filters/filter-composite.h	2007/08/20 20:55:25	1.4
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-md.c	2006/10/04 16:03:17	1.6
+++ LVM2/lib/filters/filter-md.c	2007/08/20 20:55:25	1.7
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2004 Luca Berra
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/filters/filter-persistent.c	2007/07/24 17:48:08	1.32
+++ LVM2/lib/filters/filter-persistent.c	2007/08/20 20:55:25	1.33
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-persistent.h	2006/11/04 03:34:09	1.5
+++ LVM2/lib/filters/filter-persistent.h	2007/08/20 20:55:25	1.6
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-regex.c	2007/04/27 18:52:05	1.22
+++ LVM2/lib/filters/filter-regex.c	2007/08/20 20:55:25	1.23
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-regex.h	2004/03/30 19:35:38	1.2
+++ LVM2/lib/filters/filter-regex.h	2007/08/20 20:55:25	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-sysfs.c	2007/04/26 16:44:58	1.15
+++ LVM2/lib/filters/filter-sysfs.c	2007/08/20 20:55:25	1.16
@@ -1,13 +1,13 @@
 /*
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter-sysfs.h	2004/03/30 19:35:38	1.2
+++ LVM2/lib/filters/filter-sysfs.h	2007/08/20 20:55:25	1.3
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter.c	2007/07/26 13:28:32	1.41
+++ LVM2/lib/filters/filter.c	2007/08/20 20:55:25	1.42
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/filters/filter.h	2005/10/25 19:08:20	1.14
+++ LVM2/lib/filters/filter.h	2007/08/20 20:55:25	1.15
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/disk-rep.c	2007/04/26 16:44:58	1.66
+++ LVM2/lib/format1/disk-rep.c	2007/08/20 20:55:25	1.67
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/disk-rep.h	2006/11/30 23:11:40	1.50
+++ LVM2/lib/format1/disk-rep.h	2007/08/20 20:55:25	1.51
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/format1.c	2007/04/26 16:44:58	1.100
+++ LVM2/lib/format1/format1.c	2007/08/20 20:55:25	1.101
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/format1.h	2004/03/30 19:35:39	1.11
+++ LVM2/lib/format1/format1.h	2007/08/20 20:55:25	1.12
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/import-export.c	2006/10/19 12:53:46	1.84
+++ LVM2/lib/format1/import-export.c	2007/08/20 20:55:25	1.85
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/import-extents.c	2007/04/26 16:44:58	1.33
+++ LVM2/lib/format1/import-extents.c	2007/08/20 20:55:25	1.34
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/layout.c	2006/08/17 19:15:27	1.25
+++ LVM2/lib/format1/layout.c	2007/08/20 20:55:25	1.26
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/lvm1-label.c	2006/11/30 23:11:40	1.14
+++ LVM2/lib/format1/lvm1-label.c	2007/08/20 20:55:25	1.15
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/lvm1-label.h	2004/03/30 19:35:39	1.2
+++ LVM2/lib/format1/lvm1-label.h	2007/08/20 20:55:25	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format1/vg_number.c	2006/05/09 21:23:50	1.12
+++ LVM2/lib/format1/vg_number.c	2007/08/20 20:55:25	1.13
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/disk_rep.c	2006/11/30 23:11:40	1.9
+++ LVM2/lib/format_pool/disk_rep.c	2007/08/20 20:55:25	1.10
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/disk_rep.h	2006/11/30 23:11:40	1.5
+++ LVM2/lib/format_pool/disk_rep.h	2007/08/20 20:55:25	1.6
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/format_pool.c	2006/05/09 21:23:50	1.9
+++ LVM2/lib/format_pool/format_pool.c	2007/08/20 20:55:25	1.10
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/format_pool.h	2004/06/07 19:10:21	1.1
+++ LVM2/lib/format_pool/format_pool.h	2007/08/20 20:55:25	1.2
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/import_export.c	2006/05/09 21:23:50	1.16
+++ LVM2/lib/format_pool/import_export.c	2007/08/20 20:55:25	1.17
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/pool_label.c	2006/11/30 23:11:40	1.5
+++ LVM2/lib/format_pool/pool_label.c	2007/08/20 20:55:25	1.6
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/pool_label.h	2004/06/07 19:10:21	1.1
+++ LVM2/lib/format_pool/pool_label.h	2007/08/20 20:55:25	1.2
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_pool/sptype_names.h	2005/01/20 18:12:41	1.1
+++ LVM2/lib/format_pool/sptype_names.h	2007/08/20 20:55:25	1.2
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/archive.c	2007/07/24 17:48:08	1.28
+++ LVM2/lib/format_text/archive.c	2007/08/20 20:55:26	1.29
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/archiver.c	2007/07/28 12:26:21	1.8
+++ LVM2/lib/format_text/archiver.c	2007/08/20 20:55:26	1.9
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/archiver.h	2007/07/18 15:38:58	1.3
+++ LVM2/lib/format_text/archiver.h	2007/08/20 20:55:26	1.4
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/export.c	2007/04/27 19:26:57	1.55
+++ LVM2/lib/format_text/export.c	2007/08/20 20:55:26	1.56
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/flags.c	2006/05/11 20:03:40	1.29
+++ LVM2/lib/format_text/flags.c	2007/08/20 20:55:26	1.30
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/format-text.c	2007/08/06 14:57:48	1.80
+++ LVM2/lib/format_text/format-text.c	2007/08/20 20:55:26	1.81
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/format-text.h	2007/06/08 22:38:48	1.21
+++ LVM2/lib/format_text/format-text.h	2007/08/20 20:55:26	1.22
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/import-export.h	2006/04/13 17:32:24	1.19
+++ LVM2/lib/format_text/import-export.h	2007/08/20 20:55:26	1.20
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/import.c	2006/11/04 03:34:09	1.42
+++ LVM2/lib/format_text/import.c	2007/08/20 20:55:26	1.43
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/import_vsn1.c	2007/04/26 16:44:58	1.39
+++ LVM2/lib/format_text/import_vsn1.c	2007/08/20 20:55:26	1.40
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/layout.h	2006/08/17 18:23:43	1.6
+++ LVM2/lib/format_text/layout.h	2007/08/20 20:55:26	1.7
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/tags.c	2005/10/16 23:03:57	1.3
+++ LVM2/lib/format_text/tags.c	2007/08/20 20:55:26	1.4
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/text_export.h	2005/06/07 11:00:07	1.2
+++ LVM2/lib/format_text/text_export.h	2007/08/20 20:55:26	1.3
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/text_import.h	2005/10/16 23:03:57	1.3
+++ LVM2/lib/format_text/text_import.h	2007/08/20 20:55:26	1.4
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/format_text/text_label.c	2006/11/30 23:11:41	1.17
+++ LVM2/lib/format_text/text_label.c	2007/08/20 20:55:26	1.18
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/label/label.c	2007/04/23 18:21:01	1.37
+++ LVM2/lib/label/label.c	2007/08/20 20:55:26	1.38
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/label/label.h	2007/04/23 18:21:01	1.19
+++ LVM2/lib/label/label.h	2007/08/20 20:55:26	1.20
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/cluster_locking.c	2007/01/19 22:21:45	1.17
+++ LVM2/lib/locking/cluster_locking.c	2007/08/20 20:55:26	1.18
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/external_locking.c	2006/05/16 16:48:30	1.11
+++ LVM2/lib/locking/external_locking.c	2007/08/20 20:55:26	1.12
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/file_locking.c	2007/07/28 12:26:21	1.29
+++ LVM2/lib/locking/file_locking.c	2007/08/20 20:55:26	1.30
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/locking.c	2007/06/28 17:33:44	1.38
+++ LVM2/lib/locking/locking.c	2007/08/20 20:55:26	1.39
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/locking.h	2007/06/15 20:46:04	1.32
+++ LVM2/lib/locking/locking.h	2007/08/20 20:55:26	1.33
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/locking_types.h	2006/05/16 16:48:30	1.13
+++ LVM2/lib/locking/locking_types.h	2007/08/20 20:55:26	1.14
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/locking/no_locking.c	2007/03/13 14:59:21	1.11
+++ LVM2/lib/locking/no_locking.c	2007/08/20 20:55:26	1.12
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/log/log.c	2007/07/24 17:48:08	1.40
+++ LVM2/lib/log/log.c	2007/08/20 20:55:26	1.41
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/log/log.h	2007/06/28 17:33:44	1.37
+++ LVM2/lib/log/log.h	2007/08/20 20:55:26	1.38
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/lv_alloc.h	2006/05/09 21:23:50	1.15
+++ LVM2/lib/metadata/lv_alloc.h	2007/08/20 20:55:26	1.16
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/lv_manip.c	2007/08/20 17:04:52	1.123
+++ LVM2/lib/metadata/lv_manip.c	2007/08/20 20:55:26	1.124
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/merge.c	2007/07/10 18:50:03	1.28
+++ LVM2/lib/metadata/merge.c	2007/08/20 20:55:26	1.29
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/metadata-exported.h	2007/08/20 17:04:52	1.9
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/20 20:55:26	1.10
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/metadata.c	2007/08/07 09:06:05	1.131
+++ LVM2/lib/metadata/metadata.c	2007/08/20 20:55:26	1.132
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/metadata.h	2007/07/18 15:38:58	1.170
+++ LVM2/lib/metadata/metadata.h	2007/08/20 20:55:26	1.171
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/mirror.c	2007/06/28 17:33:44	1.39
+++ LVM2/lib/metadata/mirror.c	2007/08/20 20:55:26	1.40
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/pv_alloc.h	2005/10/16 23:03:58	1.5
+++ LVM2/lib/metadata/pv_alloc.h	2007/08/20 20:55:26	1.6
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/pv_manip.c	2006/05/09 21:23:50	1.10
+++ LVM2/lib/metadata/pv_manip.c	2007/08/20 20:55:26	1.11
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 - 2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/pv_map.c	2006/10/23 15:54:51	1.27
+++ LVM2/lib/metadata/pv_map.c	2007/08/20 20:55:26	1.28
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/pv_map.h	2006/10/23 15:54:51	1.8
+++ LVM2/lib/metadata/pv_map.h	2007/08/20 20:55:26	1.9
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/segtype.c	2004/09/16 18:40:55	1.1
+++ LVM2/lib/metadata/segtype.c	2007/08/20 20:55:26	1.2
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/segtype.h	2007/01/24 16:51:24	1.17
+++ LVM2/lib/metadata/segtype.h	2007/08/20 20:55:26	1.18
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/metadata/snapshot_manip.c	2006/04/07 17:41:56	1.24
+++ LVM2/lib/metadata/snapshot_manip.c	2007/08/20 20:55:26	1.25
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/mirror/mirrored.c	2007/01/24 16:51:24	1.45
+++ LVM2/lib/mirror/mirrored.c	2007/08/20 20:55:27	1.46
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/crc.c	2006/05/16 16:48:30	1.4
+++ LVM2/lib/misc/crc.c	2007/08/20 20:55:27	1.5
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/crc.h	2006/05/16 16:48:30	1.4
+++ LVM2/lib/misc/crc.h	2007/08/20 20:55:27	1.5
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/intl.h	2004/03/30 19:35:40	1.2
+++ LVM2/lib/misc/intl.h	2007/08/20 20:55:27	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lib.h	2007/07/20 15:48:39	1.12
+++ LVM2/lib/misc/lib.h	2007/08/20 20:55:27	1.13
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-exec.c	2005/10/17 17:56:27	1.1
+++ LVM2/lib/misc/lvm-exec.c	2007/08/20 20:55:27	1.2
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-exec.h	2006/05/09 21:23:50	1.2
+++ LVM2/lib/misc/lvm-exec.h	2007/08/20 20:55:27	1.3
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-file.c	2007/07/28 15:20:36	1.23
+++ LVM2/lib/misc/lvm-file.c	2007/08/20 20:55:27	1.24
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-file.h	2007/07/28 12:26:21	1.11
+++ LVM2/lib/misc/lvm-file.h	2007/08/20 20:55:27	1.12
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-string.c	2007/04/25 18:24:19	1.13
+++ LVM2/lib/misc/lvm-string.c	2007/08/20 20:55:27	1.14
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-string.h	2007/07/20 15:38:19	1.15
+++ LVM2/lib/misc/lvm-string.h	2007/08/20 20:55:27	1.16
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-wrappers.c	2006/08/17 19:56:28	1.1
+++ LVM2/lib/misc/lvm-wrappers.c	2007/08/20 20:55:27	1.2
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/lvm-wrappers.h	2006/08/17 19:56:28	1.1
+++ LVM2/lib/misc/lvm-wrappers.h	2007/08/20 20:55:27	1.2
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/sharedlib.c	2006/08/31 22:21:00	1.13
+++ LVM2/lib/misc/sharedlib.c	2007/08/20 20:55:27	1.14
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/sharedlib.h	2006/05/16 16:48:30	1.7
+++ LVM2/lib/misc/sharedlib.h	2007/08/20 20:55:27	1.8
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/timestamp.c	2006/10/12 17:18:40	1.2
+++ LVM2/lib/misc/timestamp.c	2007/08/20 20:55:27	1.3
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/timestamp.h	2006/09/30 20:02:02	1.1
+++ LVM2/lib/misc/timestamp.h	2007/08/20 20:55:27	1.2
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/util.c	2007/07/23 10:41:19	1.2
+++ LVM2/lib/misc/util.c	2007/08/20 20:55:27	1.3
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/misc/util.h	2007/07/20 15:48:39	1.1
+++ LVM2/lib/misc/util.h	2007/08/20 20:55:27	1.2
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/mm/memlock.c	2006/08/17 18:23:44	1.9
+++ LVM2/lib/mm/memlock.c	2007/08/20 20:55:27	1.10
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/mm/memlock.h	2004/03/30 19:35:40	1.3
+++ LVM2/lib/mm/memlock.h	2007/08/20 20:55:27	1.4
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/mm/xlate.h	2005/01/20 18:13:17	1.10
+++ LVM2/lib/mm/xlate.h	2007/08/20 20:55:27	1.11
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/report/columns.h	2007/07/09 15:40:43	1.20
+++ LVM2/lib/report/columns.h	2007/08/20 20:55:27	1.21
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/report/report.c	2007/07/10 18:20:00	1.59
+++ LVM2/lib/report/report.c	2007/08/20 20:55:27	1.60
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/report/report.h	2007/07/18 15:38:58	1.4
+++ LVM2/lib/report/report.h	2007/08/20 20:55:27	1.5
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/snapshot/snapshot.c	2007/07/02 11:17:21	1.20
+++ LVM2/lib/snapshot/snapshot.c	2007/08/20 20:55:27	1.21
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/striped/striped.c	2007/07/18 15:38:58	1.21
+++ LVM2/lib/striped/striped.c	2007/08/20 20:55:27	1.22
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/uuid/uuid.c	2006/05/10 16:42:03	1.22
+++ LVM2/lib/uuid/uuid.c	2007/08/20 20:55:27	1.23
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/uuid/uuid.h	2006/05/09 21:23:50	1.14
+++ LVM2/lib/uuid/uuid.h	2007/08/20 20:55:27	1.15
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/lib/zero/zero.c	2007/07/18 15:38:58	1.12
+++ LVM2/lib/zero/zero.c	2007/08/20 20:55:29	1.13
@@ -1,13 +1,13 @@
 /*
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/man/Makefile.in	2007/03/30 21:00:25	1.19
+++ LVM2/man/Makefile.in	2007/08/20 20:55:29	1.20
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
--- LVM2/scripts/lvm_dump.sh	2007/08/20 12:06:35	1.8
+++ LVM2/scripts/lvm_dump.sh	2007/08/20 20:55:29	1.9
@@ -1,5 +1,17 @@
 #!/bin/bash
-# we use some bash-isms (getopts?)
+# We use some bash-isms (getopts?)
+
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # lvm_dump: This script is used to collect pertinent information for
 #           the debugging of lvm issues.
--- LVM2/tools/Makefile.in	2007/03/30 21:00:26	1.79
+++ LVM2/tools/Makefile.in	2007/08/20 20:55:30	1.80
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
--- LVM2/tools/args.h	2007/08/09 21:25:08	1.52
+++ LVM2/tools/args.h	2007/08/20 20:55:30	1.53
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/cmdnames.h	2004/03/30 19:35:42	1.3
+++ LVM2/tools/cmdnames.h	2007/08/20 20:55:30	1.4
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/commands.h	2007/08/09 21:25:08	1.99
+++ LVM2/tools/commands.h	2007/08/20 20:55:30	1.100
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/dumpconfig.c	2007/01/09 23:22:31	1.5
+++ LVM2/tools/dumpconfig.c	2007/08/20 20:55:30	1.6
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/formats.c	2006/05/09 21:23:51	1.2
+++ LVM2/tools/formats.c	2007/08/20 20:55:30	1.3
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvchange.c	2007/06/18 14:14:33	1.80
+++ LVM2/tools/lvchange.c	2007/08/20 20:55:30	1.81
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvconvert.c	2007/08/10 13:33:49	1.33
+++ LVM2/tools/lvconvert.c	2007/08/20 20:55:30	1.34
@@ -1,13 +1,13 @@
 /*
- * Copyright (C) 2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvcreate.c	2007/08/09 21:25:08	1.140
+++ LVM2/tools/lvcreate.c	2007/08/20 20:55:30	1.141
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvdisplay.c	2006/04/07 17:41:56	1.18
+++ LVM2/tools/lvdisplay.c	2007/08/20 20:55:30	1.19
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvextend.c	2004/03/30 19:35:42	1.5
+++ LVM2/tools/lvextend.c	2007/08/20 20:55:30	1.6
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvm-static.c	2007/02/14 16:51:48	1.2
+++ LVM2/tools/lvm-static.c	2007/08/20 20:55:30	1.3
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/tools/lvm.c	2007/02/14 16:51:48	1.102
+++ LVM2/tools/lvm.c	2007/08/20 20:55:30	1.103
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/tools/lvm2cmd-static.c	2006/08/18 21:17:18	1.1
+++ LVM2/tools/lvm2cmd-static.c	2007/08/20 20:55:30	1.2
@@ -5,9 +5,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvm2cmd.c	2007/06/19 10:51:51	1.2
+++ LVM2/tools/lvm2cmd.c	2007/08/20 20:55:30	1.3
@@ -1,13 +1,13 @@
 /*
- * Copyright (C) 2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2006-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvm2cmd.h	2004/03/30 19:35:42	1.2
+++ LVM2/tools/lvm2cmd.h	2007/08/20 20:55:30	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvm2cmdline.h	2007/02/14 16:51:48	1.5
+++ LVM2/tools/lvm2cmdline.h	2007/08/20 20:55:30	1.6
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvmchange.c	2006/05/09 21:23:51	1.6
+++ LVM2/tools/lvmchange.c	2007/08/20 20:55:30	1.7
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvmcmdlib.c	2007/01/16 18:06:11	1.4
+++ LVM2/tools/lvmcmdlib.c	2007/08/20 20:55:30	1.5
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvmcmdline.c	2007/08/20 17:04:53	1.46
+++ LVM2/tools/lvmcmdline.c	2007/08/20 20:55:30	1.47
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvmdiskscan.c	2007/06/28 17:33:44	1.19
+++ LVM2/tools/lvmdiskscan.c	2007/08/20 20:55:30	1.20
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvreduce.c	2004/03/30 19:35:42	1.6
+++ LVM2/tools/lvreduce.c	2007/08/20 20:55:30	1.7
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvremove.c	2007/08/20 17:04:53	1.52
+++ LVM2/tools/lvremove.c	2007/08/20 20:55:30	1.53
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvrename.c	2007/08/03 21:22:10	1.45
+++ LVM2/tools/lvrename.c	2007/08/20 20:55:30	1.46
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvresize.c	2007/06/28 17:33:44	1.79
+++ LVM2/tools/lvresize.c	2007/08/20 20:55:30	1.80
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/lvscan.c	2006/05/09 21:23:51	1.32
+++ LVM2/tools/lvscan.c	2007/08/20 20:55:30	1.33
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/polldaemon.c	2007/06/19 04:36:12	1.7
+++ LVM2/tools/polldaemon.c	2007/08/20 20:55:30	1.8
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/polldaemon.h	2007/07/18 15:38:58	1.2
+++ LVM2/tools/polldaemon.h	2007/08/20 20:55:30	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvchange.c	2007/06/15 22:16:55	1.51
+++ LVM2/tools/pvchange.c	2007/08/20 20:55:30	1.52
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvck.c	2007/04/25 20:03:16	1.2
+++ LVM2/tools/pvck.c	2007/08/20 20:55:30	1.3
@@ -6,9 +6,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvcreate.c	2007/06/28 17:33:44	1.54
+++ LVM2/tools/pvcreate.c	2007/08/20 20:55:30	1.55
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvdisplay.c	2007/06/15 22:16:55	1.37
+++ LVM2/tools/pvdisplay.c	2007/08/20 20:55:30	1.38
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvmove.c	2007/07/23 21:03:42	1.40
+++ LVM2/tools/pvmove.c	2007/08/20 20:55:30	1.41
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvremove.c	2007/06/28 17:33:44	1.18
+++ LVM2/tools/pvremove.c	2007/08/20 20:55:30	1.19
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvresize.c	2007/06/28 17:33:44	1.12
+++ LVM2/tools/pvresize.c	2007/08/20 20:55:30	1.13
@@ -7,9 +7,9 @@
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/pvscan.c	2007/06/28 17:33:44	1.40
+++ LVM2/tools/pvscan.c	2007/08/20 20:55:30	1.41
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/reporter.c	2007/06/15 22:16:55	1.25
+++ LVM2/tools/reporter.c	2007/08/20 20:55:30	1.26
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/segtypes.c	2006/05/09 21:23:51	1.2
+++ LVM2/tools/segtypes.c	2007/08/20 20:55:30	1.3
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/stub.h	2006/05/09 21:23:51	1.45
+++ LVM2/tools/stub.h	2007/08/20 20:55:30	1.46
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/toollib.c	2007/08/07 09:06:05	1.103
+++ LVM2/tools/toollib.c	2007/08/20 20:55:30	1.104
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/toollib.h	2007/08/07 09:06:05	1.48
+++ LVM2/tools/toollib.h	2007/08/20 20:55:30	1.49
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/tools.h	2007/08/20 17:04:53	1.55
+++ LVM2/tools/tools.h	2007/08/20 20:55:30	1.56
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgcfgbackup.c	2007/06/28 17:33:44	1.22
+++ LVM2/tools/vgcfgbackup.c	2007/08/20 20:55:30	1.23
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgcfgrestore.c	2007/06/13 15:11:19	1.15
+++ LVM2/tools/vgcfgrestore.c	2007/08/20 20:55:30	1.16
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgchange.c	2007/06/19 04:23:32	1.59
+++ LVM2/tools/vgchange.c	2007/08/20 20:55:30	1.60
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgck.c	2007/06/19 04:36:12	1.16
+++ LVM2/tools/vgck.c	2007/08/20 20:55:30	1.17
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgconvert.c	2007/06/19 04:36:12	1.23
+++ LVM2/tools/vgconvert.c	2007/08/20 20:55:30	1.24
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgcreate.c	2007/06/28 17:33:44	1.49
+++ LVM2/tools/vgcreate.c	2007/08/20 20:55:30	1.50
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgdisplay.c	2007/08/07 09:06:05	1.18
+++ LVM2/tools/vgdisplay.c	2007/08/20 20:55:30	1.19
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgexport.c	2007/06/19 04:36:12	1.16
+++ LVM2/tools/vgexport.c	2007/08/20 20:55:30	1.17
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgextend.c	2007/07/23 21:03:42	1.33
+++ LVM2/tools/vgextend.c	2007/08/20 20:55:30	1.34
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgimport.c	2007/06/19 04:23:32	1.15
+++ LVM2/tools/vgimport.c	2007/08/20 20:55:30	1.16
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgmerge.c	2007/07/23 21:03:42	1.39
+++ LVM2/tools/vgmerge.c	2007/08/20 20:55:30	1.40
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgmknodes.c	2006/05/09 21:23:51	1.4
+++ LVM2/tools/vgmknodes.c	2007/08/20 20:55:30	1.5
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgreduce.c	2007/06/19 04:36:12	1.65
+++ LVM2/tools/vgreduce.c	2007/08/20 20:55:30	1.66
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgremove.c	2007/06/19 04:36:12	1.41
+++ LVM2/tools/vgremove.c	2007/08/20 20:55:30	1.42
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgrename.c	2007/06/06 19:40:28	1.44
+++ LVM2/tools/vgrename.c	2007/08/20 20:55:30	1.45
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgscan.c	2007/06/19 04:23:32	1.26
+++ LVM2/tools/vgscan.c	2007/08/20 20:55:30	1.27
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/vgsplit.c	2007/07/23 21:10:36	1.34
+++ LVM2/tools/vgsplit.c	2007/08/20 20:55:30	1.35
@@ -1,14 +1,14 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * of the GNU Lesser General Public License v.2.1.
  *
- * You should have received a copy of the GNU General Public License
+ * You should have received a copy of the GNU Lesser General Public License
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
--- LVM2/tools/fsadm/fsadm.c	2007/07/20 15:48:39	1.2
+++ LVM2/tools/fsadm/fsadm.c	2007/08/20 20:55:30	1.3
@@ -1,10 +1,16 @@
 /*
  * Copyright (C) 2004  Red Hat GmbH. All rights reserved.
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
  *
- * LVM is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
 /*


