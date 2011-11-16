From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 16 Nov 2011 10:59:53 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87ehx8xv43.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
Message-ID: <20111116105953.GD3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 16, 2011 at 10:41:16AM +0100, Peter Rockai wrote:
> See above, and my previous mail as well. This is *not* a problem (and
> most definitely not _the_ problem). This is all about multiple
> "events". Only that we do not get any actual events from the kernel, so
> we poll every ten seconds. And to avoid actually running lvresize every
> 10 seconds, we cache the outcome of the last check and only re-run
> lvresize if things "changed" from the last time.

I don't see why the outcome of lvextend matters provided that one lvextend
is always sufficient to bring it back within bounds.  All that should matter
to the algorithm is the change in space used since the last check.

I still think:

- a minimum size needs to be passed into lvextend (to avoid repeated calls if
there is rapid growth or if snapshot_autoextend_threshold was set too small)

- the trigger logic needs improving and needs to take account of the actual
space used as well as the percentage (and set the mininum extension size
appropriately)
 
Alasdair


