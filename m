From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:30 +0200
Subject: [PATCH 0/9] FSADM updates and fixes
Message-ID: <cover.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset contains fsadm fixes which might potentially lead
to complete destruction of the filesystem.

The last patch in this set is a new test script so fsadm is regularly
checked whether it still works - probably  xfs & reiserfs tools will
need to be installed on the buildbot machines.

Zdenek Kabelac (9):
  can not -> cannot
  Fix return value from break trap
  Fix dry run exec
  Support for passing Yes flag recursively.
  Fix wrong default value setting for lvm
  Fix problem with fscking of mounted filesystem
  Fix dry run of resize command
  Support for noninteractive shell invocation of fsadm
  Testing script for fsadm and lvresize functionality

 scripts/fsadm.sh |   64 ++++++++++++++++++++---------
 test/t-fsadm.sh  |  119 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 152 insertions(+), 31 deletions(-)

-- 
1.7.3.1


