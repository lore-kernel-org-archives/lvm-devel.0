From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2013 10:22:06 +0200
Subject: [PATCH 1/2] lvm2app: Add function to retrieve the origin.
In-Reply-To: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
References: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
Message-ID: <5167C42E.4000407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.4.2013 22:58, Tony Asleson napsal(a):
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   liblvm/lvm2app.h | 16 ++++++++++++++++
>   liblvm/lvm_lv.c  |  5 +++++
>   2 files changed, 21 insertions(+)
>
> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> index 15827ac..369c300 100644
> --- a/liblvm/lvm2app.h
> +++ b/liblvm/lvm2app.h
> @@ -1223,6 +1223,22 @@ const char *lvm_lv_get_name(const lv_t lv);
>   const char *lvm_lv_get_attr(const lv_t lv);
>
>   /**
> + * Get the origin of a snapshot.
> + *
> + * \memberof lv_t
> + *
> + * The memory allocated for the name is tied to the vg_t handle and will be
> + * released when lvm_vg_close() is called.
> + *
> + * \param   lv
> + * Logical volume handle.
> + *
> + * \return
> + * Null if the logical volume is not a snapshot, else origin name.
> + */
> +const char *lvm_lv_get_origin(const lv_t lv);
> +
> +/**
>    * Get the current size in bytes of a logical volume.
>    *
>    * \memberof lv_t
> diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
> index 9d3ae79..f244a60 100644
> --- a/liblvm/lvm_lv.c
> +++ b/liblvm/lvm_lv.c
> @@ -53,6 +53,11 @@ const char *lvm_lv_get_attr(const lv_t lv)
>   	return lv_attr_dup(lv->vg->vgmem, lv);
>   }
>
> +const char *lvm_lv_get_origin(const lv_t lv)
> +{
> +	return lv_origin_dup(lv->vg->vgmem, lv);
> +}
> +

If you need just 'const' pointer - it would be probably better,
to directly return the name - instead of duplication.

i.e. lv_origin_dup() ->  rewrite to  'const char *lv_get_origin(.)' ->
and use it for  lv_name_dup() in lv_origin_dup() which returns char *.
as well as for  lvm_lv_get_origin().



>   struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
>   {
>   	return get_property(NULL, NULL, lv, NULL, NULL, name);
>


Zdenek


