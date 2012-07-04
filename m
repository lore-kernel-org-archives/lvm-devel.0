From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 13:29:50 +0100
Subject: master - RAID: Fix extending size of RAID 4/5/6 logical volumes.
In-Reply-To: <20120704045302.ECBDF113F@lists.fedorahosted.org>
References: <20120704045302.ECBDF113F@lists.fedorahosted.org>
Message-ID: <20120704122950.GG22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 04:53:02AM +0000, Jonathan Brassow wrote:
> Reducing a RAID 4/5/6 LV or extending it with a different number of
> stripes is still not implemented.  This patch covers the "simple" case
> where the LV is extended with the same number of stripes as the orginal.

For now, we only need to support this 'simple' case.

Attempts at the complex case (i.e. multiple segments in a raid LV) should just
give an error message.  (We can consider how to tackle that some other time.)

Alasdair


