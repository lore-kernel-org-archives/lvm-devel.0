From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 19 Oct 2009 19:41:10 -0400
Subject: [PATCH] Never activate hidden volumes directly in vgchange.
In-Reply-To: <4ACF0FDF.7080705@redhat.com>
References: <4ACF0FDF.7080705@redhat.com>
Message-ID: <1255995670.2499.27.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-09 at 12:26 +0200, Milan Broz wrote:
> Never activate hidden volumes directly in vgchange.
> 
> All hidden (not visible) volumes should be activated through
> other visible volumes.
> 
> (There are already exceptions like snapshot, mirror log and image,
> which should be cleaned one day...)
> 
> This solves problems for future types of hidden volumes,
> which can have special meaning and must not be activated implicitly
> (e.g. key store volume).
> 
> Signed-off-by: Milan Broz<mbroz@redhat.com>
> ---
>   tools/vgchange.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/vgchange.c b/tools/vgchange.c
> index 07d5262..9445263 100644
> --- a/tools/vgchange.c
> +++ b/tools/vgchange.c
> @@ -61,6 +61,9 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
>   	dm_list_iterate_items(lvl,&vg->lvs) {
>   		lv = lvl->lv;
> 
> +		if (!lv_is_visible(lv))
> +			continue;
> +
>   		/* Only request activation of snapshot origin devices */
>   		if ((lv->status&  SNAPSHOT) || lv_is_cow(lv))
>   			continue;
> 
> 

Ack.  Why not remove the redundant check(s) such as mirror log, etc
along with this patch?


