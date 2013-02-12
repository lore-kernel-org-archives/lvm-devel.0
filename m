From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Tue, 12 Feb 2013 22:54:34 +0530
Subject: [PATCH V3 0/2] Add thin lv and thin pool creation support
Message-ID: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add thin lv and thin pool creation support to lvm2app.

Changes from V2:
* Specify percentage for low water mark threshold instead of number of
  blocks
* man page update for lvcreate

Changes from previous version:
* Add support to specify data block size and low water mark thresold for
newly created thin pool.
* Added support for specifying lowwatermark parameter to thin pool
creation in lvcreate command

M. Mohan Kumar (2):
  lvm2app: Add thin and thin pool lv creation
  master - thin: Add low water mark parameter to pool creation

 lib/metadata/lv_manip.c          |   2 +-
 lib/metadata/metadata-exported.h |   1 +
 liblvm/lvm2app.h                 |  57 +++++++++++++++++++
 liblvm/lvm_lv.c                  | 116 +++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in                |  11 +++-
 tools/args.h                     |   1 +
 tools/commands.h                 |   6 +-
 tools/lvconvert.c                |   1 +
 tools/lvcreate.c                 |   7 ++-
 tools/toollib.c                  |  11 ++++
 tools/toollib.h                  |   1 +
 11 files changed, 209 insertions(+), 5 deletions(-)

-- 
1.7.11.7


