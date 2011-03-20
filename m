From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 21 Mar 2011 00:51:11 +0100
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <20110320214149.GZ11163@agk-dp.fab.redhat.com>
References: <20110320020053.24940.qmail@sourceware.org>
	<4D85FC79.6050709@redhat.com>
	<20110320214149.GZ11163@agk-dp.fab.redhat.com>
Message-ID: <4D8692EF.1030400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.3.2011 22:41, Alasdair G Kergon napsal(a):
> On Sun, Mar 20, 2011 at 02:09:13PM +0100, Zdenek Kabelac wrote:
>> My patch was only fixing error reporting logic.
>  
> One output case:
>   Failed to get device-mapper version
>   Support for older device-mapped version is disabled.
> 
> A quite misleading pair of messages, I think.

The order would be opposite - and I believe that giving the user knowledge,
that lvm lacks some part of code to handle this situation and code needs to be
recompiled with such support is IMHO good hint for error like this.

(Hmm typo -  device-mapper)

In fact -  Failed to get... should be probably log_warn

And also it's worth to know - we have 2 other log_error() already there:

--
dm_task_create: malloc(
--
Incompatible libdevmapper %s%s and kernel driver %s
--

Which might be printed together with "Failed to get..."

So that's why I've tried to add a bit more consistency (which strikes to my
eye with latest Milan's commit to this code).


> Another output case, when only one version is compiled into the binary:
>   ...
>   Support for older device-mapped version is disabled.
> 
> Support was not compiled in so we shouldn't mention anything about it to the
> user.

Well that's where I think 'root' should know why the operation failed.


>   We try to place it as low down in the code as we can consistent with
> minimising the number of log_errors: it is normally, but not always, at the
> lowest level.  
>   'stack' is used in other places on error paths.

The other way around would be to remove then all log_error below
dm_task_create() - and use there only log_debug/log_warn
(i.e. similar to dm_malloc() case where the actual error is defered)

Zdenek


