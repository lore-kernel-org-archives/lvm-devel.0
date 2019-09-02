From: Karel Zak <kzak@redhat.com>
Date: Mon, 2 Sep 2019 12:59:09 +0200
Subject: [PATCH] blkid: retport block size of a filesystem
In-Reply-To: <alpine.LRH.2.02.1908291142470.17653@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1908291142470.17653@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <20190902105909.ah4pi4nwjefygskd@10.255.255.10>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 29, 2019 at 11:52:13AM -0400, Mikulas Patocka wrote:
>  libblkid/src/superblocks/apfs.c        |    2 
>  libblkid/src/superblocks/befs.c        |    3 +
>  libblkid/src/superblocks/btrfs.c       |    1 
>  libblkid/src/superblocks/exfat.c       |    2 
>  libblkid/src/superblocks/exfs.c        |    4 +
>  libblkid/src/superblocks/ext.c         |    3 +
>  libblkid/src/superblocks/f2fs.c        |    2 
>  libblkid/src/superblocks/gfs.c         |    1 
>  libblkid/src/superblocks/hfs.c         |    2 
>  libblkid/src/superblocks/hpfs.c        |    1 
>  libblkid/src/superblocks/iso9660.c     |    2 
>  libblkid/src/superblocks/jfs.c         |    1 
>  libblkid/src/superblocks/minix.c       |    5 ++
>  libblkid/src/superblocks/nilfs.c       |    3 +
>  libblkid/src/superblocks/ntfs.c        |    2 
>  libblkid/src/superblocks/ocfs.c        |    3 +
>  libblkid/src/superblocks/reiserfs.c    |   10 +++-
>  libblkid/src/superblocks/romfs.c       |    3 +
>  libblkid/src/superblocks/squashfs.c    |    2 
>  libblkid/src/superblocks/superblocks.c |    7 +++
>  libblkid/src/superblocks/superblocks.h |    2 
>  libblkid/src/superblocks/udf.c         |    2 
>  libblkid/src/superblocks/ufs.c         |    5 ++
>  libblkid/src/superblocks/vfat.c        |    2 
>  libblkid/src/superblocks/vxfs.c        |   18 +++++++
>  libblkid/src/superblocks/xfs.c         |    1 
>  libblkid/src/superblocks/zfs.c         |   76 ++++++++++++++++++++++++---------
>  27 files changed, 144 insertions(+), 21 deletions(-)

Applied (with two small fixes), thanks!

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com


