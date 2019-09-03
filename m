From: Karel Zak <kzak@redhat.com>
Date: Tue, 3 Sep 2019 15:01:50 +0200
Subject: [PATCH] blkid: retport block size of a filesystem
In-Reply-To: <CADxRZqwURQJMCCAkY8TvjBaQnCL9j1AHN3mY6b1q3bN-VCZRyA@mail.gmail.com>
References: <alpine.LRH.2.02.1908291142470.17653@file01.intranet.prod.int.rdu2.redhat.com>
	<20190902105909.ah4pi4nwjefygskd@10.255.255.10>
	<CADxRZqwURQJMCCAkY8TvjBaQnCL9j1AHN3mY6b1q3bN-VCZRyA@mail.gmail.com>
Message-ID: <20190903130150.iatqincnxf4re7ce@10.255.255.10>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 03, 2019 at 03:36:46PM +0300, Anatoly Pugachev wrote:
> On Mon, Sep 2, 2019 at 1:59 PM Karel Zak <kzak@redhat.com> wrote:
> > Applied (with two small fixes), thanks!
> 
> Karel, Mikulas,
> 
> ts/blkid/low-probe started to fail on sparc64 with this patch:
> 
>         blkid: superblocks probing: [97] xfs-log             ... OK
>         blkid: superblocks probing: [98] xfs                 ...
> FAILED (blkid/low-probe-xfs)
> 
> but is "OK" on x86_64.
> 
> $ diff -u expected/blkid/low-probe-xfs output/blkid/low-probe-xfs
> --- expected/blkid/low-probe-xfs        2019-09-03 12:45:18.779505561 +0300
> +++ output/blkid/low-probe-xfs  2019-09-03 14:35:41.569815684 +0300
> @@ -1,4 +1,4 @@
> -ID_FS_BLOCK_SIZE=512
> +ID_FS_BLOCK_SIZE=131072

  blkid_probe_set_block_size(pr, xs->sb_sectsize * 256);

be16_to_cpu() is missing here :-) I'll fix it.

    Karel


>  ID_FS_LABEL=test-xfs
>  ID_FS_LABEL_ENC=test-xfs
>  ID_FS_TYPE=xfs
> 
> $ md5sum output/blkid/images-fs/xfs.img
> c4a59d4039b5ed5557e8502ca2906373  output/blkid/images-fs/xfs.img
> 
> (md5 is the same as on x86_64 test machine)
> 
> You can use gcc202 sparc64 machine from gcc compile farm for the test.
> 
> PS: can someone regenerate xfs.img(xz) with more recent XFS filesystem version?
> 
> $ xfs_info output/blkid/images-fs/xfs.img
> xfs_info: V1 inodes unsupported. Please try an older xfsprogs.

or we need to add another xfs image. I guess we want to support all
versions.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com


