From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Oct 2013 10:50:08 +0200
Subject: [PATCH v2]: Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
In-Reply-To: <1382485181.19061.3.camel@f16>
References: <1382394852.4860.4.camel@f16> <1382485181.19061.3.camel@f16>
Message-ID: <52678DC0.3020903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.10.2013 01:39, Jonathan Brassow napsal(a):
> Changed some variable/function names and added more explanation to the
> config file.
>
> I will send a separate patch that contains a warning message if mirrors
> are activated and 'ignore_lvm_mirrors' is not set... We can talk about
> whether that is needed also.
>
>   brassow
>
> Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
>
> There is a problem with the way mirrors have been designed to handle
> failures that is resulting in stuck LVM processes and hung I/O.  When
> mirrors encounter a write failure, they block I/O and notify userspace
> to reconfigure the mirror to remove failed devices.  This process is
> open to a couple races:
> 1) Any LVM process other than the one that is meant to deal with the
> mirror failure can attempt to read the mirror, fail, and block other
> LVM commands (including the repair command) from proceeding due to
> holding a lock on the volume group.
> 2) If there are multiple mirrors that suffer a failure in the same
> volume group, a repair can block while attempting to read the LVM
> label from one mirror while trying to repair the other.
>
> Mitigation of these races has been attempted by disallowing label reading
> of mirrors that are either suspended or are indicated as blocking by
> the kernel.  While this has closed the window of opportunity for hitting

Is mirror read 'abort-able' (i.e. sigalarm()) when it's blocked ?
So our  'scan' routine could try to read mirror - which suddenly
gets 'frozen' by write error.
If we would have used sigalarm - we should be able abort() read operation
(though I'm not sure where the read gets stuck - maybe it would need change in 
the kernel driver?)  - after read failure we may detect mirror error 
conditions through dm status - and make some reaction?

The very similar thing needs to be added for scanning of i.e. thinly 
provisioned devices - which may get stuck when the pool is overfilled - so 
some solution in this direction is unavoidable - IMHO we should not hide the 
problem by disabling of scanning).


> 2) Instrument a way to allow asynchronous label reading - allowing
> blocked label reads to be ignored while continuing to process the LVM
> command.  This would action would allow LVM commands to continue even
> though they would have otherwise blocked trying to read a mirror.  They
> can then release their lock and allow a repair command to commence.  In
> the event of #2 above, the repair command already in progress can continue
> and repair the failed mirror.

Async read is not the only problem here - we have other issues:

i.e. activate mirror - and wait for confirmation  (dmsetup udevcomplete)
but this may also run watch rule - and also  blkid may get blocked (mirror error)

So now we get into fancy states - where  our command is waiting for
semaphore completion (no timeout on semaphore for now) - which doesn't happen 
since master udev kills its udev scan completely  - without any 'finalization' 
step.

So - we would need to probably make a mirror device also 'unscannable' ??
(which makes it unusable for filesystems??)

Anyway - more troubles ahead....

Zdenek



