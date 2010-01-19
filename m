From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 19 Jan 2010 11:08:43 -0500
Subject: LVM2/test t-pvcreate-operation-md.sh
In-Reply-To: <4AAE7942.1040202@redhat.com>
References: <20090913192801.1983.qmail@sourceware.org>
	<20090914014018.GA4070@redhat.com> <4AAE7942.1040202@redhat.com>
Message-ID: <20100119160843.GA31041@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 14 2009 at  1:11pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> Mike Snitzer wrote:
> > We might try loading the raid0 module if it isn't loaded (grep for raid0
> > in /proc/mdstat)?  And if that fails skip this test?
> 
> I have intentionally all modules unloaded (and do not want sometimes run md tests),
> raid0 is loaded automatically, if md_mod is loaded (then /proc/mdstat exists).

md-mod doesn't provide the raid0 personality; raid0 does.  I've changed
the test to attempt loading raid0 if it isn't loaded.
 
> If md_mod is not there, test fails. For most systems it is loaded in initrd anyway.
> 
> That was just quick hack, I think there is problem in mdadm, because it created
> some device node even if md module is not present - but I have no time to debug it now.

I'd be interested to know if you still have problems with the test.  If
so we should get to the bottom of it (maybe require a minimum mdadm
version?).

t-pvcreate-operation-md.sh does provide needed testing of LVM2's MD
support so it shouldn't be skipped.

Mike


