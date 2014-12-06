From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Sat, 6 Dec 2014 14:36:27 -0800 (PST)
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <20141205144739.GA26356@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com>
	<20141205144739.GA26356@redhat.com>
Message-ID: <alpine.DEB.2.02.1412061434080.19773@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 5 Dec 2014, Mike Snitzer wrote:

> On Thu, Dec 04 2014 at 10:33am -0500,
> Mike Snitzer <snitzer@redhat.com> wrote:
> In testing this patch it is now quite clear that this change seriously
> impacts test coverage in the device-mapper-test-suite because dmts'
> wipe_device() uses /dev/zero as the ifile for dd to write to the disk.
> As such, with this patch all tests expecting to see provisioned blocks
> as a side-effect of wipe_device now fail (e.g. DiscardQuickTests).
>
> So this change won't go upstream until full test coverage can be
> restored in dmts.  I'll see what I can come up with but it is low
> priority.

Can dtms use /dev/urandom?

> BTW, this also makes me wonder if this change will be extremely
> unintuitive to existing or future user of DM thinp.  So much so that it
> might be best to require a new thin-pool feature flag to enable this
> optimization.

Good idea, some may wish to turn it off.  IMO, leaving it on by default 
would likely work for most use cases.

-Eric

> Mike
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


