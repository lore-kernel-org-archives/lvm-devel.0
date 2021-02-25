From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Feb 2021 20:39:35 +0800
Subject: [PATCH LVM2 v1 1/2] blkdeactive: Introduce option "forcevg" to forcibly deactivate VG
In-Reply-To: <5ceaf113-7d5a-3a98-3937-f3e6b1406a14@redhat.com>
References: <20210225110451.175956-1-leo.yan@linaro.org>
	<5ceaf113-7d5a-3a98-3937-f3e6b1406a14@redhat.com>
Message-ID: <20210225123935.GC160939@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

On Thu, Feb 25, 2021 at 01:01:36PM +0100, Zdenek Kabelac wrote:
> Dne 25. 02. 21 v 12:04 Leo Yan napsal(a):
> > From: Zhang Huan <zhanghuan@huayun.com>
> > 
> > This patch introduces new option "forcevg" for LVM, the main purpose is
> > to flush in-flight I/O operations and replace the LV's device mapper
> > table with 'error' target, this is accomplished by using command
> > "dmsetup wipe_table".
> 
> Hi
> 
> For this moment - I'd prefer different solution in upstream.
> 
> We should first see what are the chance to support forcible deactivation
> within lvm2 code directly.
> 
> This 'out-of-control' external logic may cause significant data loss
> breakages - as the external tools have not so good idea about connections
> between targets.
> 
> There need to be something like: vgchange -an --force --yes

I have to admit that I am not familiar with the LVM internal, so it's
quite possible that my understanding is not mature, but let me bring
up the question.

If we use "vgchange -an --force --yes" or "lvchange" commands to
disable VG or LV, seems to me this is likely to cause the egg and
chicken problem, and at the end it easily leads to "deadlock" result.

The reason is when the lock manager invokes "lvmlockctl --kill" to
kill VG, usually this means the lock manager has detected the drive
failures (e.g. the sanlock lock manager finds it cannot renew lease
due to the I/O failures), for this case, it's likely the node has no
chance to access metadata anymore.  So if we use "vgchange" command to
disable VG, it's possible to stuck for long time.

And before we use "vgchange" to deactivate the VG, here I have another
concern is if the LV is mounted (so the device-mapper is in used),
then there have dependency to need firstly umount LV, otherwise also
might cause problem for using "vgchange" command.

How about think for this?

Thanks for suggestions,
Leo

> tried first when the lvm2 'metadata' are present
> and eventually support work with targets withot 'metadata' but
> with  LVM-  uuid devices in the DM table.
> 
> Giving this to the hands of fairly naive script like blkdeactive isn't the
> right choice here.
> 
> Zdenek
> 


