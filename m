From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 21 Sep 2011 13:36:42 +0200
Subject: [PATCH 0/2] Repost clvmd bugfix
Message-ID: <cover.1316604772.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reposting this patch:
https://www.redhat.com/archives/lvm-devel/2011-September/msg00048.html

Patch is split into files - 1st is pure bugfix for easy backporting.
Second is cleanup and simplification of the restaring code.

Zdenek Kabelac (2):
  Clvmd fix restart
  Clvmd restart cleanup

 daemons/clvmd/clvmd-command.c |   45 ++++++++++++++++++----------------------
 1 files changed, 20 insertions(+), 25 deletions(-)

-- 
1.7.6.2


