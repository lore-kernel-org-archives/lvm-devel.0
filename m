From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 27 Sep 2010 17:31:54 +0200
Subject: [PATCH 0/1] memlock_fix
Message-ID: <cover.1285601408.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix reading of duplicate lines before locking unlocking memory.

Zdenek Kabelac (1):
  Maps fix

 lib/mm/memlock.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 40 insertions(+), 13 deletions(-)

-- 
1.7.3


