From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Thu, 31 Jan 2013 19:55:50 +0530
Subject: [PATCH V2 0/2] Add thin lv and thin pool creation support
Message-ID: <1359642352-9688-1-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add thin lv and thin pool creation support to lvm2app.

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
 liblvm/lvm2app.h                 |  53 +++++++++++++++++++
 liblvm/lvm_lv.c                  | 107 +++++++++++++++++++++++++++++++++++++++
 tools/args.h                     |   1 +
 tools/commands.h                 |   6 ++-
 tools/lvconvert.c                |   1 +
 tools/lvcreate.c                 |   7 ++-
 tools/toollib.c                  |   4 ++
 tools/toollib.h                  |   1 +
 10 files changed, 179 insertions(+), 4 deletions(-)

-- 
1.7.11.7


