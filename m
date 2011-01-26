From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 26 Jan 2011 14:24:35 +0100
Subject: [PATCH 05/17] Add attach_existing_mdas parameter to create_instance fn.
In-Reply-To: <87hbcxrqm4.fsf@twilight.int.mornfall.net.>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>	<1295867048-21558-6-git-send-email-prajnoha@redhat.com>
	<87hbcxrqm4.fsf@twilight.int.mornfall.net.>
Message-ID: <4D402093.8090307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/25/2011 03:43 PM +0100, Petr Rockai wrote:
> Peter Rajnoha <prajnoha@redhat.com> writes:
> 
>> If attach_existing_mdas parameter is set, we'll attach any existing
>> metadata areas found in the cache to the format_instance. Otherwise,
>> we will only initialise the format_instance and keep the metadata
>> areas list empty (so we can fill that later if that's needed).
> 
> As hinted in previous comment, I think it would be better to never
> attach existing MDAs in create_instance and simply have a single call to
> do that when it is needed. create_instance parameter list is already a
> mess...
> 

...

>> @@ -41,7 +41,8 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
>>  							  const char *pvid,
>>  							  const char *vgname,
>>  							  const char *vgid,
>> -							  void *context);
>> +							  void *context,
>> +							  int attach_existing_mdas);
>>  

Yes, I was thinking whether we should separate these somehow first - at least
pv_create_instance/vg_create_instance... Hmm. But that's a detail. As for the other
parameters - vgname/vgid is necessary and context - well I'm afraid we need that too
to handle those special cases with (current) format - the location of the mda in
filesystem (metadata backup...).

The "attach_existing_mdas" vs. calling separate function to fill the format instance
with mdas - hmm, I'll think about that and see how it fits in...

Peter


