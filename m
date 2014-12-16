From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 16 Dec 2014 10:56:05 +0100
Subject: [PATCH 1/4] report: Print NULL strings as "" in _string_disp (instead of a SEGV).
In-Reply-To: <548FF96A.4020706@redhat.com>
References: <1418682760-16427-1-git-send-email-prockai@redhat.com>
	<548FF96A.4020706@redhat.com>
Message-ID: <549001B5.6010508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/16/2014 10:20 AM, Peter Rajnoha wrote:
> On 12/15/2014 11:32 PM, Petr Rockai wrote:
>> ---
>>  lib/report/report.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/lib/report/report.c b/lib/report/report.c
>> index 5637d50..043de88 100644
>> --- a/lib/report/report.c
>> +++ b/lib/report/report.c
>> @@ -179,6 +179,8 @@ static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
>>  			struct dm_report_field *field,
>>  			const void *data, void *private __attribute__((unused)))
>>  {
>> +	if (!*(void**) data)
>> +		return _field_set_value(field, "", NULL);
>>  	return dm_report_field_string(rh, field, (const char * const *) data);
>>  }
> 
> ...we could do this, but I think more appropriate here would be to
> define field-specific reserved value to represent the "undefined"
> value so we can match against this too when using selection
> (-S|--select).
> 
> So, in lib/report/values.h, you can just define:
> 
> FIELD_RESERVED_VALUE(cache_policy, cache_policy_undefined, "", "", "undefined", ... add as many synonym to "undefined" here as you need ...)
> 

Thinking about this more, we have actually three situations to display
(correct me if I'm wrong please).

So in the end, we need:

 - if cache LV and NULL policy -> we should report "default" (or similar keyword to denote "default" policy used)
 - if cache LV and non-NULL policy -> we should report the policy name directly
 - if non-cache LV (which has always the policy NULL, if course) -> we should report "" (with "undefined", "undef" ... synonyms to match against in selection criteria)

-- 
Peter


