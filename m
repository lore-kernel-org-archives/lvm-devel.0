From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 3 Oct 2018 17:41:59 -0400 (EDT)
Subject: libblkid filesystem block size
Message-ID: <alpine.LRH.2.02.1810031724070.7859@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

As you maintain libblkid, I'd like to ask - would it be possible to add 
detection of filesystem block size to it? libblkid already has description 
of various filesystem superblocks, so it shouldn't be too hard.

LVM needs to know the block size because when it enables caching for a 
logical volume using the dm-writecache target or integrity protection 
using the dm-integrity target, the block size of the device mapper target 
should match the block size of the underlying filesystem (if the cache has 
smaller block size than the filesystem, it is inefficient, if the cache 
has larger block size than the filesystem, the filesystem won't mount).

Caching or integrity protection can be enabled on the fly for existing 
logical volumes (mounted or not mounted). XFS creates filesystems with 
512-byte block size even on some modern SSDs, so the problem with small 
block size exists even today.

Mikulas


