From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 20 Mar 2011 03:28:49 +0000
Subject: [PATCH 1 of 1] LVM: fix macro call
In-Reply-To: <201103160031.p2G0VZFZ028034@hydrogen.msp.redhat.com>
References: <201103160031.p2G0VZFZ028034@hydrogen.msp.redhat.com>
Message-ID: <20110320032849.GW11163@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 15, 2011 at 07:31:35PM -0500, Jon Brassow wrote:
> This 'bug' has been around for more than 5 years... originally put in here:
> http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?r1=1.93&r2=1.94&cvsroot=lvm2&f=h
> Thing is, I'm not sure how it was ever suppose to work - it's the wrong type
> of argument to the macro.  Perhaps the macro has changed, or perhaps I just don't
> get it.
 
The macro works - it's not a function - as long as the struct has a
member with that name (and it does) it's fine.  But do change it if you
think the other way is easier to read.

Alasdair


