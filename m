From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 12 Oct 2010 10:40:24 +0200
Subject: [PATCH 11/14] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1286810078-25769-12-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-12-git-send-email-dwysocha@redhat.com>
Message-ID: <4CB41EF8.9010706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.10.2010 17:14, Dave Wysochanski napsal(a):
> Add a generic VG property function to lvm2app.  Call the internal library
> vg_get_property() function.  Strings are dup'd internally.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  liblvm/lvm2app.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  liblvm/lvm_vg.c  |   19 +++++++++++++++++++
>  2 files changed, 61 insertions(+), 0 deletions(-)
> 
> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> index 47d3417..b5008c1 100644
> --- a/liblvm/lvm2app.h
> +++ b/liblvm/lvm2app.h
> @@ -168,6 +168,22 @@ typedef struct lvm_str_list {
>  	const char *str;
>  } lvm_str_list_t;
>  
> +/**
> + * Property Value
> + *
> + * This structure defines a single LVM property value for an LVM object.
> + * The structures are returned by functions such as
> + * lvm_vg_get_property() and lvm_vg_set_property().
> + */
> +typedef struct lvm_property_value {
> +	unsigned is_writeable;
> +	unsigned is_string;
> +	union {
> +		char *s_val;

are we going to support return of modifiable strings - or const would fit here
?  (IMHO I still think, we are duplicating way too many things on return...)

> +		uint64_t n_val;
> +	} v;
> +} lvm_property_value_t;
> +


> +int lvm_vg_get_property(const vg_t vg, const char *name,
> +			struct lvm_property_value *value)
> +{
> +	struct lvm_property_type prop;
> +
> +	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);

Hmmm why doing a copy here instead of passing/assigning  'name' ptr somewhere?


> +	if (!vg_get_property(vg, &prop))
> +		return -1;

As this is public interface - I'd add check for valid 'value' pointer.

if (value) return 0;   // might indicate, property exists and is queriable,
but user is not interested in the result.


> +	value->is_writeable = prop.is_writeable;
> +	value->is_string = prop.is_string;
> +	if (value->is_string)
> +		value->v.s_val = prop.v.s_val;
> +	else
> +		value->v.n_val = prop.v.n_val;
> +	return 0;
> +}
> +
>  struct dm_list *lvm_list_vg_names(lvm_t libh)
>  {
>  	return get_vgnames((struct cmd_context *)libh, 0);


Zdenek


