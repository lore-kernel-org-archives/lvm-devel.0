From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 30 Jul 2009 19:04:38 -0400
Subject: [PATCH 0/3] LVM2 topology support (patchset 1)
Message-ID: <1248995081-19092-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Split the overall LVM2 topology patchset into 2 sets.
This first patchset is the core of the LVM2 topology support; the second
patchset is more straight-forward.

First 2 patches are just fixes.

The --dataalignmentoffset patch (3) now adds the dataalignmentoffset to
the first mda (rather than leaving an unused gap between the first mda
and pe_start).  _text_pv_setup() was updated to make certain there isn't
a double-adjustment of pe_start.

Mike Snitzer (3):
  Formalize pe_start policy as split between .pv_setup and .pv_write.
  Fix _mda_setup() to not check first mda's size before pe_align rounding.
  Add --dataalignmentoffset to pvcreate to shift start of aligned data area.

 WHATS_NEW                        |    3 ++
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   60 +++++++++++++++++++++++++++++++------
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/metadata.c          |   30 +++++++++++++++++--
 lib/metadata/metadata.h          |    3 ++
 man/pvcreate.8.in                |   20 +++++++++++--
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++--
 tools/pvcreate.c                 |   21 ++++++++++++-
 tools/vgconvert.c                |    2 +-
 13 files changed, 132 insertions(+), 22 deletions(-)


