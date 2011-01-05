From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:33:58 +0000
Subject: [PATCH 18/23] Return PERCENT_INVALID for error case
In-Reply-To: <4D10E832.2090801@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<988f227f76fc6371eeed50b7120887c701a582d2.1292945707.git.zkabelac@redhat.com>
	<4D10E832.2090801@redhat.com>
Message-ID: <20110105023358.GT10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 06:47:30PM +0100, Milan Broz wrote:
> On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> > +	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
> > +			   0, &perc, NULL))
> > +		perc = PERCENT_INVALID;
> > +	return perc;
> 
> dunno, these functions returns 0 if (!activation()) and if lv is not activated
>  is the PERCENT_INVALID (-1) correct value here?

Seems a reasonable use of this.

Ack (current code is definitely wrong) pending a review of whether all
the code is making best use of the values of the new percent type.
 
Alasdair


