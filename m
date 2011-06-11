From: Joe Thornber <thornber@redhat.com>
Date: Sat, 11 Jun 2011 08:49:08 +0100
Subject: LVM vs. Ext4 snapshots (was: [PATCH v1 00/30] Ext4 snapshots)
In-Reply-To: <BANLkTikUZadpVJRcfX_MLMZ-p_G0bT_8uQ@mail.gmail.com>
References: <BANLkTimyBGfg4+ovGsiGqpCz345qVmU_7A@mail.gmail.com>
	<BANLkTik20iYN4c9faKD9dzerehazWTwTFw@mail.gmail.com>
	<BANLkTikKRuPu_NX49vr0w-XeN0ZnWo+9vg@mail.gmail.com>
	<alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
	<20110610101142.GA10144@ubuntu>
	<BANLkTi=zjU3-FV3AVpYsknzKFgaS7byb_Q@mail.gmail.com>
	<20110610150129.GA17585@ubuntu>
	<BANLkTikUZadpVJRcfX_MLMZ-p_G0bT_8uQ@mail.gmail.com>
Message-ID: <20110611074908.GC2517@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Jun 11, 2011 at 07:01:36AM +0300, Amir G. wrote:
> OK. Now I am convinced that there is no I/O ordering issue,
> since you are never overwriting shared data in-place.
> 
> Now I also convinced that the origin will be so heavily fragmented,
> to the point that the solution will not be practical for performance
> sensitive applications. Specifically, applications that use spinning
> media storage and require consistent and predictable performance.

I am also convinced multisnap wont be suitable for every use case.  I
want to be very careful to only advocate it for people with suitable
tasks.  Over time I'm sure we'll broaden the suitable apps, for
example by tinkering with the allocator, or doing some preemptive
defrag.  It would be disappointing for everyone to write it off, just
because it isn't suitable for say high performance database apps.

The very simple allocator I'm using at the moment will try and place
new blocks together.  My hope is that past io patterns will be similar
to future ones.  So while the volumes will be fragmented, blocks for
the typical io access patterns will still be together.  Much more
experimentation is needed.

This is very early days for multisnap, the code is still changing.
Only a few people have run it.  For instance Lukas tested it on
Thursday and got some unexpectedly poor results.  I'm there'll be a
quick fix for it (eg, wrong cache size, too much disk seeking due to
the metadata and data volumes being at opposite ends of a spindle
device), but this shows that I need more people to play with it.

> I do have a crazy idea, though, how to combine the power of the
> multisnap features with the speed of a raw ext4 fs.

I need to think this through over the weekend.  The metadata interface
is pretty clean, so you could start by looking at that.  However I do
find this suggestion surprising.  My priority is block level
snapshots, if I can expose interfaces for you such that we share code
then that would be great.

- Joe


