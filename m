From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 10 Jul 2017 15:01:03 +0200
Subject: [PATCH 1/3] trivial: fix a comment mistake
In-Reply-To: <20170708171551.19421-1-zren@suse.com>
References: <20170708171551.19421-1-zren@suse.com>
Message-ID: <d74184c5-a474-f8ed-3131-fa7aa95a6f73@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.7.2017 v 19:15 Eric Ren napsal(a):
> Comments "the pool was originally inactive, deactivate it",
> should be "...orginally ative".
> 
> Signed-off-by: Eric Ren <zren@suse.com>
> ---
>   lib/metadata/lv_manip.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index fbe0aed..9a2548f 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -7310,7 +7310,7 @@ static int _vg_check_features(struct volume_group *vg,
>    * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
>    * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
>    *   If lp->activate is AY*, activate it.
> - *   If lp->activate was AN* and the pool was originally inactive, deactivate it.
> + *   If lp->activate is AN* and the pool was originally active, deactivate it.
>    */


Hi

Comment was correct here about preserving inactive state here.
Rest of patches were upstreamed...

Regards

Zdenek




