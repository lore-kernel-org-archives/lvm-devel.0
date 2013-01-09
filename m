From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  8 Jan 2013 23:53:13 -0600
Subject: [PATCH 0/4] lv resize patch set
Message-ID: <1357710797-18574-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implements lv re-size.

Tony Asleson (4):
  lvm2app: Move percent_of_extents to lvm-percent.[h|c]
  lvm2app: Rework argument handling for lv resize
  lvm2app: Move core lv re-size code
  lvm2app: Implement lv resize

 lib/format_text/flags.c          |   1 +
 lib/metadata/lv_manip.c          | 673 ++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |  54 +++
 lib/metadata/metadata.c          |  90 ++++-
 lib/misc/lvm-percent.c           |   5 +
 lib/misc/lvm-percent.h           |  17 +
 liblvm/lvm2app.h                 |   2 -
 liblvm/lvm_lv.c                  |  19 +-
 tools/lvresize.c                 | 812 +++------------------------------------
 tools/toollib.c                  |   6 -
 tools/tools.h                    |  16 -
 11 files changed, 907 insertions(+), 788 deletions(-)

-- 
1.7.11.7


