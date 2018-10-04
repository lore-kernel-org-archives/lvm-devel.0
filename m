From: Karel Zak <kzak@redhat.com>
Date: Thu, 4 Oct 2018 11:43:29 +0200
Subject: libblkid filesystem block size
In-Reply-To: <alpine.LRH.2.02.1810031724070.7859@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1810031724070.7859@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <20181004094329.z6b7y4ahhmb4ayj6@ws.net.home>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


 Ahoj,

On Wed, Oct 03, 2018 at 05:41:59PM -0400, Mikulas Patocka wrote:
> As you maintain libblkid, I'd like to ask - would it be possible to add 
> detection of filesystem block size to it? libblkid already has description 
> of various filesystem superblocks, so it shouldn't be too hard.

we had something like this (and also FS size) in our TODO for years.
So, I don't see problem to add it now. Send patch ;-)

All you need is to add 

 libblkid/src/superblocks/superblocks.c: blkid_probe_set_fs_blocksize() 

to add "BLKSZ" variable to the probing result (use for example
blkid_probe_set_version() as a template).

And then use this function in FS specific probers. The variable will
automatically visible for udev as ID_FS_BLKSZ=.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com


