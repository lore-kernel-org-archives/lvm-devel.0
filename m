From: Tony Asleson <tasleson@redhat.com>
Date: Thu,  1 Nov 2012 18:11:22 -0500
Subject: [PATCH 0/3] lvm2app: Possible lvm_lv_resize impl.
Message-ID: <1351811485-18488-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set implements lvm_lv_resize for the lvm2app API.

As this patch set is pretty large and touches a number of different areas
I would appreciate folks to review.  Specifically the first patch where
I added a flag to lv to do additional steps on a vg_commit.  In addition
as users of the API are unable to interact the re-size has a implicit force, so
users could potentially lose data if they reduce the size of the lv.

Proposed changes pass local unit testing.

Tony Asleson (3):
  liblvm: Breakout required operations for re-size into vg_commit
  liblvm: Move core lv re-size to lv_manip.c
  lvm2app: Implement lvm_lv_resize

 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_manip.c          |  689 +++++++++++++++++++++++++++++++-
 lib/metadata/metadata-exported.h |   78 ++++-
 lib/metadata/metadata.c          |   87 ++++-
 lib/metadata/pv_manip.c          |    2 +-
 lib/misc/lvm-percent.c           |    5 +
 lib/misc/lvm-percent.h           |    2 +
 liblvm/lvm_lv.c                  |   19 +-
 tools/lvresize.c                 |  811 +++-----------------------------------
 tools/toollib.c                  |    4 +-
 tools/tools.h                    |   27 +-
 11 files changed, 925 insertions(+), 800 deletions(-)


