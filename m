From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Dec 2008 15:00:06 +0100
Subject: Re: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
In-Reply-To: <1229088579.16499.7.camel@localhost.localdomain>
References: <20081211162552.29826.qmail@sourceware.org>	
	<1229013323.20795.3.camel@localhost.localdomain>	
	<49422E5E.7030700@redhat.com>
	<1229088579.16499.7.camel@localhost.localdomain>
Message-ID: <49426E66.9020900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski napsal(a):
> On Fri, 2008-12-12 at 10:26 +0100, Zdenek Kabelac wrote:
>> Dave Wysochanski napsal(a):
>>>> +/* simplify string emiting code */
>>>> +#define EMIT_PARAMS(p, str...)\
>>>> +	do {\
>>>> +		const size_t bufsize = paramsize - (size_t)p;\
>>>> +		int w;\
>>>> +		\
>>>> +		if ((w = snprintf(params + p, bufsize, str)) < 0\
>>>> +		    || ((size_t)w >= bufsize)) {\
>>>> +			stack; /* Out of space */\
>>>> +			return -1;\
>>>> +		}\
>>>> +		p += w;\
>>>> +	} while (0)
>>>> +
>>> Do we have to do a macro here?  Macros like this are harder to debug...
>>>
>>
>> I think it's actually minimizing the chance you will add a buggy code by some 
>> cut&paste operation when you add new string emitting line.
>>
>> Also it makes the code more readable.
>>
>> Do you think there is some potential debug problem in this code, that makes
>> worth to keep the original emitting style?
>>
>> (i.e. replicator emits string 11 times - without this macro it makes the code 
>> even less readable,  and also using inline function and 'stack' macro is not 
>> going to work together, so it's hard to use gdb-friendly inline here :( )
>>
> 
> I agree something like this makes the code more readable - I was not
> suggesting keeping the original code.  Was just wondering why you chose
> the macro vs a regular function.  Is performance very critical here?
> Something to do with using va_list?  Is there another reason for a macro
> I'm missing?


Inline function would not resolve the 'if (emit() < 0) { stack; return -1;}' 
repeating part of the code. So with inline we would have actually saved only 
'p += w;' line

Eventually we could use macro 'IF_MEM_OK(emit())' to only hide 'stack; return' 
and keep emit() as a static incline function, but then there is no big victory 
against the current EMIT_PARAMS macro.

Zdenek


