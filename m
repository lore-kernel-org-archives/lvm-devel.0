From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 23:06:58 +0100
Subject: [PATCH] LVM2: Proposal #2 to fix bug 586021
In-Reply-To: <1272318287.29386.30.camel@hydrogen.msp.redhat.com>
References: <1272318287.29386.30.camel@hydrogen.msp.redhat.com>
Message-ID: <20100426220657.GV23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 26, 2010 at 04:44:47PM -0500, Jon Brassow wrote:
> This patch - in contrast to the first proposal - takes the approach that
> the behavior to remove images from a mirror that were not specified when
> a list of PVs was given is wrong.  The code was not adequately prepared
> for this behavior change and was therefore buggy.  This patch tries to
> keep the behavior change and clean-up the bugs.
 
The problem with this approach is that the user has then to include
*all* extents covered by the mimages being removed, and *no* extents
covered by mimages not to be removed.  (Hybrids turn out just as
awkward.)

No problem when you have one mimage per PV, but as soon as you've got
more complex layouts this form of syntax becomes much less forgiving
and harder to use and understand than proposal #1 IMHO.

Alasdair


