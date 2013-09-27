From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 27 Sep 2013 14:10:20 -0500
Subject: [PATCH 00/12] RFC & code review for lvm2app & python-lvm fixes
Message-ID: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set address the following bugs:

- Set PV metadata size and count
  https://bugzilla.redhat.com/show_bug.cgi?id=880395

- lvm2app lvm_vg_reduce() can delete a volume group
  https://bugzilla.redhat.com/show_bug.cgi?id=989174

- RFE: export a Python name-validation function
  https://bugzilla.redhat.com/show_bug.cgi?id=883689

In addition the following is included:

- Environmental variable LVM2APP_DEBUG if exists will cause the library to
  dump debug messages to stderr
- lvm2app -> lvm_errmsg will clear the error buffer so library users won't get
  stacked messages collecting for the entire run or until the buffer hits max.
  size.
- python-lvm was cleaned up to adhere to the expected namespace and includes
  a change to prevent segfaulting if a user call gc and then references an
  object with a stale library handle.


Tony Asleson (12):
  python-lvm: Correct names
  python-lvm: Robustness improvements.
  vgreduce: Move _vgreduce_single functionality
  metadata.c: Call refactored vgreduce_single
  python-lvm: Test case change for vg.reduce
  lvm2app: Add ability to create PV with args
  python-lvm: Add addl. PV create arguments
  python-lvm: Update and enable unit test case
  lvm2app: Add VG/LV name validation
  python-lvm: VG/LV name validation.
  lvm2app: Reset buffer after retrieving error message
  lvm2app: Add LVM2APP_DEBUG env variable for debug

 lib/log/log.c                    |  18 +++
 lib/log/log.h                    |   2 +
 lib/log/lvm-logging.h            |   1 +
 lib/metadata/metadata-exported.h |   5 +
 lib/metadata/metadata.c          |  67 ++++----
 lib/metadata/vg.c                |  93 +++++++++++
 lib/misc/lvm-string.c            |  68 ++++++--
 lib/misc/lvm-string.h            |   1 +
 liblvm/lvm2app.h                 |  96 ++++++++++++
 liblvm/lvm_base.c                |  24 ++-
 liblvm/lvm_lv.c                  |   8 +-
 liblvm/lvm_misc.c                |  10 ++
 liblvm/lvm_misc.h                |   9 +-
 liblvm/lvm_prop.c                |  31 ++++
 liblvm/lvm_prop.h                |  14 ++
 liblvm/lvm_prop_fields.h         |   7 +
 liblvm/lvm_pv.c                  | 136 ++++++++++++++--
 liblvm/lvm_vg.c                  |  25 ++-
 python/liblvm.c                  | 329 +++++++++++++++++++++++----------------
 test/api/pytest.sh               |   4 -
 test/api/python_lvm_unit.py      | 101 +++++++++++-
 tools/toollib.c                  |   6 -
 tools/vgreduce.c                 |  81 +---------
 23 files changed, 848 insertions(+), 288 deletions(-)

-- 
1.8.2.1


