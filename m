From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:39:04 +0100
Subject: [PATCH 15/22] Replicator: activate checks for missing vgs
In-Reply-To: <63d547b05e12868836f3c54eaf20ad01bce1552e.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<63d547b05e12868836f3c54eaf20ad01bce1552e.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426143904.GS23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:43PM +0200, Zdenek Kabelac wrote:
> Activation needs to have all remote VGs locked to pass for replicator.
 
> -	if (lv)
> +	if (lv) {
> +		lv_release_replicator_vgs(lv);
>  		vg_release(lv->vg);

Perhaps vg_release() should be sufficient here on its own?
- If other VGs are linked of it, they must necessarily also be released without the
caller needing to specify that explicitly?

Alasdair


