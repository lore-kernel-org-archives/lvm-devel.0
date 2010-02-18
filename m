From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 18 Feb 2010 10:05:13 +0100
Subject: [PATCH 6/8] Add lvm_vg_get_tags(), lvm_vg_add_tag(), and lvm_vg_remove_tag().
In-Reply-To: <1266427744-30327-7-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>	<1266427744-30327-5-git-send-email-dwysocha@redhat.com>	<1266427744-30327-6-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-7-git-send-email-dwysocha@redhat.com>
Message-ID: <4B7D02C9.3000307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 17.2.2010 18:29, Dave Wysochanski wrote:
> Add lvm2app functions to manage VG tags.
> For lvm_vg_get_tags(), we return a list of tags, similar to other
> functions that return lists.  An empty list is returned if there
> are no VG tags.  NULL is returned if there is a problem obtaining
> the list of tags.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  liblvm/.exported_symbols |    3 ++
>  liblvm/lvm2app.h         |   51 ++++++++++++++++++++++++++++++++++++++++++++-
>  liblvm/lvm_vg.c          |   34 ++++++++++++++++++++++++++++++
>  3 files changed, 86 insertions(+), 2 deletions(-)
> 
> diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
> index c184a88..7431248 100644
> --- a/liblvm/.exported_symbols
> +++ b/liblvm/.exported_symbols
> @@ -18,6 +18,7 @@ lvm_vg_get_extent_size
>  lvm_vg_get_extent_count
>  lvm_vg_get_free_extent_count
>  lvm_vg_get_pv_count
> +lvm_vg_get_tags
>  lvm_lv_activate
>  lvm_lv_deactivate
>  lvm_lv_get_uuid
> @@ -33,6 +34,8 @@ lvm_vg_write
>  lvm_vg_open
>  lvm_vg_close
>  lvm_vg_remove
> +lvm_vg_add_tag
> +lvm_vg_remove_tag
>  lvm_scan
>  lvm_errno
>  lvm_errmsg
> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> index 39bfff8..41ce18c 100644
> --- a/liblvm/lvm2app.h
> +++ b/liblvm/lvm2app.h
> @@ -159,10 +159,10 @@ typedef struct lvm_pv_list {
>   * Lists of these structures are returned by lvm_list_vg_names and
>   * lvm_list_vg_uuids.
>   */
> -struct lvm_str_list {
> +typedef struct lvm_str_list {
>  	struct dm_list list;
>  	const char *str;
> -};
> +} lvm_str_list_t;
>


Looks quite similar to 'struct str_list' from lib/datastruct/lvm-types.h ?
Are we going to replace old one with new version ?




>  /*************************** generic lvm handling ***************************/
>  /**
> @@ -458,6 +458,26 @@ int lvm_vg_extend(vg_t vg, const char *device);
>  int lvm_vg_reduce(vg_t vg, const char *device);
>  
>  /**
> + * Add/remove a tag to/from a VG.
> + *
> + * These functions require calling lvm_vg_write to commit the change to disk.
> + * After successfully adding/removing a tag, use lvm_vg_write to commit the
> + * new VG to disk.  Upon failure, retry the operation or release the VG handle
> + * with lvm_vg_close.
> + *
> + * \param   vg
> + * VG handle obtained from lvm_vg_create or lvm_vg_open.
> + *
> + * \param   tag
> + * Tag to add/remove to/from VG.
> + *
> + * \return
> + * 0 (success) or -1 (failure).
> + */
> +int lvm_vg_add_tag(vg_t vg, const char *tag);
> +int lvm_vg_remove_tag(vg_t vg, const char *tag);

I assume doxygen will generate comment only for the lvm_vg_add_tag()
and lvm_vg_remove_tag() would be without any comment ?

Zdenek


