From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 25 Oct 2010 02:00:31 +0100
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <20101024005515.GA31723@redhat.com>
References: <20101024005515.GA31723@redhat.com>
Message-ID: <20101025010031.GA26942@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Oct 23, 2010 at 08:55:15PM -0400, Mike Snitzer wrote:
> any device using the error target shouldn't be scanned.
 
I disagree with that:)
Scanning an error target does not cause the system to lock up so, in general,
there's no reason not to scan it.
(Remember that the error target might only be used in 1 out of hundreds
of table lines and that loop - as you'd expect for the current uses - skips the
device if *any* target matches.)

The defining characteristic here is surely that the device is no longer
meant to be available for mounting - no longer visible, in other words.
So you may (for now) need a more specific test that's limited
to snapshot merge.

Alasdair


