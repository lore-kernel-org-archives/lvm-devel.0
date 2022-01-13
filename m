From: David Teigland <teigland@redhat.com>
Date: Thu, 13 Jan 2022 08:52:26 -0600
Subject: Reg a deadlock specific to our environment
In-Reply-To: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
References: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
Message-ID: <20220113145226.GA436@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 12, 2022 at 05:10:40PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> In such a scenario, when our user space storage application gets restarted,
> there are calls to sanitize the storage backend. This involves reading the
> thin pool information. This internally, does a vg open call, which ends up
> READing to all dm devices, resulting in a deadlock during startup.
> To overcome this situation, I extended a filter to ignore all devices that
> have pxd naming part of it. This solves the problem for us.
> 
> Is there a better way to handle our deadlock situation?

Hi,

We need more details to understand this.  Which command is run that gets
stuck (any?), and can you send the output of that command with -vvvv?
By deadlock do you mean the lvm command blocks reading it?  What are the
details of this device?  Is it a dm device, and if so can you show how we
could create one here using dmsetup, or is it using a custom dm target?
Do you know why the command blocks, e.g. is the device suspended?

> Is the below posted solution good to be merged back into master?

I don't think that looks like the right solution.

Dave


