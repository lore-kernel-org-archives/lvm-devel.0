From: Milan Broz <mbroz@redhat.com>
Date: Thu, 18 Feb 2010 13:48:45 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B7D063A.7070601@redhat.com>
References: <4B7D063A.7070601@redhat.com>
Message-ID: <4B7D372D.4060608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/18/2010 10:19 AM, Zdenek Kabelac wrote:
> As we discussed yesterday at the confcall the problem with mlockall() and way
> we cannot easily disable locales, because of posix complaince and
> internationalized error message.

So here is a solution. But what's the problem? :-)

For the kindly reader of lvm-devel not attending confcall(s), 
please can you describe what's the problem you are trying to solve?

Is it glibc locale handling bug? Or lvm uses locales the wrong way?
Which other programs are affected too?

Several programs use mlockall() (e.g. I am doing the same operation
as lvm in cryptsetup), some of them use locales, some not. 
Even some libraries can lock memory (gcrypt & safe pool allocation).

> How about adding some global{} configure option ?
> 
> e.i.:  "use_plain_C_locales = 0/1"

I couldn't resist but this seems to me like
We_have_no_idea_what_is_going_on_but_setting_this_to_zero_decreases_memory_use = 0 ;-)

Milan


