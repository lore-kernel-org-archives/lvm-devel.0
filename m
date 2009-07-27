From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 27 Jul 2009 15:12:34 +0200
Subject: [PATCH 0/3] lvm_vg_reduce and vg_reduce
Message-ID: <1248700357-10112-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch series adds lvm_vg_reduce and vg_reduce. For more information 
please have a look at the patches.

Dave Wysochanski (1):
  Initialize removed_pvs list in format-specific volume_group
    constructors.

Thomas Woerner (2):
  Add vg_reduce to metadata.c and metadata-exported.h
  Add lvm_vg_reduce to liblvm2app

 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/import_vsn1.c    |    1 +
 lib/metadata/metadata-exported.h |    7 ++
 lib/metadata/metadata.c          |   61 +++++++++++++++++++
 liblvm/.exported_symbols         |    1 +
 liblvm/lvm.h                     |   18 ++++++
 liblvm/lvm_vg.c                  |   25 ++++++++
 test/api/vgtest.c                |  118 ++++++++++++++++++++++++--------------
 9 files changed, 190 insertions(+), 43 deletions(-)


