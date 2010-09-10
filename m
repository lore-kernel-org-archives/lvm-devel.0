From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 10 Sep 2010 11:38:03 +0200
Subject: [PATCH 05/12] Add pv_uuid, vg_uuid, and lv_uuid, and call id_format_and_copy.
In-Reply-To: <1284063189-4908-6-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
	<1284063189-4908-6-git-send-email-dwysocha@redhat.com>
Message-ID: <4C89FC7B.7030801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.9.2010 22:13, Dave Wysochanski napsal(a):
> Add supporting functions for pv_uuid, vg_uuid, and lv_uuid.
> Call new function id_format_and_copy.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  lib/metadata/metadata.c |   15 +++++++++++++++
>  lib/metadata/metadata.h |    3 +++
>  liblvm/lvm_lv.c         |   10 ++--------
>  liblvm/lvm_pv.c         |   10 ++--------
>  liblvm/lvm_vg.c         |    8 +-------
>  5 files changed, 23 insertions(+), 23 deletions(-)
> 
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 86f07e7..6fb69dc 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -4619,6 +4619,21 @@ char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv)
>  	return repstr;
>  }
>  
> +char *pv_uuid(struct physical_volume *pv)
> +{
> +	return id_format_and_copy(pv->vg->vgmem, &pv->id);
> +}
> +
> +char *vg_uuid(struct volume_group *vg)
> +{
> +	return id_format_and_copy(vg->vgmem, &vg->id);
> +}
> +
> +char *lv_uuid(struct logical_volume *lv)
> +{
> +	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
> +}
> +
>  static int _lv_mimage_in_sync(const struct logical_volume *lv)
>  {
>  	float percent;
> diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
> index 1749f85..4eb826a 100644
> --- a/lib/metadata/metadata.h
> +++ b/lib/metadata/metadata.h
> @@ -422,5 +422,8 @@ uint64_t vg_mda_free(const struct volume_group *vg);
>  char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv);
>  char *vg_attr(struct dm_pool *mem, const struct volume_group *vg);
>  char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
> +char *lv_uuid(struct logical_volume *lv);
> +char *vg_uuid(struct volume_group *vg);
> +char *pv_uuid(struct physical_volume *pv);

Again - 'const'for *lv, *vg, *pv  would fit here probably better.

>  const char *lvm_lv_get_uuid(const lv_t lv)
>  {
> -	char uuid[64] __attribute__((aligned(8)));
> -
> -	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {


Probably not a big issue, but I can see some 'inconsistency' -

It looks like we have put 'const' on this return value to mark value as a
string which user should not try to 'free' - but this is somewhat missuse of
'const'  - there is probably no reason to avoid modification of copied string.
As we do not keep it internally - it just allocated string and user should be
able to do anything he wants to do with it.

Maybe we should reconsider and relax this return values to plain char*.

Zdenek


