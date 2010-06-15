From: Milan Broz <mbroz@redhat.com>
Date: Tue, 15 Jun 2010 13:50:11 +0200
Subject: Allow use headers in C++.
In-Reply-To: <20100615114339.GA17838@redhat.com>
References: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
	<20100615114339.GA17838@redhat.com>
Message-ID: <4C1768F3.7010305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/15/2010 01:43 PM, Mike Snitzer wrote:
> On Mon, Jun 14 2010 at 12:20pm -0400,
> Milan Broz <mbroz@redhat.com> wrote:
> 
>> Remove C++ private keyword from header.
> ...
>> diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
>> index e13115a..2b044b5 100644
>> --- a/libdm/libdm-report.c
>> +++ b/libdm/libdm-report.c
>> @@ -566,7 +566,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
>>  				 const char *output_separator,
>>  				 uint32_t output_flags,
>>  				 const char *sort_keys,
>> -				 void *private)
>> +				 void *private_data)
>>  {
>>  	struct dm_report *rh;
>>  	const struct dm_report_object_type *type;
>> @@ -588,7 +588,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
>>  	rh->separator = output_separator;
>>  	rh->fields = fields;
>>  	rh->types = types;
>> -	rh->private = private;
>> +	rh->private = private_data;
>>  
>>  	rh->flags |= output_flags & DM_REPORT_OUTPUT_MASK;
> 
> Should struct dm_report's "private" be renamed too?

Not needed, that's not part of external API/ABI but internal to library.
(There are more such conflicting names, but these are not problem in compilation,
because this is always compiled in C only.)

Milan


