From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:11 -0500
Subject: [PATCH 0/6] 'pvmove' support for RAID, mirror, and thin
Message-ID: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following patches add support for 'pvmove'ing RAID, mirror and thin
segments.  Once applied, 'pvmove' will also handle moving portions of
thin types that sit on RAID or mirror LVs.

I have noticed one annoyance when testing.  In some cases, the metadata
LV and the data LV for RAID can get switched around.  That is, after
being moved the RAID metadata area may come after the data area even
though they were in the reverse position originally.  This is simply
a product of the way the LVs are iterated over.  It is probably worth
investigating a way to straighten this out.

Jonathan Brassow (6):
  Misc: Make get_pv_list_for_lv() available to more than just RAID
  RAID: Support moving RAID sub-LVs with pvmove
  Mirror: Make 'get_pv_list_for_lv' work with mirrors
  Thin: Make 'lv_is_on_pv(s)' and 'get_pv_list_for_lv' with with thin
    types
  Mirror: Support moving mirror sub-LVs with pvmove
  Thin: Support moving thin sub-LVs with pvmove

 lib/metadata/lv_manip.c          |  120 ++++++++++++++++++++++++++++++++-
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/raid_manip.c        |   59 +++++------------
 man/pvmove.8.in                  |    4 +-
 tools/pvmove.c                   |  136 ++++++++++++++++++++++++++++----------
 5 files changed, 238 insertions(+), 83 deletions(-)

-- 
1.7.7.6


