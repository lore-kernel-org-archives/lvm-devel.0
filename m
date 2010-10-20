From: Petr Rockai <prockai@redhat.com>
Date: Thu, 21 Oct 2010 00:50:40 +0200
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <20101007192323.GD22053@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Thu, 7 Oct 2010 20:23:23 +0100")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
	<20101007192323.GD22053@agk-dp.fab.redhat.com>
Message-ID: <877hhc8on3.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> On Thu, Oct 07, 2010 at 03:10:43PM +0200, Peter Rockai wrote:
>> There are some trade-offs involved. I have opted for using an umount
>> syscall directly since it's simpler and more robust. The downside is
>> that /etc/mtab will go out of sync and people may actually think that
>
> I'm not keen on leaving /etc/mtab out-of-date, or missing out anything
> else that /bin/umount might actually do (with an errored-out device).
> Would this patch need an update to the selinux context to allow umount?

I don't know about selinux. Anyhow, I think my plan is to fork off
/bin/umount asynchronously (i.e. outside of the dmeventd lock). That's
probably the safest possible approach I can think of, at least with our
current design. It will need a bit of thinking, but it should be doable.

>> the snapshot is still mounted (mount(8) just prints mtab without
>> thinking twice about it). We could just fork off umount(8) instead, but
>> that can fail in new and interesting ways.
>
> Yes, even if moved outside the locking.  But even umount2() within
> the lock might have deadlock possibilities, as might syslog() as
> you point out.

I will tackle that (syslog) separately.

>> The other possible issue with the patch is that I am not sure whether
>> it's actually safe to read /proc/mounts incrementally, with possibly
>
> kabi found problems like that with another /proc file.

Ok, that arguably sucks. Nevertheless, from reading the kernel code for
that, it seems that while the contents may change in between reads, the
results are still well defined: adding lines to the buffer is done
atomically in the kernel, so we should never get a garbled line. What
could happen is that we encounter the same line twice, or that we miss
something that was there when we were opening the file but was no longer
there when we got to that point in it. Neither should be a serious
problem.

That behaviour depends on the proc file implementation using the
seq_file mechanism, which may not be the case with all files. It is used
for all the mount-related files though (mounts, self/mounts,
self/mountinfo).

Yours,
   Petr.


