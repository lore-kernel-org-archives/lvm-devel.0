From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Mar 2011 22:57:44 +0100
Subject: [PATCH 0/3] Memory fixes
Message-ID: <cover.1301089240.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Originaly I wanted to post here new patch for dm_pool_splice
to join to dm_pool list together. However there is fairly simplier
fix for our memory reference problem - just fixing the vgmem release
order. (I may provide  dm_pool_splice patch - as it could be seen
as 'better' way of handling this memory problem - but as for now
it only related to vgmerge and vgsplite - it's easier this way.)

Second patch is addressing our maps mismatching - it's rather workaround,
but for now quite sufficient.

The last patch is for those who want to play with valgrind and lvm2.
There we need to disable memory size checks.

Zdenek Kabelac (3):
  Fix mem
  Set our own in/out buffers
  Valgrind updates

 lib/commands/toolcontext.c |    8 ++++++++
 lib/mm/memlock.c           |    3 +++
 libdm/mm/pool-fast.c       |   11 ++++-------
 tools/vgmerge.c            |    6 ++++--
 tools/vgsplit.c            |    6 ++++--
 5 files changed, 23 insertions(+), 11 deletions(-)

-- 
1.7.4.1


