From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 Oct 2010 22:20:48 +0200
Subject: lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <20101013195543.GB3172@redhat.com>
References: <20101013185302.GA2944@redhat.com> <4CB6034D.5080603@redhat.com>
	<20101013195543.GB3172@redhat.com>
Message-ID: <4CB614A0.7000508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/13/2010 09:55 PM, Mike Snitzer wrote:
> On Wed, Oct 13 2010 at  3:06pm -0400,
> Milan Broz <mbroz@redhat.com> wrote:
> 
>> On 10/13/2010 08:53 PM, Mike Snitzer wrote:
>>> Convey need for snapshot-merge target in lvconvert error message and man
>>> page.
>>
>>> --- a/lib/metadata/segtype.h
>>> +++ b/lib/metadata/segtype.h
>>> @@ -66,6 +66,7 @@ struct segment_type {
>>>  
>>>  struct segtype_handler {
>>>  	const char *(*name) (const struct lv_segment * seg);
>>> +	const char *(*target_name) (const struct lv_segment * seg);
>>>  	void (*display) (const struct lv_segment * seg);
>>>  	int (*text_export) (const struct lv_segment * seg,
>>>  			    struct formatter * f);
>>
>> I think this will break shared (external) segment module ABI.
>> Nobody uses that but worth to mention it.
>> (See e.g. lib/mirror and --with-mirrors=shared)
> 
> OK, I'm not familiar with that ABI concern.  Any ideas on how I avoid
> this breakage?  Add function pointer to end of struct?  Or any change
> to struct will be taken as breakage?

Well, git history shows that it was broken several times already...

So ignore it and just add the function there ;-)

Milan


