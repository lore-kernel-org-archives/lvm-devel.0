From: Petr Rockai <prockai@redhat.com>
Date: Fri, 13 Aug 2010 12:54:15 +0200
Subject: [PATCH] Bug 612291: Fix splitmirrors in cluster.
In-Reply-To: <1281652261.16190.5.camel@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Thu, 12 Aug 2010 17:30:57 -0500")
References: <1281652261.16190.5.camel@hydrogen.msp.redhat.com>
Message-ID: <87pqxm9414.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

looks OK, on the assumption that the devices still do get correctly
renamed by DM upon activation.

Jonathan Brassow <jbrassow@redhat.com> writes:

> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Reviewed-By: Petr Rockai <prockai@redhat.com>

> Index: LVM2/lib/metadata/mirror.c
> ===================================================================
> --- LVM2.orig/lib/metadata/mirror.c
> +++ LVM2/lib/metadata/mirror.c
> @@ -719,19 +719,8 @@ static int _split_mirror_images(struct l
>  		return 0;
>  	}
>  
> -	/*
> -	 * Suspend the newly split-off LV (balance memlock count
> -	 * and prepare for DM automated renaming via resume).
> -	 */
> -	if (!suspend_lv(lv->vg->cmd, new_lv)) {
> -		log_error("Failed to lock newly split LV, %s", new_lv->name);
> -		vg_revert(lv->vg);
> -		return 0;
> -	}
> -
>  	/* Bring newly split-off LV into existence */
> -	log_very_verbose("Creating %s", new_lv->name);
> -	if (!resume_lv(lv->vg->cmd, new_lv)) {
> +	if (!activate_lv(lv->vg->cmd, new_lv)) {
>  		log_error("Failed to activate newly split LV, %s",
>  			  new_lv->name);
>  		return 0;
>

Yours,
   Petr.


