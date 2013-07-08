From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:19:12 +0200
Subject: [PATCH 0/4] locking updates
Message-ID: <cover.1373296602.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Locking changes to support Ctrl+C during yes_no_prompt
When we allow interrupts for the command,
and the lock VG, the current code no longer supports
breaks when allowed again in yes_no_prompt.
This code adds extra level of depth to support it.

Zdenek Kabelac (4):
  locking: use sigint functions
  configure: drop siginterrupt
  locking: support stacking
  cleanup: add comment

 configure                  | 11 ---------
 configure.in               |  1 -
 lib/display/display.c      |  2 +-
 lib/locking/file_locking.c | 57 +++++-----------------------------------------
 lib/locking/locking.c      | 49 ++++++++++++++++++++-------------------
 lib/misc/configure.h.in    |  3 ---
 lib/misc/lvm-wrappers.h    | 15 ------------
 7 files changed, 32 insertions(+), 106 deletions(-)

-- 
1.8.3.1


