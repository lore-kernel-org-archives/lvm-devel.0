From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Apr 2011 17:21:54 +0200
Subject: [PATCH 0/2] Fix mawk incompatibility for vgimportclone
Message-ID: <cover.1304090389.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch addresses incompatibility with older version of mawk.
See attached comments.

Zdenek Kabelac (2):
  Replace char class :space: with explicit chars
  Update test case

 scripts/vgimportclone.sh |   10 +++++-----
 test/t-vgimportclone.sh  |   22 ++++++++--------------
 2 files changed, 13 insertions(+), 19 deletions(-)

-- 
1.7.5


