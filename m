From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 23 Apr 2010 14:14:44 +0200
Subject: [PATCH] Utilize new IMPORT{db} udev rule to repopulate udev db for spurious events
In-Reply-To: <20100422233856.GC23791@agk-dp.fab.redhat.com>
References: <4BCDBF80.3010902@redhat.com>
	<20100422233856.GC23791@agk-dp.fab.redhat.com>
Message-ID: <4BD18F34.10601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/23/2010 01:38 AM, Alasdair G Kergon wrote:
> On Tue, Apr 20, 2010 at 04:51:44PM +0200, Peter Rajnoha wrote:
>> @@ -44,6 +44,28 @@ ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env
>   
>> +IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
> 
> How does this cope if an older version of udev is installed?
> 
> Do we need to install/activate it conditionally?

Good question! We'll probably need to do something like that.
Looking precisely at udevd debug log:

 - it tries to fallback to "auto mode" if it can't recognize the type of IMPORT

 - it tries to stat the file with the name given as parameter, e.g.
   "DM_UDEV_DISABLE_DM_RULES_FLAG"

 - if it's not a valid path, it will put "/lib/udev/" as a prefix first, so we'll
   have "/lib/udev/disable/DM_UDEV_DISBALE_DM_RULES_FLAG"

 - if the file *really exists* by chance then:
     - it will try to execute it if it has executable flag set (fallback to IMPORT{program})
     - it will try to read the contents of it (fallback to IMPORT{file})

Hmm, this definitely needs to be taken care of...

Peter


