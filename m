From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:26 +0800
Subject: [RFC 0/6] Waiting for the missing device in mirror
Message-ID: <1433749712-11837-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi List,

The implementation here is trying to add another policy for the
missing leg/log device in mirror. We want to wait the device for some
time in case of a temporary device failure, especially a network disconnection
for clvmd, to avoid a full disk recovery.

This version is kind of a draft. There are many immature places to improve. So comments
and suggestions are welcomed.

The responding kernel part is here:
https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/
commit/?h=for-next&id=ed63287dd670f8e9d2412a913de7fdc50a689831

Regards,
Lidong

Lidong Zhong (6):
  Enable the keep_log feature while creating a mirror device
  Replace table info and export two simple APIs to do suspend/resume
  Mark a device if already being waited
  Write the device number into metadata
  Add another policy for the missing device -- wait
  lvconvert: implement the wait policy

 lib/config/config_settings.h     |   2 +
 lib/config/defaults.h            |   2 +
 lib/format_text/export.c         |   4 +
 lib/format_text/import_vsn1.c    |   5 +
 lib/metadata/lv_manip.c          |   1 +
 lib/metadata/metadata-exported.h |   1 +
 lib/metadata/pv.h                |   1 +
 lib/mirror/mirrored.c            |   3 +
 lib/misc/lvm-globals.c           |  11 ++
 lib/misc/lvm-globals.h           |   2 +
 libdm/libdevmapper.h             |   7 +
 libdm/libdm-deptree.c            |  96 +++++++++++-
 tools/commands.h                 |   4 +-
 tools/lvconvert.c                | 325 +++++++++++++++++++++++++++++++++++++--
 tools/lvcreate.c                 |   4 +-
 15 files changed, 453 insertions(+), 15 deletions(-)

-- 
1.8.1.4


