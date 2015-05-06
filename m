From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 06 May 2015 12:25:08 +0200
Subject: [PATCH 4/5] lvm2app: Correct missing string properties
In-Reply-To: <1430861659-2755-5-git-send-email-tasleson@redhat.com>
References: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
	<1430861659-2755-5-git-send-email-tasleson@redhat.com>
Message-ID: <5549EC04.1060302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/05/2015 11:34 PM, Tony Asleson wrote:
> Synopsis: STR_LIST needs to be treated as STR for properties.
> 
> For any lvm property that was internally 'typed' as a string list we were failing
> to return a string in the property API.  This was due to the fact that for the
> properties to work the value needs to either be evaulated as a string or a
> number.  This change corrects the macro used to build the memory array of
> structures so that the string bitfield is set as needed to ensure that the value
> is a string.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1139920
> 
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>  lib/properties/prop_common.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
> index 0b1678d..9cc963a 100644
> --- a/lib/properties/prop_common.h
> +++ b/lib/properties/prop_common.h
> @@ -132,6 +132,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
>  
>  #define FIELD_MODIFIABLE 0x00000001
>  #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
> -	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT) || (field_type == SNUM)), ((field_type == SNUM) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
> +	{ type, #id, settable, (field_type == STR || field_type == STR_LIST), ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT) || (field_type == SNUM)), ((field_type == SNUM) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },

My mistake! I always forget to add these. Thanks for fixing this!

-- 
Peter


