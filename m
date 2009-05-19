From: Petr Rockai <prockai@redhat.com>
Date: Tue, 19 May 2009 10:18:23 +0200
Subject: [PATCH] add error message if vgcfg fails because og missing PVs
In-Reply-To: <4A0D5471.4050307@redhat.com> (Milan Broz's message of "Fri, 15
	May 2009 13:39:29 +0200")
References: <4A0D5471.4050307@redhat.com>
Message-ID: <87ab59bj5c.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>

> diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
> index 5362adb..d80c0ba 100644
> --- a/lib/format_text/archiver.c
> +++ b/lib/format_text/archiver.c
> @@ -335,7 +335,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
>  			     const char *file)
>  {
>  	struct volume_group *vg;
> -	int r = 0;
> +	int missing_pvs, r = 0;
>  
>  	/*
>  	 * Read in the volume group from the text file.
> @@ -343,11 +343,12 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
>  	if (!(vg = backup_read_vg(cmd, vg_name, file)))
>  		return_0;
>  
> -	/*
> -	 * If PV is missing, there is already message from read above
> -	 */
> -	if (!vg_missing_pv_count(vg))
> +	missing_pvs = vg_missing_pv_count(vg);
> +	if (missing_pvs == 0)
>  		r = backup_restore_vg(cmd, vg);
> +	else
> +		log_error("Cannot restore Volume Group %s with %i PVs "
> +			  "marked as missing.", vg->name, missing_pvs);
>  
>  	vg_release(vg);
>  	return r;

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


