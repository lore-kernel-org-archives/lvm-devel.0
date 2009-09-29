From: Milan Broz <mbroz@redhat.com>
Date: Tue, 29 Sep 2009 08:13:26 +0200
Subject: [PATCH 2/3] Fix possible lost of temporary devices in pvmove.
In-Reply-To: <20090928194440.GL5351@agk-dp.fab.redhat.com>
References: <4AB254F7.5050509@redhat.com>
	<20090928194440.GL5351@agk-dp.fab.redhat.com>
Message-ID: <4AC1A586.4080303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Thu, Sep 17, 2009 at 05:25:43PM +0200, Milan Broz wrote:
>>  - if pvmove fails, try to sleep some time and retry. Usually device is locked
>>  by scan from wrong udev rule and remapping to error target causes all scanning
>>  programs to quickly fail.
> 
> I'd rather see the real problem addressed: people fixing misbehaving udev
> rules.  There should be no need for workarounds like this in lvm2, which would
> only perpetuate the problem.  Presumably the problem will disappear anyway
> when the udev integration work is activated.

Of course the real problem must be addressed. But this is not the first time someone
had idea to scan all devices in system. Now udev calling dmsetup from rules,
DevKit doing the same using own programs, various GUI disk utilities etc.
Maybe even some monitoring systems do that...

If there is no such workaround, pvmove is no longer reliable in such enviroment.
The problem exists in most of recent distros.
And it leads to data corruption, see  https://bugzilla.redhat.com/show_bug.cgi?id=520913

I would prefer adding simple and documented workaround then lose users' data.

Milan


