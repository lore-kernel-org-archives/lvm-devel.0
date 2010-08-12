From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 16:07:55 +0200
Subject: [PATCH 0/4] pvcreate & detection of foreign signatures
Message-ID: <cover.1281621747.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After the third report of broken LUKS after pvcreate (just this week...)
I added LUKS detection to lvm. But the current code is messy and in fact
it wipes superblocks without asking by default.

This is attempt to change that to something more user friendly.

Milan Broz (4):
  Change the pvcreate swap/md logic
  Remove assumption that --ye must be used only in --force mode
  Fix file open leak in swap signature detection
  Detect LUKS signature in pvcreate

 lib/Makefile.in         |    1 +
 lib/device/dev-luks.c   |   43 ++++++++++++++++++++++++++++
 lib/device/dev-swap.c   |   12 +++----
 lib/device/device.h     |    1 +
 lib/metadata/metadata.c |   71 +++++++++++++++++++++++++----------------------
 tools/pvremove.c        |    5 ---
 tools/toollib.c         |    5 ---
 7 files changed, 88 insertions(+), 50 deletions(-)
 create mode 100644 lib/device/dev-luks.c


