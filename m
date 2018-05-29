From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:13 -0400
Subject: master - Merge branch '2018-05-29-radix-tree-iterate' into 2018-05-23-radix-tree-remove
Message-ID: <201805291716.w4THGDOk023699@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0181c77e3fe0fd4c82b10e283d4852a09ff78452
Commit:        0181c77e3fe0fd4c82b10e283d4852a09ff78452
Parent:        6cd798f556b34c4c4171d536298d8f718f8aef62 033df741e2e771b3abda3e190ed9c359d579ce4a
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 29 11:04:32 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 29 11:04:32 2018 +0100

Merge branch '2018-05-29-radix-tree-iterate' into 2018-05-23-radix-tree-remove


 .gitignore                          |   52 +++++++++++++++-
 VERSION                             |    2 +-
 VERSION_DM                          |    2 +-
 WHATS_NEW                           |   25 ++++----
 WHATS_NEW_DM                        |    7 ++-
 base/data-struct/radix-tree.c       |   10 ++-
 base/data-struct/radix-tree.h       |    7 +-
 doc/release-notes/2.02.178          |   53 ++++++++++++++++
 lib/device/dev-cache.c              |    2 +
 lib/format_text/archive.c           |    4 +-
 lib/label/label.c                   |  115 +++++++++++++++++++++++++++++++---
 man/dmeventd.8_main                 |    4 +-
 man/vgexport.8_pregen               |   19 +++++-
 test/lib/aux.sh                     |   30 ++++++---
 test/shell/lvmetad-pvscan-md.sh     |    3 +-
 test/shell/pvcreate-md-fake-hdr.sh  |   94 ++++++++++++++++++++++++++++
 test/shell/pvcreate-operation-md.sh |   17 ++++-
 test/unit/radix_tree_t.c            |    4 +-
 18 files changed, 388 insertions(+), 62 deletions(-)


