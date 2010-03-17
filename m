From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Mar 2010 11:17:12 +0100
Subject: [PATCH] Avoid scanning all pvs in the system if pvcreating on a device with mdas.
In-Reply-To: <1268778829-18908-1-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Tue, 16 Mar 2010 18:33:49 -0400")
References: <1268778829-18908-1-git-send-email-dwysocha@redhat.com>
Message-ID: <87r5nj8d7b.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> Other areas of the code check whether there are mdas on an orphan pv before
> doing the expensive scan of the system.  This patch adds this check to pvcreate
> as well, and so will avoid the unnecessary scan if pvcreate on a device that
> is an orphan PV.
Looks OK to me. As far as I can tell, it should never happen that the
metadata is out-of-date and we overwrite a non-orphan PV mistakenly.

This would require that the metadata on the PV claim this is an orphan
but a newer copy of the metadata elsewhere claims this is part of a
VG. That would mean that vgextend (or similar) failed to update the
metadata on the new PV, which would presumably lead to overall vgextend
failure and no new metadata on the pre-existing PVs either. So this
should be safe.

> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 2cab0b6..fff7a61 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -1254,11 +1254,14 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
>  	struct device *dev;
>  	uint64_t md_superblock, swap_signature;
>  	int wipe_md, wipe_swap;
> +	struct dm_list mdas;
> +
> +	dm_list_init(&mdas);
>  
>  	/* FIXME Check partition type is LVM unless --force is given */
>  
>  	/* Is there a pv here already? */
> -	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
> +	pv = pv_read(cmd, name, &mdas, NULL, 0, 0);
>  
>  	/*
>  	 * If a PV has no MDAs it may appear to be an orphan until the
> @@ -1266,7 +1269,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
>  	 * this means checking every VG by scanning every PV on the
>  	 * system.
>  	 */
> -	if (pv && is_orphan(pv)) {
> +	if (pv && is_orphan(pv) && !dm_list_size(&mdas)) {
>  		if (!scan_vgs_for_pvs(cmd))
>  			return_0;
>  		pv = pv_read(cmd, name, NULL, NULL, 0, 0);

ACK.

Yours,
   Petr.


