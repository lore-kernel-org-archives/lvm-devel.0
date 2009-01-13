From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 13 Jan 2009 14:52:35 -0500
Subject: [PATCH 10/11] Convert vgsplit to use vg_read_for_update.
In-Reply-To: <1231769286-15534-11-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
	<1231769286-15534-5-git-send-email-prockai@redhat.com>
	<1231769286-15534-6-git-send-email-prockai@redhat.com>
	<1231769286-15534-7-git-send-email-prockai@redhat.com>
	<1231769286-15534-8-git-send-email-prockai@redhat.com>
	<1231769286-15534-9-git-send-email-prockai@redhat.com>
	<1231769286-15534-10-git-send-email-prockai@redhat.com>
	<1231769286-15534-11-git-send-email-prockai@redhat.com>
Message-ID: <1231876356.5073.54.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2009-01-12 at 15:08 +0100, Petr Rockai wrote:
> Fri Jan  9 15:47:09 CET 2009  Petr Rockai <me@mornfall.net>
>   * Convert vgsplit to use vg_read_for_update.
> diff -rN -u -p old-lvmlib_apply/tools/vgsplit.c new-lvmlib_apply/tools/vgsplit.c
> --- old-lvmlib_apply/tools/vgsplit.c	2009-01-12 14:56:01.263018781 +0100
> +++ new-lvmlib_apply/tools/vgsplit.c	2009-01-12 14:56:01.355015599 +0100
> @@ -320,21 +320,20 @@ int vgsplit(struct cmd_context *cmd, int
>  	}
>  
>  	log_verbose("Checking for volume group \"%s\"", vg_name_from);
> -	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
> -				       CLUSTERED | EXPORTED_VG |
> -				       RESIZEABLE_VG | LVM_WRITE,
> -				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
> -		 return ECMD_FAILED;
> +	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
> +				     REQUIRE_RESIZEABLE);
> +	if (vg_read_error(vg_from))
> +		return ECMD_FAILED;
>  
>  	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
> -	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
> -		log_error("Can't get lock for %s", vg_name_to);
> -		unlock_vg(cmd, vg_name_from);
> -		return ECMD_FAILED;
> -	}
> +	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, REQUIRE_RESIZEABLE |
> +				   NONBLOCKING_LOCK | KEEP_LOCK |
> +				   EXISTENCE_CHECK);
> +
> +	if (vg_read_error(vg_to))
> +		goto_bad;
>  
> -	consistent = 0;
> -	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
> +	if (vg_might_exist(vg_to)) {
>  		existing_vg = 1;
>  		if (new_vg_option_specified(cmd)) {
>  			log_error("Volume group \"%s\" exists, but new VG "
> @@ -450,12 +449,14 @@ int vgsplit(struct cmd_context *cmd, int
>  	 * Finally, remove the EXPORTED flag from the new VG and write it out.
>  	 */
>  	consistent = 1;

You can also remove consistent here and in the declaration.

> -	if (!test_mode() &&
> -	    (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
> -	     !consistent)) {
> -		log_error("Volume group \"%s\" became inconsistent: please "
> -			  "fix manually", vg_name_to);
> -		goto_bad;
> +	if (!test_mode()) {
> +		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
> +					   DISABLE_LOCK | ALLOW_EXPORTED);
> +		if (vg_read_error(vg_to)) {
> +			log_error("Volume group \"%s\" became inconsistent: "
> +				  "please fix manually", vg_name_to);
> +			goto_bad;
> +		}
>  	}
>  
>  	vg_to->status &= ~EXPORTED_VG;
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


