From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 16 Dec 2014 10:20:42 +0100
Subject: [PATCH 1/4] report: Print NULL strings as "" in _string_disp (instead of a SEGV).
In-Reply-To: <1418682760-16427-1-git-send-email-prockai@redhat.com>
References: <1418682760-16427-1-git-send-email-prockai@redhat.com>
Message-ID: <548FF96A.4020706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/15/2014 11:32 PM, Petr Rockai wrote:
> ---
>  lib/report/report.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/lib/report/report.c b/lib/report/report.c
> index 5637d50..043de88 100644
> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -179,6 +179,8 @@ static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
>  			struct dm_report_field *field,
>  			const void *data, void *private __attribute__((unused)))
>  {
> +	if (!*(void**) data)
> +		return _field_set_value(field, "", NULL);
>  	return dm_report_field_string(rh, field, (const char * const *) data);
>  }

...we could do this, but I think more appropriate here would be to
define field-specific reserved value to represent the "undefined"
value so we can match against this too when using selection
(-S|--select).

So, in lib/report/values.h, you can just define:

FIELD_RESERVED_VALUE(cache_policy, cache_policy_undefined, "", "", "undefined", ... add as many synonym to "undefined" here as you need ...)

With this, any "" or "undefined" (or any other synonym) can be used
in selection criteria to match against (the first synonym on the list
is the one printed - in this case it's blank value "").

But that would mean defining own display function for the
cache_policy, not using the generic _string_disp (but that's
not a problem, of course).

So the patch above is OK, but it depends how you need
the selection to behave when matching the cache_policy
field.

(I'm thinking whether the "" STR value should be a global
reserved value with that "undefined" and other synonyms,
but it's possible that wouldn't probably suit all STR fields...
I'd probably go with the field-specific reserved value for now.
We can make that generic anytime later...)

-- 
Peter


