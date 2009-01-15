From: Milan Broz <mbroz@redhat.com>
Date: Thu, 15 Jan 2009 14:22:35 +0100
Subject: lvresize.c: use kilobytes when passing sizes to fsadm
In-Reply-To: <496E202C.1060009@redhat.com>
References: <496E202C.1060009@redhat.com>
Message-ID: <496F389B.4060603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bryn M. Reeves wrote:
> The code in lvresize.c computes a new file system size to pass to 
> fsadm when resizing as (extents * extent_size), giving a result in 
> kilobytes.
> 
> This is then passed on to fsadm without a suffix, meaning that fsadm 
> interprets it as a count of the number of file system blocks instead.
> 
> This breaks fsadm for all file system block sizes other than 1K.
> 
> The attached patch adds a "K" suffix and fixes the problem for me - see:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=480022

Reviewed-by: Milan Broz <mbroz@redhat.com>
Tested-by: Milan Broz <mbroz@redhat.com>

(btw lvresize -r still works but is is not mentioned in man page, it is
intentional to prefer using fsadm --lvresize now?)

Milan

p.s.
Jaroslav, please can you add some tests internally for fsadm/lvresize?
(test in bugzilla, just extend/reduce for 1024,2048,4096 fs blocksize,
mke2fs -b <bs> is enough (or maybe xfs, reiserfs tests too))



