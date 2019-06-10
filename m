From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 10 Jun 2019 11:07:20 -0400
Subject: master - Merge remote-tracking branch 'origin/master'
Message-ID: <201906101507.x5AF7K7S013584@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c020b4d4afff51272252f58e5251f79c26f6603
Commit:        4c020b4d4afff51272252f58e5251f79c26f6603
Parent:        dbc5543cbb1010265d8febeb1489e2c0ab8c456a d7c1168c6ac66fec30ef21c0a59d00d0259ab126
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Jun 10 17:05:04 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Jun 10 17:05:04 2019 +0200

Merge remote-tracking branch 'origin/master'

* origin/master: (22 commits)
  tests: add metadata-bad-mdaheader.sh
  tests: add metadata-bad-text.sh
  tests: add outdated-pv.sh
  tests: add metadata-old.sh
  tests: add missing-pv missing-pv-unused
  metadata.c: removed unused code
  improve reading and repairing vg metadata
  add a warning message when updating old metadata
  vgcfgbackup add error messages
  vgck --updatemetadata is a new command
  move pv header repairs to vg_write
  process_each_pv handle outdated pvs
  move wipe_outdated_pvs to vg_write
  create separate lvmcache update functions for read and write
  fix vg_commit return value
  change args for text label read function
  add mda arg to add_mda
  keep track of which mdas have old metadata in lvmcache
  ability to keep track of outdated pvs in lvmcache
  ability to keep track of bad mdas in lvmcache
  ...

 lib/cache/lvmcache.c                        |  468 ++++++-
 lib/cache/lvmcache.h                        |   45 +-
 lib/commands/toolcontext.h                  |    3 +
 lib/config/config_settings.h                |   25 +-
 lib/config/defaults.h                       |    2 +
 lib/device/dev-md.c                         |    5 +-
 lib/device/dev-type.c                       |    5 +-
 lib/device/device.h                         |    1 +
 lib/format_text/format-text.c               |  107 +-
 lib/format_text/format-text.h               |    6 +-
 lib/format_text/import.c                    |    6 +-
 lib/format_text/layout.h                    |    4 +-
 lib/format_text/text_label.c                |  235 +++-
 lib/label/label.c                           |   69 +-
 lib/label/label.h                           |    2 +-
 lib/metadata/metadata-exported.h            |   32 +-
 lib/metadata/metadata.c                     | 2199 ++++++++++-----------------
 lib/metadata/metadata.h                     |   18 +-
 lib/metadata/pv.h                           |    1 +
 lib/metadata/vg.c                           |    6 +-
 lib/metadata/vg.h                           |    5 -
 test/shell/inconsistent-metadata.sh         |   49 +-
 test/shell/lvconvert-repair-cache.sh        |    3 +
 test/shell/lvconvert-repair-policy.sh       |    2 +
 test/shell/lvconvert-repair-raid.sh         |    7 +
 test/shell/lvconvert-repair.sh              |    6 +
 test/shell/lvm-on-md.sh                     |   75 +-
 test/shell/lvmcache-exercise.sh             |   10 +-
 test/shell/metadata-bad-mdaheader.sh        |   80 +
 test/shell/metadata-bad-text.sh             |  236 +++
 test/shell/metadata-old.sh                  |  177 +++
 test/shell/mirror-vgreduce-removemissing.sh |    8 +
 test/shell/missing-pv-unused.sh             |   86 ++
 test/shell/missing-pv.sh                    |  152 ++
 test/shell/outdated-pv.sh                   |   66 +
 test/shell/pv-ext-flags.sh                  |   34 +-
 test/shell/unlost-pv.sh                     |   52 +-
 test/shell/vgck.sh                          |    4 +-
 tools/args.h                                |    3 +
 tools/command-lines.in                      |    5 +
 tools/commands.h                            |    2 +-
 tools/lvmcmdline.c                          |   55 +-
 tools/polldaemon.c                          |   17 +-
 tools/toollib.c                             |   83 +-
 tools/vgcfgbackup.c                         |   19 +-
 tools/vgck.c                                |   54 +
 tools/vgextend.c                            |   19 +-
 tools/vgremove.c                            |    2 +
 tools/vgsplit.c                             |    7 +-
 49 files changed, 2820 insertions(+), 1737 deletions(-)


