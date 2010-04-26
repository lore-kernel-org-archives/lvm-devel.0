From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 22:59:39 +0100
Subject: [PATCH] LVM2: Proposal #1 to fix bug 586021
In-Reply-To: <1272318274.29386.29.camel@hydrogen.msp.redhat.com>
References: <1272318274.29386.29.camel@hydrogen.msp.redhat.com>
Message-ID: <20100426215939.GU23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 26, 2010 at 04:44:34PM -0500, Jon Brassow wrote:
> specified, only those images can be used for removal.  However, when
> more images are specified for removal than PVs given to satisfy the
> request, things become somewhat ambiguous.  The buggy code that existed
> prior to the fix for 581611 would take a hybrid approach to the problem
> - ensuring the specified PVs where among those removed, but satisfying
> the balance of the request from the remaining unspecified PVs.  It has
> been assumed that this was the designed behavior, 

That was the intended behaviour: all PVs specified should be removed.
If any specified are not removed (e.g. due to a conflict with the
-m parameter), then you get the error message:

> Messages like 'remove_mirror_images()log_error("%u images are removed
> out of requested %u."...)' and other logic in the code seem to suggest
> that this is /not/ the desired behavior.

But the previous behaviour *was* inconsistent - either the command
should have changed nothing and given the error, or it should have
just given a warning level message, not an error.
 
Alasdair


