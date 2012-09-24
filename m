From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:11 -0500
Subject: [PATCH 00/12] python-lvm feature parity
Message-ID: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set brings python-lvm up to date with the features that are currently
in lvm2app.h.

Minimal unit testing has been done at this time.

Tony Asleson (12):
  test.py Reformated to use spaces
  Add support for lvm_lv_rename.
  Add support for lvm_percent_to_float
  Add support for lvm_vg_[get|set]_property
  Add support for lvm_lv_from_name
  Add support for lvm_lv_from_uuid
  Add support for lvm_pv_from_[name|uuid]
  Add support for lvm_lv_get_property
  Add support for lvm_pv_get_property
  Add support for lvm_config_find_bool
  Add support for lvm_lv_list_lvsegs, lvm_lvseg_get_property
  Add support for lvm_pv_list_pvsegs, lvm_pvseg_get_property

 liblvm.c | 507 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 test.py  | 125 ++++++++--------
 2 files changed, 570 insertions(+), 62 deletions(-)

-- 
1.7.11.4


