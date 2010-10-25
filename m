From: Mike Snitzer <snitzer@redhat.com>
Date: Sun, 24 Oct 2010 21:23:04 -0400
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <20101025010031.GA26942@agk-dp.fab.redhat.com>
References: <20101024005515.GA31723@redhat.com>
	<20101025010031.GA26942@agk-dp.fab.redhat.com>
Message-ID: <20101025012304.GA5698@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 24 2010 at  9:00pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Sat, Oct 23, 2010 at 08:55:15PM -0400, Mike Snitzer wrote:
> > any device using the error target shouldn't be scanned.
>  
> I disagree with that:)
> Scanning an error target does not cause the system to lock up so, in general,
> there's no reason not to scan it.
> (Remember that the error target might only be used in 1 out of hundreds
> of table lines and that loop - as you'd expect for the current uses - skips the
> device if *any* target matches.)
> 
> The defining characteristic here is surely that the device is no longer
> meant to be available for mounting - no longer visible, in other words.
> So you may (for now) need a more specific test that's limited
> to snapshot merge.

What about skipping a dm device whose table only has a single error
target?

Anyway... guess I need to back this change out and have another look.

Mike


