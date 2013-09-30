From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 30 Sep 2013 08:28:43 +0200
Subject: compile error with lvm2: '_raid_target_present' undeclared
In-Reply-To: <524759BE.9070203@mglug.de>
References: <524759BE.9070203@mglug.de>
Message-ID: <52491A1B.5010204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/29/2013 12:35 AM, Oliver Rath wrote:
> Hi list,
> 
> my compilation of the last git (today) results a compiling error:
> 
> raid/raid.c:384:20: error: '_raid_target_percent' undeclared here (not
> in a function)
> raid/raid.c:385:20: error: '_raid_target_present' undeclared here (not
> in a function)
> 
> The complete compile step:
> 
> http://paste.ubuntu.com/6168893/
> 
> The thin-provisioning-tools are from today, too.
> 
> my configure-line from lvm is:
> 
> ./configure --enable-udev_sync --enable-udev_rules --with-thin=internal
> 

There's been a patch added recently to fix compilation with configure --disable-devmapper:

  https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=b4637bd298a7a12e0ce9f15104d41158b96cb642

Though it broke the configure --disable-dmeventd (which is used by default and you don't use
--enable-dmeventd in your configure).

Should be fixed now with:

  https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=e02ff3226021ddaf0861f65637d9be65d855506b

Thanks for the report.

Peter


