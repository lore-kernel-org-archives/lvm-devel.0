From: Petr Rockai <prockai@redhat.com>
Date: Tue, 12 Oct 2010 13:04:44 +0200
Subject: [PATCH 11/14] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1286810078-25769-12-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 11 Oct 2010 11:14:35 -0400")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-12-git-send-email-dwysocha@redhat.com>
Message-ID: <87bp6zwu2b.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
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
^^ Can you make this a bitfield? Allocating 4 bytes for a single-bit
value is a bit wasteful.

What does "is_writeable" mean? That a corresponding lvm_vg_set_property
makes sense? Should go into the docstring.

> +	union {
> +		char *s_val;
> +		uint64_t n_val;
> +	} v;
> +} lvm_property_value_t;
(Sadly, no anonymous unions in standard C...) Would it make the client
code more readable to say

union {
      char *string;
      uint64_t integer;
} value;

though?

We'd then get foo.value.integer instead of foo.v.n_val; Contracting
value to val may be acceptable.

> +/**
> + * Get the value of a VG property
> + *
> + * \memberof vg_t
> + *
> + * The memory allocated for a string property value is tied to the vg_t
> + * handle and will be released when lvm_vg_close() is called.
> + *
> + * Example:
> + *      lvm_property_value value;
> + *
> + *      if (lvm_vg_get_property(vg, "vg_mda_count", &value) < 0) {
^^ can we strip the vg_ prefix in the vg_mda_count? It would make a
slightly less repetitive API. Alternatively, accept both.

> + *              // handle error
> + *      }
> + *      if (value.is_string)
> + *           printf(", value = %s\n", value.u.s_val);
> + *	else
> + *           printf(", value = %"PRIu64"\n", value.u.n_val);
> + *
> + *
> + * \return
> + * 0 (success) or -1 (failure).
> + */

> +int lvm_vg_get_property(const vg_t vg, const char *name,
> +			struct lvm_property_value *value);
^^ As for the signature of this function, would it make sense to just
make this a composite return, instead of taking a value pointer? What is
the tradeoff?

lvm_property_value v = lvm_vg_get_property(vg, "foo");
if (v.valid) {
   // ... use stuff in v
}

lvm_property_value v;
if (lvm_vg_get_property(vg, "foo", &v)) {
  // ... use stuff in v
}

I probably slightly prefer the former, for situations like those, too:

lvm_property_value foo = lvm_vg_get_property(vg, "foo"),
                   bar = lvm_vg_get_property(vg, "bar");
if (foo.valid && bar.valid) {
   // ...
}

Moreover, this would make it possible to have an universal and
unconditional release function, if we ever decide to go for explicit
memory management (for scalability reasons):

void lvm_property_value_release(lvm_property_value v) {
    if (!v.valid)
        return;
    // ... free up resources
}

>  /************************** logical volume handling *************************/
>  
>  /**
> diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
> index a09208a..848a497 100644
> --- a/liblvm/lvm_vg.c
> +++ b/liblvm/lvm_vg.c
> @@ -20,6 +20,7 @@
>  #include "locking.h"
>  #include "lvmcache.h"
>  #include "lvm_misc.h"
> +#include "properties.h"
>  
>  int lvm_vg_add_tag(vg_t vg, const char *tag)
>  {
> @@ -335,6 +336,24 @@ const char *lvm_vg_get_name(const vg_t vg)
>  	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
>  }
>  
> +
> +int lvm_vg_get_property(const vg_t vg, const char *name,
> +			struct lvm_property_value *value)
> +{
> +	struct lvm_property_type prop;
> +
> +	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
> +	if (!vg_get_property(vg, &prop))
> +		return -1;
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

Yours,
   Petr.


