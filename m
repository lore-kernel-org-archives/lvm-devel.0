From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 19 Feb 2010 17:11:09 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B7D4014.3010205@redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com>
Message-ID: <4B7EB81D.6090405@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 18.2.2010 14:26, Zdenek Kabelac wrote:
> On 18.2.2010 13:48, Milan Broz wrote:
>> On 02/18/2010 10:19 AM, Zdenek Kabelac wrote:
>>> As we discussed yesterday at the confcall the problem with mlockall() and way
>>> we cannot easily disable locales, because of posix complaince and
>>> internationalized error message.
>>
>> So here is a solution. But what's the problem? :-)
>>
>> For the kindly reader of lvm-devel not attending confcall(s), 
>> please can you describe what's the problem you are trying to solve?
>>
>> Is it glibc locale handling bug? Or lvm uses locales the wrong way?
>> Which other programs are affected too?
>>
>> Several programs use mlockall() (e.g. I am doing the same operation
>> as lvm in cryptsetup), some of them use locales, some not. 
>> Even some libraries can lock memory (gcrypt & safe pool allocation).
>>
>>> How about adding some global{} configure option ?
>>>
>>> e.i.:  "use_plain_C_locales = 0/1"
>>
>> I couldn't resist but this seems to me like
>> We_have_no_idea_what_is_going_on_but_setting_this_to_zero_decreases_memory_use = 0 ;-)
>>
> 
> Well we know quite well what is going on here, but the solution is a bit of
> problem we are not sure about. :)
> 
> Please check the bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=553193
> 
> The problem is - we should support locales - to give localized system error
> messages to the user - thus just purely disabling locales by not enabling it
> is not an option - we cannot be smarter then user and avoid him getting nice
> i.e. Czech error message about running out-of-memory if he wants to.


Ok

After some discussion with Jakub - here is the outcome of our chat:

There are no plans to change anything on the glibc side about handling locales
- locale-archive is an optimization which seems to share a lot of common
tables between various locales in one place. The size of separate locale files
would probably take several times more as much space as the current large
single file version.

Once the file is mapped (locales set) - it stays in - we cannot switch back to
'C' with the hope, the locale-archive would be unmapped.

As a side note - there are also other potentially huge files mmaped
with glibc - i.e. nscd database.

Jakub suggest solution to use  a tiny small forked() process with very limited
funcionality to handle mlockall() task  without any usage of locales.
Eventually error reports, debugs and other things should be handled in
surrounding environment - just like we have discussed already as a one
potential solution.

So please feel free to add any comment.

Zdenek


