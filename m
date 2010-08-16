From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Aug 2010 17:53:44 +0100
Subject: [PATCH 3 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
In-Reply-To: <1281911721.30206.11.camel@hydrogen.msp.redhat.com>
References: <1281911721.30206.11.camel@hydrogen.msp.redhat.com>
Message-ID: <20100816165344.GG11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Aug 15, 2010 at 05:35:21PM -0500, Jon Brassow wrote:
> At the moment, I've tried to minimize my changes by detecting which
> type of suspend is necessary based on whether the mirror is being
> altered (and if it is progressing from PARTIAL_LV to !PARTIAL_LV).
> Upon resuming, I simply detect if the origin is not suspended, while
> the mirror it rests on is suspended.  So, while this solution works,
> it is somewhat incomplete because it does not run up the stack and
> become available to any API.
 
I'd rather see this specified explicitly: The code that initiates
the sequence should know if it's trying to process the origin or
the device under the origin and it should pass that information
through.

> +static int _lv_activate_lv_bypass_origin(struct logical_volume *lv)

I don't think we need new cloned internal functions - just add another
parameter.  I think that makes for a smaller and simpler patch.

> @@ -49,6 +49,7 @@ struct dev_manager {
> +	int bypass_origin;
  
Wonder how that's defined precisely in the general case.
Maybe it's bypass_top_origin - and is that struct the right place to store it?
And is it only bypassing it for certain operations, not all of them?

I'm worrying that this patch still feels too large (I don't count any parameter
changes in its size) for what it's trying to do.

Alasdair


