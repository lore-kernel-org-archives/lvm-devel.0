From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 1 Oct 2009 01:42:00 +0100
Subject: [PATCH 1/2] Avoid depending on comparison of floating-point values.
In-Reply-To: <1254236202-30381-2-git-send-email-snitzer@redhat.com>
References: <1254236202-30381-1-git-send-email-snitzer@redhat.com>
	<1254236202-30381-2-git-send-email-snitzer@redhat.com>
Message-ID: <20091001004200.GY5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29, 2009 at 10:56:41AM -0400, Mike Snitzer wrote:
> TARGET_STATUS_ERROR --- error occured
> TARGET_STATUS_INVALIDATED --- the snapshot is invalidated (there may still exist
> 	100% filled snapshot that is not invalidated)
> TARGET_STATUS_PROCESSING --- mirror is resynchronizing, snapshot is neither
> 	empty nor invalidated.
> TARGET_STATUS_FINISHED --- finished. For mirrors, it is returned when the mirror
> 	resynchronization finished. For snapshots, it is returned when the
> 	snapshot contains no exceptions (merging finished).

I've done this as a new percent_range_t enum, reporting whether the
percentage is 0, 100, or between those two and leaving it to the caller
to interpret what the percentage means (e.g. finished) in each
particular context.  I've not checked all the code paths so more
tweaking could be required.

In the snapshot case, I'm expecting we can define PERCENT_0 to ignore
the header stored in the cow.

Alasdair


