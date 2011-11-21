From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Nov 2011 00:16:16 -0000
Subject: LVM2/test Makefile.in shell/000-basic.sh shell ...
Message-ID: <20111121001616.19467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-21 00:15:47

Modified files:
	test           : Makefile.in 
Added files:
	test/shell     : 000-basic.sh activate-missing.sh 
	                 activate-partial.sh clvmd-restart.sh 
	                 covercmd.sh dmeventd-restart.sh fsadm.sh 
	                 inconsistent-metadata.sh listings.sh 
	                 lock-blocking.sh lvchange-mirror.sh 
	                 lvconvert-mirror-basic-0.sh 
	                 lvconvert-mirror-basic-1.sh 
	                 lvconvert-mirror-basic-2.sh 
	                 lvconvert-mirror-basic-3.sh 
	                 lvconvert-mirror-basic.sh lvconvert-mirror.sh 
	                 lvconvert-raid.sh lvconvert-repair-dmeventd.sh 
	                 lvconvert-repair-policy.sh 
	                 lvconvert-repair-replace.sh 
	                 lvconvert-repair-snapshot.sh 
	                 lvconvert-repair-transient-dmeventd.sh 
	                 lvconvert-repair-transient.sh 
	                 lvconvert-repair.sh lvconvert-twostep.sh 
	                 lvcreate-large.sh lvcreate-mirror.sh 
	                 lvcreate-operation.sh lvcreate-pvtags.sh 
	                 lvcreate-raid.sh lvcreate-repair.sh 
	                 lvcreate-small-snap.sh 
	                 lvcreate-striped-mirror.sh lvcreate-thin.sh 
	                 lvcreate-usage.sh lvextend-percent-extents.sh 
	                 lvextend-snapshot-dmeventd.sh 
	                 lvextend-snapshot-policy.sh lvm-init.sh 
	                 lvmcache-exercise.sh lvresize-mirror.sh 
	                 lvresize-rounding.sh lvresize-usage.sh 
	                 mdata-strings.sh metadata-balance.sh 
	                 metadata-dirs.sh metadata.sh mirror-names.sh 
	                 mirror-vgreduce-removemissing.sh 
	                 nomda-missing.sh pool-labels.sh pv-duplicate.sh 
	                 pv-min-size.sh pv-range-overflow.sh 
	                 pvchange-usage.sh pvcreate-metadata0.sh 
	                 pvcreate-operation-md.sh pvcreate-operation.sh 
	                 pvcreate-usage.sh pvmove-basic.sh 
	                 pvremove-usage.sh read-ahead.sh 
	                 snapshot-autoumount-dmeventd.sh 
	                 snapshot-merge.sh snapshots-of-mirrors.sh 
	                 tags.sh test-partition.sh topology-support.sh 
	                 unknown-segment.sh unlost-pv.sh 
	                 vgcfgbackup-usage.sh vgchange-maxlv.sh 
	                 vgchange-sysinit.sh vgchange-usage.sh 
	                 vgcreate-usage.sh vgextend-restoremissing.sh 
	                 vgextend-usage.sh vgimportclone.sh 
	                 vgmerge-operation.sh vgmerge-usage.sh 
	                 vgreduce-removemissing-snapshot.sh 
	                 vgreduce-usage.sh vgrename-usage.sh 
	                 vgsplit-operation.sh vgsplit-stacked.sh 
	                 vgsplit-usage.sh 
Removed files:
	test           : t-000-basic.sh t-activate-missing.sh 
	                 t-activate-partial.sh t-clvmd-restart.sh 
	                 t-covercmd.sh t-dmeventd-restart.sh t-fsadm.sh 
	                 t-inconsistent-metadata.sh t-listings.sh 
	                 t-lock-blocking.sh t-lvchange-mirror.sh 
	                 t-lvconvert-mirror-basic-0.sh 
	                 t-lvconvert-mirror-basic-1.sh 
	                 t-lvconvert-mirror-basic-2.sh 
	                 t-lvconvert-mirror-basic-3.sh 
	                 t-lvconvert-mirror-basic.sh 
	                 t-lvconvert-mirror.sh t-lvconvert-raid.sh 
	                 t-lvconvert-repair-dmeventd.sh 
	                 t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair-replace.sh 
	                 t-lvconvert-repair-snapshot.sh 
	                 t-lvconvert-repair-transient-dmeventd.sh 
	                 t-lvconvert-repair-transient.sh 
	                 t-lvconvert-repair.sh t-lvconvert-twostep.sh 
	                 t-lvcreate-large.sh t-lvcreate-mirror.sh 
	                 t-lvcreate-operation.sh t-lvcreate-pvtags.sh 
	                 t-lvcreate-raid.sh t-lvcreate-repair.sh 
	                 t-lvcreate-small-snap.sh 
	                 t-lvcreate-striped-mirror.sh t-lvcreate-thin.sh 
	                 t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 
	                 t-lvextend-snapshot-dmeventd.sh 
	                 t-lvextend-snapshot-policy.sh t-lvm-init.sh 
	                 t-lvmcache-exercise.sh t-lvresize-mirror.sh 
	                 t-lvresize-rounding.sh t-lvresize-usage.sh 
	                 t-mdata-strings.sh t-metadata-balance.sh 
	                 t-metadata-dirs.sh t-metadata.sh 
	                 t-mirror-names.sh 
	                 t-mirror-vgreduce-removemissing.sh 
	                 t-nomda-missing.sh t-pool-labels.sh 
	                 t-pv-duplicate.sh t-pv-min-size.sh 
	                 t-pv-range-overflow.sh t-pvchange-usage.sh 
	                 t-pvcreate-metadata0.sh 
	                 t-pvcreate-operation-md.sh 
	                 t-pvcreate-operation.sh t-pvcreate-usage.sh 
	                 t-pvmove-basic.sh t-pvremove-usage.sh 
	                 t-read-ahead.sh 
	                 t-snapshot-autoumount-dmeventd.sh 
	                 t-snapshot-merge.sh t-snapshots-of-mirrors.sh 
	                 t-tags.sh t-test-partition.sh 
	                 t-topology-support.sh t-unknown-segment.sh 
	                 t-unlost-pv.sh t-vgcfgbackup-usage.sh 
	                 t-vgchange-maxlv.sh t-vgchange-sysinit.sh 
	                 t-vgchange-usage.sh t-vgcreate-usage.sh 
	                 t-vgextend-restoremissing.sh 
	                 t-vgextend-usage.sh t-vgimportclone.sh 
	                 t-vgmerge-operation.sh t-vgmerge-usage.sh 
	                 t-vgreduce-removemissing-snapshot.sh 
	                 t-vgreduce-usage.sh t-vgrename-usage.sh 
	                 t-vgsplit-operation.sh t-vgsplit-stacked.sh 
	                 t-vgsplit-usage.sh 

Log message:
	Tidy the shell tests into their own subdir. We now have:
	- test/lib -- infrastructure and helper code
	- test/api -- liblvm2app API tests
	- test/unit -- C-based unit tests
	- test/shell -- shell-based functional tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-missing.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-clvmd-restart.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.9&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-listings.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvchange-mirror.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient-dmeventd.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-large.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-raid.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-small-snap.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-striped-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.21&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-policy.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvm-init.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-mirror.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-rounding.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-balance.sh.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-dirs.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-nomda-missing.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pool-labels.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-duplicate.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-min-size.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.15&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.21&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.20&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.9&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-tags.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-test-partition.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unknown-segment.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unlost-pv.sh.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-maxlv.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-sysinit.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.19&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-restoremissing.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgimportclone.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-removemissing-snapshot.sh.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.28&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.16&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/000-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-missing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-partial.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/clvmd-restart.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/covercmd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dmeventd-restart.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/fsadm.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/listings.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lock-blocking.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvchange-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-raid.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-large.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-raid.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-small-snap.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-striped-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-thin.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-policy.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvm-init.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-rounding.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mdata-strings.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata-balance.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata-dirs.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-names.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/nomda-missing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pool-labels.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-duplicate.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-min-size.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-range-overflow.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvchange-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvmove-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvremove-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/read-ahead.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-merge.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/tags.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/test-partition.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/topology-support.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/unknown-segment.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/unlost-pv.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-maxlv.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-sysinit.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgextend-restoremissing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgextend-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgimportclone.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgmerge-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgmerge-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgreduce-removemissing-snapshot.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgreduce-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgrename-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/test/Makefile.in	2011/11/20 21:55:24	1.62
