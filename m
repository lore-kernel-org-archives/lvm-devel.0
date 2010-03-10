From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 10 Mar 2010 04:07:46 -0500 (EST)
Subject: PATCH: Replace mlockall() with interal implementation
In-Reply-To: <4B90D58C.7090501@redhat.com>
References: <4B87D947.4060300@redhat.com> <4B87F062.8090407@redhat.com>
	<4B90D58C.7090501@redhat.com>
Message-ID: <Pine.LNX.4.64.1003100334531.13100@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The whole thing is bad.

First, you must understand the users' priorities:

priority #1: the computer doesn't crash

priority #2: lvm takes less memory

priority #3: the user sees localized error messages


The problem with this selective mlocking (mlock everything except locale) 
is that it is hard to review the call graph that no locale data is being 
accessed while the memory is locked.

For example, if something calls isdigit() or isalpha(), it is accessing 
locale. If you call sprintf or sscanf, it may access locale as well. 
strcasecmp accesses locale as well.

It is very hard to prove that there is no locale-access in the current 
lvm+glibc while some devices are suspended --- and worst of all, it is
IMPOSSIBLE to prove that there will be no locale access in future glibc 
versions. For example, even if we review the current sprintf 
implementation, we can't prove that all future sprintf implementations 
won't call isdigit() or other is* functions when parsing the string.

Zdenek said that Alasdair's opinion is to solve these crashes only when 
they happen. In my opinion, this approach is not good becase
1. you already hurt the user (cause crash) before starting to solve the 
problem
2. if such crash happens, the user has no way to find out why, so he will 
likely send a bug report "the machine hung when manipulating root LV and I 
can't reproduce it" --- so linking this crash report to the mlocking 
problem is impossible...

See for example bug 193330 --- no one knew why the system crashed and it 
was just closed because the crash couldn't be reproduced the developers 
--- the crashes due to this selective mlock will be just like this :-(



So, if we go back to priorities, this patch attempts to solve priority #2 
and at the same time damages priority #1. It hurts the usability of LVM.

Other proposition, to not set locales at all and use mlockall() damages 
priority #3 but improves priority #2 (and doesn't affect priority #1), so 
would be better solution.

Alasdair for some reason want to have localized error strings, but he just 
got his priorities wrong. #1 (not crash) is more important than #2 (take 
less memory) which is more important than #3 (see national error 
messages).

Mikulas



On Fri, 5 Mar 2010, Zdenek Kabelac wrote:

> 3rd version of mlockall() replace.
> 
> Fixing some comments:
> 
> - new text for lvm.conf
> - using '1' for success for _maps_line
> - checking sscanf ret value
> - moved default string values to const char array in front of the source code.
> - added simple statistic for size of locked areas and issue internal error
>   if the size is different for mlock/munlock
> - add some more libs to list of unlocked maps - (though some checks are still
>   needed here.
> - slightly changed debug output.
> 
> Zdenek
> 


