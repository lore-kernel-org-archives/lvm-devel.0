From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 06 May 2015 12:23:30 +0200
Subject: [PATCH 1/5] lvm2app: Add signed numerical property values
In-Reply-To: <1430861659-2755-2-git-send-email-tasleson@redhat.com>
References: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
	<1430861659-2755-2-git-send-email-tasleson@redhat.com>
Message-ID: <5549EBA2.1080805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/05/2015 11:34 PM, Tony Asleson wrote:
> Currently lvm2app properties have the following structure:
> 
> typedef struct lvm_property_value {
>         uint32_t is_settable:1;
>         uint32_t is_string:1;
>         uint32_t is_integer:1;
>         uint32_t is_valid:1;
>         uint32_t padding:28;
>         union {
>                 const char *string;
>                 uint64_t integer;
>         } value;
> } lvm_property_value_t;
> 
> which assumes that numerical values were in the range of 0 to 2**64-1.  However,
> some of the properties were 'signed', like LV major/minor numbers and some
> reserved values for properties that represent percentages.  Thus when the
> values were retrieved they were in two's complement notation.  So for a -1
> major number the API user would get a value of 18446744073709551615.  The
> API user could cast the returned value to an int64_t to handle this, but that
> requires the API developer to look at the source code and determine when it
> should be done.
> 
> This change modifies the return property structure to:
> 
> typedef struct lvm_property_value {
>         uint32_t is_settable:1;
>         uint32_t is_string:1;
>         uint32_t is_integer:1;
>         uint32_t is_valid:1;
>         uint32_t is_signed:1;
>         uint32_t padding:27;
>         union {
>                 const char *string;
>                 uint64_t integer;
>                 int64_t signed_integer;
>         } value;
> } lvm_property_value_t;
> 
...
> +FIELD(LVS, lv, SNUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
> +FIELD(LVS, lv, SNUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
...
> +FIELD(LVSINFO, lv, SNUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
> +FIELD(LVSINFO, lv, SNUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
>  FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
>  FIELD(LVSINFO, lv, STR, "LPerms", lvid, 8, lvpermissions, lv_permissions, "LV permissions.", 0)
>  FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Set if LV is suspended.", 0)
...
> diff --git a/lib/report/report.c b/lib/report/report.c
> index 500bf2b..a107669 100644
> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -2057,6 +2057,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
>  #define SIZ DM_REPORT_FIELD_TYPE_SIZE
>  #define PCT DM_REPORT_FIELD_TYPE_PERCENT
>  #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
> +#define SNUM DM_REPORT_FIELD_TYPE_NUMBER

Yes, for now, these negative numbers are here to indicate individual
special values only (just like the "-1" for major/minor/kmajor/kminor
when it's "undefined").

When it comes to reporting, we cover these extra values at the moment
with "reserved" values (defined in values.h). But once we need to report
negative numbers fully, not just individual reserved values, we'd need
similar patch for reporting part too, introducing new DM_REPORT_FIELD_TYPE_SIGNED_NUMBER.

But for now, I think it's fine to map SNUM to DM_REPORT_FILED_TYPE_NUMBER
as we don't actually report negative numbers in their full range, it's
just the "-1" (with the "undefined", "undef", "unknown" synonyms for
those 4 fields).

But we surely need your patch for the liblvm as we don't export these
synonyms/reserved values via liblvm in any way so liblvm users
don't know about these mappings of these special values...

-- 
Peter


