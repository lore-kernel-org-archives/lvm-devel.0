From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Nov 2010 15:10:40 +0100
Subject: [PATCH 0/3] OCF support
Message-ID: <cover.1288706876.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patch from
https://bugzilla.redhat.com/show_bug.cgi?id=646854

First two patches are modifing surrounding Makefiles so
recursive makefile is easier (FIXME: write better recursive target)
Second one tries to avoid unexpected installation to live system
(but as the target is rather hidden one - it's probably hard to hit)
(FIXME: write make help with supported targets)

OCF patch:
  user needs to configure --enable-ocf so it gets installed with
  make install target by default.
  Otherwise he might use  make install_ocf to get only ocf files installed.
  With disabled (default) ocf support - no files are installed.

Zdenek Kabelac (3):
  Use include make.tmpl as other headers
  Add ${prefix}
  ocf support

 configure.in            |   10 ++
 include/Makefile.in     |   18 +---
 make.tmpl.in            |    8 +-
 scripts/Makefile.in     |   23 +++-
 scripts/VolumeGroup.ocf |  279 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 316 insertions(+), 22 deletions(-)
 create mode 100644 scripts/VolumeGroup.ocf

--
1.7.3.2


