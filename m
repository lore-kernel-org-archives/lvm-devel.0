From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 11 Sep 2018 08:27:39 -0400
Subject: master - Merge branch 'master' of git://sourceware.org/git/lvm2
Message-ID: <201809111227.w8BCRdYi002402@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0ff078e77e9f1018d14e824ae16b5d861a7f818
Commit:        d0ff078e77e9f1018d14e824ae16b5d861a7f818
Parent:        3255e384dbd567a4d6ddec8dc3eaac2d16476d3c 07d2794a1640f05a451657a2176ccea5308d3298
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Sep 11 13:19:08 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Sep 11 13:19:08 2018 +0100

Merge branch 'master' of git://sourceware.org/git/lvm2


 WHATS_NEW                                          |    2 +
 lib/metadata/raid_manip.c                          |   28 ++--
 test/Makefile.in                                   |    3 -
 test/lib/aux.sh                                    |   83 --------
 test/lib/flavour-ndev-lvmetad-lvmpolld.sh          |    3 -
 test/lib/flavour-ndev-lvmetad.sh                   |    2 -
 test/lib/flavour-udev-lvmetad-lvmpolld.sh          |    4 -
 test/lib/flavour-udev-lvmetad.sh                   |    3 -
 test/lib/flavour-udev-lvmlockd-test-lvmetad.sh     |    9 -
 test/lib/inittest.sh                               |   18 +--
 test/shell/dmsetup-integrity-keys.sh               |    2 -
 test/shell/dmsetup-keyring.sh                      |    2 -
 test/shell/inconsistent-metadata.sh                |   55 +++---
 test/shell/lvconvert-mirror-basic.sh               |    3 -
 test/shell/lvconvert-mirror.sh                     |    3 -
 test/shell/lvconvert-raid-status-validation.sh     |    2 -
 .../lvconvert-raid-takeover-linear_to_raid4.sh     |   71 +++++++
 .../lvconvert-raid-takeover-raid4_to_linear.sh     |   82 ++++++++
 test/shell/lvconvert-raid-takeover.sh              |   16 ++-
 test/shell/lvconvert-raid.sh                       |    2 -
 test/shell/lvcreate-repair.sh                      |    1 -
 test/shell/mirror-vgreduce-removemissing.sh        |    3 -
 test/shell/name-mangling.sh                        |    2 -
 test/shell/pool-labels.sh                          |    4 -
 test/shell/process-each-lv.sh                      |    3 -
 test/shell/pv-duplicate-uuid.sh                    |    8 +-
 test/shell/pv-ext-update.sh                        |    3 -
 test/shell/pvmove-basic.sh                         |    3 -
 test/shell/pvmove-restart.sh                       |    2 -
 test/shell/pvmove-resume-1.sh                      |    2 -
 test/shell/pvmove-resume-2.sh                      |    2 -
 test/shell/pvmove-resume-multiseg.sh               |    3 -
 test/shell/relative-sign-options.sh                |    4 -
 test/shell/report-fields.sh                        |    2 -
 test/shell/report-hidden.sh                        |    2 -
 test/shell/snapshot-remove-dmsetup.sh              |    2 -
 test/shell/system_id.sh                            |  197 --------------------
 test/shell/test-partition.sh                       |    1 -
 test/shell/thin-dmeventd-warns.sh                  |    2 -
 test/shell/vgchange-many.sh                        |    2 -
 test/shell/vgck.sh                                 |    7 +-
 test/shell/vgcreate-many-pvs.sh                    |    2 -
 test/shell/vgimportclone.sh                        |   12 --
 test/shell/vgremove-corrupt-vg.sh                  |    1 -
 test/shell/vgsplit-operation.sh                    |    3 -
 test/unit/Makefile                                 |    2 +-
 test/unit/unit-test.sh                             |    2 -
 47 files changed, 213 insertions(+), 457 deletions(-)


