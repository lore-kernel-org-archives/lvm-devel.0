From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Feb 2010 09:16:13 +0100
Subject: [PATCH 4/7] Add _tag_copy() to allocate memory and copy a tag in {lv|vg}_change_tag()
In-Reply-To: <1266349189-23166-5-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-5-git-send-email-dwysocha@redhat.com>
Message-ID: <4B7BA5CD.9010104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 16.2.2010 20:39, Dave Wysochanski wrote:
> We need to allocate memory for the tag and copy the tag value before we
> add it to the list of tags.  We could put this inside lvm2app since the
> tools keep their memory around until vg_write/vg_commit is called.
> Call _tag_copy() from {vg|lv}_change_tag().  We need to copy the tag passed
> in by the caller to ensure the memory until the {vg|lv} handle is released.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  lib/metadata/metadata.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 2b8a1be..e0d63c3 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -665,8 +665,22 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
>  	return 0;
>  }
>  
> +static char *_tag_copy(struct dm_pool *p, const char *tag)
> +{
> +	char *tag_new;
> +
> +	/* FIXME: verify tag length */
> +	if (!(tag_new = dm_pool_alloc(p, strlen(tag)))) {

strlen(tag) + 1
(for '\0')

But better way is to use directly  dm_pool_strdup() - and avoid whole
_tag_copy() function.

> +		log_error("Failed to alloc memory for tag %s.", tag);
> +		return NULL;
> +	}
> +	strcpy(tag_new, tag);
> +	return tag_new;
> +}
> +


