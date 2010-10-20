From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Oct 2010 13:47:28 +0200
Subject: [PATCH 3/4] Add lvm_lvseg_get_property() function.
In-Reply-To: <1287494696-18310-4-git-send-email-dwysocha@redhat.com>
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-4-git-send-email-dwysocha@redhat.com>
Message-ID: <4CBED6D0.9040809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.10.2010 15:24, Dave Wysochanski napsal(a):
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
> 
> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> index f6d54f1..7e2eb69 100644
> --- a/liblvm/lvm2app.h
> +++ b/liblvm/lvm2app.h
> @@ -1099,6 +1099,45 @@ uint64_t lvm_lv_get_size(const lv_t lv);
>  struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name);
>  
>  /**
> + * Get the value of a LV segment property
> + *
> + * \memberof lv_t
> + *
> + * \param   lvseg
> + * Logical volume segment handle.
> + *
> + * \param   name
> + * Name of property to query.  See lvs man page for full list of properties
> + * that may be queried.
> + *
> + * The memory allocated for a string property value is tied to the vg_t
> + * handle and will be released when lvm_vg_close() is called.
> + *
> + * Example:
> + *      lvm_property_value v;
> + *      char *prop_name = "seg_start_pe";
> + *
> + *      v = lvm_lvseg_get_property(lv, prop_name);
> + *      if (lvm_errno(libh) || !v.is_valid) {
> + *           // handle error
> + *           printf("Invalid property name or unable to query"
> + *                  "'%s'.\n", prop_name);
> + *           return;
> + *      }

That's IMHO not practical.

if (!lvm_lvseg_get_property(lv, prop_name, &v)) {
	/* error  path */
}

or whatever return error status we use, looks much more natural.


Zdenek


