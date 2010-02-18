From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 18 Feb 2010 14:26:44 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B7D372D.4060608@redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
Message-ID: <4B7D4014.3010205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 18.2.2010 13:48, Milan Broz wrote:
> On 02/18/2010 10:19 AM, Zdenek Kabelac wrote:
>> As we discussed yesterday at the confcall the problem with mlockall() and way
>> we cannot easily disable locales, because of posix complaince and
>> internationalized error message.
> 
> So here is a solution. But what's the problem? :-)
> 
> For the kindly reader of lvm-devel not attending confcall(s), 
> please can you describe what's the problem you are trying to solve?
> 
> Is it glibc locale handling bug? Or lvm uses locales the wrong way?
> Which other programs are affected too?
> 
> Several programs use mlockall() (e.g. I am doing the same operation
> as lvm in cryptsetup), some of them use locales, some not. 
> Even some libraries can lock memory (gcrypt & safe pool allocation).
> 
>> How about adding some global{} configure option ?
>>
>> e.i.:  "use_plain_C_locales = 0/1"
> 
> I couldn't resist but this seems to me like
> We_have_no_idea_what_is_going_on_but_setting_this_to_zero_decreases_memory_use = 0 ;-)
> 

Well we know quite well what is going on here, but the solution is a bit of
problem we are not sure about. :)

Please check the bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=553193

The problem is - we should support locales - to give localized system error
messages to the user - thus just purely disabling locales by not enabling it
is not an option - we cannot be smarter then user and avoid him getting nice
i.e. Czech error message about running out-of-memory if he wants to.

Some distributions supports customized locale-archive generation - thus
the total size of memory taken by this file is not approaching 100MB like
current Fedora does - so if the administrator selected only few locales -
typically english and his native language - the size is within few MB - so not
a real problem anymore.

However e.g. on Fedora you can't simply create a smaller file - thus running
command like lvm in fact puts 100MB file in memory - quite fast and
unnoticable on 2GB machine with SSD driver - but a bit of problem of limited
memory sized kvm/xem guest...

We are trying to search for the solution.

Some of them requires modification on else's userspace code - and some of them
might lead to modification of our code.

Glibc most probably cannot avoid mmaping whole file into a system memory once
it asked to do so - as user could change locales in mlockall() state and this
would lead to disk read operation. This actually remainds me - if  glibc could
switch locales anytime - why it does  not load this locale-archive file in
case of C locales. Is this 'bug or feature' ?

I think there is no big chance to have personalized generated local files
anytime soon in distribution and wouldn't help the problem with multilingual
installations all that much (i.e. Anaconda).

That's the state and we try to look out for a solution how to use locales and
mlockall() programs together.

Zdenek


