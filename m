From: Milan Broz <mbroz@redhat.com>
Date: Thu, 26 Aug 2010 10:17:56 +0200
Subject: [PATCH] Fix zombie mirror poll daemon (bug 585328)
In-Reply-To: <1282772027.18079.3.camel@hydrogen.msp.redhat.com>
References: <1282772027.18079.3.camel@hydrogen.msp.redhat.com>
Message-ID: <4C762334.8060403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/25/2010 11:33 PM, Jonathan Brassow wrote:
> -	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
> +	if (!(lv->status & MIRRORED) ||
> +	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
>  			       &percent_range, &event_nr) ||
>  	    (percent_range == PERCENT_INVALID)) {
>  		log_error("ABORTING: Mirror percentage check failed.");

why not move this check inside lv_mirror_percent?
(or is this only place where the bug can appear?)

(and it should probably use !lv_is_mirrored(lv) instead of mask)

otherwise ack

Milan


