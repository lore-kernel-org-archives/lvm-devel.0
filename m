From: Marcus Müller <marcus@hostalia.de>
Date: Wed,  2 Aug 2017 19:42:34 +0200
Subject: [PATCH 0/1] adding Btrfs resizing capability to lvresize/fsadm.sh
Message-ID: <20170802174235.19869-1-marcus@hostalia.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Btrfs support was missing from LVM's volume resize tools.
Fixed that.

Marcus M?ller (1):
  added resizing for btrfs

 scripts/fsadm.sh | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

-- 
2.13.0


