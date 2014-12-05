From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 5 Dec 2014 09:47:39 -0500
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <20141204153358.GA19315@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com>
Message-ID: <20141205144739.GA26356@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 04 2014 at 10:33am -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> From: Mike Snitzer <snitzer@redhat.com>
> Date: Thu, 4 Dec 2014 10:18:32 -0500
> Subject: [PATCH] dm thin: optimize away writing all zeroes to unprovisioned blocks
> 
> Introduce bio_is_zero_filled() and use it to optimize away writing all
> zeroes to unprovisioned blocks.  Subsequent reads to the associated
> unprovisioned blocks will be zero filled.
> 
> Signed-off-by: Mike Snitzer <snitzer@redhat.com>
> Cc: Eric Wheeler <ewheeler@ewheeler.net>
> Cc: Jens Axboe <axboe@kernel.dk>

In testing this patch it is now quite clear that this change seriously
impacts test coverage in the device-mapper-test-suite because dmts'
wipe_device() uses /dev/zero as the ifile for dd to write to the disk.
As such, with this patch all tests expecting to see provisioned blocks
as a side-effect of wipe_device now fail (e.g. DiscardQuickTests).

So this change won't go upstream until full test coverage can be
restored in dmts.  I'll see what I can come up with but it is low
priority.

BTW, this also makes me wonder if this change will be extremely
unintuitive to existing or future user of DM thinp.  So much so that it
might be best to require a new thin-pool feature flag to enable this
optimization.

Mike


