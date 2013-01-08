From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 08 Jan 2013 11:37:09 +0100
Subject: [PATCH 1/3] lvm2app: Implementation of pv resize (v4)
In-Reply-To: <1357592534-14672-1-git-send-email-tasleson@redhat.com>
References: <1357592534-14672-1-git-send-email-tasleson@redhat.com>
Message-ID: <50EBF6D5.200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.1.2013 22:02, Tony Asleson napsal(a):
> Patch correctly checks for update lock before allowing
> resize to process and also requires lvm_vg_write to
> make changes persistent.  As the API does not allow the
> re-size of a orphaned pv this is accomplished through
> the existing vg_write, vg_commit sequence which is done
> in lvm_vg_write.
>
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/metadata/metadata-exported.h |  8 +++++--
>   lib/metadata/pv_manip.c          | 48 +++++++++++++++++++++++++++++++++++++++-
>   liblvm/lvm2app.h                 |  5 +++--
>   liblvm/lvm_pv.c                  | 21 ++++++++++++++----
>   tools/pvresize.c                 | 26 +---------------------
>   5 files changed, 74 insertions(+), 34 deletions(-)
>
> diff --git a/tools/pvresize.c b/tools/pvresize.c
> index 2f0693a..abf8432 100644
> --- a/tools/pvresize.c
> +++ b/tools/pvresize.c
> @@ -30,7 +30,6 @@ static int _pv_resize_single(struct cmd_context *cmd,
>   			     const uint64_t new_size)
>   {
>   	struct pv_list *pvl;
> -	uint64_t size = 0;
>   	int r = 0;
>   	const char *pv_name = pv_dev_name(pv);
>   	const char *vg_name = pv_vg_name(pv);
> @@ -70,33 +69,10 @@ static int _pv_resize_single(struct cmd_context *cmd,
>   			goto out;
>   	}
>
> -	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
> -		log_error("Physical volume %s format does not support resizing.",
> -			  pv_name);
> -		goto out;
> -	}
> -
> -	/* Get new size */
> -	if (!dev_get_size(pv_dev(pv), &size)) {
> -		log_error("%s: Couldn't get size.", pv_name);
> +	if( !pv_resize(cmd, vg, pv, new_size)) {
>   		goto out;
>   	}
>

To get nicer backtrace logging -  goto_out;

Zdenek



