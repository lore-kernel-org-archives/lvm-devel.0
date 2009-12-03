From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 03 Dec 2009 12:15:54 -0500
Subject: [PATCH] Print error if VG already exist.
In-Reply-To: <1259850701-32101-1-git-send-email-mbroz@redhat.com>
References: <1259850701-32101-1-git-send-email-mbroz@redhat.com>
Message-ID: <1259860554.2283.0.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-12-03 at 15:31 +0100, Milan Broz wrote:
> This test have to be moved because of new vg read error handling.
> 
> Signed-off-by: Milan Broz <mbroz@redhat.com>
> ---
>  tools/vgcreate.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/vgcreate.c b/tools/vgcreate.c
> index b1b0c63..8aef7a2 100644
> --- a/tools/vgcreate.c
> +++ b/tools/vgcreate.c
> @@ -55,8 +55,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
>  
>  	/* Create the new VG */
>  	vg = vg_create(cmd, vp_new.vg_name);
> -	if (vg_read_error(vg))
> -		goto_bad;
> +	if (vg_read_error(vg)) {
> +		if (vg_read_error(vg) == FAILED_EXIST)
> +			log_error("A volume group called %s already exists.", vp_new.vg_name);
> +		else
> +			log_error("Can't get lock for %s", vp_new.vg_name);
> +		goto bad;
> +	}
>  
>  	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
>  	    !vg_set_max_lv(vg, vp_new.max_lv) ||

Ack.

Some more cleanup probably warranted but another time and there are
already FIXMEs in the code.


