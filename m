From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 7 Oct 2010 20:23:23 +0100
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
Message-ID: <20101007192323.GD22053@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 07, 2010 at 03:10:43PM +0200, Peter Rockai wrote:
> There are some trade-offs involved. I have opted for using an umount
> syscall directly since it's simpler and more robust. The downside is
> that /etc/mtab will go out of sync and people may actually think that

I'm not keen on leaving /etc/mtab out-of-date, or missing out anything
else that /bin/umount might actually do (with an errored-out device).
Would this patch need an update to the selinux context to allow umount?

> the snapshot is still mounted (mount(8) just prints mtab without
> thinking twice about it). We could just fork off umount(8) instead, but
> that can fail in new and interesting ways.

Yes, even if moved outside the locking.  But even umount2() within
the lock might have deadlock possibilities, as might syslog() as
you point out.

The options/problems here need a bit more investigation.
 
> The other possible issue with the patch is that I am not sure whether
> it's actually safe to read /proc/mounts incrementally, with possibly
 
kabi found problems like that with another /proc file.

Alasdair


