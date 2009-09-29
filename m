From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 29 Sep 2009 21:44:20 +0100
Subject: [PATCH 4/4] Move activation of background polling processes to a common function.
In-Reply-To: <1254237777-30501-5-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
	<1254237777-30501-5-git-send-email-snitzer@redhat.com>
Message-ID: <20090929204420.GS5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29, 2009 at 11:22:57AM -0400, Mike Snitzer wrote:
> Move activation of background polling processes to a common function.
> Avoids code duplication and fixes an associated where vgchange would
> only restart pvmove and _not_ lvconvert (lvchange would restart
> both).
 
Applied, but I've retained the more-efficient version for pvmove for
vgchange: when you know you are looping through all the LVs in the VG
you can skip the normal (LOCKED) LVs which are being moved and trigger
from the PVMOVE ones that perform the pvmove.  As lvchange might only
be processing a single LV, you can't do that.

Alasdair


