From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 04 Apr 2011 14:09:07 +0200
Subject: [PATCH 2/3] Set our own in/out buffers
In-Reply-To: <4D8DE1BB.1080608@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>	<49609a18834f11b833c31a164a2b467dd52095f3.1301089240.git.zkabelac@redhat.com>	<4D8DBB4D.9060604@redhat.com>
	<4D8DE1BB.1080608@redhat.com>
Message-ID: <4D99B4E3.6040801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.3.2011 13:53, Zdenek Kabelac napsal(a):
> Dne 26.3.2011 11:09, Milan Broz napsal(a):
>> On 03/25/2011 10:57 PM, Zdenek Kabelac wrote:
>>> Memory lock from critical_section is now being kept over the critical
>>> section - mallopt() should ensure, that mmap is not used for allocation,
>>> and we preallocate some memory to be able to satisfy some small
>>> alloc request. However when glibc needs buffers for line buffering of
>>> input and output buffers - it allocates these buffers in such way it
>>> adds memory page for each such buffer and size of unlock memory check will
>>> mismatch by 1 or 2 pages.
>>
>> ack in principle, these warnings appears quite often on various places
>> and distract people form real problems.
>>
>>> +    	static char inbuf[4096];
>>> +	static char outbuf[4096];
>>
>> Because we are handling stdin/stdout, I think this call is common
>> for glibc, right?
>>
>> Shouldn't this be initialized only once (do we support multiple command
>> contexts, IOW reentrant code here)? Is create_toolcontext() the right
>> place for it?
> 
> AFAIK lvm2 code is quite far far away from being reentrant - thus I'd not say
> there could be any new problem with this. However if the lvm2api user will set
> his own buffering it will get overwritten.
> 
> So another option would be to move it into lvm_main - but I'm not sure,
> how to resolve lvm2api users - but I guess we may set some limits for these
> users - anyway - I think we have not even resolved yet, how is the memory
> locking supposed to work for them...
> 
> The real fix is to avoid sending text lines without '\n' while the memory is
> locked - as we do this while queering some questions - once we will do this
> outside VG locks - we may probably again switch to default glib settings.
> Until this is fixed - this patch avoids distracting warnings.
> 

Here is updated version  based on review, which enables this only for liblvm
and lvm2api and does not modify glibc settings in CLVMD and reverts glibc
default behavior when context is destroyed.

Zdenek

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: 0001-Set-our-own-in-out-buffers.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110404/f9afac97/attachment.ksh>
