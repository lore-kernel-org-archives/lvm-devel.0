From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 18:47:30 +0100
Subject: [PATCH 18/23] Return PERCENT_INVALID for error case
In-Reply-To: <988f227f76fc6371eeed50b7120887c701a582d2.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<988f227f76fc6371eeed50b7120887c701a582d2.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10E832.2090801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> +	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
> +			   0, &perc, NULL))
> +		perc = PERCENT_INVALID;
> +	return perc;

dunno, these functions returns 0 if (!activation()) and if lv is not activated
 is the PERCENT_INVALID (-1) correct value here?

But it is apparent bug, it returns undefined value in API now.

Milan


