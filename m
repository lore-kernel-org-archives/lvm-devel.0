From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Mar 2013 15:12:59 +0100
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <1363212806-16025-4-git-send-email-tasleson@redhat.com>
References: <1363212806-16025-1-git-send-email-tasleson@redhat.com>
	<1363212806-16025-4-git-send-email-tasleson@redhat.com>
Message-ID: <5141DAEB.8080902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.3.2013 23:13, Tony Asleson napsal(a):
> Moved to allow use from command line and for library use.
>
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/metadata/lv_manip.c          | 734 +++++++++++++++++++++++++++++++++++++
>   lib/metadata/metadata-exported.h |  46 +++
>   tools/lvresize.c                 | 771 ---------------------------------------
>   3 files changed, 780 insertions(+), 771 deletions(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index ad8160e..5baa9b3 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> +	}
> +
> +	*stripesize = 0;
> +	return 0;
> +}
> +
> +int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
> +		     struct lvresize_params *lp, struct dm_list *pvh)
> +{

Non-internal -> remove '_' ->  ???_lvresize

we should probably introduce some tool prefix to make it recognizable

> -	}
> -
> -	return ECMD_PROCESSED;
> -}
> -
>   int lvresize(struct cmd_context *cmd, int argc, char **argv)
>   {
>   	struct lvresize_params lp = { 0 };
>

to remove conflict from this place.

Zdenek


