From: Petr Rockai <prockai@redhat.com>
Date: Wed, 08 Apr 2009 01:20:07 +0200
Subject: [PATCH 4/6] vg mempool: fix archiver code
In-Reply-To: <49D9BE34.4010308@redhat.com> (Milan Broz's message of "Mon, 06
	Apr 2009 10:32:52 +0200")
References: <49D9BE34.4010308@redhat.com>
Message-ID: <87skkk9hlk.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Properly release VG memory pool in archiver code.
>
> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Ro?kai <prockai@redhat.com>

Please also see inline comments below.

> diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
> index 3e5b0c4..0077f14 100644
> --- a/lib/format_text/archive.c
> +++ b/lib/format_text/archive.c
> @@ -326,7 +326,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
>  	log_print("Description:\t%s", desc ? : "<No description>");
>  	log_print("Backup Time:\t%s", ctime(&when));
>  
> -	dm_pool_free(cmd->mem, vg);
> +	vg_release(vg);
Check. Actually looks much more robust. While looking through the code, I have
noticed that there is likely still a leak in there though, since
create_text_context will call dm_pool_alloc/dm_pool_strdup a few times. If I
understand dm_pool_free correctly, this only frees the part of the pool from
the "vg" pointer till end of the pool, so the leak has been there even
before. You might want to fix that by calling dm_pool_free(cmd->mem, context)
besides the vg_release. (This all needs double-checking though.)

>  	tf->fmt->ops->destroy_instance(tf);
>  }
>  
> diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
> index e221500..61d2441 100644
> --- a/lib/format_text/archiver.c
> +++ b/lib/format_text/archiver.c
> @@ -326,6 +326,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
>  			     const char *file)
>  {
>  	struct volume_group *vg;
> +	int r = 0;
>  
>  	/*
>  	 * Read in the volume group from the text file.
> @@ -336,10 +337,11 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
>  	/*
>  	 * If PV is missing, there is already message from read above
>  	 */
> -	if (vg_missing_pv_count(vg))
> -		return_0;
> +	if (!vg_missing_pv_count(vg))
> +		r = backup_restore_vg(cmd, vg);
>  
> -	return backup_restore_vg(cmd, vg);
> +	vg_release(vg);
> +	return r;
Check.

>  }
>  
>  int backup_restore(struct cmd_context *cmd, const char *vg_name)
> @@ -414,12 +416,15 @@ void check_current_backup(struct volume_group *vg)
>  	    (vg->seqno == vg_backup->seqno) &&
>  	    (id_equal(&vg->id, &vg_backup->id))) {
>  		log_suppress(old_suppress);
> +		vg_release(vg_backup);
>  		return;
>  	}
>  	log_suppress(old_suppress);
>  
> -	if (vg_backup)
> +	if (vg_backup) {
>  		archive(vg_backup);
> +		vg_release(vg_backup);
> +	}
>  	archive(vg);
>  	backup(vg);
>  }
Check.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


