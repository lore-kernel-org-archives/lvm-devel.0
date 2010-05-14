From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 10:28:24 +0200
Subject: [PATCH 0/1] Use bash
Message-ID: <cover.1273825538.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac (1):
  Use /bin/bash instead of /bin/sh

 scripts/clvmd_fix_conf.sh       |    2 +-
 scripts/fsadm.sh                |    2 +-
 scripts/last_cvs_update.sh      |    2 +-
 scripts/lvmconf.sh              |    2 +-
 scripts/lvmconf_lockingtype2.sh |    2 +-
 scripts/vgimportclone.sh        |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)


