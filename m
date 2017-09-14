From: David Teigland <teigland@redhat.com>
Date: Thu, 14 Sep 2017 13:39:14 -0500
Subject: [Patch review 0/1] introduce lvm forcevg option to forcibly deactivate the whole vg
In-Reply-To: <f74eba33-de77-2b26-31d1-5c103f4ec261@redhat.com>
References: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
	<f74eba33-de77-2b26-31d1-5c103f4ec261@redhat.com>
Message-ID: <20170914183914.GB31269@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Sep 14, 2017 at 01:24:54PM +0200, Zdenek Kabelac wrote:
> Dne 14.9.2017 v 09:37 Zhang Huan napsal(a):
> > Hi all,
> > 
> > commit 92ded9af9809dd0f4233bacaafab3e7942a6afff
> > Author: Huan Zhang <zhanghuan@chinac.com>
> > Date:   Thu Sep 14 15:25:05 2017 +0800
> > 
> >      introduce lvm forcevg option to forcibly deactivate the whole vg
> 
> Hi
> 
> Coincidentally - I've just opened this BZ today:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1491609
> 
> Mostly likely this BZ can be extended to also support forcible table
> remove for  'vg/lvchange' command.

Using an lvm command is a problem for us here because it will read devices
and may likely get stuck, blocking the script which only has about 40
seconds to finish in our case.  And this is run precisely because i/o to a
device is not working.

> The solution presented in this patch can interfere with lvm2 commands so I'd
> be worrying about data correctness.

Our particular use of this is as a helper script that sanlock runs when
the device holding the leases goes away, and the machine will be
imminently reset by the watchdog if we can't disable the LVs.  Given those
unique circumstances, we don't care about other lvm commands.  Is this
case is so specialized that it should be put in a separate script rather
than in blkdeactivate?

This is also described in the section "sanlock lease storage failure" in
http://man7.org/linux/man-pages/man8/lvmlockd.8.html


