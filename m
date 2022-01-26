From: David Teigland <teigland@redhat.com>
Date: Wed, 26 Jan 2022 10:40:23 -0600
Subject: Reg a deadlock specific to our environment
In-Reply-To: <CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
References: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
	<20220113145226.GA436@redhat.com>
	<CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
Message-ID: <20220126164023.GA29106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 26, 2022 at 06:41:07PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> From the code, all commands that internally does vg_open() gets stuck.

vg_open() sounds like the old liblvm2app, is there a program you've
written using that library?  That lib was seriously flawed, so you're
unlikely to get it to work well.  It was dropped some years ago now.
We can take a brief look at the debug output to see if there's any
obvious workaround for whatever is blocking it.

Dave


