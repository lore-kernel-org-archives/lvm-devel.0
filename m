From: Andy Grover <agrover@redhat.com>
Date: Tue,  2 Oct 2012 09:03:41 -0700
Subject: [PATCH 0/4] Add initial python-lvm support v2
Message-ID: <1349193825-32244-1-git-send-email-agrover@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi agk and all,

This patchset adds a Python wrapper library to lvm2. It is a re-send &
squash of my previous patchset, as well as incorporating further fixes
and improvements from Tony Asleson's patchset. It also has whitespace
and other style fixes.

Thanks -- Regards -- Andy

The following changes since commit 886656e4ac5e5c932d9fbe60d18c063136288a38:

  RAID: Fix problems with creating, extending and converting large RAID LVs (2012-09-27 16:51:22 -0500)

are available in the git repository at:
  git://fedorapeople.org/home/fedora/grover/public_git/lvm2.git for-upstream

Andy Grover (3):
      python-lvm: initial checkin of liblvm.c in liblvm/python/
      python-lvm: build infrastructure
      python-lvm: Add example code for python-lvm.

Tony Asleson (1):
      python-lvm: feature parity with liblvm

 Makefile.in               |    3 +
 configure.in              |   10 +
 liblvm/Makefile.in        |    6 +-
 liblvm/python/Makefile.in |   30 +
 liblvm/python/example.py  |  107 +++
 liblvm/python/liblvm.c    | 1712 +++++++++++++++++++++++++++++++++++++++++++++
 liblvm/python/setup.py.in |   17 +
 7 files changed, 1884 insertions(+), 1 deletions(-)
 create mode 100644 liblvm/python/Makefile.in
 create mode 100644 liblvm/python/example.py
 create mode 100644 liblvm/python/liblvm.c
 create mode 100644 liblvm/python/setup.py.in


