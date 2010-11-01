From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  1 Nov 2010 13:53:50 +0100
Subject: [PATCH 0/3] Resize online
Message-ID: <cover.1288614451.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset tries to deal with online resize where we need from
the user to instrument 'lvresize -r' tool to skip fsck part.

Now fsadm tool reports different status code for online mounted
filesystem and updated exec_cmd() is able to pass return status code,
so the new status code is recognized by lvresize and allows
to continue with online resize operation.

Zdenek Kabelac (3):
  Return different error value for check of mounted fs
  Document fsadm script return codes
  Handle new return code from fsadm check

 lib/activate/activate.c |    2 +-
 lib/misc/lvm-exec.c     |   14 ++++++++++++--
 lib/misc/lvm-exec.h     |    4 ++--
 man/fsadm.8.in          |    6 ++++++
 scripts/fsadm.sh        |   14 ++++++++++++--
 tools/lvresize.c        |   20 +++++++++++++-------
 6 files changed, 46 insertions(+), 14 deletions(-)
 mode change 100644 => 100755 scripts/fsadm.sh

-- 
1.7.3.2


