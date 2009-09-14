From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Sep 2009 19:11:30 +0200
Subject: Re: LVM2/test t-pvcreate-operation-md.sh
In-Reply-To: <20090914014018.GA4070@redhat.com>
References: <20090913192801.1983.qmail@sourceware.org>
	<20090914014018.GA4070@redhat.com>
Message-ID: <4AAE7942.1040202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mike Snitzer wrote:
> We might try loading the raid0 module if it isn't loaded (grep for raid0
> in /proc/mdstat)?  And if that fails skip this test?

I have intentionally all modules unloaded (and do not want sometimes run md tests),
raid0 is loaded automatically, if md_mod is loaded (then /proc/mdstat exists).

If md_mod is not there, test fails. For most systems it is loaded in initrd anyway.

That was just quick hack, I think there is problem in mdadm, because it created
some device node even if md module is not present - but I have no time to debug it now.

Milan



