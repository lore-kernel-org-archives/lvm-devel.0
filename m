From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Sep 2020 17:38:17 +0800
Subject: [PATCH 0/4] LVM2: some code cleanups and bugfixs checked by codeDEX tools
Message-ID: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When I learn the LVM2 source code and test it, I
find some bugs and fix them. At the same time,
static scanning tools were used to analyze the code,
and several possible problems were found.

repo: https://sourceware.org/git/lvm2.git
repo link: https://sourceware.org/git/lvm2.git
branch: master

wuguanghao (4):
  pvmove: check return value of top_level_lv_name() in _set_up_pvmove_lv
  lvconvert_poll: check whether lv is a snapshot type in poll_thin_merge_progress
  lvconvert: _lvconvert_splitsnapshot check if lv is snapshot type
  fix core dump when thinpool size more than the remaining space of vg

 tools/lvconvert.c      | 3 +++
 tools/lvconvert_poll.c | 2 +-
 tools/lvcreate.c       | 7 +++++++
 tools/pvmove.c         | 7 ++++++-
 4 files changed, 17 insertions(+), 2 deletions(-)

-- 