+++ LVM2/test/Makefile.in	2011/11/21 00:15:42	1.63
@@ -29,8 +29,8 @@
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL = $(shell find $(srcdir) \( -name t-\*.sh -or -path */api/\*.sh \) | sort)
-RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
+ALL = $(shell find $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
+RUN = $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 # Shell quote;
@@ -91,6 +91,7 @@
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 
 .tests-stamp: $(ALL) $(LIB)
+	mkdir -p shell
 	@if test "$(srcdir)" != . ; then \
 	    echo "Copying tests to builddir."; \
 	    for f in $(ALL); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
/cvs/lvm2/LVM2/test/shell/000-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/000-basic.sh
+++ -	2011-11-21 00:16:04.305057000 +0000
@@ -0,0 +1,28 @@
+# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+lvm version
+
+v=$abs_top_srcdir/lib/misc/lvm-version.h
+sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
+
+lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
+
+# ensure they are the same
+diff -u actual expected
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 5
+
+# ensure we do not crash on a bug in config file
+aux lvmconf 'log/prefix = 1""'
+not lvs
/cvs/lvm2/LVM2/test/shell/activate-missing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/activate-missing.sh
+++ -	2011-11-21 00:16:04.389066000 +0000
@@ -0,0 +1,87 @@
+#!/bin/bash
+
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test activation behaviour with devices missing.
+# - snapshots and their origins are only activated together; if one fails, both
+#   fail
+# - partial mirrors are not activated (but maybe they should? maybe we should
+#   instead lvconvert --repair them?)
+# - linear LVs with bits missing are not activated
+
+. lib/test
+
+aux prepare_vg 4
+
+lvcreate -l1 -n linear1 $vg $dev1
+lvcreate -l1 -n linear2 $vg $dev2
+lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+
+lvcreate -l1 -n origin1 $vg $dev1
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
+lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+
+vgchange -a n $vg
+aux disable_dev $dev1
+not vgchange -a y $vg
+not vgck $vg
+
+check inactive $vg linear1
+check active $vg linear2
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg linear12
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+aux enable_dev $dev1
+aux disable_dev $dev2
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg linear1
+check inactive $vg linear2
+check inactive $vg linear12
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+aux enable_dev $dev2
+aux disable_dev $dev3
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check inactive $vg mirror123
+check active $vg mirror12
+
+vgchange -a n $vg
+aux enable_dev $dev3
+aux disable_dev $dev4
+vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check active $vg mirror12
+check active $vg mirror123
/cvs/lvm2/LVM2/test/shell/activate-partial.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/activate-partial.sh
+++ -	2011-11-21 00:16:04.469077000 +0000
@@ -0,0 +1,30 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+aux disable_dev $dev1
+
+not vgreduce --removemissing $vg
+not lvchange -v -a y $vg/mirror
+lvchange -v --partial -a y $vg/mirror
+not lvchange -v --refresh $vg/mirror
+lvchange -v --refresh --partial $vg/mirror
+
+# also check that vgchange works
+vgchange -a n --partial $vg
+vgchange -a y --partial $vg
+
+# check vgremove
+vgremove -f $vg
/cvs/lvm2/LVM2/test/shell/clvmd-restart.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/clvmd-restart.sh
+++ -	2011-11-21 00:16:04.554396000 +0000
@@ -0,0 +1,53 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# set before test's clvmd is started, so it's passed in environ
+export LVM_CLVMD_BINARY=clvmd
+export LVM_BINARY=lvm
+
+. lib/test
+
+# only clvmd based test, skip otherwise
+test -e LOCAL_CLVMD || skip
+read LOCAL_CLVMD < LOCAL_CLVMD
+
+aux prepare_pvs 1
+
+vgcreate --clustered y $vg $(cat DEVICES)
+
+lvcreate -an --zero n -n $lv1 -l1 $vg
+lvcreate -an --zero n -n $lv2 -l1 $vg
+lvcreate -l1 $vg
+
+lvchange -aey $vg/$lv1
+lvchange -aey $vg/$lv2
+
+"$LVM_CLVMD_BINARY" -S
+sleep .2
+# restarted clvmd has the same PID (no fork, only execvp)
+NEW_LOCAL_CLVMD=$(pgrep clvmd)
+test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+
+# try restart once more
+
+"$LVM_CLVMD_BINARY" -S
+sleep .2
+# restarted clvmd has the same PID (no fork, only execvp)
+NEW_LOCAL_CLVMD=$(pgrep clvmd)
+test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+
+# FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+
+"$LVM_CLVMD_BINARY" -R
+
+vgremove -ff $vg
/cvs/lvm2/LVM2/test/shell/covercmd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/covercmd.sh
+++ -	2011-11-21 00:16:04.636154000 +0000
@@ -0,0 +1,82 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests basic functionality of read-ahead and ra regressions
+#
+
+. lib/test
+
+TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
+
+get_lvs_()
+{
+  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+    *$2) true ;;
+    *) false ;;
+  esac
+}
+
+aux prepare_devs 5
+
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
+vgcreate -c n $vg $(cat DEVICES)
+lvcreate -n $lv -l 5 -i5 -I256 $vg
+
+# test *scan and *display tools
+pvscan
+vgscan
+lvscan
+lvmdiskscan
+vgdisplay --units k
+lvdisplay --units g
+for i in h b s k m g t p e H B S K M G T P E ; do
+    pvdisplay --units "$i" "$dev1"
+done
+
+# test vgexport vgimport tools
+vgchange -an $vg
+vgexport $vg
+vgimport $vg
+vgchange -ay $vg
+
+# "-persistent y --major 254 --minor 20"
+# "-persistent n"
+# test various lvm utils
+for i in dumpconfig formats segtypes; do
+    lvm "$i"
+done
+
+for i in pr "p rw" an ay "-monitor y" "-monitor n" \
+        -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
+    lvchange -$i "$vg"/"$lv"
+done
+
+pvck "$dev1"
+vgck "$vg"
+lvrename "$vg" "$lv" "$lv-rename"
+vgcfgbackup -f "$(pwd)/backup.$$" "$vg"
+vgchange -an "$vg"
+vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
+pvremove -y -ff $dev5
+not vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
+pvcreate -u $TEST_UUID --restorefile  "$(pwd)/backup.$$" $dev5
+vgremove -f "$vg"
+pvresize --setphysicalvolumesize 10M "$dev1"
+
+# test various errors and obsoleted tools
+not lvmchange
+not lvrename "$vg"
+not lvrename "$vg-xxx"
+not lvrename "$vg"  "$vg"/"$lv-rename" "$vg"/"$lv"
/cvs/lvm2/LVM2/test/shell/dmeventd-restart.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/dmeventd-restart.sh
+++ -	2011-11-21 00:16:04.721351000 +0000
@@ -0,0 +1,42 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+aux prepare_dmeventd
+
+which mkfs.ext2 || exit 200
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+lvcreate -m 2 --ig -L 1 -n 3way $vg
+lvchange --monitor y $vg/3way
+
+dmeventd -R -f &
+echo "$!" > LOCAL_DMEVENTD
+
+sleep 1 # wait a bit, so we talk to the new dmeventd later
+
+lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
+grep 'already monitored' lvchange.out
+lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
+grep 'already monitored' lvchange.out
+
+# now try what happens if no dmeventd is running
+kill -9 `cat LOCAL_DMEVENTD`
+dmeventd -R -f &
+echo "$!" > LOCAL_DMEVENTD
+sleep 3
+lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
+not grep 'already monitored' lvchange.out
+
+vgremove -ff $vg
/cvs/lvm2/LVM2/test/shell/fsadm.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/fsadm.sh
+++ -	2011-11-21 00:16:04.807044000 +0000
@@ -0,0 +1,128 @@
+#!/bin/bash
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise fsadm filesystem resize'
+
+. lib/test
+
+aux prepare_vg 1 100
+
+# set to "skip" to avoid testing given fs and test warning result
+# i.e. check_reiserfs=skip
+check_ext3=
+check_xfs=
+check_reiserfs=
+
+which mkfs.ext3 || check_ext3=${check_ext3:=mkfs.ext3}
+which fsck.ext3 || check_ext3=${check_ext3:=fsck.ext3}
+which mkfs.xfs || check_xfs=${check_xfs:=mkfs.xfs}
+which xfs_check || check_xfs=${check_xfs:=xfs_check}
+which mkfs.reiserfs || check_reiserfs=${check_reiserfs:=mkfs.reiserfs}
+which reiserfsck || check_reiserfs=${check_reiserfs:=reiserfsck}
+
+vg_lv="$vg/$lv1"
+dev_vg_lv="$DM_DEV_DIR/$vg_lv"
+mount_dir="$TESTDIR/mnt"
+# for recursive call
+export LVM_BINARY=$(which lvm)
+
+test ! -d $mount_dir && mkdir $mount_dir
+
+cleanup_mounted_and_teardown()
+{
+	umount $mount_dir || true
+	aux teardown
+}
+
+fscheck_ext3()
+{
+	fsck.ext3 -p -F -f $dev_vg_lv
+}
+
+fscheck_xfs()
+{
+	xfs_check $dev_vg_lv
+}
+
+fscheck_reiserfs()
+{
+	reiserfsck --check -p -f $dev_vg_lv </dev/null
+}
+
+check_missing()
+{
+	eval local t=$\check_$1
+	test -z "$t" && return 0
+	test "$t" = skip && return 1
+	# trick for warning test
+	echo "TEST ""WARNING: fsadm skips $1 tests, $t tool is missing"
+	return 1
+}
+
+# Test for block sizes != 1024 (rhbz #480022)
+lvcreate -n $lv1 -L20M $vg
+trap 'cleanup_mounted_and_teardown' EXIT
+
+if check_missing ext3; then
+	mkfs.ext3 -b4096 -j $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	# Fails - not enough space for 4M fs
+	not fsadm -y --lvresize resize $dev_vg_lv 4M
+	lvresize -L+10M -r $vg_lv
+	lvreduce -L10M -r $vg_lv
+
+	fscheck_ext3
+	mount $dev_vg_lv $mount_dir
+	not fsadm -y --lvresize resize $vg_lv 4M
+	echo n | not lvresize -L4M -r -n $vg_lv
+	lvresize -L+20M -r -n $vg_lv
+	umount $mount_dir
+	fscheck_ext3
+
+	lvresize -f -L20M $vg_lv
+fi
+
+if check_missing xfs; then
+	mkfs.xfs -l internal,size=1000b -f $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	# Fails - not enough space for 4M fs
+	lvresize -L+10M -r $vg_lv
+	not lvreduce -L10M -r $vg_lv
+
+	fscheck_xfs
+	mount $dev_vg_lv $mount_dir
+	lvresize -L+10M -r -n $vg_lv
+	umount $mount_dir
+	fscheck_xfs
+
+	lvresize -f -L20M $vg_lv
+fi
+
+if check_missing reiserfs; then
+	mkfs.reiserfs -s 513 -f $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	lvresize -L+10M -r $vg_lv
+	fsadm --lvresize -y resize $vg_lv 10M
+
+	fscheck_reiserfs
+	mount $dev_vg_lv $mount_dir
+
+	fsadm -y --lvresize resize $vg_lv 30M
+	umount $mount_dir
+	fscheck_reiserfs
+
+	lvresize -f -L20M $vg_lv
+fi
+
+vgremove -ff $vg
/cvs/lvm2/LVM2/test/shell/inconsistent-metadata.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/inconsistent-metadata.sh
+++ -	2011-11-21 00:16:04.892212000 +0000
@@ -0,0 +1,75 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3 12
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -l 1 -n resized $vg
+lvchange -a n $vg/mirror
+
+aux backup_dev $(cat DEVICES)
+
+init() {
+	aux restore_dev $(cat DEVICES)
+	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
+	grep resized lvs.out | not grep 8192
+	lvresize -L 8192K $vg/resized
+	aux restore_dev $dev1
+}
+
+check() {
+	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
+	grep resized lvs.out | grep 8192
+}
+
+# vgscan fixes up metadata
+init
+vgscan 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgscan 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
+
+# vgdisplay fixes
+init
+vgdisplay 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgdisplay 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
+
+# lvs fixes up
+init
+lvs 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgdisplay 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
+
+# vgs fixes up as well
+init
+vgs 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgs 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
+
+echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
+vgremove -f $vg
+pvremove -ff $(cat DEVICES)
+pvcreate $(cat DEVICES)
+aux backup_dev $dev2
+vgcreate $vg $dev1
+vgextend $vg $dev2
+aux restore_dev $dev2
+should check compare_fields vgs $vg vg_mda_count pvs $dev2 vg_mda_count
/cvs/lvm2/LVM2/test/shell/listings.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/listings.sh
+++ -	2011-11-21 00:16:04.972641000 +0000
@@ -0,0 +1,83 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests functionality of lvs, pvs, vgs, *display tools
+#
+
+. lib/test
+
+get_lvs_()
+{
+  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+    *$2) true ;;
+    *) false ;;
+  esac
+}
+
+aux prepare_devs 5
+
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --metadatacopies 0 $dev5
+
+#COMM bz195276 -- pvs doesn't show PVs until a VG is created
+pvs --noheadings|tee out
+test $(wc -l <out) -eq 5
+
+#COMM pvs with segment attributes works even for orphans
+pvs --noheadings -o  seg_all,pv_all,lv_all,vg_all | tee out
+test $(wc -l <out) -eq 5
+
+vgcreate -c n $vg $(cat DEVICES)
+
+#COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
+pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
+for I in $dev2 $dev3 $dev5; do
+	check pv_field $I pv_mda_count 0
+	check pv_field $I pv_mda_free 0
+done
+vgs -o +vg_mda_count,vg_mda_free $vg
+check vg_field $vg vg_mda_count 2
+
+#COMM pvs doesn't display --metadatacopies 0 PVs as orphans (bz409061)
+pvdisplay $dev2|grep "VG Name.*$vg"
+test $(pvs -o vg_name --noheadings $dev2) = $vg
+
+#COMM lvs displays snapshots (bz171215)
+lvcreate -l4 -n $lv1 $vg
+lvcreate -l4 -s -n $lv2 $vg/$lv1
+lvs $vg --noheadings|tee out
+test $(wc -l <out) -eq 2
+lvs -a --noheadings|tee out
+# should lvs -a display cow && real devices? (it doesn't)
+test $(wc -l <out) -eq 2
+dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+lvremove -f $vg/$lv2
+
+#COMM lvs -a displays mirror legs and log
+lvcreate -l4  -m2 -n$lv3 $vg
+lvs $vg --noheadings|tee out
+test $(wc -l <out) -eq 2
+lvs -a --noheadings|tee out
+test $(wc -l <out) -eq 6
+dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+
+#COMM vgs with options from pvs still treats arguments as VGs (bz193543)
+vgs -o pv_name,vg_name $vg
+# would complain if not
+
+#COMM pvdisplay --maps feature (bz149814)
+pvdisplay $(cat DEVICES) >out
+pvdisplay --maps $(cat DEVICES) >out2
+not diff out out2
+
/cvs/lvm2/LVM2/test/shell/lock-blocking.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lock-blocking.sh
+++ -	2011-11-21 00:16:05.062764000 +0000
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='test some blocking / non-blocking multi-vg operations'
+
+. lib/test
+
+aux prepare_devs 3
+test -e LOCAL_CLVMD && exit 200
+pvcreate $dev1 $dev2
+vgcreate $vg $dev1 $dev2
+
+# if wait_for_locks set, vgremove should wait for orphan lock
+# flock process should have exited by the time first vgremove completes
+flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
+
+vgremove --config 'global { wait_for_locks = 1 }' $vg
+not vgremove --config 'global { wait_for_locks = 1 }' $vg
+
+test ! -f $TESTDIR/var/lock/lvm/P_orphans
+
+# if wait_for_locks not set, vgremove should fail on non-blocking lock
+# we must wait for flock process at the end - vgremove won't wait
+vgcreate $vg $dev1 $dev2
+flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+
+while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
+flock_pid=`jobs -p`
+
+not vgremove --config 'global { wait_for_locks = 0 }' $vg
+test -f $TESTDIR/var/lock/lvm/P_orphans # still running
+kill $flock_pid
/cvs/lvm2/LVM2/test/shell/lvchange-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvchange-mirror.sh
+++ -	2011-11-21 00:16:05.146548000 +0000
@@ -0,0 +1,28 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+aux prepare_vg 3
+
+# force resync 2-way active mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check mirror $vg $lv1 $dev3
+echo y | lvchange --resync $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# force resync 2-way inactive mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvchange --resync $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror-basic-0.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror-basic-0.sh
+++ -	2011-11-21 00:16:05.238224000 +0000
@@ -0,0 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./t-lvconvert-mirror-basic.sh
+test_many 0
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror-basic-1.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror-basic-1.sh
+++ -	2011-11-21 00:16:05.328847000 +0000
@@ -0,0 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./t-lvconvert-mirror-basic.sh
+test_many 1
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror-basic-2.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror-basic-2.sh
+++ -	2011-11-21 00:16:05.416027000 +0000
@@ -0,0 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./t-lvconvert-mirror-basic.sh
+test_many 2
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror-basic-3.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror-basic-3.sh
+++ -	2011-11-21 00:16:05.499116000 +0000
@@ -0,0 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./t-lvconvert-mirror-basic.sh
+test_many 3
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror-basic.sh
+++ -	2011-11-21 00:16:05.591688000 +0000
@@ -0,0 +1,142 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+log_name_to_count()
+{
+	if [ "$1" = "mirrored" ]; then
+		echo 2
+	elif [ "$1" = "disk" ]; then
+		echo 1
+	else
+		echo 0
+	fi
+}
+
+# FIXME: For test_[up|down]convert, I'd still like to be able
+# to specifiy devices - especially if I can do partial PV
+# specification for down-converts.  It may even be wise to
+# do one round through these tests without specifying the PVs
+# to use and one round where we do.
+
+# test_lvconvert
+#   start_mirror_count:  The '-m' argument to create with
+#   start_log_type: core|disk|mirrored
+#   final_mirror_count: The '-m' argument to convert to
+#   final_log_type: core|disk|mirrored
+#   active: Whether the LV should be active when the convert happens
+#
+# Exmaple: Convert 3-way disk-log mirror to
+#          2-way disk-log mirror while not active
+# -> test_lvconvert 2 disk 3 disk 0
+
+test_lvconvert()
+{
+	local start_count=$1
+	local start_count_p1=$(($start_count + 1))
+	local start_log_type=$2
+	local finish_count=$3
+	local finish_count_p1=$(($finish_count + 1))
+	local finish_log_type=$4
+	local dev_array=($dev1 $dev2 $dev3 $dev4 $dev5)
+	local start_log_count
+	local finish_log_count
+	local max_log_count
+	local alloc=""
+	local active=true
+	local i
+
+	test "$5" = "active" && active=false
+	#test $finish_count -gt $start_count && up=true
+
+	# Do we have enough devices for the mirror images?
+	if [ $start_count_p1 -gt ${#dev_array[@]} ]; then
+		echo "Action requires too many devices"
+		return 1
+	fi
+
+	# Do we have enough devices for the mirror images?
+	if [ $finish_count_p1 -gt ${#dev_array[@]} ]; then
+		echo "Action requires too many devices"
+		return 1
+	fi
+
+	start_log_count=`log_name_to_count $start_log_type`
+	finish_log_count=`log_name_to_count $finish_log_type`
+	if [ $finish_log_count -gt $start_log_count ]; then
+		max_log_count=$finish_log_count
+	else
+		max_log_count=$start_log_count
+	fi
+
+	if [ $start_count -gt 0 ]; then
+		# Are there extra devices for the log or do we overlap
+		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
+			alloc="--alloc anywhere"
+		fi
+
+		lvcreate -l2 -m $start_count --mirrorlog $start_log_type \
+			-n $lv1 $vg $alloc
+		check mirror_legs $vg $lv1 $start_count_p1
+		# FIXME: check mirror log
+	else
+		lvcreate -l2 -n $lv1 $vg
+	fi
+
+	lvs -a -o name,copy_percent,devices $vg
+	if ! $active; then
+		lvchange -an $vg/$lv1
+	fi
+
+	# Are there extra devices for the log or do we overlap
+	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
+		alloc="--alloc anywhere"
+	fi
+
+	lvconvert -m $finish_count --mirrorlog $finish_log_type \
+		$vg/$lv1 $alloc
+
+	if ! $active; then
+		lvchange -ay $vg/$lv1
+	fi
+
+	check mirror_no_temporaries $vg $lv1
+	if [ "$finish_count_p1" -eq 1 ]; then
+		check linear $vg $lv1
+	else
+		if test -n "$alloc"; then
+			check mirror_nonredundant $vg $lv1
+		else
+			check mirror $vg $lv1
+		fi
+		check mirror_legs $vg $lv1 $finish_count_p1
+	fi
+}
+
+aux prepare_vg 5 16
+
+test_many() {
+	i=$1
+	for j in $(seq 0 3); do
+		for k in core disk mirrored; do
+			for l in core disk mirrored; do
+				if test "$i" -eq "$j" && test "$k" = "$l"; then continue; fi
+				: ----------------------------------------------------
+				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
+				: ----------------------------------------------------
+				test_lvconvert $i $k $j $l 0
+				lvremove -ff $vg
+				test_lvconvert $i $k $j $l 1
+				lvremove -ff $vg
+			done
+		done
+	done
+}
/cvs/lvm2/LVM2/test/shell/lvconvert-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-mirror.sh
+++ -	2011-11-21 00:16:05.699948000 +0000
@@ -0,0 +1,255 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# convert from linear to 2-way mirror
+aux prepare_vg 5
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1
+check mirror $vg $lv1 $dev3
+
+# convert from 2-way mirror to linear
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -m-1 $vg/$lv1
+check linear $vg $lv1
+lvremove -ff $vg
+# and now try removing a specific leg (bz453643)
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -m0 $vg/$lv1 $dev2
+check lv_on $vg $lv1 $dev1
+lvremove -ff $vg
+
+# convert from disklog to corelog, active
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -f --mirrorlog core $vg/$lv1
+check mirror $vg $lv1 core
+lvremove -ff $vg
+
+# convert from corelog to disklog, active
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# bz192865: lvconvert log of an inactive mirror lv
+# convert from disklog to corelog, inactive
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+echo y | lvconvert -f --mirrorlog core $vg/$lv1
+check mirror $vg $lv1 core
+lvremove -ff $vg
+
+# convert from corelog to disklog, inactive
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvchange -an $vg/$lv1
+lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# convert linear to 2-way mirror with 1 PV
+aux prepare_vg 5
+lvcreate -l2 -n $lv1 $vg $dev1
+not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
+lvremove -ff $vg
+
+# Start w/ 3-way mirror
+# Test pulling primary image before mirror in-sync (should fail)
+# Test pulling primary image after mirror in-sync (should work)
+# Test that the correct devices remain in the mirror
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0
+# FIXME:
+#  This is somewhat timing dependent - sync /could/ finish before
+#  we get a chance to have this command fail
+should not lvconvert -m-1 $vg/$lv1 $dev1
+
+lvconvert $vg/$lv1 # wait
+lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0 # If the above "should" failed...
+
+lvconvert -m-1 $vg/$lv1 $dev1
+check mirror_images_on $lv1 $dev2 $dev4
+lvconvert -m-1 $vg/$lv1 $dev2
+check linear $vg $lv1
+check lv_on $vg $lv1 $dev4
+
+# No parallel lvconverts on a single LV please
+
+aux prepare_vg 5
+lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+check mirror $vg $lv1
+check mirror_legs $vg $lv1 2
+lvconvert -m+1 -b $vg/$lv1 $dev4
+
+# Next convert should fail b/c we can't have 2 at once
+should not lvconvert -m+1 $vg/$lv1 $dev5
+lvconvert $vg/$lv1 # wait
+lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# add 1 mirror to core log mirror, but
+#  implicitly keep log as 'core'
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvconvert -m +1 -i1 $vg/$lv1
+
+check mirror $vg $lv1 core
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# remove 1 mirror from corelog'ed mirror; should retain 'core' log type
+aux prepare_vg 5
+lvcreate -l2 -m2 --corelog -n $lv1 $vg
+lvconvert -m -1 -i1 $vg/$lv1
+
+check mirror $vg $lv1 core
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# add 1 mirror then add 1 more mirror during conversion
+# FIXME this has been explicitly forbidden?
+#aux prepare_vg 5
+#lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+#lvconvert -m+1 -b $vg/$lv1 $dev4
+#lvconvert -m+1 $vg/$lv1 $dev5
+#
+#check mirror $vg $lv1 $dev3
+#check mirror_no_temporaries $vg $lv1
+#check mirror_legs $vg $lv1 4
+
+# Linear to mirror with mirrored log using --alloc anywhere
+aux prepare_vg 5
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
+should check mirror $vg $lv1
+
+# convert inactive mirror and start polling
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvchange -an $vg/$lv1
+lvconvert -m+1 $vg/$lv1 $dev4
+lvchange -ay $vg/$lv1
+lvconvert $vg/$lv1 # wait
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+
+# ---------------------------------------------------------------------
+# removal during conversion
+
+# "remove newly added mirror"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4
+lvconvert -m-1 $vg/$lv1 $dev4
+lvconvert $vg/$lv1 # wait
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# "remove one of newly added mirrors"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5
+lvconvert -m-1 $vg/$lv1 $dev4
+lvconvert $vg/$lv1 # wait
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# "remove from original mirror (the original is still mirror)"
+aux prepare_vg 5
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert $vg/$lv1 
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# "remove from original mirror (the original becomes linear)"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert $vg/$lv1 
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# ---------------------------------------------------------------------
+
+# "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
+aux prepare_vg 5
+lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
+lvconvert -m0 $vg/$lv1 $dev1
+check linear $vg $lv1
+
+# "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n$lv1 --nosync $vg 
+lvconvert -m0 $vg/$lv1
+lvconvert -m1 $vg/$lv1
+lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
+
+# lvconvert from linear (on multiple PVs) to mirror
+aux prepare_vg 5
+lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
+lvconvert -m1 $vg/$lv1
+
+should check mirror $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# BZ 463272: disk log mirror convert option is lost if downconvert option is also given
+aux prepare_vg 5
+lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
+lvconvert -m1 --mirrorlog disk $vg/$lv1
+check mirror $vg $lv1
+not check mirror $vg $lv1 core
+
+# ---
+# add mirror and disk log
+
+# "add 1 mirror and disk log" 
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+
+# FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# simple mirrored stripe
+aux prepare_vg 5
+lvcreate -i2 -l10 -n $lv1 $vg
+lvconvert -m1 -i1 $vg/$lv1
+lvreduce -f -l1 $vg/$lv1
+lvextend -f -l10 $vg/$lv1
+lvremove -ff $vg/$lv1
+
+# extents must be divisible
+lvcreate -l15 -n $lv1 $vg
+not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
+lvremove -ff $vg/$lv1
/cvs/lvm2/LVM2/test/shell/lvconvert-raid.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-raid.sh
+++ -	2011-11-21 00:16:05.824572000 +0000
@@ -0,0 +1,197 @@
+#!/bin/bash
+
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# is_in_sync <VG/LV>
+function is_in_sync()
+{
+	local dm_name
+	local a
+	local b
+	local idx
+
+	dm_name=`echo $1 | sed s:-:--: | sed s:/:-:`
+
+	if ! a=(`dmsetup status $dm_name`); then
+		echo "Unable to get sync status of $1"
+		exit 1
+	fi
+
+	# 6th argument is the sync ratio for RAID and mirror
+	echo ${a[@]}
+	if [ ${a[2]} = "raid" ]; then
+		# Last argument is the sync ratio for RAID
+		idx=$((${#a[@]} - 1))
+	elif [ ${a[2]} = "mirror" ]; then
+		# 4th Arg tells us how far to the sync ratio
+		idx=$((${a[3]} + 4))
+	else
+		echo "Unable to get sync ratio for target type '${a[2]}'"
+		exit 1
+	fi
+	b=(`echo ${a[$idx]} | sed s:/:' ':`)
+
+	if [ ${b[0]} != ${b[1]} ]; then
+		echo "$dm_name (${a[3]}) is not in-sync"
+		return 1
+	fi
+
+	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
+		echo "$dm_name in-sync, but 'a' characters in health status"
+		exit 1
+	fi
+
+	if [ ${a[2]} = "raid" ]; then
+		echo "$dm_name (${a[3]}) is in-sync"
+	else
+		echo "$dm_name (${a[2]}) is in-sync"
+	fi
+
+	return 0
+}
+
+# wait_for_sync <VG/LV>
+function wait_for_sync()
+{
+	local i=0
+
+	while ! is_in_sync $1; do
+		sleep 2
+		i=$(($i + 1))
+		if [ $i -gt 500 ]; then
+			echo "Sync is taking too long - assume stuck"
+			exit 1
+		fi
+	done
+}
+
+function is_raid_available()
+{
+	local a
+
+	modprobe dm-raid
+	a=(`dmsetup targets | grep raid`)
+	if [ -z $a ]; then
+		echo "RAID target not available"
+		return 1
+	fi
+	if [ ${a[1]} != "v1.1.0" ]; then
+		echo "Bad RAID version"
+		return 1
+	fi
+
+	return 0
+}
+
+########################################################
+# MAIN
+########################################################
+is_raid_available || exit 200
+
+aux prepare_vg 5 80
+
+###########################################
+# RAID1 convert tests
+###########################################
+for i in 1 2 3 4; do
+	for j in 1 2 3 4; do
+		if [ $i -eq 1 ]; then
+			from="linear"
+		else
+			from="$i-way"
+		fi
+		if [ $j -eq 1 ]; then
+			to="linear"
+		else
+			to="$j-way"
+		fi
+		echo "Converting from $from to $to"
+		if [ $i -eq 1 ]; then
+			# Shouldn't be able to create with just 1 image
+			not lvcreate --type raid1 -m 0 -l 2 -n $lv1 $vg
+
+			lvcreate -l 2 -n $lv1 $vg
+		else
+			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
+			wait_for_sync $vg/$lv1
+		fi
+		lvconvert -m $((j - 1))  $vg/$lv1
+
+		# FIXME: ensure no residual devices
+
+		if [ $j -eq 1 ]; then
+			check linear $vg $lv1
+		fi
+		lvremove -ff $vg
+	done
+done
+
+#
+# FIXME: Add tests that specify particular devices to be removed
+#
+
+###########################################
+# RAID1 split tests
+###########################################
+# 3-way to 2-way/linear
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_sync $vg/$lv1
+lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+check lv_exists $vg $lv1
+check linear $vg $lv2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+# 2-way to linear/linear
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+wait_for_sync $vg/$lv1
+lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+check linear $vg $lv1
+check linear $vg $lv2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+# 3-way to linear/2-way
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_sync $vg/$lv1
+# FIXME: Can't split off a RAID1 from a RAID1 yet
+should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
+#check linear $vg $lv1
+#check lv_exists $vg $lv2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+###########################################
+# RAID1 split + trackchanges / merge
+###########################################
+# 3-way to 2-way/linear
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_sync $vg/$lv1
+lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
+check lv_exists $vg $lv1
+check linear $vg ${lv1}_rimage_2
+lvconvert --merge $vg/${lv1}_rimage_2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+###########################################
+# Mirror to RAID1 conversion
+###########################################
+for i in 1 2 3 ; do
+	lvcreate --type mirror -m $i -l 2 -n $lv1 $vg
+	wait_for_sync $vg/$lv1
+	lvconvert --type raid1 $vg/$lv1
+	lvremove -ff $vg
+done
+
+exit 0
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-dmeventd.sh
+++ -	2011-11-21 00:16:05.925859000 +0000
@@ -0,0 +1,26 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+aux prepare_dmeventd
+
+which mkfs.ext2 || exit 200
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+aux disable_dev $dev2 $dev4
+mkfs.ext2 $DM_DEV_DIR/$vg/4way
+sleep 10 # FIXME: need a "poll" utility, akin to "check"
+aux enable_dev $dev2 $dev4
+check mirror $vg 4way
+check mirror_legs $vg 4way 2
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-policy.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-policy.sh
+++ -	2011-11-21 00:16:06.021913000 +0000
@@ -0,0 +1,91 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 4
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+# Clean-up and create a 2-way mirror, where the the
+# leg devices are always on $dev[12] and the log
+# is always on $dev3.  ($dev4 behaves as a spare)
+cleanup() {
+	vgreduce --removemissing $vg
+	for d in "$@"; do aux enable_dev $d; done
+	for d in "$@"; do vgextend $vg $d; done
+	lvremove -ff $vg/mirror
+	lvcreate -m 1 --ig -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
+}
+
+repair() {
+	lvconvert --repair --use-policies --config "$1" $vg/mirror
+}
+
+lvcreate -m 1 -L 1 -n mirror $vg
+lvchange -a n $vg/mirror
+
+# Fail a leg of a mirror.
+aux disable_dev $dev1
+lvchange --partial -a y $vg/mirror
+repair 'activation { mirror_image_fault_policy = "remove" }'
+check linear $vg mirror
+cleanup $dev1
+
+# Fail a leg of a mirror.
+# Expected result: Mirror (leg replaced, should retain log)
+aux disable_dev $dev1
+repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
+check mirror $vg mirror
+check active $vg mirror_mlog
+cleanup $dev1
+
+# Fail a leg of a mirror.
+# Expected result: Mirror (leg replaced)
+aux disable_dev $dev1
+repair 'activation { mirror_image_fault_policy = "replace" }'
+check mirror $vg mirror
+check active $vg mirror_mlog
+cleanup $dev1
+
+# Fail a leg of a mirror (use old name for policy specification)
+# Expected result: Mirror (leg replaced)
+aux disable_dev $dev1
+repair 'activation { mirror_image_fault_policy = "replace" }'
+check mirror $vg mirror
+check active $vg mirror_mlog
+cleanup $dev1
+
+# Fail a leg of a mirror w/ no available spare
+# Expected result: linear
+#                  (or 2-way with leg/log overlap if alloc anywhere)
+aux disable_dev $dev2 $dev4
+repair 'activation { mirror_image_fault_policy = "replace" }'
+check mirror $vg mirror
+not check lv_exists $vg mirror_mlog
+cleanup $dev2 $dev4
+
+# Fail the log device of a mirror w/ no available spare
+# Expected result: mirror w/ corelog
+aux disable_dev $dev3 $dev4
+repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
+check mirror $vg mirror
+not check lv_exists $vg mirror_mlog
+cleanup $dev3 $dev4
+
+# Fail the log device with a remove policy
+# Expected result: mirror w/ corelog
+lvchange -a y $vg/mirror
+aux disable_dev $dev3 $dev4
+repair 'activation { mirror_log_fault_policy = "remove" }'
+check mirror $vg mirror core
+not check lv_exists $vg mirror_mlog
+cleanup $dev3 $dev4
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-replace.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-replace.sh
+++ -	2011-11-21 00:16:06.110046000 +0000
@@ -0,0 +1,93 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 6
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+# 3-way, disk log
+# multiple failures, full replace
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
+aux disable_dev $dev1 $dev2
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev $dev1 $dev2
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 2-way, mirrored log
+# Double log failure, full replace
+lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+    $dev1 $dev2 $dev3:0 $dev4:0
+aux disable_dev $dev3 $dev4
+echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 2way.out
+vgreduce --removemissing $vg
+check mirror $vg 2way
+aux enable_dev $dev3 $dev4
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 3-way, mirrored log
+# Single log failure, replace
+lvcreate --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev $dev4
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
+
+# 3-way, disk log
+# multiple failures, partial replace
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
+aux disable_dev $dev1 $dev2
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+grep "WARNING: Failed" 3way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev $dev1 $dev2
+lvchange -a n $vg/3way
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3
+
+lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3
+aux disable_dev $dev1
+echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+grep "WARNING: Failed" 2way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 2way
+aux enable_dev $dev1 $dev2
+lvchange -a n $vg/2way
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
+
+# Test repair of inactive mirror with log failure
+#  Replacement should fail, but covert should succeed (switch to corelog)
+lvcreate -m 2 --ig -l 2 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4:0
+vgchange -a n $vg
+pvremove -ff -y $dev4
+echo 'y' | lvconvert -y --repair $vg/mirror2
+check mirror $vg mirror2
+vgs
+
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-snapshot.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-snapshot.sh
+++ -	2011-11-21 00:16:06.191941000 +0000
@@ -0,0 +1,27 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+lvcreate -s $vg/4way -L 2M -n snap
+
+aux disable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+aux enable_dev $dev2 $dev4
+lvs -a -o +devices
+check mirror $vg 4way $dev5
+
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ -	2011-11-21 00:16:06.300150000 +0000
@@ -0,0 +1,27 @@
+#!/bin/bash
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+aux prepare_dmeventd
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+aux disable_dev $dev2 $dev4
+mkfs.ext3 $DM_DEV_DIR/$vg/4way
+aux enable_dev $dev2 $dev4
+sleep 3
+lvs -a -o +devices | not grep unknown
+check mirror $vg 4way
+check mirror_legs $vg 4way 2
+lvs -a -o +devices | not grep mimage_1
+lvs -a -o +devices | not grep mimage_3
/cvs/lvm2/LVM2/test/shell/lvconvert-repair-transient.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair-transient.sh
+++ -	2011-11-21 00:16:06.418169000 +0000
@@ -0,0 +1,26 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+aux disable_dev $dev2 $dev4
+mkfs.ext3 $DM_DEV_DIR/$vg/4way &
+sleep 1
+aux enable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 4way
+lvchange -a n $vg/4way
+wait
/cvs/lvm2/LVM2/test/shell/lvconvert-repair.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-repair.sh
+++ -	2011-11-21 00:16:06.513036000 +0000
@@ -0,0 +1,108 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+# fail multiple devices
+
+# 4-way, disk log => 2-way, disk log
+aux prepare_vg 5
+lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+aux disable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+aux enable_dev $dev2 $dev4
+check mirror $vg 4way $dev5
+
+# 3-way, disk log => linear
+aux prepare_vg 5
+lvcreate -m 2 --ig -L 1 -n 3way $vg
+aux disable_dev $dev1 $dev2
+echo n | lvconvert --repair $vg/3way
+check linear $vg 3way
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev1 $dev2
+check linear $vg 3way
+
+# fail just log and get it removed
+
+# 3-way, disk log => 3-way, core log
+aux prepare_vg 5
+lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
+aux disable_dev $dev4
+echo n | lvconvert --repair $vg/3way
+check mirror $vg 3way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev4
+
+# 3-way, mirrored log => 3-way, core log
+aux prepare_vg 5
+lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4 $dev5
+echo n | lvconvert --repair $vg/3way
+check mirror $vg 3way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev4 $dev5
+
+# 2-way, disk log => 2-way, core log
+aux prepare_vg 5
+lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
+aux disable_dev $dev3
+echo n | lvconvert --repair $vg/2way
+check mirror $vg 2way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev3
+
+# fail single devices
+
+aux prepare_vg 5
+vgreduce $vg $dev4
+
+lvcreate -m 1 --ig -L 1 -n mirror $vg
+lvchange -a n $vg/mirror
+vgextend $vg $dev4
+aux disable_dev $dev1
+lvchange --partial -a y $vg/mirror
+
+not vgreduce -v --removemissing $vg
+lvconvert -y --repair $vg/mirror
+vgreduce --removemissing $vg
+
+aux enable_dev $dev1
+vgextend $vg $dev1
+aux disable_dev $dev2
+lvconvert -y --repair $vg/mirror
+vgreduce --removemissing $vg
+
+aux enable_dev $dev2
+vgextend $vg $dev2
+aux disable_dev $dev3
+lvconvert -y --repair $vg/mirror
+vgreduce --removemissing $vg
+aux enable_dev $dev3
+vgextend $vg $dev3
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/lvconvert-twostep.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvconvert-twostep.sh
+++ -	2011-11-21 00:16:06.611884000 +0000
@@ -0,0 +1,26 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 4
+
+lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
+not lvconvert -m 2 --mirrorlog core $vg/mirror $dev3 2>&1 | tee errs
+grep "two steps" errs
+
+lvconvert -m 2 $vg/mirror $dev3
+lvconvert --mirrorlog core $vg/mirror
+not lvconvert -m 1 --mirrorlog disk $vg/mirror $dev3 2>&1 | tee errs
+grep "two steps" errs
+
+not lvconvert -m 1 --mirrorlog mirrored $vg/mirror $dev3 $dev4 2>&1 | tee errs
+grep "two steps" errs
/cvs/lvm2/LVM2/test/shell/lvcreate-large.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-large.sh
+++ -	2011-11-21 00:16:06.717154000 +0000
@@ -0,0 +1,40 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+aux prepare_vg 4
+
+lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
+
+#FIXME this should be 1024T
+#check lv_field $vg/$lv size "128.00m"
+
+aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+
+pvcreate $DM_DEV_DIR/$vg/$lv
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
+
+lvcreate -l 100%FREE -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "1024.00t"
+lvresize -f -l 72%VG $vg1/$lv1
+check lv_field $vg1/$lv1 size "737.28t"
+lvremove -ff $vg1/$lv1
+
+lvcreate -l 100%VG -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "1024.00t"
+lvresize -f -l 72%VG $vg1/$lv1
+check lv_field $vg1/$lv1 size "737.28t"
+lvremove -ff $vg1/$lv1
+
+lvremove -ff $vg/$lv
/cvs/lvm2/LVM2/test/shell/lvcreate-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-mirror.sh
+++ -	2011-11-21 00:16:06.861420000 +0000
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+aux prepare_vg 5 80
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+# 2-way mirror with corelog, 2 PVs
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+# 2-way mirror with disklog, 3 PVs
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check mirror_images_redundant $vg $lv1
+check mirror_log_on $vg $lv1 $dev3
+lvremove -ff $vg
+
+# 3-way mirror with disklog, 4 PVs
+lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+check mirror_images_redundant $vg $lv1
+check mirror_log_on $vg $lv1 $dev3
+lvremove -ff $vg
+
+# lvcreate --nosync is in 100% sync after creation (bz429342)
+lvcreate -l2 -m1 --nosync -n $lv1 $vg $dev1 $dev2 $dev3:0-1 2>out
+grep "New mirror won't be synchronised." out
+lvs -o copy_percent --noheadings $vg/$lv1 | grep 100.00
+lvremove -ff $vg
+
+# creating 2-way mirror with disklog from 2 PVs fails
+not lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2
/cvs/lvm2/LVM2/test/shell/lvcreate-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-operation.sh
+++ -	2011-11-21 00:16:06.952508000 +0000
@@ -0,0 +1,43 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+cleanup_lvs() {
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+}
+
+aux prepare_pvs 2
+aux pvcreate --metadatacopies 0 $dev1
+aux vgcreate -c n $vg $(cat DEVICES)
+
+# ---
+# Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
+lvcreate -n$lv1 -l4 $vg $dev1
+lvcreate -n$lv2 -l4 -s $vg/$lv1
+lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
+cleanup_lvs
+
+# ---
+# Create mirror on two devices with mirrored log using --alloc anywhere
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1 $dev2
+cleanup_lvs
+
+# --
+# Create mirror on one dev with mirrored log using --alloc anywhere, should fail
+not lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
+cleanup_lvs
/cvs/lvm2/LVM2/test/shell/lvcreate-pvtags.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-pvtags.sh
+++ -	2011-11-21 00:16:07.082402000 +0000
@@ -0,0 +1,47 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_pvs 3
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+# not required, just testing
+aux pvcreate --metadatacopies 0 $dev1
+
+vgcreate -c n $vg $(cat DEVICES)
+pvchange --addtag fast $(cat DEVICES)
+
+# 3 stripes with 3 PVs (selected by tag, @fast) is fine
+lvcreate -l3 -i3 $vg @fast
+
+# too many stripes(4) for 3 PVs
+not lvcreate -l4 -i4 $vg @fast
+
+# 2 stripes is too many with just one PV
+not lvcreate -l2 -i2 $vg $DM_DEV_DIR/mapper/pv1
+
+# lvcreate mirror
+lvcreate -l1 -m1 $vg @fast
+
+# lvcreate mirror w/corelog
+lvcreate -l1 -m2 --corelog $vg @fast
+
+# lvcreate mirror w/no free PVs
+not lvcreate -l1 -m2 $vg @fast
+
+# lvcreate mirror (corelog, w/no free PVs)
+not lvcreate -l1 -m3 --corelog $vg @fast
+
+# lvcreate mirror with a single PV arg
+not lvcreate -l1 -m1 --corelog $vg $dev1
+
+vgremove -ff $vg
/cvs/lvm2/LVM2/test/shell/lvcreate-raid.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-raid.sh
+++ -	2011-11-21 00:16:07.220880000 +0000
@@ -0,0 +1,113 @@
+#!/bin/bash
+
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# is_raid_in_sync <VG/LV>
+function is_raid_in_sync()
+{
+	local dm_name
+	local a
+	local b
+	local idx
+
+	dm_name=`echo $1 | sed s:-:--: | sed s:/:-:`
+
+	if ! a=(`dmsetup status $dm_name`); then
+		echo "Unable to get sync status of $1"
+		exit 1
+	fi
+	idx=$((${#a[@]} - 1))
+	b=(`echo ${a[$idx]} | sed s:/:' ':`)
+
+	if [ ${b[0]} != ${b[1]} ]; then
+		echo "$dm_name (${a[3]}) is not in-sync"
+		return 1
+	fi
+
+	echo "$dm_name (${a[3]}) is in-sync"
+	return 0
+}
+
+# wait_for_raid_sync <VG/LV>
+function wait_for_raid_sync()
+{
+	local i=0
+
+	while ! is_raid_in_sync $1; do
+		sleep 2
+		i=$(($i + 1))
+		if [ $i -gt 500 ]; then
+			echo "Sync is taking too long - assume stuck"
+			exit 1
+		fi
+	done
+}
+
+function is_raid_available()
+{
+	local a
+
+	modprobe dm-raid
+	a=(`dmsetup targets | grep raid`)
+	if [ -z $a ]; then
+		echo "RAID target not available"
+		return 1
+	fi
+	if [ ${a[1]} != "v1.1.0" ]; then
+		echo "Bad RAID version"
+		return 1
+	fi
+
+	return 0
+}
+
+########################################################
+# MAIN
+########################################################
+is_raid_available || exit 200
+
+aux prepare_vg 5 80
+
+
+###########################################
+# Create, wait for sync, remove tests
+###########################################
+
+# Create RAID1 (implicit 2-way)
+lvcreate --type raid1 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvremove -ff $vg
+
+# Create RAID1 (explicit 2-way)
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvremove -ff $vg
+
+# Create RAID1 (explicit 3-way)
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvremove -ff $vg
+
+# Create RAID 4/5/6 (explicit 3-stripe + parity devs)
+for i in raid4 \
+	raid5 raid5_ls raid5_la raid5_rs raid5_ra \
+	raid6 raid6_zr raid6_nr raid6_nc; do
+
+	lvcreate --type $i -l 3 -i 3 -n $lv1 $vg
+	wait_for_raid_sync $vg/$lv1
+	lvremove -ff $vg
+done
+
+#
+# FIXME: Add tests that specify particular PVs to use for creation
+#
/cvs/lvm2/LVM2/test/shell/lvcreate-repair.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-repair.sh
+++ -	2011-11-21 00:16:07.301542000 +0000
@@ -0,0 +1,97 @@
+#!/bin/bash
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA	02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3
+
+# fail multiple devices
+for i in pv1 pv2 pv3 ; do
+	for j in pv2 pv3 ; do
+
+		if test $i = $j ; then continue ; fi
+
+		vgremove -ff $vg
+		vgcreate $vg $dev1 $dev2 $dev3
+
+		lvcreate -l1 -n $lv1 $vg $dev1
+
+		aux lvmconf "devices/filter = [ \"r/.*$i$/\", \"r/.*$j$/\", \"a/dev\/mapper\/.*pv[0-9_]*$/\", \"r/.*/\" ]"
+
+		vgreduce --removemissing --force $vg
+
+		# check if reduced device was removed
+		test $i = pv1 && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
+
+		lvcreate -l1 -n $lv2 $vg
+
+		test $i != pv1 && check lv_exists $vg $lv1
+		check lv_exists $vg $lv2
+
+		aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
+
+		test $i != pv1 && check lv_exists $vg $lv1
+		check lv_exists $vg $lv2
+	done
+done
+
+vgremove -ff $vg
+vgcreate $vg $dev1 $dev2 $dev3
+
+# use tricky 'dd'
+for i in "$dev1" "$dev2" "$dev3" ; do
+	for j in "$dev2" "$dev3" ; do
+
+		if test "$i" = "$j" ; then continue ; fi
+
+		dd if="$i" of=backup_i bs=256K count=1
+		dd if="$j" of=backup_j bs=256K count=1
+
+		lvcreate -l1 -n $lv1 $vg $dev1
+
+		dd if=backup_j of="$j" bs=256K count=1
+		dd if=backup_i of="$i" bs=256K count=1
+
+		check lv_exists $vg $lv1
+		# mda should be now consistent
+		lvremove -f $vg/$lv1
+	done
+done
+
+
+# confuse lvm with active LV left behind
+dd if="$dev1" of=backup_i bs=256K count=1
+dd if="$dev2" of=backup_j bs=256K count=1
+
+lvcreate -l1 $vg $dev1
+
+dd if=backup_j of="$dev2" bs=256K count=1
+dd if=backup_i of="$dev1" bs=256K count=1
+
+# CHECKME: following command writes here:
+# vgreduce --removemissing --force $vg
+#
+# WARNING: Inconsistent metadata found for VG LVMTESTvg - updating to use version 2
+# Volume group "LVMTESTvg" is already consistent
+
+# dirty game
+dd if=/dev/zero of="$dev3" bs=256K count=1
+
+vgreduce --removemissing --force $vg
+
+# FIXME: here is LV1 left active - but metadata does not know about it
+# and lvcreate does not check whether such device exists in the table
+# so it ends with: 
+#
+# device-mapper: create ioctl failed: Device or resource busy
+# Failed to activate new LV.
+
+should lvcreate -l1 $vg $dev1
/cvs/lvm2/LVM2/test/shell/lvcreate-small-snap.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-small-snap.sh
+++ -	2011-11-21 00:16:07.390573000 +0000
@@ -0,0 +1,30 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_pvs 3
+
+vgcreate -c n -s 1k $vg $(cat DEVICES)
+
+lvcreate -n one -l 10 $vg
+lvcreate -s -l 8 -n snapA $vg/one
+lvcreate -s -c 4k -l 8 -n snapX1 $vg/one
+lvcreate -s -c 8k -l 16 -n snapX2 $vg/one
+
+# Check that snapshots that are too small are caught with correct error.
+not lvcreate -s -c 8k -l 8 -n snapX3 $vg/one 2>&1 | tee lvcreate.out
+not grep "suspend origin one" lvcreate.out
+grep "Unable to create a snapshot" lvcreate.out
+
+not lvcreate -s -l 4 -n snapB $vg/one 2>&1 | tee lvcreate.out
+not grep "suspend origin one" lvcreate.out
+grep "Unable to create a snapshot" lvcreate.out
/cvs/lvm2/LVM2/test/shell/lvcreate-striped-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-striped-mirror.sh
+++ -	2011-11-21 00:16:07.501435000 +0000
@@ -0,0 +1,65 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+aux prepare_vg 9
+
+lvcreate -i2 -l2 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i2 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l3 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+
+lvcreate -i2 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l3 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i2 -l2 -m3 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (2 extents) up to .* (3 extents)" log
+lvremove -ff $vg
+
+lvcreate -i3 -l4 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (4 extents) up to .* (6 extents)" log
+lvremove -ff $vg
+
+lvcreate -i3 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (4 extents) up to .* (6 extents)" log
+lvremove -ff $vg
+
+lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/lvcreate-thin.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-thin.sh
+++ -	2011-11-21 00:16:07.645826000 +0000
@@ -0,0 +1,186 @@
+#!/bin/sh
+
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test currently needs to drop
+# 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
+
+. lib/test
+
+check_lv_exists_()
+{
+	for d in $*; do
+		check lv_exists $vg $d
+	done
+}
+
+check_lv_field_modules_()
+{
+	mod=$1
+	shift
+
+	for d in $*; do
+		check lv_field $vg/$d modules $mod
+	done
+}
+
+
+#
+# Main
+#
+aux target_at_least dm-thin-pool 1 0 0 || skip
+
+aux prepare_devs 2 64
+
+pvcreate $dev1 $dev2
+
+clustered=
+test -e LOCAL_CLVMD && clustered="--clustered y"
+
+vgcreate $clustered $vg -s 64K $dev1 $dev2
+
+# Create named pool only
+lvcreate -l1 -T $vg/pool1
+lvcreate -l1 -T --thinpool $vg/pool2
+lvcreate -l1 -T --thinpool pool3 $vg
+lvcreate -l1 --type thin $vg/pool4
+lvcreate -l1 --type thin --thinpool $vg/pool5
+lvcreate -l1 --type thin --thinpool pool6 $vg
+lvcreate -l1 --type thin_pool $vg/pool7
+lvcreate -l1 --type thin_pool --thinpool $vg/pool8
+lvcreate -l1 --type thin_pool --thinpool pool9 $vg
+
+lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/pool7 $vg/pool8 $vg/pool9
+check vg_field $vg lv_count 0
+
+
+# Create default pool name
+lvcreate -l1 -T $vg
+lvcreate -l1 --type thin $vg
+lvcreate -l1 --type thin_pool $vg
+
+lvremove -ff $vg/lvol0 $vg/lvol1 $vg/lvol2
+check vg_field $vg lv_count 0
+
+
+# Create default pool and default thin LV
+lvcreate -l1 -V2G -T $vg
+lvcreate -l1 -V2G --type thin $vg
+
+lvremove -ff $vg
+
+
+# Create named pool and default thin LV
+lvcreate -L4M -V2G -T $vg/pool1
+lvcreate -L4M -V2G -T --thinpool $vg/pool2
+lvcreate -L4M -V2G -T --thinpool pool3 $vg
+lvcreate -L4M -V2G --type thin $vg/pool4
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool5
+lvcreate -L4M -V2G --type thin --thinpool pool6 $vg
+
+check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+lvremove -ff $vg
+
+
+# Create named pool and named thin LV
+lvcreate -L4M -V2G -T $vg/pool1 --name lv1
+lvcreate -L4M -V2G -T $vg/pool2 --name $vg/lv2
+lvcreate -L4M -V2G -T --thinpool $vg/pool3 --name lv3
+lvcreate -L4M -V2G -T --thinpool $vg/pool4 --name $vg/lv4
+lvcreate -L4M -V2G -T --thinpool pool5 --name lv5 $vg
+lvcreate -L4M -V2G -T --thinpool pool6 --name $vg/lv6 $vg
+
+check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
+lvremove -ff $vg
+
+
+lvcreate -L4M -V2G --type thin $vg/pool1 --name lv1
+lvcreate -L4M -V2G --type thin $vg/pool2 --name $vg/lv2
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool3 --name lv3
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool4 --name $vg/lv4
+lvcreate -L4M -V2G --type thin --thinpool pool5 --name lv5 $vg
+lvcreate -L4M -V2G --type thin --thinpool pool6 --name $vg/lv6 $vg
+
+check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
+lvremove -ff $vg
+
+
+# Create default thin LV in existing pool
+lvcreate -L4M -T $vg/pool
+lvcreate -V2G -T $vg/pool
+lvcreate -V2G -T --thinpool $vg/pool
+lvcreate -V2G -T --thinpool pool $vg
+lvcreate -V2G --type thin $vg/pool
+lvcreate -V2G --type thin --thinpool $vg/pool
+lvcreate -V2G --type thin --thinpool pool $vg
+
+check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+
+
+# Create named thin LV in existing pool
+lvcreate -V2G -T $vg/pool --name lv1
+lvcreate -V2G -T $vg/pool --name $vg/lv2
+lvcreate -V2G -T --thinpool $vg/pool --name lv3
+lvcreate -V2G -T --thinpool $vg/pool --name $vg/lv4
+lvcreate -V2G -T --thinpool pool --name lv5 $vg
+lvcreate -V2G -T --thinpool pool --name $vg/lv6 $vg
+lvcreate -V2G --type thin $vg/pool --name lv7
+lvcreate -V2G --type thin $vg/pool --name $vg/lv8
+lvcreate -V2G --type thin --thinpool $vg/pool --name lv9
+lvcreate -V2G --type thin --thinpool $vg/pool --name $vg/lv10
+lvcreate -V2G --type thin --thinpool pool --name lv11 $vg
+lvcreate -V2G --type thin --thinpool pool --name $vg/lv12 $vg
+
+check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6 lv7 lv8 lv9 lv10 lv11 lv12
+check vg_field $vg lv_count 19
+
+lvremove -ff $vg
+check vg_field $vg lv_count 0
+
+# Create thin snapshot of thinLV
+lvcreate -L10M -V10M -T $vg/pool --name lv1
+mkfs.ext4 $DM_DEV_DIR/$vg/lv1
+lvcreate -s $vg/lv1
+fsck -p $DM_DEV_DIR/$vg/lvol0
+lvcreate -s $vg/lv1 --name lv2
+lvcreate -s $vg/lv1 --name $vg/lv3
+lvcreate --type snapshot $vg/lv1
+lvcreate --type snapshot $vg/lv1 --name lv4
+lvcreate --type snapshot $vg/lv1 --name $vg/lv5
+
+check_lv_field_modules_ thin-pool lv1 lvol0 lv2 lv3 lvol1 lv4 lv5
+check vg_field $vg lv_count 8
+lvremove -ff $vg
+
+
+# Normal Snapshots of thinLV
+lvcreate -L4M -V2G -T $vg/pool --name lv1
+lvcreate -s $vg/lv1 -l1
+lvcreate -s $vg/lv1 -l1 --name lv2
+lvcreate -s $vg/lv1 -l1 --name $vg/lv3
+lvcreate -s lv1 -L4M --name $vg/lv4
+
+check_lv_field_modules_ snapshot lvol0 lv2 lv3 lv4
+check vg_field $vg lv_count 6
+
+lvremove -ff $vg
+check vg_field $vg lv_count 0
+
+
+# Fail cases
+# Too small pool size (1 extent 64KB) for given chunk size
+not lvcreate --chunksize 256 -l1 -T $vg/pool1
+# Too small chunk size (min is 64KB -  128 sectors)
+not lvcreate --chunksize 32 -l1 -T $vg/pool1
+
+lvcreate -L4M -V2G --name lv1 -T $vg/pool1
+# Origin name is not accepted
+not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
/cvs/lvm2/LVM2/test/shell/lvcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvcreate-usage.sh
+++ -	2011-11-21 00:16:07.725613000 +0000
@@ -0,0 +1,152 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+aux prepare_pvs 4
+aux pvcreate --metadatacopies 0 $dev1
+vgcreate -cn $vg $(cat DEVICES)
+
+# "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
+lvcreate -n $lv -l 4 $vg 
+not lvcreate -n $lv -l 4 $vg
+lvremove -ff $vg/$lv
+# try to remove it again - should fail (but not segfault)
+not lvremove -ff $vg/$lv
+
+# "lvcreate rejects a negative stripe_size"
+not lvcreate -L 64m -n $lv -i2 --stripesize -4 $vg 2>err;
+grep "^  Negative stripesize is invalid\$" err
+
+# 'lvcreate rejects a too-large stripesize'
+not lvcreate -L 64m -n $lv -i2 --stripesize 4294967291 $vg 2>err
+grep "^  Stripe size cannot be larger than" err
+
+# 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
+lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg 2> err | tee out
+grep "^  Ignoring stripesize argument with single stripe\$" out 
+lvdisplay $vg 
+lvremove -ff $vg
+
+# 'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout'
+lvcreate -L 64m -n $lv -i2 $vg > out
+grep "^  Using default stripesize" out 
+lvdisplay $vg 
+check lv_field $vg/$lv stripesize "64.00k"
+lvremove -ff $vg
+
+# 'lvcreate rejects an invalid number of stripes' 
+not lvcreate -L 64m -n $lv -i129 $vg 2>err
+grep "^  Number of stripes (129) must be between 1 and 128\$" err
+
+# The case on lvdisplay output is to verify that the LV was not created.
+# 'lvcreate rejects an invalid stripe size'
+not lvcreate -L 64m -n $lv -i2 --stripesize 3 $vg 2>err
+grep "^  Invalid stripe size" err
+case $(lvdisplay $vg) in "") true ;; *) false ;; esac
+
+# Setting max_lv works. (bz490298)
+lvremove -ff $vg
+vgchange -l 3 $vg
+lvcreate -l1 -n $lv1 $vg
+lvcreate -l1 -s -n $lv2 $vg/$lv1
+lvcreate -l1 -n $lv3 $vg
+not lvcreate -l1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -s -n $lv3 $vg/$lv1
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -m1 -n $lv3 $vg
+lvs
+vgs -o +max_lv
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvconvert -m0 $vg/$lv3
+lvconvert -m2 -i 1 $vg/$lv3
+lvconvert -m1 $vg/$lv3
+
+not vgchange -l 2
+vgchange -l 4
+vgs $vg
+
+lvremove -ff $vg
+vgchange -l 0 $vg
+
+# lvcreate rejects invalid chunksize, accepts between 4K and 512K
+# validate origin_size
+vgremove -ff $vg
+vgcreate -cn $vg $(cat DEVICES)
+lvcreate -L 32m -n $lv1 $vg
+not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
+not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
+lvcreate -L 8m -n $lv2 -s --chunksize 4k $vg/$lv1
+check lv_field $vg/$lv2 chunk_size 4.00k
+check lv_field $vg/$lv2 origin_size 32.00m
+lvcreate -L 8m -n $lv3 -s --chunksize 512k $vg/$lv1
+check lv_field $vg/$lv3 chunk_size 512.00k
+check lv_field $vg/$lv3 origin_size 32.00m
+lvremove -ff $vg
+vgchange -l 0 $vg
+
+# regionsize must be
+# - nonzero (bz186013)
+# - a power of 2 and a multiple of page size
+# - <= size of LV
+not lvcreate -L 32m -n $lv -R0 $vg 2>err
+grep "Non-zero region size must be supplied." err
+not lvcreate -L 32m -n $lv -R 11k $vg
+not lvcreate -L 32m -n $lv -R 1k $vg
+lvcreate -L 32m -n $lv --regionsize 128m  -m 1 $vg
+check lv_field $vg/$lv regionsize "32.00m"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --regionsize 4m -m 1 $vg
+check lv_field $vg/$lv regionsize "4.00m"
+lvremove -ff $vg
+
+# snapshot with virtual origin works
+lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
+lvrename $vg/$lv1 $vg/$lv2
+lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
+lvchange -a n $vg/$lv1
+lvremove -ff $vg/$lv1
+lvremove -ff $vg
+
+# readahead default (auto), none, #, auto
+lvcreate -L 32m -n $lv $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead none $vg
+check lv_field $vg/$lv lv_read_ahead "0"
+check lv_field $vg/$lv lv_kernel_read_ahead "0"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead 8k $vg
+check lv_field $vg/$lv lv_read_ahead "8.00k"
+check lv_field $vg/$lv lv_kernel_read_ahead "8.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead auto $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv -i2 --stripesize 16k --readahead auto $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv -i2 --stripesize 128k --readahead auto $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "512.00k"
+lvremove -ff $vg
+
/cvs/lvm2/LVM2/test/shell/lvextend-percent-extents.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvextend-percent-extents.sh
+++ -	2011-11-21 00:16:07.819008000 +0000
@@ -0,0 +1,106 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Check extents percentage arguments'
+
+. lib/test
+
+aux prepare_vg 2 128
+
+lvcreate -L 64m -n $lv $vg
+
+# 'lvextend rejects both size and extents without PVs'
+not lvextend -l 10 -L 64m $vg/$lv 2>err
+grep "^  Please specify either size or extents but not both.\$" err
+
+# 'lvextend rejects both size and extents with PVs'
+not lvextend -l 10 -L 64m $vg/$lv $dev1 2>err
+grep "^  Please specify either size or extents but not both.\$" err
+
+# 'lvextend accepts no size or extents but one PV - bz154691'
+lvextend $vg/$lv $dev1 >out
+grep "^  Logical volume $lv successfully resized\$" out
+check pv_field $dev1 pv_free "0"
+
+lvremove -f $vg/$lv 
+
+# 'lvextend computes necessary free space correctly - bz213552'
+vgsize=$(vgs -o vg_extent_count --noheadings)
+lvcreate -l $vgsize  -n $lv $vg
+lvreduce -f -l $(( $vgsize / 2 )) $vg/$lv
+lvextend -l $vgsize $vg/$lv
+
+# 'Reset LV to original size' 
+lvremove -f $vg/$lv 
+lvcreate -L 64m -n $lv $vg
+
+# 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
+lvextend -l +100%PVS $vg/$lv $dev1 $dev2 >out
+grep "^  Logical volume $lv successfully resized\$" out 
+check pv_field $dev1 pv_free "0" 
+check pv_field $dev2 pv_free "0"
+
+# Exercise the range overlap code.  Allocate every 2 extents.
+#
+#      Physical Extents
+#          1         2
+#012345678901234567890123
+#
+#aaXXaaXXaaXXaaXXaaXXaaXX - (a)llocated
+#rrrXXXrrrXXXrrrXXXrrrXXX - (r)ange on cmdline
+#ooXXXXXXoXXXooXXXXXXoXXX - (o)verlap of range and allocated
+#
+# Key: a - allocated
+#      F - free
+#      r - part of a range on the cmdline
+#      N - not on cmdline
+#
+# Create the LV with 12 extents, allocated every other 2 extents.
+# Then extend it, with a range of PVs on the cmdline of every other 3 extents.
+# Total number of extents should be 12 + overlap = 12 + 6 = 18.
+# Thus, total size for the LV should be 18 * 4M = 72M
+#
+# 'Reset LV to 12 extents, allocate every other 2 extents' 
+create_pvs=`for i in $(seq 0 4 20); do echo -n "\$dev1:$i-$(($i + 1)) "; done` 
+lvremove -f $vg/$lv
+lvcreate -l 12 -n $lv $vg $create_pvs
+check lv_field $vg/$lv lv_size "48.00m"
+
+# 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' 
+extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$dev1:$i-$(($i + 2)) "; done` 
+lvextend -l +100%PVS $vg/$lv $extend_pvs >out
+grep "^  Logical volume $lv successfully resized\$" out 
+check lv_field $vg/$lv lv_size "72.00m"
+
+# Simple seg_count validation; initially create the LV with half the # of
+# extents (should be 1 lv segment), extend it (should go to 2 segments),
+# then reduce (should be back to 1)
+# FIXME: test other segment fields such as seg_size, pvseg_start, pvseg_size
+lvremove -f $vg/$lv
+pe_count=$(pvs -o pv_pe_count --noheadings $dev1)
+pe1=$(( $pe_count / 2 ))
+lvcreate -l $pe1 -n $lv $vg
+pesize=$(lvs -ovg_extent_size --units b --nosuffix --noheadings $vg/$lv)
+segsize=$(( $pe1 * $pesize / 1024 / 1024 ))m
+check lv_field $vg/$lv seg_count 1
+check lv_field $vg/$lv seg_start 0
+check lv_field $vg/$lv seg_start_pe 0
+#check lv_field $vg/$lv seg_size $segsize
+lvextend -l +$(( $pe_count * 1 )) $vg/$lv
+check lv_field $vg/$lv seg_count 2
+lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
+check lv_field $vg/$lv seg_count 1
+
+# do not reduce to 0 extents
+lvremove -f $vg/$lv
+lvcreate -i2 -I 64k -l10 -n $lv $vg
+lvreduce -f -l1 $vg/$lv
+check lv_field $vg/$lv lv_size "8.00m"
/cvs/lvm2/LVM2/test/shell/lvextend-snapshot-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvextend-snapshot-dmeventd.sh
+++ -	2011-11-21 00:16:07.908516000 +0000
@@ -0,0 +1,51 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+extend() {
+	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+}
+
+write() {
+	mount $DM_DEV_DIR/$vg/snap mnt
+	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
+	umount mnt
+}
+
+percent() {
+	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+}
+
+which mkfs.ext2 || exit 200
+
+aux prepare_vg 2
+aux prepare_dmeventd
+
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+lvchange --monitor y $vg/snap
+
+mkdir mnt
+
+write 1 4096
+pre=`percent`
+sleep 10 # dmeventd only checks every 10 seconds :(
+post=`percent`
+
+test $pre = $post
+write 2 5000
+pre=`percent`
+sleep 10 # dmeventd only checks every 10 seconds :(
+post=`percent`
+test $pre -gt $post
/cvs/lvm2/LVM2/test/shell/lvextend-snapshot-policy.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvextend-snapshot-policy.sh
+++ -	2011-11-21 00:16:07.996996000 +0000
@@ -0,0 +1,47 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+extend() {
+	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+}
+
+write() {
+	mount $DM_DEV_DIR/$vg/snap mnt
+	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
+	umount mnt
+}
+
+percent() {
+	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+}
+
+which mkfs.ext2 || exit 200
+
+aux prepare_vg 2
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+mkdir mnt
+
+write 1 4096
+pre=`percent`
+extend 50
+post=`percent`
+
+test $pre = $post
+write 2 4096
+pre=`percent`
+extend 50
+post=`percent`
+test $pre -gt $post
/cvs/lvm2/LVM2/test/shell/lvm-init.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvm-init.sh
+++ -	2011-11-21 00:16:08.083102000 +0000
@@ -0,0 +1,21 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests lvm initialization, and especially negative tests of error paths
+#
+
+. lib/test
+
+aux prepare_devs 5
+
+# invalid units
+not pvs --config 'global { units = "<" }'
+
/cvs/lvm2/LVM2/test/shell/lvmcache-exercise.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvmcache-exercise.sh
+++ -	2011-11-21 00:16:08.166933000 +0000
@@ -0,0 +1,23 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_pvs 5
+
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev3
+
+aux disable_dev $dev1
+pvscan
+vgcreate $vg1 $dev2
+aux enable_dev $dev1
+pvs
+pvs
/cvs/lvm2/LVM2/test/shell/lvresize-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvresize-mirror.sh
+++ -	2011-11-21 00:16:08.267253000 +0000
@@ -0,0 +1,38 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+aux prepare_vg 5 80
+
+# extend 2-way mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+lvextend -l+2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+check mirror_images_contiguous $vg $lv1
+lvremove -ff $vg
+
+# reduce 2-way mirror
+lvcreate -l4 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+lvreduce -l-2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# extend 2-way mirror (cling if not contiguous)
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l1 -n $lv2 $vg $dev1
+lvcreate -l1 -n $lv3 $vg $dev2
+lvchange -an $vg/$lv1
+lvextend -l+2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+check mirror_images_clung $vg $lv1
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/lvresize-rounding.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvresize-rounding.sh
+++ -	2011-11-21 00:16:08.352747000 +0000
@@ -0,0 +1,25 @@
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 2
+
+lvcreate -l 10 -n lv -i2 $vg
+
+lvextend -l +1 $vg/lv 2>&1 | tee log
+grep 'down to stripe' log
+lvresize -l +1 $vg/lv 2>&1 | tee log
+grep 'down to stripe' log
+
+lvreduce -f -l -1 $vg/lv 2>&1 | tee log
+grep 'up to stripe' log
+lvresize -f -l -1 $vg/lv 2>&1 | tee log
+grep 'up to stripe' log
/cvs/lvm2/LVM2/test/shell/lvresize-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvresize-usage.sh
+++ -	2011-11-21 00:16:08.472820000 +0000
@@ -0,0 +1,20 @@
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 2
+
+lvcreate -L 10M -n lv -i2 $vg
+lvresize -l +4 $vg/lv
+lvremove -ff $vg
+
+lvcreate -L 64M -n $lv -i2 $vg
+not lvresize -v -l +4 xxx/$lv
/cvs/lvm2/LVM2/test/shell/mdata-strings.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/mdata-strings.sh
+++ -	2011-11-21 00:16:08.580042000 +0000
@@ -0,0 +1,39 @@
+#!/bin/sh
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Test for proper escaping of strings in metadata (bz431474)'
+
+. lib/test
+
+aux prepare_devs 2
+
+# for udev impossible to create
+pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
+
+# 'set up temp files, loopback devices' 
+name=$(basename "$dev1")
+dmsetup rename "$name" "$PREFIX$pv_ugly"
+dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
+
+dmsetup table | grep -F "$pv_ugly"
+
+# 'pvcreate, vgcreate on filename with backslashed chars' 
+created=$dev1
+# when used with real udev without fallback, it will fail here
+pvcreate "$dev1" || created=$dev2
+pvdisplay | should grep -F "$pv_ugly"
+should check pv_field "$dev1" pv_name "$dev1"
+vgcreate $vg "$created"
+# 'no parse errors and VG really exists' 
+vgs 2>err
+not grep "Parse error" err;
+vgs $vg
+
/cvs/lvm2/LVM2/test/shell/metadata-balance.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/metadata-balance.sh
+++ -	2011-11-21 00:16:08.696411000 +0000
@@ -0,0 +1,232 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 6
+
+echo Make sure we can ignore / un-ignore mdas on a per-PV basis
+for pv_in_vg in 1 0; do
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2
+        pvcreate --metadatacopies 0 $dev3
+	if [ $pv_in_vg = 1 ]; then
+		vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	fi
+	pvchange --metadataignore y $dev1
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_used_count 0
+	check pv_field $dev2 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
+	if [ $pv_in_vg = 1 ]; then
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_used_count $mdacp
+		check vg_field $vg vg_mda_copies unmanaged
+	fi
+	pvchange --metadataignore n $dev1
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_used_count $mdacp
+	if [ $pv_in_vg = 1 ]; then
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_copies unmanaged
+		vgremove -f $vg
+	fi
+done
+done
+
+# Check if a PV has unignored (used) mdas, and if so, ignore
+pvignore_ () {
+	pv_mda_used_count=$(get pv_field "$1" pv_mda_used_count)
+	if [ $pv_mda_used_count -ne 0 ]; then
+	    pvchange --metadataignore y $1
+	fi
+}
+
+# Check if a PV has ignored mdas, and if so, unignore (make used)
+pvunignore_ () {
+	pv_mda_count=$(get pv_field "$1" pv_mda_count)
+	pv_mda_used_count=$(get pv_field "$1" pv_mda_used_count)
+	if [ $pv_mda_count -gt $pv_mda_used_count ]; then
+	    pvchange --metadataignore n $1
+	fi
+}
+
+echo Test of vgmetadatacopies with vgcreate and vgchange
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
+	check pv_field $dev1 pv_mda_used_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check pv_field $dev5 pv_mda_used_count $mdacp
+	pvcreate --metadatacopies 0 $dev3
+	vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	check vg_field $vg vg_mda_copies unmanaged
+	echo ensure both --vgmetadatacopies and --metadatacopies accepted
+	vgchange --metadatacopies $(($mdacp * 1)) $vg
+	echo --vgmetadatacopies is persistent on disk
+	echo --vgmetadatacopies affects underlying pv mda ignore
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 1))
+	vgchange --vgmetadatacopies $(($mdacp * 2)) $vg
+	check vg_field $vg vg_mda_copies $(($mdacp * 2))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+	echo allow setting metadatacopies larger than number of PVs
+	vgchange --vgmetadatacopies $(($mdacp * 5)) $vg
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+	echo setting to 0 disables automatic balancing
+	vgchange --vgmetadatacopies unmanaged $vg
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+	echo vgcreate succeeds even when creating a VG w/all ignored mdas
+	pvchange --metadataignore y $dev1 $dev2
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_used_count 0
+	vgcreate -c n "$vg" $dev1 $dev2
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+	echo vgcreate succeeds with a specific number of metadata copies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) "$vg" $dev1 $dev2
+	check vg_field $vg vg_mda_copies $(($mdacp * 2))
+	vgremove -f $vg
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	vgremove -f $vg
+	echo vgcreate succeeds with a larger value than total metadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	vgremove -f $vg
+	echo vgcreate succeeds with --vgmetadatacopies unmanaged
+	vgcreate -c n --vgmetadatacopies unmanaged "$vg" $dev1 $dev2
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+	pvunignore_ $dev1
+	pvunignore_ $dev2
+	pvunignore_ $dev4
+	pvunignore_ $dev5
+	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
+	vgcreate -c n --vgmetadatacopies 1 "$vg" $dev1 $dev2 $dev4 $dev5
+	check vg_field $vg vg_mda_copies 1
+	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_used_count 1
+	echo Setting a larger value should trigger non-ignore of mdas
+	vgchange --metadatacopies 3 $vg
+	check vg_field $vg vg_mda_copies 3
+	check vg_field $vg vg_mda_used_count 3
+	echo Setting all should trigger unignore of all mdas
+	vgchange --vgmetadatacopies all $vg
+	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_used_count $(($mdacp * 4))
+	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate
+	vgchange --vgmetadatacopies 0 $vg
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+	vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2 $dev4 $dev5
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+done
+
+echo Test vgextend / vgreduce with vgmetadatacopies
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
+	pvcreate --metadatacopies 0 $dev3
+	echo Set a large value of vgmetadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2 $dev3
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	echo Ignore mdas on devices to be used for vgextend
+	echo Large value of vgetadatacopies should automatically un-ignore mdas
+	pvchange --metadataignore y $dev4 $dev5
+	check pv_field $dev4 pv_mda_used_count 0
+	vgextend $vg $dev4 $dev5
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check pv_field $dev5 pv_mda_used_count $mdacp
+	vgremove -f $vg
+	echo Set a small value of vgmetadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2 $dev3
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	echo Ignore mdas on devices to be used for vgextend
+	echo Small value of vgetadatacopies should leave mdas as ignored
+	pvchange --metadataignore y $dev4 $dev5
+	check pv_field $dev4 pv_mda_used_count 0
+	vgextend $vg $dev4 $dev5
+	check pv_field $dev4 pv_mda_used_count 0
+	check pv_field $dev5 pv_mda_used_count 0
+	echo vgreduce of ignored pv w/mda should not trigger any change to ignore bits
+	vgreduce $vg $dev4
+	check pv_field $dev4 pv_mda_used_count 0
+	check pv_field $dev5 pv_mda_used_count 0
+	echo vgreduce of un-ignored pv w/mda should trigger un-ignore on an mda
+	vgreduce $vg $dev1 $dev2 $dev3
+	check pv_field $dev5 pv_mda_used_count $mdacp
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	pvunignore_ $dev1
+	pvunignore_ $dev2
+	echo setting vgmetadatacopies to unmanaged should allow vgextend to add w/out balancing
+	vgchange --vgmetadatacopies unmanaged $vg
+	vgextend $vg $dev1 $dev2
+	check vg_field $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_count $(($mdacp * 3))
+	check vg_field $vg vg_mda_used_count $((mdacp * 3))
+	check pv_field $dev1 pv_mda_used_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
+	vgremove -f $vg
+done
+
+echo Test special situations, vgsplit, vgmerge, etc
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
+	vgcreate -c n --vgmetadatacopies 2 $vg1 $dev1 $dev2 $dev3
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 $dev4 $dev5
+	echo vgsplit/vgmerge preserves value of metadata copies
+	check vg_field $vg1 vg_mda_copies 2
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
+	vgsplit $vg1 $vg2 $dev1
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
+	vgmerge $vg1 $vg2
+	check vg_field $vg1 vg_mda_copies 2
+	check vg_field $vg1 vg_mda_count $(($mdacp * 5))
+	echo vgsplit into new vg sets proper value of vgmetadatacopies
+	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 $dev1 $dev2
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 2))
+	echo vgchange fails if given both vgmetadatacopies and metadatacopies
+	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2
+	vgremove -f $vg1
+	vgremove -f $vg2
+done
+
+echo Test combination of --vgmetadatacopies and pvchange --metadataignore
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg1 $dev1 $dev2
+	check vg_field $vg1 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
+	pvignore_ $dev3
+	echo Ensure vgextend of PVs with ignored MDAs does not add to vg_mda_used_count
+	vgextend $vg1 $dev3
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
+	echo Using pvchange to unignore should update vg_mda_used_count
+	pvchange -f --metadataignore n $dev3
+	check pv_field $dev3 pv_mda_used_count $mdacp
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	echo Set unmanaged on the vg should keep ignore bits the same during vgextend
+	vgchange --vgmetadatacopies unmanaged $vg1
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	pvunignore_ $dev4
+	vgextend $vg1 $dev4
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 3))
+	echo Using pvchange to ignore should update vg_mda_used_count
+	pvchange -f --metadataignore y $dev4
+	check pv_field $dev4 pv_mda_used_count 0
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	vgremove -f $vg1
+done
/cvs/lvm2/LVM2/test/shell/metadata-dirs.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/metadata-dirs.sh
+++ -	2011-11-21 00:16:08.840008000 +0000
@@ -0,0 +1,43 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 3
+pvcreate --metadatacopies 0 $(cat DEVICES)
+
+not vgcreate $vg $(cat DEVICES)
+
+aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
+
+vgcreate $vg $dev1
+check vg_field $vg vg_mda_count 1
+vgremove -ff $vg
+
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 1
+
+vgremove -ff $vg
+pvcreate --metadatacopies 1 --metadataignore y $dev1
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2
+
+vgremove -ff $vg
+pvcreate --metadatacopies 1 --metadataignore n $dev1
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2
+
+vgremove -ff $vg
+pvcreate --metadatacopies 0 $dev1
+
+aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2
/cvs/lvm2/LVM2/test/shell/metadata.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/metadata.sh
+++ -	2011-11-21 00:16:08.944490000 +0000
@@ -0,0 +1,80 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 5
+
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --metadatacopies 0 $dev5
+
+vgcreate -c n "$vg" $(cat DEVICES)
+lvcreate -n $lv -l 1 -i5 -I256 $vg
+
+pvchange -x n $dev1
+pvchange -x y $dev1
+vgchange -a n $vg
+pvchange --uuid $dev1
+pvchange --uuid $dev2
+vgremove -f $vg
+
+# check that PVs without metadata don't cause too many full device rescans (bz452606)
+for mdacp in 1 0; do
+	pvcreate --metadatacopies $mdacp $(cat DEVICES)
+	pvcreate $dev1
+	vgcreate -c n $vg $(cat DEVICES)
+	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
+	lvcreate -n $lv2 -m2 -l 2  $vg
+	#lvchange -an $vg
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/$lv2
+	vgchange -ay $vg
+	lvchange -vvvv -an $vg/$lv1 >out$mdacp 2>&1 
+	lvchange -vvvv -an $vg/$lv2 >>out$mdacp 2>&1 
+	vgremove -f $vg
+done
+not grep "Cached VG .* incorrect PV list" out0
+
+# some M1 metadata tests
+pvcreate -M1 $dev1
+pvcreate -M1 $dev2
+pvcreate -M1 $dev3
+pv3_uuid=$(pvs --noheadings -o pv_uuid $dev3)
+vgcreate -M1 -c n $vg $dev1 $dev2 $dev3
+pvchange --uuid $dev1
+
+# verify pe_start of all M1 PVs
+pv_align="128.00k"
+check pv_field $dev1 pe_start $pv_align
+check pv_field $dev2 pe_start $pv_align
+check pv_field $dev3 pe_start $pv_align
+
+pvs --units k -o name,pe_start,vg_mda_size,vg_name
+
+# upgrade from v1 to v2 metadata
+vgconvert -M2 $vg
+
+# verify pe_start of all M2 PVs
+check pv_field $dev1 pe_start $pv_align
+check pv_field $dev2 pe_start $pv_align
+check pv_field $dev3 pe_start $pv_align
+
+pvs --units k -o name,pe_start,vg_mda_size,vg_name
+
+# create backup and then restore $dev3
+vgcfgbackup -f $TESTDIR/bak-%s $vg
+pvcreate -ff -y --restorefile $TESTDIR/bak-$vg --uuid $pv3_uuid $dev3
+vgcfgrestore -f $TESTDIR/bak-$vg $vg
+
+# verify pe_start of $dev3
+check pv_field $dev3 pe_start $pv_align
/cvs/lvm2/LVM2/test/shell/mirror-names.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/mirror-names.sh
+++ -	2011-11-21 00:16:09.118536000 +0000
@@ -0,0 +1,156 @@
+#!/bin/sh
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2008 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="check namings of mirrored LV"
+
+. lib/test
+
+# ---------------------------------------------------------------------
+# Utilities
+
+lv_devices_() {
+  local d
+  local lv=$1
+  shift
+  local devices=$*
+
+  local devs=$(lvs -a -odevices --noheadings $lv | sed 's/([0-9]*)//g' |
+               sed 's/ //g' | sed 's/,/ /g')
+
+  for d in $devs; do
+    (echo $devices | grep $d >/dev/null)  || return 1
+    devices=$(echo $devices | sed "s/$d//")
+  done
+
+  [ "$(echo $devices | sed 's/ //g')" = "" ]
+}
+
+lv_mirror_log_() {
+  local lv=$1
+
+  echo $(lvs -a -omirror_log --noheadings $lv | sed 's/ //g')
+}
+
+lv_convert_lv_() {
+  local lv=$1
+
+  echo $(lvs -a -oconvert_lv --noheadings $lv | sed 's/ //g')
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+aux prepare_vg 5 80
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_() {
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+  :
+}
+
+check_and_cleanup_lvs_() {
+  lvs -a -o+devices $vg 
+  lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+}
+
+prepare_lvs_ 
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+# basic
+
+#COMM "init: lvcreate" 
+prepare_lvs_
+
+#COMM "mirror images are ${lv1}_mimage_x"
+lvcreate -l2 -m1 -n $lv1 $vg 
+lv_devices_ $vg/$lv1 "$lv1"_mimage_0 "$lv1"_mimage_1
+
+#COMM "mirror log is ${lv1}_mlog"
+lv_mirror_log_ $vg/$lv1 "$lv1"_mlog
+
+# "cleanup" 
+check_and_cleanup_lvs_
+
+#COMM "mirror with name longer than 22 characters (bz221322)"
+name="LVwithanamelogerthan22characters_butidontwonttocounthem"
+lvcreate -m1 -l2 -n"$name" $vg
+lvs $vg/"$name"
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+# lvrename
+
+#COMM "init: lvrename" 
+prepare_lvs_
+
+#COMM "renamed mirror names: $lv1 to $lv2" 
+lvcreate -l2 -m1 -n $lv1 $vg 
+lvrename $vg/$lv1 $vg/$lv2 
+lv_devices_ $vg/$lv2 "$lv2"_mimage_0 "$lv2"_mimage_1 
+lv_mirror_log_ $vg/$lv2 "$lv2"_mlog
+
+#COMM "cleanup" 
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+# lvconvert
+
+#COMM "init: lvconvert" 
+prepare_lvs_
+
+#COMM "converting mirror names is ${lv1}_mimagetmp_2"
+lvcreate -l2 -m1 -n $lv1 $vg 
+lvconvert -m+1 -i+40 -b $vg/$lv1
+convlv=$(lv_convert_lv_ "$vg/$lv1") 
+test "$convlv" = "$lv1"_mimagetmp_2 
+lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv1"_mlog
+
+#COMM "mirror log name after re-adding is ${lv1}_mlog" \
+lvconvert --mirrorlog core $vg/$lv1 
+lvconvert --mirrorlog disk $vg/$lv1 
+convlv=$(lv_convert_lv_ "$vg/$lv1") 
+lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv1"_mlog
+
+#COMM "renamed converting mirror names: $lv1 to $lv2" \
+lvrename $vg/$lv1 $vg/$lv2 
+convlv=$(lv_convert_lv_ "$vg/$lv2") 
+lv_devices_ $vg/$lv2 "$convlv" "$lv2"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv2"_mimage_0 "$lv2"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv2"_mlog
+
+#COMM "cleanup" 
+check_and_cleanup_lvs_
+
+# Temporary mirror log should have "_mlogtmp_<n>" suffix
+# but currently lvconvert doesn't have an option to add the log.
+# If such feature is added in future, a test for that should
+# be added.
+
+# ---------------------------------------------------------------------
/cvs/lvm2/LVM2/test/shell/mirror-vgreduce-removemissing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/mirror-vgreduce-removemissing.sh
+++ -	2011-11-21 00:16:09.215885000 +0000
@@ -0,0 +1,424 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
+
+. lib/test
+
+lv_is_on_ ()
+{
+	local lv=$vg/$1
+	shift
+	local pvs=$*
+
+	echo "Check if $lv is exactly on PVs $pvs"
+	rm -f out1 out2
+	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+
+	lvs -a -o+devices $lv
+	lvs -a -odevices --noheadings $lv > lvs_log
+	sed 's/([^)]*)//g; s/[ ,]/\n/g' lvs_log | sort | uniq > out2 || true
+
+	diff --ignore-blank-lines out1 out2
+}
+
+mimages_are_on_ ()
+{
+	local lv=$1
+	shift
+	local pvs="$*"
+	local mimages
+	local i
+
+	echo "Check if mirror images of $lv are on PVs $pvs"
+	rm -f out1 out2
+	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+	lvs --noheadings -a -o lv_name $vg > lvs_log
+	mimages=$(grep "${lv}_mimage_" lvs_log | \
+		sed 's/\[//g; s/\]//g' || true)
+	
+	for i in $mimages; do
+		echo "Checking $vg/$i"
+		lvs -a -o+devices $vg/$i
+		lvs -a -odevices --noheadings $vg/$i > lvs_log
+		sed 's/([^)]*)//g; s/ //g; s/,/ /g' lvs_log | sort | uniq >> out2 || true
+	done
+
+	diff --ignore-blank-lines out1 out2
+}
+
+mirrorlog_is_on_()
+{
+	local lv="$1"_mlog
+	shift
+	lv_is_on_ $lv $*
+}
+
+lv_is_linear_()
+{
+	echo "Check if $1 is linear LV (i.e. not a mirror)"
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep '^1-' >/dev/null
+}
+
+rest_pvs_()
+{
+	local index=$1
+	local num=$2
+	local rem=""
+	local n
+
+	for n in $(seq 1 $(($index - 1))) $(seq $(($index + 1)) $num); do
+		eval local dev=$\dev$n
+		rem="$rem $dev"
+	done
+
+	echo "$rem"
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+aux prepare_vg 5
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+	lvremove -ff $vg;
+	if dmsetup table|grep -v -- "-missing_"|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+	:
+}
+
+check_and_cleanup_lvs_()
+{
+	lvs -a -o+devices $vg 
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+}
+
+recover_vg_()
+{
+	aux enable_dev $* 
+	pvcreate -ff $* 
+	vgextend $vg $* 
+	check_and_cleanup_lvs_
+}
+
+#COMM "check environment setup/cleanup" 
+prepare_lvs_ 
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+# one of mirror images has failed
+
+#COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvchange -an $vg/$lv1
+mimages_are_on_ $lv1 $dev1 $dev2
+mirrorlog_is_on_ $lv1 $dev3
+aux disable_dev $dev2
+vgreduce --removemissing --force $vg
+lv_is_linear_ $lv1
+lv_is_on_ $lv1 $dev1
+
+# "cleanup"
+recover_vg_ $dev2
+
+# ---------------------------------------------------------------------
+# LV has 3 images in flat,
+# 1 out of 3 images fails
+
+#COMM test_3way_mirror_fail_1_ <PV# to fail>
+test_3way_mirror_fail_1_()
+{
+	local index=$1
+
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
+	lvchange -an $vg/$lv1
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
+	mirrorlog_is_on_ $lv1 $dev4
+	eval aux disable_dev \$dev$index
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
+	mirrorlog_is_on_ $lv1 $dev4
+}
+
+for n in $(seq 1 3); do
+	#COMM fail mirror image $(($n - 1)) of 3-way mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_fail_1_ $n
+	eval recover_vg_ \$dev$n
+done
+
+# ---------------------------------------------------------------------
+# LV has 3 images in flat,
+# 2 out of 3 images fail
+
+#COMM test_3way_mirror_fail_2_ <PV# NOT to fail>
+test_3way_mirror_fail_2_()
+{
+	local index=$1
+
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
+	lvchange -an $vg/$lv1
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
+	mirrorlog_is_on_ $lv1 $dev4
+	rest_pvs_ $index 3
+	aux disable_dev $(rest_pvs_ $index 3)
+	vgreduce --force --removemissing $vg
+	lvs -a -o+devices $vg
+	lv_is_linear_ $lv1
+	eval lv_is_on_ $lv1 \$dev$n
+}
+
+for n in $(seq 1 3); do
+	#COMM fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
+	prepare_lvs_
+	test_3way_mirror_fail_2_ $n
+	recover_vg_ $(rest_pvs_ $n 3)
+done
+
+# ---------------------------------------------------------------------
+# LV has 4 images, 1 of them is in the temporary mirror for syncing.
+# 1 out of 4 images fails
+
+#COMM test_3way_mirror_plus_1_fail_1_ <PV# to fail>
+test_3way_mirror_plus_1_fail_1_()
+{
+	local index=$1
+
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
+	lvchange -an $vg/$lv1 
+	lvconvert -m+1 $vg/$lv1 $dev4 
+	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4 
+	check mirror_log_on $vg $lv1 $dev5 
+	eval aux disable_dev \$dev$index 
+        lvs -a -o +devices
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices # $vg 
+	check mirror_images_on $vg $lv1 $dev5 # $(rest_pvs_ $index 4) 
+	check mirror_log_on $vg $lv1 $dev5
+}
+
+for n in $(seq 1 4); do
+	#COMM "fail mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_plus_1_fail_1_ $n
+	eval recover_vg_ \$dev$n
+done
+
+# ---------------------------------------------------------------------
+# LV has 4 images, 1 of them is in the temporary mirror for syncing.
+# 3 out of 4 images fail
+
+#COMM test_3way_mirror_plus_1_fail_3_ <PV# NOT to fail>
+test_3way_mirror_plus_1_fail_3_()
+{
+	local index=$1
+
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
+	lvchange -an $vg/$lv1
+	lvconvert -m+1 $vg/$lv1 $dev4
+	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4
+	check mirror_log_on $vg $lv1 $dev5
+	lvs -a -o+devices $vg
+	aux disable_dev $(rest_pvs_ $index 4)
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
+	eval local dev=\$dev$n
+	check linear $vg $lv1
+        check lv_on $vg $lv1 $dev
+}
+
+for n in $(seq 1 4); do
+	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_plus_1_fail_3_ $n
+	recover_vg_ $(rest_pvs_ $n 4)
+done
+
+# ---------------------------------------------------------------------
+# LV has 4 images, 2 of them are in the temporary mirror for syncing.
+# 1 out of 4 images fail
+
+# test_2way_mirror_plus_2_fail_1_ <PV# to fail>
+test_2way_mirror_plus_2_fail_1_()
+{
+	local index=$1
+
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+	lvchange -an $vg/$lv1 
+	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	eval aux disable_dev \$dev$n 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
+	mirrorlog_is_on_ $lv1 $dev5
+}
+
+for n in $(seq 1 4); do
+	#COMM "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV" 
+	prepare_lvs_ 
+	test_2way_mirror_plus_2_fail_1_ $n
+	eval recover_vg_ \$dev$n
+done
+
+# ---------------------------------------------------------------------
+# LV has 4 images, 2 of them are in the temporary mirror for syncing.
+# 3 out of 4 images fail
+
+# test_2way_mirror_plus_2_fail_3_ <PV# NOT to fail>
+test_2way_mirror_plus_2_fail_3_()
+{
+	local index=$1
+
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+	lvchange -an $vg/$lv1 
+	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	aux disable_dev $(rest_pvs_ $index 4) 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	eval local dev=\$dev$n
+	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
+	not mirrorlog_is_on_ $lv1 $dev5
+}
+
+for n in $(seq 1 4); do
+	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
+	prepare_lvs_
+	test_2way_mirror_plus_2_fail_3_ $n
+	recover_vg_ $(rest_pvs_ $n 4)
+done
+
+# ---------------------------------------------------------------------
+# log device is gone (flat mirror and stacked mirror)
+
+#COMM "fail mirror log of 2-way mirrored LV" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+aux disable_dev $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 
+not mirrorlog_is_on_ $lv1 $dev5
+recover_vg_ $dev5
+
+#COMM "fail mirror log of 3-way (1 converting) mirrored LV" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+lvconvert -m+1 $vg/$lv1 $dev3 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+mirrorlog_is_on_ $lv1 $dev5 
+aux disable_dev $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+not mirrorlog_is_on_ $lv1 $dev5
+recover_vg_ $dev5
+
+# ---------------------------------------------------------------------
+# all images are gone (flat mirror and stacked mirror)
+
+#COMM "fail all mirror images of 2-way mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+aux disable_dev $dev1 $dev2 
+vgreduce --removemissing --force $vg 
+not lvs $vg/$lv1
+recover_vg_ $dev1 $dev2
+
+#COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+lvconvert -m+1 $vg/$lv1 $dev3 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+mirrorlog_is_on_ $lv1 $dev5 
+aux disable_dev $dev1 $dev2 $dev3 
+vgreduce --removemissing --force $vg 
+not lvs $vg/$lv1
+recover_vg_ $dev1 $dev2 $dev3
+
+# ---------------------------------------------------------------------
+# Multiple LVs
+
+#COMM "fail a mirror image of one of mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
+lvchange -an $vg/$lv2 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv1 $dev5 
+mirrorlog_is_on_ $lv2 $dev5 
+aux disable_dev $dev2 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv2 $dev5 
+lv_is_linear_ $lv1 
+lv_is_on_ $lv1 $dev1
+recover_vg_ $dev2
+
+#COMM "fail mirror images, one for each mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
+lvchange -an $vg/$lv2 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv1 $dev5 
+mirrorlog_is_on_ $lv2 $dev5 
+aux disable_dev $dev2 
+aux disable_dev $dev4 
+vgreduce --removemissing --force $vg 
+lv_is_linear_ $lv1 
+lv_is_on_ $lv1 $dev1 
+lv_is_linear_ $lv2 
+lv_is_on_ $lv2 $dev3
+recover_vg_ $dev2 $dev4
+
+# ---------------------------------------------------------------------
+# no failure
+
+#COMM "no failures"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+
/cvs/lvm2/LVM2/test/shell/nomda-missing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/nomda-missing.sh
+++ -	2011-11-21 00:16:09.347259000 +0000
@@ -0,0 +1,83 @@
+#!/bin/bash
+
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 4
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3 $dev4
+vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
+
+lvcreate -l1 -n linear1 $vg $dev1
+lvcreate -l1 -n linear2 $vg $dev2
+lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+
+lvcreate -l1 -n origin1 $vg $dev1
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
+lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+
+vgchange -a n $vg
+aux disable_dev $dev1
+not vgchange -a y $vg
+not vgck $vg
+
+check inactive $vg linear1
+check active $vg linear2
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg linear12
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+aux enable_dev $dev1
+aux disable_dev $dev2
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg linear1
+check inactive $vg linear2
+check inactive $vg linear12
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+aux enable_dev $dev2
+aux disable_dev $dev3
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check inactive $vg mirror123
+check active $vg mirror12
+
+vgchange -a n $vg
+aux enable_dev $dev3
+aux disable_dev $dev4
+vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check active $vg mirror12
+check active $vg mirror123
/cvs/lvm2/LVM2/test/shell/pool-labels.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pool-labels.sh
+++ -	2011-11-21 00:16:09.472714000 +0000
@@ -0,0 +1,39 @@
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# create the old GFS pool labeled linear devices
+create_pool_label_()
+{
+  # FIXME
+  # echo -e is bashism, dash builtin sh doesn't do \xNN in printf either
+  # printf comes from coreutils, and is probably not posix either
+  env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
+  env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
+}
+
+env printf "" || exit 200 # skip if printf is not available
+
+aux prepare_devs 2
+
+create_pool_label_ 0 "$dev1"
+create_pool_label_ 1 "$dev2"
+
+# check that pvcreate fails without -ff on the pool device
+not pvcreate "$dev1"
+
+# check that vgdisplay and pvcreate -ff works with the pool device
+vgdisplay --config 'global { locking_type = 0 }'
+aux disable_dev "$dev2"
+# FIXME! since pool1 cannot be opened, vgdisplay gives error... should we say
+# "not" there instead, checking that it indeed does fail?
+vgdisplay --config 'global { locking_type = 0 }' || true
+pvcreate -ff -y "$dev1"
/cvs/lvm2/LVM2/test/shell/pv-duplicate.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pv-duplicate.sh
+++ -	2011-11-21 00:16:09.611140000 +0000
@@ -0,0 +1,25 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise duplicate metadata diagnostics'
+
+. lib/test
+
+aux prepare_devs 3
+
+vgcreate -c n --metadatasize 128k $vg1 $dev1
+
+# copy mda
+dd if=$dev1 of=$dev2 bs=256K count=1
+dd if=$dev1 of=$dev3 bs=256K count=1
+
+pvs $dev1
+vgs $vg1
/cvs/lvm2/LVM2/test/shell/pv-min-size.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pv-min-size.sh
+++ -	2011-11-21 00:16:09.725960000 +0000
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# use small default size  - 512KB
+aux lvmconf 'devices/pv_min_size = 512'
+
+aux prepare_pvs 1 8
+
+check pv_field $dev1 pv_name $dev1
+
+# increase min size beyond created PV size 10MB
+aux lvmconf 'devices/pv_min_size = 10240'
+
+# and test device is not visible
+not check pv_field $dev1 pv_name $dev1
+
+# set too low value errornous value
+aux lvmconf 'devices/pv_min_size = -100'
+
+# check the incorrect value is printed
+pvs $dev1 2>&1 | grep -- -100
/cvs/lvm2/LVM2/test/shell/pv-range-overflow.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pv-range-overflow.sh
+++ -	2011-11-21 00:16:09.858130000 +0000
@@ -0,0 +1,32 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
+
+. lib/test
+
+aux prepare_vg 2
+
+lvcreate -L4 -n"$lv" $vg
+
+# Test for the bogus diagnostic reported in BZ 284771
+# http://bugzilla.redhat.com/284771.
+# 'run pvmove with an unrecognized LV name to show bad diagnostic'
+not pvmove -v -nbogus $dev1 $dev2 2> err
+grep "  Logical volume bogus not found." err
+
+# With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
+# the PE range parsing code would accept values up to 2^64-1, but would
+# silently truncate them to int32_t.  I.e., $dev1:$(echo 2^32|bc) would be
+# treated just like $dev1:0.
+# 'run the offending pvmove command'
+not pvmove -v -n$lv $dev1:4294967296 $dev2
+
/cvs/lvm2/LVM2/test/shell/pvchange-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvchange-usage.sh
+++ -	2011-11-21 00:16:09.987955000 +0000
@@ -0,0 +1,66 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Test pvchange option values'
+
+. lib/test
+
+aux prepare_devs 4
+
+for mda in 0 1 2 
+do
+# "setup pv with metadatacopies = $mda" 
+	pvcreate $dev4 
+	pvcreate --metadatacopies $mda $dev1 
+	vgcreate $vg1 $dev1 $dev4 
+
+# "pvchange adds/dels tag to pvs with metadatacopies = $mda " 
+	pvchange $dev1 --addtag test$mda 
+	check pv_field $dev1 pv_tags test$mda 
+	pvchange $dev1 --deltag test$mda 
+	check pv_field $dev1 pv_tags ""
+
+# "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
+	pvchange $dev1 -x n 
+	check pv_field $dev1 pv_attr  ---
+	pvchange $dev1 -x y 
+	check pv_field $dev1 pv_attr  a--
+
+# 'remove pv'
+	vgremove $vg1 
+	pvremove $dev1 $dev4
+done
+
+# "pvchange uuid"
+pvcreate --metadatacopies 0 $dev1 
+pvcreate --metadatacopies 2 $dev2 
+vgcreate $vg1 $dev1 $dev2 
+pvchange -u $dev1 
+pvchange -u $dev2 
+check pvlv_counts $vg1 2 0 0
+pvchange -u --all
+check pvlv_counts $vg1 2 0 0
+
+# "pvchange rejects uuid change under an active lv" 
+lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 
+check pvlv_counts $vg1 2 1 0 
+not pvchange -u $dev1
+lvchange -an "$vg1"/"$lv" 
+pvchange -u $dev1
+
+# "cleanup" 
+lvremove -f "$vg1"/"$lv"
+vgremove $vg1
+
+# "pvchange reject --addtag to lvm1 pv"
+pvcreate -M1 $dev1 
+not pvchange $dev1 --addtag test
+
/cvs/lvm2/LVM2/test/shell/pvcreate-metadata0.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvcreate-metadata0.sh
+++ -	2011-11-21 00:16:10.110595000 +0000
@@ -0,0 +1,32 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Testcase for bugzilla #450651
+# also checks that vgremove properly removes all lv devices in the right order
+#
+# 'Test pvcreate without metadata on all pvs'
+
+. lib/test
+
+aux prepare_devs 2 128
+
+#lv_snap=$lv2
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+
+# "check lv snapshot" 
+vgcreate -c n "$vg" "$dev1" "$dev2" 
+lvcreate -n "$lv" -l 60%FREE "$vg" 
+lvcreate -s -n $lv2 -l 10%FREE "$vg"/"$lv" 
+pvdisplay 
+lvdisplay
+vgremove -f "$vg"
/cvs/lvm2/LVM2/test/shell/pvcreate-operation-md.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvcreate-operation-md.sh
+++ -	2011-11-21 00:16:10.281384000 +0000
@@ -0,0 +1,147 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# skip this test if mdadm or sfdisk (or others) aren't available
+which mdadm || exit 200
+which sfdisk || exit 200
+which perl || exit 200
+which awk || exit 200
+which cut || exit 200
+
+test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
+modprobe raid0 || exit 200
+
+. lib/test
+
+aux lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux prepare_devs 2
+
+# Have MD use a non-standard name to avoid colliding with an existing MD device
+# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
+# - newer mdadm _completely_ defers to udev to create the associated device node
+mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
+[ $mdadm_maj -ge 3 ] && \
+    mddev=/dev/md/md_lvm_test0 || \
+    mddev=/dev/md_lvm_test0
+
+cleanup_md() {
+    # sleeps offer hack to defeat: 'md: md127 still in use'
+    # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
+    aux udev_wait
+    mdadm --stop $mddev || true
+    aux udev_wait
+    if [ -b "$mddev" ]; then
+        # mdadm doesn't always cleanup the device node
+	sleep 2
+	rm -f $mddev
+    fi
+}
+
+cleanup_md_and_teardown() {
+    cleanup_md
+    aux teardown
+}
+
+# create 2 disk MD raid0 array (stripe_width=128K)
+test -b "$mddev" && exit 200
+mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
+trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
+test -b "$mddev" || exit 200
+
+# Test alignment of PV on MD without any MD-aware or topology-aware detection
+# - should treat $mddev just like any other block device
+pv_align="1.00m"
+pvcreate --metadatasize 128k \
+    --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check pv_field $mddev pe_start $pv_align
+
+# Test md_chunk_alignment independent of topology-aware detection
+pv_align="1.00m"
+pvcreate --metadatasize 128k \
+    --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check pv_field $mddev pe_start $pv_align
+
+
+# Test newer topology-aware alignment detection
+# - first added to 2.6.31 but not "reliable" until 2.6.33
+if kernel_at_least 2 6 33 ; then
+    pv_align="1.00m"
+    # optimal_io_size=131072, minimum_io_size=65536
+    pvcreate --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check pv_field $mddev pe_start $pv_align
+fi
+
+# partition MD array directly, depends on blkext in Linux >= 2.6.28
+if kernel_at_least 2 6 28 ; then
+    # create one partition
+    sfdisk $mddev <<EOF
+,,83
+EOF
+    # make sure partition on MD is _not_ removed
+    # - tests partition -> parent lookup via sysfs paths
+    not pvcreate --metadatasize 128k $mddev
+
+    # verify alignment_offset is accounted for in pe_start
+    # - topology infrastructure is available in Linux >= 2.6.31
+    # - also tests partition -> parent lookup via sysfs paths
+
+    # Oh joy: need to lookup /sys/block/md127 rather than /sys/block/md_lvm_test0
+    mddev_maj_min=$(ls -lL $mddev | awk '{ print $5 $6 }' | perl -pi -e 's|,|:|')
+    mddev_p_sysfs_name=$(echo /sys/dev/block/${mddev_maj_min}/*p1)
+    base_mddev_p=`basename $mddev_p_sysfs_name`
+    mddev_p=/dev/${base_mddev_p}
+
+    # in case the system is running without devtmpfs /dev
+    # wait here for created device node on tmpfs
+    aux udev_wait $mddev_p
+    test -b $mddev_p || exit 200
+
+    # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
+    # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
+    sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
+    [ -f $sysfs_alignment_offset ] && kernel_at_least 2 6 33 && \
+	alignment_offset=`cat $sysfs_alignment_offset` || \
+	alignment_offset=0
+
+    if [ $alignment_offset -gt 0 ]; then
+        # default alignment is 1M, add alignment_offset
+	pv_align=$((1048576+$alignment_offset))B
+	pvcreate --metadatasize 128k $mddev_p
+	check pv_field $mddev_p pe_start $pv_align "--units b"
+	pvremove $mddev_p
+    fi
+fi
+
+# Test newer topology-aware alignment detection w/ --dataalignment override
+if kernel_at_least 2 6 33 ; then
+    cleanup_md
+    pvcreate -f $dev1
+    pvcreate -f $dev2
+
+    # create 2 disk MD raid0 array (stripe_width=2M)
+    test -b "$mddev" && exit 200
+    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 $dev1 $dev2
+    test -b "$mddev" || exit 200
+
+    # optimal_io_size=2097152, minimum_io_size=1048576
+    pv_align="2.00m"
+    pvcreate --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check pv_field $mddev pe_start $pv_align
+
+    # now verify pe_start alignment override using --dataalignment
+    pv_align="192.00k"
+    pvcreate --dataalignment 64k --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check pv_field $mddev pe_start $pv_align
+fi
/cvs/lvm2/LVM2/test/shell/pvcreate-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvcreate-operation.sh
+++ -	2011-11-21 00:16:10.366281000 +0000
@@ -0,0 +1,121 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 4
+
+for mdatype in 1 2
+do
+# pvcreate (lvm$mdatype) refuses to overwrite an mounted filesystem (bz168330)
+	test ! -d $TESTDIR/mnt && mkdir $TESTDIR/mnt
+	if mke2fs $dev1; then
+		mount $dev1 $TESTDIR/mnt
+		not pvcreate -M$mdatype $dev1 2>err
+		grep "Can't open $dev1 exclusively.  Mounted filesystem?" err
+		umount $dev1
+	fi
+
+# pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)
+    pvcreate -M$mdatype $dev1
+    pvcreate -M$mdatype $dev1
+    pvremove -f $dev1
+
+# pvcreate (lvm$mdatype) fails when PV belongs to VG" \
+    pvcreate -M$mdatype $dev1
+    vgcreate -M$mdatype $vg1 $dev1
+    not pvcreate -M$mdatype $dev1
+
+    vgremove -f $vg1
+    pvremove -f $dev1
+
+# pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG
+    pvcreate -M$mdatype $dev1
+    pvcreate -M$mdatype $dev2
+    vgcreate -M$mdatype $vg1 $dev1
+
+# pvcreate a second time on $dev2 and $dev1
+    not pvcreate -M$mdatype $dev2 $dev1
+
+    vgremove -f $vg1
+    pvremove -f $dev2
+    pvremove -f $dev1
+
+# NOTE: Force pvcreate after test completion to ensure clean device
+#test_expect_success \
+#  "pvcreate (lvm$mdatype) fails on md component device" \
+#  'mdadm -C -l raid0 -n 2 /dev/md0 $dev1 $dev2 &&
+#   pvcreate -M$mdatype $dev1;
+#   status=$?; echo status=$status; test $status != 0 &&
+#   mdadm --stop /dev/md0 &&
+#   pvcreate -ff -y -M$mdatype $dev1 $dev2 &&
+#   pvremove -f $dev1 $dev2'
+done
+
+# pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG
+pvcreate --metadatacopies 0 $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate $vg1 $dev1 $dev2
+not pvcreate $dev1
+vgremove -f $vg1
+pvremove -f $dev2
+pvremove -f $dev1
+
+# pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG
+pvcreate --metadatacopies 0 $dev1 
+pvcreate --metadatacopies 1 $dev2
+vgcreate $vg1 $dev1 $dev2 
+pvcreate -ff -y $dev1 
+vgreduce --removemissing $vg1 
+vgremove -ff $vg1 
+pvremove -f $dev2 
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# pvcreate (lvm2) succeeds writing LVM label at sector $i
+    pvcreate --labelsector $i $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    pvremove -f $dev1
+done
+
+# pvcreate (lvm2) fails writing LVM label at sector 4
+not pvcreate --labelsector 4 $dev1
+
+backupfile=$PREFIX.mybackupfile
+uuid1=freddy-fred-fred-fred-fred-fred-freddy
+uuid2=freddy-fred-fred-fred-fred-fred-fredie
+bogusuuid=fred
+
+# pvcreate rejects uuid option with less than 32 characters
+not pvcreate --norestorefile --uuid $bogusuuid $dev1
+
+# pvcreate rejects uuid option without restorefile
+not pvcreate --uuid $uuid1 $dev1
+
+# pvcreate rejects uuid already in use
+pvcreate --norestorefile --uuid $uuid1 $dev1
+not pvcreate --norestorefile --uuid $uuid1 $dev2
+
+# pvcreate rejects non-existent file given with restorefile
+not pvcreate --uuid $uuid1 --restorefile $backupfile $dev1
+
+# pvcreate rejects restorefile with uuid not found in file
+pvcreate --norestorefile --uuid $uuid1 $dev1
+vgcfgbackup -f $backupfile
+not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
+
+# pvcreate wipes swap signature when forced
+dd if=/dev/zero of=$dev1 bs=1024 count=64
+mkswap $dev1
+blkid -c /dev/null $dev1 | grep "swap"
+pvcreate -f $dev1
+# blkid cannot make up its mind whether not finding anything it knows is a failure or not
+(blkid -c /dev/null $dev1 || true) | not grep "swap"
/cvs/lvm2/LVM2/test/shell/pvcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvcreate-usage.sh
+++ -	2011-11-21 00:16:10.443665000 +0000
@@ -0,0 +1,192 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test pvcreate option values'
+PAGESIZE=$(getconf PAGESIZE)
+
+. lib/test
+
+aux prepare_devs 4
+
+#COMM 'pvcreate rejects negative setphysicalvolumesize'
+not pvcreate --setphysicalvolumesize -1024 $dev1
+
+#COMM 'pvcreate rejects negative metadatasize'
+not pvcreate --metadatasize -1024 $dev1
+
+# x. metadatasize 0, defaults to 255
+# FIXME: unable to check default value, not in reporting cmds
+# should default to 255 according to code
+#   check pv_field pv_mda_size 255 
+#COMM 'pvcreate accepts metadatasize 0'
+pvcreate --metadatasize 0 $dev1
+pvremove $dev1
+
+#Verify vg_mda_size is smaller pv_mda_size
+pvcreate --metadatasize 512k $dev1
+pvcreate --metadatasize 96k $dev2
+vgcreate $vg $dev1 $dev2
+check compare_fields vgs $vg vg_mda_size pvs $dev2 pv_mda_size
+vgremove -ff $vg
+
+# x. metadatasize too large
+# For some reason we allow this, even though there's no room for data?
+##COMM  'pvcreate rejects metadatasize too large' 
+#not pvcreate --metadatasize 100000000000000 $dev1
+
+#COMM 'pvcreate rejects metadatacopies < 0'
+not pvcreate --metadatacopies -1 $dev1
+
+#COMM 'pvcreate accepts metadatacopies = 0, 1, 2'
+for j in metadatacopies pvmetadatacopies
+do
+pvcreate --$j 0 $dev1
+pvcreate --$j 1 $dev2
+pvcreate --$j 2 $dev3
+check pv_field $dev1 pv_mda_count 0
+check pv_field $dev2 pv_mda_count 1
+check pv_field $dev3 pv_mda_count 2
+pvremove $dev1 
+pvremove $dev2 
+pvremove $dev3
+done
+
+#COMM 'pvcreate rejects metadatacopies > 2'
+not pvcreate --metadatacopies 3 $dev1
+
+#COMM 'pvcreate rejects invalid device'
+not pvcreate $dev1bogus
+
+#COMM 'pvcreate rejects labelsector < 0'
+not pvcreate --labelsector -1 $dev1
+
+#COMM 'pvcreate rejects labelsector > 1000000000000'
+not pvcreate --labelsector 1000000000000 $dev1
+
+# other possibilites based on code inspection (not sure how hard)
+# x. device too small (min of 512 * 1024 KB)
+# x. device filtered out
+# x. unable to open /dev/urandom RDONLY
+# x. device too large (pe_count > UINT32_MAX)
+# x. device read-only
+# x. unable to open device readonly
+# x. BLKGETSIZE64 fails
+# x. set size to value inconsistent with device / PE size
+
+#COMM 'pvcreate basic dataalignment sanity checks'
+not pvcreate --dataalignment -1 $dev1
+not pvcreate -M 1 --dataalignment 1 $dev1
+not pvcreate --dataalignment 1e $dev1
+
+#COMM 'pvcreate always rounded up to page size for start of device'
+#pvcreate --metadatacopies 0 --dataalignment 1 $dev1
+# amuse shell experts
+#check pv_field $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00k"
+
+#COMM 'pvcreate sets data offset directly'
+pvcreate --dataalignment 512k $dev1
+check pv_field $dev1 pe_start 512.00k
+
+#COMM 'vgcreate/vgremove do not modify data offset of existing PV'
+vgcreate $vg $dev1  --config 'devices { data_alignment = 1024 }'
+check pv_field $dev1 pe_start 512.00k
+vgremove $vg --config 'devices { data_alignment = 1024 }'
+check pv_field $dev1 pe_start 512.00k
+
+#COMM 'pvcreate sets data offset next to mda area'
+pvcreate --metadatasize 100k --dataalignment 100k $dev1
+check pv_field $dev1 pe_start 200.00k
+
+# metadata area start is aligned according to pagesize
+if [ $PAGESIZE -eq 65536 ] ; then
+	pv_align="192.50k"
+elif [ $PAGESIZE -eq 8192 ] ; then
+	pv_align="136.50k"
+else
+	pv_align="133.00k"
+fi
+
+pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
+check pv_field $dev1 pe_start $pv_align
+
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
+check pv_field $dev1 pe_start $pv_align
+
+# data area is aligned to 1M by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="1052160B" # 1048576 + (7*512)
+pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
+check pv_field $dev1 pe_start $pv_align "--units b"
+
+# 2nd metadata area is created without problems when
+# data area start is shifted by the specified alignment_offset
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s $dev1
+check pv_field $dev1 pv_mda_count 2
+# FIXME: compare start of 2nd mda with and without --dataalignmentoffset
+
+#COMM 'pv with LVM1 compatible data alignment can be convereted'
+#compatible == LVM1_PE_ALIGN == 64k
+pvcreate --dataalignment 256k $dev1
+vgcreate -s 1m $vg $dev1
+vgconvert -M1 $vg
+vgconvert -M2 $vg
+check pv_field $dev1 pe_start 256.00k
+vgremove $vg
+
+#COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
+pvcreate --dataalignment 10k $dev1
+vgcreate -s 1m $vg $dev1
+not vgconvert -M1 $vg
+vgremove $vg
+
+#COMM 'vgcfgrestore allows pe_start=0'
+#basically it produces nonsense, but it tests vgcfgrestore,
+#not that final cfg is usable...
+pvcreate --metadatacopies 0 $dev1
+pvcreate $dev2
+vgcreate $vg $dev1 $dev2
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
+sed 's/pe_start = [0-9]*/pe_start = 0/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+vgcfgrestore -f "$(pwd)/backup.$$1" $vg
+check pv_field $dev1 pe_start 0
+check pv_field $dev2 pe_start 0
+vgremove $vg
+
+echo test pvcreate --metadataignore
+for pv_in_vg in 1 0; do
+for mdacp in 1 2; do
+for ignore in y n; do
+	echo pvcreate --metadataignore has proper mda_count and mda_used_count
+	pvcreate --metadatacopies $mdacp --metadataignore $ignore $dev1 $dev2
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_count $mdacp
+	if [ $ignore = y ]; then
+		check pv_field $dev1 pv_mda_used_count 0
+		check pv_field $dev2 pv_mda_used_count 0
+	else
+		check pv_field $dev1 pv_mda_used_count $mdacp
+		check pv_field $dev2 pv_mda_used_count $mdacp
+	fi
+	echo vgcreate has proper vg_mda_count and vg_mda_used_count
+	if [ $pv_in_vg = 1 ]; then
+		vgcreate -c n "$vg" $dev1 $dev2
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		if [ $ignore = y ]; then
+			check vg_field $vg vg_mda_used_count 1
+		else
+			check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+		fi
+		check vg_field $vg vg_mda_copies unmanaged
+		vgremove $vg
+	fi
+done
+done
+done
/cvs/lvm2/LVM2/test/shell/pvmove-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvmove-basic.sh
+++ -	2011-11-21 00:16:10.530213000 +0000
@@ -0,0 +1,378 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that pvmove works with basic options"
+
+. lib/test
+
+# ---------------------------------------------------------------------
+# Utilities
+
+lvdev_() {
+  echo "$DM_DEV_DIR/$1/$2"
+}
+
+lv_is_on_() {
+  local lv=$1 #allready vg/lv
+  shift 1
+  lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
+#is on all specified devs
+  for d in $*; do grep "$d(" out; done
+#isn't on any other dev (we are set -e remember)
+  for d in $*; do ! grep -v "$d(" out; done
+  return 0
+}
+
+save_dev_sum_() {
+  mkfs.ext3 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
+}
+
+check_dev_sum_() {
+  md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+aux prepare_vg 5 40
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+FIRST=""
+
+prepare_lvs_() {
+  lvcreate -l2 -n $lv1 $vg $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1
+  lvcreate -l9 -i3 -n $lv2 $vg $dev2 $dev3 $dev4 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4
+  lvextend -l+2 $vg/$lv1 $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2
+  lvextend -l+2 $vg/$lv1 $dev3 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3
+  lvextend -l+2 $vg/$lv1 $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1
+  lvcreate -l1 -n $lv3 $vg $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv3 $dev2
+  save_dev_sum_ $(lvdev_ $vg $lv1) 
+  save_dev_sum_ $(lvdev_ $vg $lv2) 
+  save_dev_sum_ $(lvdev_ $vg $lv3) 
+  if test -z "$FIRST" ; then
+    lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs
+    lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs
+    lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+  fi
+  FIRST=done
+}
+
+lv_not_changed_() {
+  lvs -a -o devices --noheadings $1 > out
+  diff $(basename $1)_devs out
+}
+
+check_and_cleanup_lvs_() {
+  lvs -a -o+devices $vg
+  check_dev_sum_ $(lvdev_ $vg $lv1)
+  check_dev_sum_ $(lvdev_ $vg $lv2)
+  check_dev_sum_ $(lvdev_ $vg $lv3)
+  lvs -a -o name $vg > out && ! grep ^pvmove out
+  lvremove -ff $vg
+	if ! dmsetup table|not grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
+			return 1
+	fi
+	:
+}
+
+#COMM "check environment setup/cleanup"
+prepare_lvs_
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+# pvmove tests
+
+# ---
+# filter by LV
+
+#COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# segments in a LV
+
+#COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev1 $dev4 
+lv_is_on_ $vg/$lv1 $dev4 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev2 $dev4 
+lv_is_on_ $vg/$lv1 $dev1 $dev4 $dev3 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev3 $dev4 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev4 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# multiple LVs matching
+
+#COMM "1 out of 3 LVs is moved: from pv4 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev4 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev5 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "2 out of 3 LVs are moved: from pv3 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 $dev1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "3 out of 3 LVs are moved: from pv2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_is_on_ $vg/$lv3 $dev5 
+check_and_cleanup_lvs_
+
+# ---
+# areas of striping
+
+#COMM "move the 1st stripe: from pv2 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev2 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev1 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev3 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev4 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev1 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# partial segment match (source segment splitted)
+
+#COMM "match to the start of segment:from pv2:0-0 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-0 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "match to the middle of segment: from pv2:1-1 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:1-1 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "match to the end of segment: from pv2:2-2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:2-2 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# destination segment splitted
+
+#COMM "no destination split: from pv2:0-2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-2 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev2:0-2 $dev5:5-5 $dev4:5-6 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev4 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev3 $dev4 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# alloc policy (anywhere, contiguous) with both success and failure cases
+
+#COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" 
+prepare_lvs_ 
+not pvmove -i1 $dev3:0-2 $dev3:5-7
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5 
+lv_not_changed_ $vg/$lv1 
+#lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
+prepare_lvs_ 
+not pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:5-5 $dev4:5-6
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
+prepare_lvs_ 
+pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:0-0 $dev5:3-5 $dev4:5-6 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# multiple segments in a LV
+
+#COMM "multiple source LVs: from pv3 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---
+# move inactive LV
+
+#COMM "move inactive LV: from pv2 to pv5"
+prepare_lvs_ 
+lvchange -an $vg/$lv1 
+lvchange -an $vg/$lv3 
+pvmove -i1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_is_on_ $vg/$lv3 $dev5 
+check_and_cleanup_lvs_
+
+# ---
+# other failure cases
+
+#COMM "no PEs to move: from pv3 to pv1"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev1 
+not pvmove -i1 $dev3 $dev1
+# "(cleanup previous test)"
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev1 
+lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "no space available: from pv2:0-0 to pv1:0-0" 
+prepare_lvs_ 
+not pvmove -i1 $dev2:0-0 $dev1:0-0
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM 'same source and destination: from pv1 to pv1'
+prepare_lvs_ 
+not pvmove -i1 $dev1 $dev1
+#"(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough"
+prepare_lvs_ 
+not pvmove --alloc anywhere $dev1:0-2 $dev1:0-2 $dev5:0-0 2> err
+#"(cleanup previous test)"
+grep "Insufficient free space" err 
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+# ---------------------------------------------------------------------
+
+#COMM "pvmove abort"
+prepare_lvs_ 
+pvmove -i100 -b $dev1 $dev3 
+pvmove --abort 
+check_and_cleanup_lvs_
+
+#COMM "pvmove out of --metadatacopies 0 PV (bz252150)"
+vgremove -ff $vg
+pvcreate $(cat DEVICES)
+pvcreate --metadatacopies 0 $dev1 $dev2
+vgcreate -c n $vg $(cat DEVICES)
+lvcreate -l4 -n $lv1 $vg $dev1
+pvmove $dev1
+
+#COMM "pvmove fails activating mirror, properly restores state before pvmove"
+dmsetup create "$vg-pvmove0" --notable
+not pvmove -i 1 $dev2
+test $(dmsetup info --noheadings -c -o suspended "$vg-$lv1") = "Active"
+dmsetup remove "$vg-pvmove0"
/cvs/lvm2/LVM2/test/shell/pvremove-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/pvremove-usage.sh
+++ -	2011-11-21 00:16:10.611510000 +0000
@@ -0,0 +1,68 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 3
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 2 $dev3
+pvremove $dev2
+
+# failing, but still removing everything what can be removed
+# is somewhat odd as default, what do we have -f for?
+pvs | not grep $dev2
+pvcreate  --metadatacopies 0 $dev2
+
+# check pvremove refuses to remove pv in a vg
+vgcreate -c n $vg $dev1 $dev2
+not pvremove $dev2 $dev3
+
+for mdacp in 0 1 2; do
+    # check pvremove truly wipes the label (pvscan wont find) (---metadatacopies $mdacp)
+    pvcreate --metadatacopies $mdacp $dev3
+    pvremove $dev3
+    # try to remove agail - should fail cleanly
+    not pvremove $dev3
+    pvscan | not grep $dev3
+
+	# bz179473 refuse to wipe non-PV device without -f
+    not pvremove $dev3
+    pvremove -f $dev3
+
+    # reset setup
+    vgremove -ff $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    pvcreate $dev2
+    vgcreate $vg $dev1 $dev2 
+
+    # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
+    not pvremove -f $dev1
+    pvs $dev1
+
+    # pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)
+    echo n | not pvremove -ff $dev1
+
+    # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
+    pvremove -ffy $dev1
+    not pvs $dev1
+
+    vgreduce --removemissing $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    vgextend $vg $dev1
+
+    # pvremove -ff -y is sufficient when pv in a vg (---metadatacopies $mdacp)" '
+    pvremove -ff -y $dev1
+
+    vgreduce --removemissing $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    vgextend $vg $dev1
+done
/cvs/lvm2/LVM2/test/shell/read-ahead.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/read-ahead.sh
+++ -	2011-11-21 00:16:10.694357000 +0000
@@ -0,0 +1,62 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests basic functionality of read-ahead and ra regressions
+#
+
+test_description='Test read-ahead functionality'
+
+. lib/test
+
+
+get_lvs_() {
+   lvs --units s --nosuffix --noheadings -o $1 "$vg"/"$lv"
+}
+
+check_lvs_() {
+   case $(get_lvs_ $1) in
+    *$2) true ;;
+    *) false ;;
+   esac
+}
+
+aux prepare_vg 5
+
+#COMM "test various read ahead settings (bz450922)"
+lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"
+ra="$(get_lvs_ lv_kernel_read_ahead)"
+test "$(( ( $ra / 5 ) * 5 ))" -eq $ra
+lvdisplay "$vg"/"$lv"
+not lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
+check_lvs_ lv_read_ahead auto
+check_lvs_ lv_kernel_read_ahead 5120
+lvchange -r 640 "$vg/$lv"
+check_lvs_ lv_read_ahead 640
+lvremove -ff "$vg"
+
+#COMM "read ahead is properly inherited from underlying PV"
+blockdev --setra 768 $dev1
+vgscan
+lvcreate -n $lv -L4m $vg $dev1
+test $(blockdev --getra $DM_DEV_DIR/$vg/$lv) -eq 768
+lvremove -ff $vg
+
+# Check default, active/inactive values for read_ahead / kernel_read_ahead
+lvcreate -n $lv -l 50%FREE $vg
+lvchange -an $vg/$lv
+check lv_field $vg/$lv lv_read_ahead auto
+check lv_field $vg/$lv lv_kernel_read_ahead -1
+lvchange -r 512 $vg/$lv
+lvchange -ay $vg/$lv
+check lv_field $vg/$lv lv_read_ahead 256.00k
+check lv_field $vg/$lv lv_kernel_read_ahead 256.00k
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/snapshot-autoumount-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/snapshot-autoumount-dmeventd.sh
+++ -	2011-11-21 00:16:10.772198000 +0000
@@ -0,0 +1,39 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# no automatic extensions please
+
+. lib/test
+
+which mkfs.ext2 || exit 200
+
+aux lvmconf "activation/snapshot_autoextend_percent = 0" \
+            "activation/snapshot_autoextend_threshold = 100"
+
+aux prepare_vg 2
+aux prepare_dmeventd
+
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+lvchange --monitor y $vg/snap
+
+mkdir mnt
+mount $DM_DEV_DIR/mapper/$vg-snap mnt
+mount
+cat /proc/mounts | grep $vg-snap
+
+dd if=/dev/zero of=mnt/file$1 bs=1M count=17
+sync
+sleep 10 # dmeventd only checks every 10 seconds :(
+
+cat /proc/mounts | not grep $vg-snap
/cvs/lvm2/LVM2/test/shell/snapshot-merge.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/snapshot-merge.sh
+++ -	2011-11-21 00:16:10.851279000 +0000
@@ -0,0 +1,133 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+set -xv
+
+which mkfs.ext3 || exit 200
+
+. lib/test
+
+lvdev_()
+{
+    echo "$DM_DEV_DIR/$1/$2"
+}
+
+snap_lv_name_() {
+    echo ${1}_snap
+}
+
+setup_merge() {
+    local VG_NAME=$1
+    local LV_NAME=$2
+    local NUM_EXTRA_SNAPS="$3"
+    test -z "$NUM_EXTRA_SNAPS" && NUM_EXTRA_SNAPS=0
+    local BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
+
+    lvcreate -n $LV_NAME -l 50%FREE $VG_NAME
+    lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
+    mkfs.ext3 $(lvdev_ $VG_NAME $LV_NAME)
+
+    if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
+	for i in `seq 1 $NUM_EXTRA_SNAPS`; do
+	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%FREE ${VG_NAME}/${LV_NAME}
+	done
+    fi
+}
+
+aux prepare_vg 1 100
+
+
+# test full merge of a single LV
+setup_merge $vg $lv1
+# now that snapshot LV is created: test if snapshot-merge target is available
+$(dmsetup targets | grep snapshot-merge >/dev/null) || exit 200
+lvs -a
+# make sure lvconvert --merge requires explicit LV listing
+not lvconvert --merge 2>err
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
+
+
+# test that an actively merging snapshot may not be removed
+setup_merge $vg $lv1
+lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
+not lvremove -f $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
+
+
+# "onactivate merge" test
+setup_merge $vg $lv1
+lvs -a
+mkdir test_mnt
+mount $(lvdev_ $vg $lv1) test_mnt
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
+lvchange --refresh $vg/$lv1
+umount test_mnt
+rm -r test_mnt
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin "
+
+# -- refresh LV to start merge (now that FS is unmounted),
+#    an active merge uses the 'snapshot-merge' target
+lvchange --refresh $vg/$lv1
+dmsetup table ${vg}-${lv1} | grep " snapshot-merge "
+# -- don't care if merge is still active; lvremove at this point
+#    may test stopping an active merge
+lvremove -f $vg/$lv1
+
+
+# "onactivate merge" test
+# -- deactivate/remove after disallowed merge attempt, tests
+#    to make sure preload of origin's metadata is _not_ performed
+setup_merge $vg $lv1
+lvs -a
+mkdir test_mnt
+mount $(lvdev_ $vg $lv1) test_mnt
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
+lvchange --refresh $vg/$lv1
+umount test_mnt
+rm -r test_mnt
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin " >/dev/null
+lvremove -f $vg/$lv1
+
+
+# test multiple snapshot merge; tests copy out that is driven by merge
+setup_merge $vg $lv1 1
+lvs -a
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
+
+
+# test merging multiple snapshots that share the same tag
+setup_merge $vg $lv1
+setup_merge $vg $lv2
+lvs -a
+lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
+lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
+lvconvert --merge @this_is_a_test
+lvs | not grep $(snap_lv_name_ $lv1)
+lvs | not grep $(snap_lv_name_ $lv2)
+lvremove -f $vg/$lv1
+lvremove -f $vg/$lv2
+
+# FIXME following tests would need to poll merge progress, via periodic lvs?
+# Background processes don't lend themselves to lvm testsuite...
+
+# test: onactivate merge of a single lv
+
+# test: do onactivate, deactivate the origin LV, reactivate the LV, merge should resume
+
+# test: multiple onactivate merge
+
+
+vgremove -f "$vg"
/cvs/lvm2/LVM2/test/shell/snapshots-of-mirrors.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/snapshots-of-mirrors.sh
+++ -	2011-11-21 00:16:10.938705000 +0000
@@ -0,0 +1,44 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 4
+
+# Create snapshot of a mirror origin
+lvcreate -m 1 -L 10M -n lv $vg
+lvcreate -s $vg/lv -L 10M -n snap
+
+# Down-convert (mirror -> linear) under a snapshot
+lvconvert -m0 $vg/lv
+
+# Up-convert (linear -> mirror)
+lvconvert -m2 $vg/lv
+
+# Down-convert (mirror -> mirror)
+lvconvert -m1 $vg/lv
+
+# Up-convert (mirror -> mirror) -- Not supported!
+not lvconvert -m2 $vg/lv
+
+# Log conversion (disk -> core)
+lvconvert --mirrorlog core $vg/lv
+
+# Log conversion (core -> mirrored)
+lvconvert --mirrorlog mirrored $vg/lv
+
+# Log conversion (mirrored -> core)
+lvconvert --mirrorlog core $vg/lv
+
+# Log conversion (core -> disk)
+lvconvert --mirrorlog disk $vg/lv
+
+# Clean-up
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/shell/tags.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/tags.sh
+++ -	2011-11-21 00:16:11.017367000 +0000
@@ -0,0 +1,74 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_pvs 5
+
+# vgcreate with --addtag
+vgcreate -c n --addtag firstvg $vg1 $dev1 $dev2
+vgcreate -c n --addtag secondvg $vg2 $dev3 $dev4
+check vg_field $vg1 tags firstvg
+check vg_field $vg2 tags secondvg
+vgremove -ff $vg1
+vgremove -ff $vg2
+
+# vgchange with --addtag and --deltag
+vgcreate -c n $vg1 $dev1 $dev2
+vgcreate -c n $vg2 $dev3 $dev4
+vgchange --addtag firstvgtag1 $vg1
+# adding a tag multiple times is not an error
+vgchange --addtag firstvgtag2 $vg1
+vgchange --addtag firstvgtag2 $vg1
+vgchange --addtag firstvgtag3 $vg1
+vgchange --addtag secondvgtag1 $vg2
+vgchange --addtag secondvgtag2 $vg2
+vgchange --addtag secondvgtag3 $vg2
+check vg_field @firstvgtag2 tags "firstvgtag1,firstvgtag2,firstvgtag3"
+check vg_field @secondvgtag1 tags "secondvgtag1,secondvgtag2,secondvgtag3"
+vgchange --deltag firstvgtag2 $vg1
+check vg_field @firstvgtag1 tags "firstvgtag1,firstvgtag3"
+# deleting a tag multiple times is not an error
+vgchange --deltag firstvgtag2 $vg1
+vgchange --deltag firstvgtag1 $vg2
+vgremove -ff $vg1
+vgremove -ff $vg2
+
+# lvcreate with --addtag
+vgcreate -c n $vg1 $dev1 $dev2
+lvcreate --addtag firstlvtag1 -l 4 -n $lv1 $vg1
+lvcreate --addtag secondlvtag1 -l 4 -n $lv2 $vg1
+check lv_field @firstlvtag1 tags "firstlvtag1"
+not check lv_field @secondlvtag1 tags "firstlvtag1"
+check lv_field $vg1/$lv2 tags "secondlvtag1"
+not check lv_field $vg1/$lv1 tags "secondlvtag1"
+vgremove -ff $vg1
+
+# lvchange with --addtag and --deltag
+vgcreate -c n $vg1 $dev1 $dev2
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv2 $vg1
+lvchange --addtag firstlvtag1 $vg1/$lv1
+# adding a tag multiple times is not an error
+lvchange --addtag firstlvtag2 $vg1/$lv1
+lvchange --addtag firstlvtag2 $vg1/$lv1
+lvchange --addtag firstlvtag3 $vg1/$lv1
+lvchange --addtag secondlvtag1 $vg1/$lv2
+lvchange --addtag secondlvtag2 $vg1/$lv2
+lvchange --addtag secondlvtag3 $vg1/$lv2
+check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag2,firstlvtag3"
+not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
+check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
+not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
+# deleting a tag multiple times is not an error
+lvchange --deltag firstlvtag2 $vg1/$lv1
+lvchange --deltag firstlvtag2 $vg1/$lv1
+check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag3"
+check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
/cvs/lvm2/LVM2/test/shell/test-partition.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/test-partition.sh
+++ -	2011-11-21 00:16:11.219382000 +0000
@@ -0,0 +1,30 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Testcase for bugzilla #621173 
+# excercises partition table scanning code path
+#
+
+which sfdisk || exit 200
+
+LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
+
+. lib/test
+
+aux prepare_pvs 1 30
+
+pvs
+
+# create small partition table
+echo "1 2" | sfdisk $dev1
+
+pvs
/cvs/lvm2/LVM2/test/shell/topology-support.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/topology-support.sh
+++ -	2011-11-21 00:16:12.420361000 +0000
@@ -0,0 +1,106 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+which mkfs.ext3 || exit 200
+
+. lib/test
+
+check_logical_block_size()
+{
+    local DEV_=$(cat SCSI_DEBUG_DEV)
+    # Verify logical_block_size - requires Linux >= 2.6.31
+    SYSFS_LOGICAL_BLOCK_SIZE=`echo /sys/block/$(basename $DEV_)/queue/logical_block_size`
+    if [ -f "$SYSFS_LOGICAL_BLOCK_SIZE" ] ; then
+	ACTUAL_LOGICAL_BLOCK_SIZE=`cat $SYSFS_LOGICAL_BLOCK_SIZE`
+	test $ACTUAL_LOGICAL_BLOCK_SIZE = $1
+    fi
+}
+
+lvdev_()
+{
+    echo "$DM_DEV_DIR/$1/$2"
+}
+
+test_snapshot_mount()
+{
+    lvcreate -L 16M -n $lv1 $vg $dev1
+    mkfs.ext3 $(lvdev_ $vg $lv1)
+    mkdir test_mnt
+    mount $(lvdev_ $vg $lv1) test_mnt
+    lvcreate -L 16M -n $lv2 -s $vg/$lv1
+    umount test_mnt
+    # mount the origin
+    mount $(lvdev_ $vg $lv1) test_mnt
+    umount test_mnt
+    # mount the snapshot
+    mount $(lvdev_ $vg $lv2) test_mnt
+    umount test_mnt
+    rm -r test_mnt
+    vgchange -an $vg
+    lvremove -f $vg/$lv2
+    lvremove -f $vg/$lv1
+}
+
+# FIXME add more topology-specific tests and validation (striped LVs, etc)
+
+NUM_DEVS=1
+PER_DEV_SIZE=34
+DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
+
+# Test that kernel supports topology
+aux prepare_scsi_debug_dev $DEV_SIZE
+if [ ! -e /sys/block/$(basename $(cat SCSI_DEBUG_DEV))/alignment_offset ] ; then
+	aux cleanup_scsi_debug_dev
+	exit 200
+fi
+aux cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "desktop-class" 4K drive
+# (logical_block_size=512, physical_block_size=4096, alignment_offset=0):
+LOGICAL_BLOCK_SIZE=512
+aux prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
+check_logical_block_size $LOGICAL_BLOCK_SIZE
+
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $(cat DEVICES)
+test_snapshot_mount
+vgremove $vg
+
+aux cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "desktop-class" 4K drive w/ 63-sector DOS partition compensation
+# (logical_block_size=512, physical_block_size=4096, alignment_offset=3584):
+LOGICAL_BLOCK_SIZE=512
+aux prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
+check_logical_block_size $LOGICAL_BLOCK_SIZE
+
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $(cat DEVICES)
+test_snapshot_mount
+vgremove $vg
+
+aux cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "enterprise-class" 4K drive
+# (logical_block_size=4096, physical_block_size=4096, alignment_offset=0):
+LOGICAL_BLOCK_SIZE=4096
+aux prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE
+check_logical_block_size $LOGICAL_BLOCK_SIZE
+
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $(cat DEVICES)
+test_snapshot_mount
+vgremove $vg
/cvs/lvm2/LVM2/test/shell/unknown-segment.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/unknown-segment.sh
+++ -	2011-11-21 00:16:12.498802000 +0000
@@ -0,0 +1,34 @@
+#!/bin/sh
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 4
+
+lvcreate -l 1 -n $lv1 $vg
+lvcreate -l 2 -m 1 -n $lv2 $vg
+
+vgcfgbackup -f bak0 $vg
+sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
+vgcfgrestore -f bak0 $vg
+
+# we have on-disk metadata with unknown segments now
+not lvchange -a y $vg/$lv1 # check that activation is refused
+
+vgcfgbackup -f bak1 $vg
+cat bak1
+sed -e 's,unstriped,striped,;s,unmirror,mirror,' -i.orig bak1
+vgcfgrestore -f bak1 $vg
+vgcfgbackup -f bak2 $vg
+
+egrep -v 'description|seqno|creation_time|Generated' < bak0.orig > a
+egrep -v 'description|seqno|creation_time|Generated' < bak2 > b
+diff -u a b
/cvs/lvm2/LVM2/test/shell/unlost-pv.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/unlost-pv.sh
+++ -	2011-11-21 00:16:13.197233000 +0000
@@ -0,0 +1,38 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+
+check() {
+vgscan 2>&1 | tee vgscan.out
+grep "Inconsistent metadata found for VG $vg" vgscan.out
+vgscan 2>&1 | tee vgscan.out
+not grep "Inconsistent metadata found for VG $vg" vgscan.out
+}
+
+# try orphaning a missing PV (bz45867)
+aux disable_dev $dev1
+vgreduce --removemissing --force $vg
+aux enable_dev $dev1
+check
+
+# try to just change metadata; we expect the new version (with MISSING_PV set
+# on the reappeared volume) to be written out to the previously missing PV
+vgextend $vg $dev1
+aux disable_dev $dev1
+lvremove $vg/mirror
+aux enable_dev $dev1
+check
/cvs/lvm2/LVM2/test/shell/vgcfgbackup-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgcfgbackup-usage.sh
+++ -	2011-11-21 00:16:13.318565000 +0000
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_pvs 4
+
+# vgcfgbackup handles similar VG names (bz458941)
+vg1=${PREFIX}vg00
+vg2=${PREFIX}vg01
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcfgbackup -f $TESTDIR/bak-%s >out
+grep "Volume group \"$vg1\" successfully backed up." out
+grep "Volume group \"$vg2\" successfully backed up." out
+vgremove -ff $vg1
+vgremove -ff $vg2
+
+# vgcfgbackup correctly stores metadata with missing PVs
+# and vgcfgrestore able to restore them when device reappears
+pv1_uuid=$(pvs --noheadings -o pv_uuid $dev1)
+pv2_uuid=$(pvs --noheadings -o pv_uuid $dev2)
+vgcreate $vg $(cat DEVICES)
+lvcreate -l1 -n $lv1 $vg $dev1
+lvcreate -l1 -n $lv2 $vg $dev2
+lvcreate -l1 -n $lv3 $vg $dev3
+vgchange -a n $vg
+pvcreate -ff -y $dev1
+pvcreate -ff -y $dev2
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
+sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+pvcreate -ff -y --norestorefile -u $pv1_uuid $dev1
+pvcreate -ff -y --norestorefile -u $pv2_uuid $dev2
+vgcfgrestore -f "$(pwd)/backup.$$1" $vg
+vgremove -ff $vg
+
+# vgcfgbackup correctly stores metadata LVM1 with missing PVs
+# FIXME: clvmd seems to have problem with metadata format change here
+# fix it and remove this vgscan
+vgscan
+pvcreate -M1 $(cat DEVICES)
+vgcreate -M1 -c n $vg $(cat DEVICES)
+lvcreate -l1 -n $lv1 $vg $dev1
+pvremove -ff -y $dev2
+not lvcreate -l1 -n $lv1 $vg $dev3
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
/cvs/lvm2/LVM2/test/shell/vgchange-maxlv.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgchange-maxlv.sh
+++ -	2011-11-21 00:16:14.203465000 +0000
@@ -0,0 +1,31 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_dmeventd
+aux prepare_pvs 3
+
+vgcreate -c n -l 2 $vg $dev1 $dev2 $dev3
+lvcreate -n one -l 1 $vg
+lvcreate -n two -l 1 $vg
+not lvcreate -n three -l 1 $vg
+vgchange -an $vg
+vgremove -ff $vg
+
+vgcreate -c n -l 3 $vg $dev1 $dev2 $dev3
+lvcreate -n one -l 1 $vg
+lvcreate -n snap -s -l 1 $vg/one
+lvcreate -n two -l 1 $vg
+not lvcreate -n three -l 1 $vg
+vgchange --monitor y $vg
+vgchange -an $vg 2>&1 | tee vgchange.out
+not grep "event server" vgchange.out
/cvs/lvm2/LVM2/test/shell/vgchange-sysinit.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgchange-sysinit.sh
+++ -	2011-11-21 00:16:14.284128000 +0000
@@ -0,0 +1,51 @@
+#!/bin/bash
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+which mkfs.ext3 || exit 200
+
+aux prepare_pvs 2 8
+test -e LOCAL_CLVMD && exit 200
+
+var_lock="$DM_DEV_DIR/$vg1/$lv1"
+# keep in sync with aux configured lockingdir
+mount_dir="$TESTDIR/var/lock/lvm"
+
+cleanup_mounted_and_teardown()
+{
+	umount $mount_dir || true
+	aux teardown
+}
+
+vgcreate -c n $vg1 $dev1
+vgcreate -c n $vg2 $dev2
+
+lvcreate -l 1 -n $lv2 $vg2
+vgchange -an $vg2
+
+lvcreate -n $lv1 -l 100%FREE $vg1
+mkfs.ext3 -b4096 -j $var_lock
+
+trap 'cleanup_mounted_and_teardown' EXIT
+mount -n -r $var_lock $mount_dir
+
+# locking must fail on read-only filesystem
+not vgchange -ay $vg2
+
+# no-locking with --sysinit
+vgchange --sysinit -ay $vg2
+test -b "$DM_DEV_DIR/$vg2/$lv2"
+
+vgchange --sysinit -an $vg2
+test ! -b "$DM_DEV_DIR/$vg2/$lv2"
+
+vgchange --ignorelockingfailure -ay $vg2
/cvs/lvm2/LVM2/test/shell/vgchange-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgchange-usage.sh
+++ -	2011-11-21 00:16:14.392312000 +0000
@@ -0,0 +1,44 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgchange diagnostics'
+
+. lib/test
+
+aux prepare_pvs 3
+pvcreate --metadatacopies 0 $dev1
+vgcreate $vg $(cat DEVICES)
+
+vgdisplay $vg
+
+# vgchange -p MaxPhysicalVolumes (bz202232)
+aux check vg_field $vg max_pv 0
+vgchange -p 128 $vg
+aux check vg_field $vg max_pv 128
+
+pv_count=$(get vg_field $vg pv_count)
+not vgchange -p 2 $vg 2>err
+grep "MaxPhysicalVolumes is less than the current number $pv_count of PVs for" err
+aux check vg_field $vg max_pv 128
+
+# vgchange -l MaxLogicalVolumes
+aux check vg_field $vg max_lv 0
+vgchange -l 128 $vg
+aux check vg_field $vg max_lv 128
+
+lvcreate -l4 -n$lv1 $vg
+lvcreate -l4 -n$lv2 $vg
+
+lv_count=$(get vg_field $vg lv_count)
+not vgchange -l 1 $vg 2>err
+grep "MaxLogicalVolume is less than the current number $lv_count of LVs for"  err
+aux check vg_field $vg max_lv 128
+
/cvs/lvm2/LVM2/test/shell/vgcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgcreate-usage.sh
+++ -	2011-11-21 00:16:14.495900000 +0000
@@ -0,0 +1,163 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgcreate diagnostics'
+
+. lib/test
+
+aux prepare_devs 3
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3
+
+vg=${PREFIX}vg
+
+#COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
+vgcreate -c n $vg --physicalextentsize 8.00m $dev1 $dev2
+check vg_field  $vg vg_extent_size 8.00m
+vgremove $vg
+# try vgck and to remove it again - should fail (but not segfault)
+not vgremove $vg
+not vgck $vg
+
+#COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
+vgcreate -c n $vg --maxlogicalvolumes 128 $dev1 $dev2 
+check vg_field $vg max_lv 128 
+vgremove $vg
+
+#COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
+vgcreate -c n $vg --maxphysicalvolumes 128 $dev1 $dev2
+check vg_field $vg max_pv 128
+vgremove $vg
+
+#COMM 'vgcreate rejects a zero physical extent size'
+not vgcreate -c n --physicalextentsize 0 $vg $dev1 $dev2 2>err
+grep "^  Physical extent size may not be zero\$" err
+
+#COMM 'vgcreate rejects "inherit" allocation policy'
+not vgcreate -c n --alloc inherit $vg $dev1 $dev2 2>err
+grep "^  Volume Group allocation policy cannot inherit from anything\$" err
+
+#COMM 'vgcreate rejects vgname "."'
+vginvalid=.; 
+not vgcreate -c n $vginvalid $dev1 $dev2 2>err
+grep "New volume group name \"$vginvalid\" is invalid\$" err
+
+#COMM 'vgcreate rejects vgname greater than 128 characters'
+vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
+not vgcreate -c n $vginvalid $dev1 $dev2 2>err
+grep "New volume group name \"$vginvalid\" is invalid\$" err
+
+#COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
+#touch /tmp/$vg
+#not vgcreate $vg $dev1 $dev2 2>err
+#grep "New volume group name \"$vg\" is invalid\$" err
+
+#COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
+vgcreate -c n $vg $dev1 $dev2
+not vgcreate -c n $vg $dev1 $dev2
+vgremove -ff $vg
+
+#COMM 'vgcreate rejects MaxLogicalVolumes > 255'
+not vgcreate -c n --metadatatype 1 --maxlogicalvolumes 1024 $vg $dev1 $dev2 2>err
+grep "^  Number of volumes may not exceed 255\$" err
+
+#COMM "vgcreate fails when the only pv has --metadatacopies 0"
+not vgcreate -c n $vg $dev3
+
+# Test default (4MB) vg_extent_size as well as limits of extent_size
+not vgcreate -c n --physicalextentsize 0k $vg $dev1 $dev2
+vgcreate -c n --physicalextentsize 1k $vg $dev1 $dev2
+check vg_field $vg vg_extent_size 1.00k
+vgremove -ff $vg
+not vgcreate -c n --physicalextentsize 3K $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 1024t $vg $dev1 $dev2
+#not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
+# FIXME: vgcreate allows physicalextentsize larger than pv size!
+
+# Test default max_lv, max_pv, extent_size, alloc_policy, clustered
+vgcreate -c n $vg $dev1 $dev2
+check vg_field $vg vg_extent_size 4.00m
+check vg_field $vg max_lv 0
+check vg_field $vg max_pv 0
+check vg_field $vg vg_attr "wz--n-"
+vgremove -ff $vg
+
+# Implicit pvcreate tests, test pvcreate options on vgcreate
+# --force, --yes, --metadata{size|copies|type}, --zero
+# --dataalignment[offset]
+pvremove $dev1 $dev2
+vgcreate -c n --force --yes --zero y $vg $dev1 $dev2
+vgremove -f $vg
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# vgcreate (lvm2) succeeds writing LVM label at sector $i
+    vgcreate -c n --labelsector $i $vg $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+
+# pvmetadatacopies
+for i in 1 2
+do
+    vgcreate -c n --pvmetadatacopies $i $vg $dev1
+    check pv_field $dev1 pv_mda_count $i
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+not vgcreate -c n --pvmetadatacopies 0 $vg $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
+check pv_field $dev1 pv_mda_count 0
+check pv_field $dev2 pv_mda_count 1
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatasize, dataalignment, dataalignmentoffset
+#COMM 'pvcreate sets data offset next to mda area'
+vgcreate -c n --metadatasize 100k --dataalignment 100k $vg $dev1
+check pv_field $dev1 pe_start 200.00k
+vgremove -f $vg
+pvremove -f $dev1
+
+# data area is aligned to 1M by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="1052160B" # 1048576 + (7*512)
+vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+check pv_field $dev1 pe_start $pv_align "--units b"
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatatype
+for i in 1 2
+do
+    vgcreate -c n -M $i $vg $dev1
+    check vg_field $vg vg_fmt lvm$i
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+
+# vgcreate fails if pv belongs to existing vg
+vgcreate -c n $vg1 $dev1 $dev2
+not vgcreate $vg2 $dev2
+vgremove -f $vg1
+pvremove -f $dev1 $dev2
+
+# all PVs exist in the VG after created
+pvcreate $dev1
+vgcreate -c n $vg1 $dev1 $dev2 $dev3
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
+check pv_field $dev3 vg_name $vg1
+vgremove -f $vg1
+pvremove -f $dev1 $dev2 $dev3
/cvs/lvm2/LVM2/test/shell/vgextend-restoremissing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgextend-restoremissing.sh
+++ -	2011-11-21 00:16:14.578585000 +0000
@@ -0,0 +1,30 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+
+aux prepare_vg 3
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+lvcreate -l 1 -n lv1 $vg $dev1
+
+# try to just change metadata; we expect the new version (with MISSING_PV set
+# on the reappeared volume) to be written out to the previously missing PV
+aux disable_dev $dev1
+lvremove $vg/mirror
+aux enable_dev $dev1
+not vgck $vg 2>&1 | tee log
+grep "missing 1 physical volume" log
+not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
+vgextend --restore $vg $dev1 # restore the missing device
+vgck $vg
+lvcreate -m 1 -l 1 -n mirror $vg
/cvs/lvm2/LVM2/test/shell/vgextend-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgextend-usage.sh
+++ -	2011-11-21 00:16:15.219408000 +0000
@@ -0,0 +1,129 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Exercise various vgextend commands
+#
+
+. lib/test
+
+aux prepare_devs 5
+
+for mdatype in 1 2
+do
+
+# Explicit pvcreate
+pvcreate -M$mdatype $dev1 $dev2 $dev3 $dev4 $dev5
+vgcreate -M$mdatype $vg1 $dev1 $dev2
+vgextend $vg1 $dev3 $dev4 $dev5
+vgremove -ff $vg1
+
+# Implicit pvcreate
+pvremove $dev1 $dev2 $dev3 $dev4 $dev5
+vgcreate -M$mdatype $vg1 $dev1 $dev2
+vgextend -M$mdatype $vg1 $dev3 $dev4 $dev5
+vgremove -ff $vg1
+pvremove $dev1 $dev2 $dev3 $dev4 $dev5
+
+done
+
+# Implicit pvcreate tests, test pvcreate options on vgcreate
+# --force, --yes, --metadata{size|copies|type}, --zero
+# --dataalignment[offset]
+vgcreate $vg $dev2
+vgextend --force --yes --zero y $vg $dev1
+vgreduce $vg $dev1
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# vgcreate (lvm2) succeeds writing LVM label at sector $i
+    vgextend --labelsector $i $vg $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    vgreduce $vg $dev1
+    pvremove -f $dev1
+done
+
+# pvmetadatacopies
+for i in 0 1 2
+do
+    vgextend --pvmetadatacopies $i $vg $dev1
+    check pv_field $dev1 pv_mda_count $i
+    vgreduce $vg $dev1
+    pvremove -f $dev1
+done
+
+# metadatasize, dataalignment, dataalignmentoffset
+#COMM 'pvcreate sets data offset next to mda area'
+vgextend --metadatasize 100k --dataalignment 100k $vg $dev1
+check pv_field $dev1 pe_start 200.00k
+vgreduce $vg $dev1
+pvremove -f $dev1
+
+# data area is aligned to 1M by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="1052160B" # 1048576 + (7*512)
+vgextend --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+check pv_field $dev1 pe_start $pv_align "--units b"
+vgremove -f $vg
+pvremove -f $dev1
+
+# vgextend fails if pv belongs to existing vg
+vgcreate $vg1 $dev1 $dev3
+vgcreate $vg2 $dev2
+not vgextend $vg2 $dev3
+vgremove -f $vg1
+vgremove -f $vg2
+pvremove -f $dev1 $dev2 $dev3
+
+#vgextend fails if vg is not resizeable
+vgcreate $vg1 $dev1 $dev2
+vgchange --resizeable n $vg1
+not vgextend $vg1 $dev3
+vgremove -f $vg1
+pvremove -f $dev1 $dev2
+
+# all PVs exist in the VG after extended
+pvcreate $dev1
+vgcreate $vg1 $dev2
+vgextend $vg1 $dev1 $dev3
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
+check pv_field $dev3 vg_name $vg1
+vgremove -f $vg1
+pvremove -f $dev1 $dev2 $dev3
+
+echo test vgextend --metadataignore
+for mdacp in 1 2; do
+for ignore in y n; do
+	echo vgextend --metadataignore has proper mda_count and mda_used_count
+	vgcreate $vg $dev3
+	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg $dev1 $dev2
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_count $mdacp
+	if [ $ignore = y ]; then
+		check pv_field $dev1 pv_mda_used_count 0
+		check pv_field $dev2 pv_mda_used_count 0
+	else
+		check pv_field $dev1 pv_mda_used_count $mdacp
+		check pv_field $dev2 pv_mda_used_count $mdacp
+	fi
+	echo vg has proper vg_mda_count and vg_mda_used_count
+	check vg_field $vg vg_mda_count $(($mdacp * 2 + 1))
+	if [ $ignore = y ]; then
+		check vg_field $vg vg_mda_used_count 1
+	else
+		check vg_field $vg vg_mda_used_count $(($mdacp * 2 + 1))
+	fi
+	check vg_field $vg vg_mda_copies unmanaged
+	vgremove $vg
+	pvremove -ff $dev1 $dev2 $dev3
+done
+done
/cvs/lvm2/LVM2/test/shell/vgimportclone.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgimportclone.sh
+++ -	2011-11-21 00:16:15.314794000 +0000
@@ -0,0 +1,30 @@
+# Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 2
+
+vgcreate -c n --metadatasize 128k $vg1 $dev1
+lvcreate -l100%FREE -n $lv1 $vg1
+
+# Clone the LUN
+dd if=$dev1 of=$dev2 bs=256K count=1
+
+# Verify pvs works on each device to give us vgname
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
+
+# Import the cloned PV to a new VG
+vgimportclone --basevgname $vg2 $dev2
+
+# Verify we can activate / deactivate the LV from both VGs
+lvchange -ay $vg1/$lv1 $vg2/$lv1
+vgchange -an $vg1 $vg2
/cvs/lvm2/LVM2/test/shell/vgmerge-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgmerge-operation.sh
+++ -	2011-11-21 00:16:15.429581000 +0000
@@ -0,0 +1,81 @@
+#!/bin/sh
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test vgmerge operation'
+
+. lib/test
+
+aux prepare_pvs 4 64
+
+# 'vgmerge succeeds with single linear LV in source VG'
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 $dev1 
+vgchange -an $vg1 
+check pvlv_counts $vg1 2 1 0 
+check pvlv_counts $vg2 2 0 0 
+vgmerge $vg2 $vg1 
+check pvlv_counts $vg2 4 1 0 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with single linear LV in source and destination VG'
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg2 
+vgchange -an $vg1 
+vgchange -an $vg2 
+check pvlv_counts $vg1 2 1 0 
+check pvlv_counts $vg2 2 1 0 
+vgmerge $vg2 $vg1 
+check pvlv_counts $vg2 4 2 0 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with linear LV + snapshots in source VG'
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 $vg1 
+lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
+vgchange -an $vg1 
+check pvlv_counts $vg1 2 2 1 
+check pvlv_counts $vg2 2 0 0 
+vgmerge $vg2 $vg1 
+check pvlv_counts $vg2 4 2 1 
+lvremove -f $vg2/$lv2 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with mirrored LV in source VG'
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+vgcreate -c n $vg2 $dev4 
+lvcreate -l 4 -n $lv1 -m1 $vg1 
+vgchange -an $vg1 
+check pvlv_counts $vg1 3 1 0 
+check pvlv_counts $vg2 1 0 0 
+vgmerge $vg2 $vg1 
+check pvlv_counts $vg2 4 1 0 
+lvremove -f $vg2/$lv1 
+vgremove -f $vg2
+
+# 'vgmerge rejects LV name collision'
+vgcreate -c n $vg1 $dev1 $dev2
+vgcreate -c n $vg2 $dev3 $dev4
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv1 $vg2
+vgchange -an $vg1
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 1 0
+not vgmerge $vg2 $vg1 2>err
+grep "Duplicate logical volume name \"$lv1\" in \"$vg2\" and \"$vg1" err
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 1 0
+vgremove -f $vg1
+vgremove -f $vg2
+
/cvs/lvm2/LVM2/test/shell/vgmerge-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgmerge-usage.sh
+++ -	2011-11-21 00:16:15.550844000 +0000
@@ -0,0 +1,67 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Test vgmerge command options for validity'
+
+. lib/test
+
+aux prepare_pvs 4
+
+# 'vgmerge normal operation'
+# ensure ordering does not matter
+vgcreate  $vg1 $dev1 $dev2 
+vgcreate  $vg2 $dev3 $dev4 
+vgmerge $vg1 $vg2 
+vgremove $vg1
+vgcreate -c n $vg2 $dev1 $dev2
+vgcreate -c n $vg1 $dev3 $dev4
+vgmerge $vg2 $vg1
+vgremove $vg2
+
+# 'vgmerge rejects duplicate vg name'
+vgcreate  $vg1 $dev1 $dev2 
+vgcreate  $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg1 2>err
+grep "^  Duplicate volume group name \"$vg1\"\$" err 
+vgremove $vg1 $vg2
+
+# 'vgmerge rejects vgs with incompatible extent_size'
+vgcreate  --physicalextentsize 4M $vg1 $dev1 $dev2 
+vgcreate  --physicalextentsize 8M $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Extent sizes differ" err 
+vgremove $vg1 $vg2
+
+# 'vgmerge rejects vgmerge because max_pv is exceeded'
+vgcreate  --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate  --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Maximum number of physical volumes (2) exceeded" err 
+vgremove $vg1 $vg2
+
+# 'vgmerge rejects vg with active lv'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+lvcreate -l 4 -n lv1 $vg2 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Logical volumes in \"$vg2\" must be inactive\$" err 
+vgremove -f $vg1 $vg2
+
+# 'vgmerge rejects vgmerge because max_lv is exceeded' 
+vgcreate --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+lvcreate -l 4 -n lv1 $vg1 
+lvcreate -l 4 -n lv2 $vg1 
+lvcreate -l 4 -n lv3 $vg2 
+vgchange -an $vg1 $vg2
+not vgmerge $vg1 $vg2 2>err
+grep "^  Maximum number of logical volumes (2) exceeded" err 
+vgremove -f $vg1 $vg2
/cvs/lvm2/LVM2/test/shell/vgreduce-removemissing-snapshot.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgreduce-removemissing-snapshot.sh
+++ -	2011-11-21 00:16:15.647312000 +0000
@@ -0,0 +1,26 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+lvcreate -s $vg/4way -L 2M -n snap
+lvcreate -i 2 -L 2M $vg $dev1 $dev2 -n stripe
+
+aux disable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way
+aux enable_dev $dev2 $dev4
+#not vgreduce --removemissing $vg
+vgreduce -v --removemissing --force $vg # $dev2 $dev4
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices
+check mirror $vg 4way $dev5
+
/cvs/lvm2/LVM2/test/shell/vgreduce-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgreduce-usage.sh
+++ -	2011-11-21 00:16:15.764576000 +0000
@@ -0,0 +1,87 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 4
+
+for mdatype in 1 2
+do
+    # setup PVs
+    pvcreate -M$mdatype $dev1 $dev2 
+
+    # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
+    vgreduce $vg1 $dev1
+    check pv_field $dev2 vg_name $vg1
+    vgremove -f $vg1
+
+    # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
+    not vgreduce --all $vg1
+    vgremove -f $vg1
+
+    # (lvm$mdatype) vgreduce rejects removing the last pv
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
+    not vgreduce $vg1 $dev1 $dev2
+    vgremove -f $vg1
+
+    pvremove -ff $dev1 $dev2
+done
+
+mdatype=2 # we only expect the following to work for lvm2 metadata
+
+# (lvm$mdatype) setup PVs (--metadatacopies 0)
+pvcreate -M$mdatype $dev1 $dev2
+pvcreate --metadatacopies 0 -M$mdatype $dev3 $dev4
+
+# (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
+vgcreate -c n -M$mdatype $vg1 $dev1 $dev3
+not vgreduce $vg1 $dev1
+vgremove -f $vg1
+
+#COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
+# (lvm$mdatype) setup: create mirror & damage one pv
+vgcreate -c n -M$mdatype $vg1 $dev1 $dev2 $dev3
+lvcreate -n $lv1 -m1 -l 4 $vg1
+lvcreate -n $lv2  -l 4 $vg1 $dev2
+lvcreate -n $lv3 -l 4 $vg1 $dev3
+vgchange -an $vg1
+aux disable_dev $dev1
+# (lvm$mdatype) vgreduce --removemissing --force repares to linear
+vgreduce --removemissing --force $vg1
+check lv_field $vg1/$lv1 segtype linear
+check pvlv_counts $vg1 2 3 0
+# cleanup
+aux enable_dev $dev1
+pvscan
+vgremove -ff $vg1
+not vgs $vg1 # just double-check it's really gone
+
+#COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
+# (lvm$mdatype) setup: create mirror + linear lvs
+vgcreate -c n -M$mdatype $vg1 $(cat DEVICES)
+lvcreate -n $lv2 -l 4 $vg1
+lvcreate -m1 -n $lv1 -l 4 $vg1 $dev1 $dev2 $dev3
+lvcreate -n $lv3 -l 4 $vg1 $dev3
+pvs --segments -o +lv_name # for record only
+# (lvm$mdatype) setup: damage one pv
+vgchange -an $vg1 
+aux disable_dev $dev1
+#pvcreate -ff -y $dev1
+# vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too
+not vgreduce -c n --removemissing --mirrorsonly --force $vg1
+
+aux enable_dev $dev1
+
+pvs -P # for record
+lvs -P # for record
+vgs -P # for record
/cvs/lvm2/LVM2/test/shell/vgrename-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgrename-usage.sh
+++ -	2011-11-21 00:16:15.876665000 +0000
@@ -0,0 +1,41 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_devs 4
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3 $dev4
+
+# vgrename normal operation - rename vg1 to vg2
+# vgrename normal operation - rename vg2 to vg1
+# ensure name ordering does not matter
+vgcreate $vg1 $dev1 $dev2
+vgrename $vg1 $vg2
+check vg_field $vg2 vg_name $vg2
+vgrename $vg2 $vg1
+check vg_field $vg1 vg_name $vg1
+vgremove $vg1
+
+# vgrename by uuid (bz231187)
+vgcreate $vg1 $dev1 $dev3
+UUID=$(vgs --noheading -o vg_uuid $vg1)
+check vg_field $vg1 vg_uuid $UUID
+vgrename $UUID $vg2
+check vg_field $vg2 vg_name $vg2
+vgremove $vg2
+
+# vgrename fails - new vg already exists
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+not vgrename $vg1 $vg2
+vgremove $vg1
+vgremove $vg2
+
/cvs/lvm2/LVM2/test/shell/vgsplit-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgsplit-operation.sh
+++ -	2011-11-21 00:16:15.966533000 +0000
@@ -0,0 +1,315 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test vgsplit operation, including different LV types
+
+. lib/test
+
+COMM() {  
+	LAST_TEST="$@"
+}
+
+aux prepare_pvs 5 258
+# FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
+# fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
+# metadata
+
+#
+# vgsplit can be done into a new or existing VG
+#
+for i in new existing
+do
+	#
+	# We can have PVs or LVs on the cmdline
+	#
+	for j in PV LV
+	do
+COMM "vgsplit correctly splits single linear LV into $i VG ($j args)"
+		vgcreate $vg1 $dev1 $dev2 
+		if [ $i = existing ]; then
+		   vgcreate $vg2 $dev3 $dev4
+		fi 
+		lvcreate -l 4 -n $lv1 $vg1 $dev1 
+		vgchange -an $vg1 
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi 
+		check pvlv_counts $vg1 1 0 0 
+		if [ $i = existing ]; then
+		   check pvlv_counts $vg2 3 1 0
+		else
+		   check pvlv_counts $vg2 1 1 0
+		fi 
+		lvremove -f $vg2/$lv1 
+		vgremove -f $vg2 
+		vgremove -f $vg1
+
+COMM "vgsplit correctly splits single striped LV into $i VG ($j args)"
+		vgcreate $vg1 $dev1 $dev2 
+		if [ $i = existing ]; then
+		   vgcreate $vg2 $dev3 $dev4
+		fi 
+		lvcreate -l 4 -i 2 -n $lv1 $vg1 $dev1 $dev2 
+		vgchange -an $vg1 
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1 $dev2
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi 
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 4 1 0
+		else
+		  check pvlv_counts $vg2 2 1 0
+		fi 
+		lvremove -f $vg2/$lv1 
+		vgremove -f $vg2
+
+COMM "vgsplit correctly splits mirror LV into $i VG ($j args)" 
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev4
+		fi 
+		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
+		vgchange -an $vg1 
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi 
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 4 1 0
+		else
+		  check pvlv_counts $vg2 3 1 0
+		fi 
+		lvremove -f $vg2/$lv1 
+		vgremove -f $vg2
+# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
+
+COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev5
+		fi
+
+		lvcreate -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
+		    $dev1 $dev2 $dev3 $dev4
+
+		vgchange -an $vg1
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3 $dev4
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 5 1 0
+		else
+		  check pvlv_counts $vg2 4 1 0
+		fi
+		lvremove -f $vg2/$lv1
+		vgremove -f $vg2
+# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
+
+COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
+		vgcreate -c n $vg1 $dev1 $dev2 
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev3 $dev4
+		fi 
+		lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
+		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
+		vgchange -an $vg1 
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1 $dev2
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi 
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 4 2 1
+		else
+		  check pvlv_counts $vg2 2 2 1
+		fi 
+		lvremove -f $vg2/$lv2 
+		lvremove -f $vg2/$lv1 
+		vgremove -f $vg2
+
+COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" 
+		vgcreate -c n $vg1 $dev1 $dev2 
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev3
+		fi 
+		lvcreate -l 64 -i 2 -n $lv1 $vg1 
+		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
+		vgextend $vg1 $dev4 
+		lvcreate -l 64 -n $lv3 $vg1 $dev4 
+		vgchange -an $vg1 
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev4
+		else
+		  vgsplit -n $lv3 $vg1 $vg2
+		fi 
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 2 1 0
+		  check pvlv_counts $vg1 2 2 1
+		else
+		  check pvlv_counts $vg2 1 1 0
+		  check pvlv_counts $vg1 2 2 1
+		fi 
+		lvremove -f $vg1/$lv2 
+		lvremove -f $vg1/$lv1 
+		lvremove -f $vg2/$lv3 
+		vgremove -f $vg1 
+		vgremove -f $vg2
+
+COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" 
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev5
+		fi 
+		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
+		vgextend $vg1 $dev4 
+		lvcreate -l 64 -n $lv2 $vg1 $dev4 
+		vgchange -an $vg1 
+		vgs
+		lvs 
+		pvs
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev4
+		else
+		  vgsplit -n $lv2 $vg1 $vg2
+		fi 
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg1 3 1 0
+		  check pvlv_counts $vg2 2 1 0
+		else
+		vgs
+		lvs 
+		pvs
+		  check pvlv_counts $vg1 3 1 0
+		  check pvlv_counts $vg2 1 1 0
+		fi 
+		lvremove -f $vg1/$lv1 
+		lvremove -f $vg2/$lv2 
+		vgremove -f $vg1 
+		vgremove -f $vg2
+
+	done
+done
+
+#
+# Test more complex setups where the code has to find associated PVs and
+# LVs to split the VG correctly
+# 
+COMM "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified" 
+vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 -i 2 $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv2 -i 2 $vg1 $dev2 $dev3 
+lvcreate -l 4 -n $lv3 -i 2 $vg1 $dev3 $dev4 
+vgchange -an $vg1 
+not vgsplit -n $lv1 $vg1 $vg2
+vgremove -ff $vg1
+
+COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
+check pvlv_counts $vg1 4 3 2 
+vgchange -an $vg1 
+not vgsplit -n $lv1 $vg1 $vg2;
+lvremove -f $vg1/$lv2 
+lvremove -f $vg1/$lv3 
+lvremove -f $vg1/$lv1 
+vgremove -ff $vg1
+
+COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
+check pvlv_counts $vg1 4 3 2 
+vgchange -an $vg1 
+not vgsplit -n $lv2 $vg1 $vg2
+lvremove -f $vg1/$lv2 
+lvremove -f $vg1/$lv3 
+lvremove -f $vg1/$lv1 
+vgremove -ff $vg1
+
+COMM "vgsplit fails splitting one mirror LV, only one PV specified" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
+check pvlv_counts $vg1 4 1 0 
+vgchange -an $vg1 
+not vgsplit $vg1 $vg2 $dev2 
+vgremove -ff $vg1
+
+COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
+lvcreate -l 16 -n $lv2 -i 2 $vg1 $dev3 $dev4 
+check pvlv_counts $vg1 4 2 0 
+vgchange -an $vg1 
+not vgsplit -n $lv2 $vg1 $vg2 2>err
+vgremove -ff $vg1
+
+#
+# Verify vgsplit rejects active LVs only when active LVs involved in split
+#
+COMM "vgsplit fails, active mirror involved in split" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
+lvcreate -l 16 -n $lv2 $vg1 $dev4 
+lvchange -an $vg1/$lv2 
+check pvlv_counts $vg1 4 2 0 
+not vgsplit -n $lv1 $vg1 $vg2;
+check pvlv_counts $vg1 4 2 0 
+vgremove -ff $vg1
+
+COMM "vgsplit succeeds, active mirror not involved in split" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
+lvcreate -l 16 -n $lv2 $vg1 $dev4 
+lvchange -an $vg1/$lv2 
+check pvlv_counts $vg1 4 2 0 
+vgsplit -n $lv2 $vg1 $vg2 
+check pvlv_counts $vg1 3 1 0 
+check pvlv_counts $vg2 1 1 0 
+vgremove -ff $vg1 
+vgremove -ff $vg2
+
+COMM "vgsplit fails, active snapshot involved in split" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
+lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
+lvcreate -l 64 -i 2 -n $lv3 $vg1 $dev3 $dev4 
+lvchange -an $vg1/$lv3 
+check pvlv_counts $vg1 4 3 1 
+not vgsplit -n $lv2 $vg1 $vg2;
+check pvlv_counts $vg1 4 3 1 
+lvremove -f $vg1/$lv2 
+vgremove -ff $vg1
+
+COMM "vgsplit succeeds, active snapshot not involved in split" 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
+lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
+vgextend $vg1 $dev4 
+lvcreate -l 64 -n $lv3 $vg1 $dev4 
+lvchange -an $vg1/$lv3 
+check pvlv_counts $vg1 4 3 1 
+vgsplit -n $lv3 $vg1 $vg2 
+check pvlv_counts $vg1 3 2 1 
+check pvlv_counts $vg2 1 1 0 
+vgchange -an $vg1 
+lvremove -f $vg1/$lv2 
+vgremove -ff $vg1 
+vgremove -ff $vg2
+
/cvs/lvm2/LVM2/test/shell/vgsplit-stacked.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgsplit-stacked.sh
+++ -	2011-11-21 00:16:16.072781000 +0000
@@ -0,0 +1,29 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux lvmconf 'devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+cat $TESTDIR/etc/lvm.conf
+aux prepare_devs 3
+
+pvcreate $(cat DEVICES)
+vgcreate $vg1 $dev1 $dev2
+lvcreate -n $lv1 -l 100%FREE $vg1
+
+#top VG
+pvcreate $DM_DEV_DIR/$vg1/$lv1
+vgcreate $vg $DM_DEV_DIR/$vg1/$lv1 $dev3
+
+vgchange -a n $vg
+vgchange -a n $vg1
+
+# this should fail but not segfault, RHBZ 481793.
+not vgsplit $vg $vg1 $dev3
/cvs/lvm2/LVM2/test/shell/vgsplit-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/vgsplit-usage.sh
+++ -	2011-11-21 00:16:16.163848000 +0000
@@ -0,0 +1,168 @@
+#!/bin/sh
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test vgsplit command options for validity
+
+. lib/test
+
+aux prepare_devs 5
+
+for mdatype in 1 2
+do
+
+pvcreate -M$mdatype $(cat DEVICES)
+
+# ensure name order does not matter
+# NOTE: if we're using lvm1, we must use -M on vgsplit
+vgcreate -M$mdatype $vg1 $(cat DEVICES)
+vgsplit -M$mdatype $vg1 $vg2 $dev1
+vgremove $vg1 $vg2
+
+vgcreate -M$mdatype $vg2 $(cat DEVICES)
+vgsplit -M$mdatype $vg2 $vg1 $dev1
+vgremove $vg1 $vg2
+
+# vgsplit accepts new vg as destination of split
+# lvm1 -- bz244792
+vgcreate -M$mdatype $vg1 $(cat DEVICES)
+vgsplit $vg1 $vg2 $dev1 1>err
+grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgremove $vg1 $vg2
+
+# vgsplit accepts existing vg as destination of split
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+vgsplit $vg1 $vg2 $dev1 1>err
+grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgremove $vg1 $vg2
+
+# vgsplit accepts --maxphysicalvolumes 128 on new VG
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $dev1 
+check vg_field $vg2 max_pv 128 
+vgremove $vg1 $vg2
+
+# vgsplit accepts --maxlogicalvolumes 128 on new VG
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $dev1 
+check vg_field $vg2 max_lv 128 
+vgremove $vg1 $vg2
+
+# vgsplit rejects split because max_pv of destination would be exceeded
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Maximum number of physical volumes (2) exceeded" err
+vgremove $vg1 $vg2
+
+# vgsplit rejects split because maxphysicalvolumes given with existing vg
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+not vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $dev1 2>err;
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg1 $vg2
+
+# vgsplit rejects split because maxlogicalvolumes given with existing vg
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+not vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $dev1 2>err
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg1 $vg2
+
+# vgsplit rejects split because alloc given with existing vg
+vgcreate -M$mdatype --alloc cling $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --alloc cling $vg2 $dev3 $dev4 
+not vgsplit --alloc cling $vg1 $vg2 $dev1 2>err;
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg1 $vg2
+
+# vgsplit rejects split because clustered given with existing vg
+vgcreate -M$mdatype --clustered n $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --clustered n $vg2 $dev3 $dev4 
+not vgsplit --clustered n $vg1 $vg2 $dev1 2>err
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg1 $vg2
+
+# vgsplit rejects vg with active lv
+pvcreate -M$mdatype -ff $dev3 $dev4 
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Logical volumes in \"$vg1\" must be inactive\$" err 
+vgremove -f $vg1 $vg2
+
+# vgsplit rejects split because max_lv is exceeded
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg1 
+lvcreate -l 4 -n $lv3 $vg2 
+vgchange -an $vg1 $vg2
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Maximum number of logical volumes (2) exceeded" err 
+vgremove -f $vg1 $vg2
+
+# vgsplit verify default - max_lv attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+check compare_vg_field $vg1 $vg2 max_lv 
+vgremove -f $vg1 $vg2
+
+# vgsplit verify default - max_pv attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+check compare_vg_field $vg1 $vg2 max_pv 
+vgremove -f $vg1 $vg2
+
+# vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+check compare_vg_field $vg1 $vg2 vg_fmt 
+vgremove -f $vg2 $vg1
+
+# vgsplit rejects split because PV not in VG
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg1 
+vgchange -an $vg1 
+not vgsplit $vg1 $vg2 $dev3 2>err;
+vgremove -f $vg2 $vg1
+done
+
+# ONLY LVM2 metadata
+# setup PVs" '
+pvcreate --metadatacopies 0 $dev5
+
+# vgsplit rejects to give away pv with the last mda copy
+vgcreate $vg1 $dev5 $dev2  
+lvcreate -l 10 -n $lv1  $vg1 
+lvchange -an $vg1/$lv1 
+check pvlv_counts $vg1 2 1 0 
+not vgsplit  $vg1 $vg2 $dev5;
+check pvlv_counts $vg1 2 1 0 
+vgremove -ff $vg1
+
+# vgsplit rejects split because metadata types differ
+pvcreate -ff -M1 $dev3 $dev4 
+pvcreate -ff $dev1 $dev2 
+vgcreate -M1 $vg1 $dev3 $dev4 
+vgcreate $vg2 $dev1 $dev2 
+not vgsplit $vg1 $vg2 $dev3 2>err;
+grep "^  Metadata types differ" err 
+vgremove $vg1 $vg2


