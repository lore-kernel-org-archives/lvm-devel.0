From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:09:06 +0100
Subject: [PATCH 0/2] Valgrind fixes
Message-ID: <cover.1299089143.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While hunting for sharing vg bugs - few unrelated problems appeared.
Here is the first set that tries to address reported problems.

Zdenek Kabelac (2):
  Fix read byte from char[-1] position
  Do not send random bytes in message

 daemons/clvmd/clvmd.c     |    9 +++++++--
 libdm/ioctl/libdm-iface.c |    6 ++++--
 2 files changed, 11 insertions(+), 4 deletions(-)

-- 
1.7.4.1


